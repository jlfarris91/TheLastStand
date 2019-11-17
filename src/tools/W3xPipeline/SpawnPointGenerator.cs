namespace W3xPipeline
{
    using System;
    using System.Collections;
    using System.Collections.Generic;
    using System.IO;
    using System.Linq;
    using System.Numerics;
    using StormLibSharp;
    using WorldEditor.Common;

    public class SpawnPointGenerator : IPipelineObject
    {
        private const string ARCHIVE_TERRAIN_FILE_PATH = "war3map.wpm";
        private const string ARCHIVE_UNIT_PLACEMENT_FILE_PATH = "war3mapUnits.doo";
        private const string ARCHIVE_REGION_PLACEMENT_FILE_PATH = "war3map.w3r";
        private static readonly Tag SpawnPointUnitId = Tag.FromString("h00I");
        private const int SPAWN_POINT_OWNER_ID = 8; // Undead
        private const float SPAWN_POINT_RADIUS = 256.0f;

        private readonly ILogger m_logger;

        public SpawnPointGenerator(ILogger logger)
        {
            m_logger = logger;
        }

        public void DoWork(MpqArchive archive)
        {
            m_logger.Log("Generating spawn points");

            string tempFileName = Path.GetTempFileName();

            try
            {
                PathingMap pathingMap;
                UnitPlacements unitPlacements;
                MapRegions mapRegions; 

                using (MpqFileStream file = archive.OpenFile(ARCHIVE_TERRAIN_FILE_PATH))
                using (var reader = new BinaryReader(file))
                {
                    pathingMap = new PathingMapDeserializer().Deserialize(reader);
                }

                using (MpqFileStream file = archive.OpenFile(ARCHIVE_UNIT_PLACEMENT_FILE_PATH))
                using (var reader = new BinaryReader(file))
                {
                    unitPlacements = new UnitPlacementsFileDeserializer().Deserialize(reader);
                }

                using (MpqFileStream file = archive.OpenFile(ARCHIVE_REGION_PLACEMENT_FILE_PATH))
                using (var reader = new BinaryReader(file))
                {
                    mapRegions = new MapRegionsBinaryDeserializer().Deserialize(reader);
                }

                RemoveExistingSpawnPoints(unitPlacements);

                m_logger.Log("Calculating positions...");
                QuadTreeNode<Vector2> spawnPointTree = GenerateSpawnPointPositions(pathingMap);
                QuadTreeNode<Vector2>[] spawnPointsNodes = spawnPointTree.GetAllNodes().Where(_ => _.IsLeaf).ToArray();
                m_logger.Log("Done calculating positions");

                int desiredSpawnRadius = 512;
                int totalPixelSize = pathingMap.Width * pathingMap.Height * pathingMap.CellSize * pathingMap.CellSize;
                int desiredDensity = totalPixelSize / (desiredSpawnRadius * desiredSpawnRadius);
                int skip = (int)Math.Floor(spawnPointsNodes.Length / (float)desiredDensity) + 1;

                m_logger.Log($"Desired spawn point density: {desiredDensity}");

                Vector2[] spawnPoints = spawnPointsNodes.Where((_, i) => i % skip == 0).Select(_ => _.Data).ToArray();

                GenerateSpawnPointUnits(unitPlacements, spawnPoints);

                m_logger.Log("Serializing unit placements...");
                using (Stream file = File.Create(tempFileName))
                using (var writer = new BinaryWriter(file))
                {
                    new UnitPlacementsFileSerializer().Serialize(writer, unitPlacements);
                }
                m_logger.Log("Done serializing unit placements");
                
                m_logger.Log($"Replacing file {ARCHIVE_UNIT_PLACEMENT_FILE_PATH} in mpq");
                archive.ReplaceFile(tempFileName, ARCHIVE_UNIT_PLACEMENT_FILE_PATH);

                m_logger.Log("Done generating spawn points");
            }
            finally
            {
                if (File.Exists(tempFileName))
                {
                    File.Delete(tempFileName);
                }
            }
        }

        private void RemoveExistingSpawnPoints(UnitPlacements unitPlacements)
        {
            UnitPlacement[] existingSpawnPoints = unitPlacements.Placements.Where(_ => _.Id == SpawnPointUnitId).ToArray();

            m_logger.Log($"Deleting {existingSpawnPoints.Length} existing spawn points");

            unitPlacements.Placements = unitPlacements.Placements.Except(existingSpawnPoints).ToList();
        }

        private void GenerateSpawnPointUnits(UnitPlacements unitPlacements, Vector2[] positions)
        {
            m_logger.Log("Creating spawn point units...");

            foreach (Vector2 pos in positions)
            {
                var unit = new UnitPlacement
                {
                    Id = SpawnPointUnitId,
                    Position = new Vector3(pos, 0.0f),
                    Scale = Vector3.One * 2.0f,
                    PlayerId = SPAWN_POINT_OWNER_ID,
                };

                unitPlacements.Placements.Add(unit);
            }

            m_logger.Log($"Done creating spawn points. Created {positions.Length} units.");
        }

        private QuadTreeNode<Vector2> GenerateSpawnPointPositions(PathingMap pathingMap)
        {
            float mapWidth = pathingMap.Width * pathingMap.CellSize;
            float mapHeight = pathingMap.Height * pathingMap.CellSize;

            var boundsMin = new Vector2(-mapWidth / 2.0f, -mapHeight / 2.0f);
            var boundsMax = new Vector2(mapWidth / 2.0f - 1, mapHeight / 2.0f - 1);

            float minRadius = Math.Max(boundsMax.X - boundsMin.X, boundsMax.Y - boundsMin.Y);

            while (minRadius > SPAWN_POINT_RADIUS)
            {
                minRadius = minRadius / 2;
            }

            minRadius = (int)Math.Floor(minRadius);

            var tree = new QuadTree<Vector2>(boundsMin, boundsMax);

            GenerateNodesRecursive(pathingMap, tree, minRadius);

            return tree;
        }

        private void GenerateNodesRecursive(PathingMap pathingMap, QuadTreeNode<Vector2> parent, float minSize)
        {
            Vector2 parentMin = parent.Min;
            Vector2 parentMax = parent.Max;
            Vector2 parentCenter = (parentMin + (parentMax + Vector2.One)) / 2.0f;

            /*
                +y
                ^           cx      max
                │       ┌────┬────┐
                │       │ TL │ TR │
                │   cy  ├────┼────┤  cy
                │       │ BL │ BR │
                │       └────┴────┘
                │   min     cx
                │
                └─────────────────────> +x
            */

            if (AreaIsInvalidated(pathingMap, parentMin, parentMax))
            {
                GenerateChildNode(pathingMap, parent, QuadTreeChild.TopLeft, minSize);
                GenerateChildNode(pathingMap, parent, QuadTreeChild.TopRight, minSize);
                GenerateChildNode(pathingMap, parent, QuadTreeChild.BottomLeft, minSize);
                GenerateChildNode(pathingMap, parent, QuadTreeChild.BottomRight, minSize);
            }
            else
            {
                parent.Data = parentCenter;
            }
        }

        private void GenerateChildNode(PathingMap pathingMap, QuadTreeNode<Vector2> parent, QuadTreeChild type, float minSize)
        {
            Vector2 parentMin = parent.Min;
            Vector2 parentMax = parent.Max;
            Vector2 parentCenter = (parentMin + (parentMax + Vector2.One)) / 2.0f;

            Vector2 childMin;
            Vector2 childMax;

            switch (type)
            {
                case QuadTreeChild.TopLeft:
                    childMin = new Vector2(parentMin.X, parentCenter.Y);
                    childMax = new Vector2(parentCenter.X, parentMax.Y); 
                    break;
                case QuadTreeChild.TopRight:
                    childMin = parentCenter;
                    childMax = parentMax; 
                    break;
                case QuadTreeChild.BottomLeft:
                    childMin = parentMin;
                    childMax = parentCenter;
                    break;
                case QuadTreeChild.BottomRight:
                    childMin = new Vector2(parentCenter.X, parentMin.Y);
                    childMax = new Vector2(parentMax.X, parentCenter.Y); 
                    break;
                default:
                    throw new ArgumentOutOfRangeException(nameof(type), type, null);
            }

            if (Math.Abs(childMax.X - childMin.X) < minSize ||
                Math.Abs(childMax.Y - childMin.Y) < minSize)
            {
                return;
            }

            var child = new QuadTreeNode<Vector2>(parent, childMin, childMax);
            parent[type] = child;

            GenerateNodesRecursive(pathingMap, child, minSize);
        }

        private bool AreaIsInvalidated(PathingMap pathingMap, Vector2 parentMin, Vector2 parentMax)
        {
            int minCell = pathingMap.WorldToCell(parentMin);
            int maxCell = pathingMap.WorldToCell(parentMax);

            int xmin = pathingMap.GetColumn(minCell);
            int xmax = pathingMap.GetColumn(maxCell);
            int ymin = pathingMap.GetRow(minCell);
            int ymax = pathingMap.GetRow(maxCell);

            for (int y = ymin; y < ymax; ++y)
            {
                for (int x = xmin; x < xmax; ++x)
                {
                    if (pathingMap[y, x].HasFlag(PathingType.NotWalkable))
                    {
                        return true;
                    }
                }
            }

            return false;
        }
    }

    public enum QuadTreeChild
    {
        TopLeft,
        TopRight,
        BottomLeft,
        BottomRight
    }

    public class QuadTreeNode<T> : IEnumerable<QuadTreeNode<T>>
    {
        private readonly QuadTreeNode<T>[] m_children = new QuadTreeNode<T>[4];

        public QuadTreeNode(QuadTreeNode<T> parent, Vector2 min, Vector2 max)
        {
            Parent = parent;
            Min = min;
            Max = max;
        }

        public QuadTreeNode<T> Parent { get; }

        public T Data { get; set; }

        public Vector2 Min { get; }

        public Vector2 Max { get; }

        public bool IsLeaf
        {
            get
            {
                return m_children[0] == null &&
                       m_children[1] == null &&
                       m_children[2] == null &&
                       m_children[3] == null;
            }
        }

        public QuadTreeNode<T> this[QuadTreeChild index]
        {
            get => m_children[(int)index];
            set => m_children[(int)index] = value;
        }

        public IEnumerator<QuadTreeNode<T>> GetEnumerator()
        {
            yield return m_children[0];
            yield return m_children[1];
            yield return m_children[2];
            yield return m_children[3];
        }

        IEnumerator IEnumerable.GetEnumerator()
        {
            return GetEnumerator();
        }
    }

    public class QuadTree<T> : QuadTreeNode<T>
    {
        public QuadTree(Vector2 min, Vector2 max)
            : base(null, min, max)
        {
        }
    }

    public static class QuadTreeExtensions
    {
        public static IEnumerable<QuadTreeNode<T>> GetAllNodes<T>(this QuadTreeNode<T> parent)
        {
            if (parent == null)
            {
                yield break;
            }

            yield return parent;
            
            foreach (QuadTreeNode<T> child in parent)
            {
                foreach (QuadTreeNode<T> childChild in child.GetAllNodes())
                {
                    yield return childChild;
                }
            }
        }
    }
}