namespace W3xPipeline
{
    using System;
    using System.Collections.Generic;
    using System.IO;
    using System.Linq;
    using System.Numerics;
    using StormLibSharp;
    using War3.Net;
    using War3.Net.IO;
    using War3.Net.Maps.Pathing;
    using War3.Net.Maps.Regions;
    using War3.Net.Maps.Units;

    public class SpawnPointGenerator : IPipelineObject
    {
        private const string ARCHIVE_TERRAIN_FILE_PATH = "war3map.wpm";
        private const string ARCHIVE_UNIT_PLACEMENT_FILE_PATH = "war3mapUnits.doo";
        private const string ARCHIVE_REGION_PLACEMENT_FILE_PATH = "war3map.w3r";
        private static readonly Tag SpawnPointUnitId = Tag.FromString("h00I");
        private const int SPAWN_POINT_OWNER_ID = 8; // Undead
        private const float SPAWN_POINT_RADIUS = 256.0f;

        private readonly ILogger m_logger;
        private readonly IDataDeserializer<BinaryReader, PathMapFile> m_pathMapFileDeserializer;

        public SpawnPointGenerator(ILogger logger, IDataDeserializer<BinaryReader, PathMapFile> pathMapFileDeserializer)
        {
            m_logger = logger;
            m_pathMapFileDeserializer = pathMapFileDeserializer;
        }

        public void DoWork(MpqArchive archive)
        {
            m_logger.Log("Generating spawn points");

            string tempFileName = Path.GetTempFileName();

            try
            {
                PathMap pathingMap;
                UnitPlacementFile unitPlacements;
                MapRegions mapRegions;

                using (MpqFileStream file = archive.OpenFile(ARCHIVE_TERRAIN_FILE_PATH))
                using (var reader = new BinaryReader(file))
                {
                    pathingMap = m_pathMapFileDeserializer.Deserialize(reader).Map;
                }

                using (MpqFileStream file = archive.OpenFile(ARCHIVE_UNIT_PLACEMENT_FILE_PATH))
                using (var reader = new BinaryReader(file))
                {
                    IBinaryDeserializer<IList<UnitPlacement>> Factory(int v, int sv) => new UnitPlacementBinaryDeserializer();
                    unitPlacements = new UnitPlacementFileBinaryDeserializer(Factory).Deserialize(reader);
                }

                using (MpqFileStream file = archive.OpenFile(ARCHIVE_REGION_PLACEMENT_FILE_PATH))
                using (var reader = new BinaryReader(file))
                {
                    mapRegions = new MapRegionsBinaryDeserializer().Deserialize(reader);
                }

                RemoveExistingSpawnPoints(unitPlacements.Placements);

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

                GenerateSpawnPointUnits(unitPlacements.Placements, spawnPoints);

                m_logger.Log("Serializing unit placements...");
                using (Stream file = File.Create(tempFileName))
                using (var writer = new BinaryWriter(file))
                {
                    IBinarySerializer<IList<UnitPlacement>> Factory(int v, int sv) => new UnitPlacementBinarySerializer();
                    new UnitPlacementFileBinarySerializer(Factory).Serialize(writer, unitPlacements);
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

        private void RemoveExistingSpawnPoints(ICollection<UnitPlacement> unitPlacements)
        {
            UnitPlacement[] existingSpawnPoints = unitPlacements.Where(_ => _.Id == SpawnPointUnitId).ToArray();

            m_logger.Log($"Deleting {existingSpawnPoints.Length} existing spawn points");

            foreach (UnitPlacement spawnPoint in existingSpawnPoints)
            {
                unitPlacements.Remove(spawnPoint);
            }
        }

        private void GenerateSpawnPointUnits(ICollection<UnitPlacement> unitPlacements, IReadOnlyCollection<Vector2> positions)
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

                unitPlacements.Add(unit);
            }

            m_logger.Log($"Done creating spawn points. Created {positions.Count} units.");
        }

        private QuadTreeNode<Vector2> GenerateSpawnPointPositions(PathMap pathingMap)
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

        private void GenerateNodesRecursive(PathMap pathingMap, QuadTreeNode<Vector2> parent, float minSize)
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

        private void GenerateChildNode(PathMap pathingMap, QuadTreeNode<Vector2> parent, QuadTreeChild type, float minSize)
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

        private bool AreaIsInvalidated(PathMap pathingMap, Vector2 parentMin, Vector2 parentMax)
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
                    if (pathingMap[y, x].HasFlag(PathType.NotWalkable))
                    {
                        return true;
                    }
                }
            }

            return false;
        }
    }
}