namespace W3xPipeline
{
    using System;
    using System.Collections.Generic;
    using System.IO;
    using System.Linq;
    using StormLibSharp;
    using War3.Net;
    using War3.Net.Data;
    using War3.Net.Doodads;
    using War3.Net.IO;
    using War3.Net.Maps.Doodads;
    using War3.Net.Maps.Regions;
    using War3.Net.Math;
    using War3.Net.Slk;

    public class RegionMapper : IPipelineObject
    {
        private const string ARCHIVE_TERRAIN_FILE_PATH = "war3map.wpm";
        private const string ARCHIVE_REGION_PLACEMENT_FILE_PATH = "war3map.w3r";
        private const string ARCHIVE_DOCUMENT_PLACEMENT_FILE_PATH = "war3map.doo";
        private const string SPAWN_REGION_NAME_PREFIX = "SPAWN_REGION_";
        private const string ARCHIVE_DOCUMENT_DOODAD_DATA_FILE_PATH = @"Units\DestructableData.slk";
        private const string ARCHIVE_DOCUMENT_DOODAD_METADATA_FILE_PATH = @"Units\DestructableMetaData.slk";

        private readonly ILogger m_logger;
        private readonly IReadOnlyFileSystem m_fileSystem;
        private readonly IReadOnlyEntityLibrary m_objectLibrary;

        public RegionMapper(ILogger logger,
                            IReadOnlyFileSystem fileSystem,
                            IReadOnlyEntityLibrary objectLibrary)
        {
            m_logger = logger;
            m_fileSystem = fileSystem;
            m_objectLibrary = objectLibrary;
        }

        public void FindIslands(PathingMap map)
        {
            var openStack = new Stack<int>(Enumerable.Range(0, map.Width*map.Height));

            for (var i = 0; i < map.Width * map.Height; ++i)
            {
                map.SetIsland(map.GetRow(i), map.GetColumn(i), -1);
            }

            var currentIsland = 0;

            while (openStack.Any())
            {
                int current = openStack.Pop();

                int r = map.GetRow(current);
                int c = map.GetColumn(current);

                if (!map.IsWalkable(r, c) || map.GetIsland(r, c) != -1)
                {
                    continue;
                }

                GridCell[] neighbors = map.GetNeighboringCells(new GridCell(r, c)).ToArray();
                int island = neighbors.Select(cell => map.GetIsland(cell.Row, cell.Column))
                    .Where(i => i != -1)
                    .DefaultIfEmpty(-1)
                    .First();

                if (island == -1)
                {
                    island = currentIsland++;
                }

                map.SetIsland(r, c, island);

                foreach (GridCell neighbor in neighbors.Where(neighbor => map.GetIsland(neighbor.Row, neighbor.Column) == -1 && map.IsWalkable(r, c)))
                {
                    openStack.Push(map.GetIndex(neighbor.Row, neighbor.Column));
                }
            }
        }

        private int FindLargestIsland(PathingMap pathingMap)
        {
            var islandMap = new Dictionary<int, int>();
            int largestIsland = -1;
            int largestIslandCount = -1;
            foreach (GridCell cell in pathingMap)
            {
                int cellIsland = pathingMap.GetIsland(cell.Row, cell.Column);
                if (cellIsland == -1)
                    continue;
                if (!islandMap.ContainsKey(cellIsland))
                {
                    islandMap.Add(cellIsland, 0);
                }
                islandMap[cellIsland]++;
                if (islandMap[cellIsland] > largestIslandCount)
                {
                    largestIsland = cellIsland;
                    largestIslandCount = islandMap[cellIsland];
                }
            }

            return largestIsland;
        }

        public GridSpan[] BuildSpawnRegions(PathingMap pathingMap, GridCell min, GridCell max, int island)
        {
            var openStack = new Queue<GridCell>();
            var regions = new List<GridSpan>();
            var closeStack = new HashSet<int>();

            bool IsCellInvalid(int r, int c)
            {
                return pathingMap.GetIsland(r, c) != island ||
                       !pathingMap.IsWalkable(r, c) ||
                       closeStack.Contains(pathingMap.GetIndex(r, c));
            }

            openStack.Enqueue(min);

            while (openStack.Any())
            {
                GridCell minCell = openStack.Dequeue();
                var span = new GridSpan(minCell, minCell);

                int cellIndex = pathingMap.GetIndex(minCell.Row, minCell.Column);

                if (closeStack.Contains(cellIndex))
                {
                    continue;
                }

                if (!IsCellInvalid(minCell.Row, minCell.Column))
                {
                    GridCell maxCell = minCell;

                    for (int c = minCell.Column; c < max.Column; ++c)
                    {
                        if (IsCellInvalid(minCell.Row, c))
                        {
                            break;
                        }
                        maxCell.Column = c;
                    }

                    for (int r = minCell.Row; r < max.Row; ++r)
                    {
                        if (IsCellInvalid(r, minCell.Column))
                        {
                            break;
                        }
                        maxCell.Row = r;
                    }

                    span = FindLargestRectangleInSpan(IsCellInvalid, minCell, maxCell);

                    if (span.Area != 0)
                    {
                        for (int r = span.Min.Row; r <= span.Max.Row; ++r)
                        {
                            for (int c = span.Min.Column; c <= span.Max.Column; ++c)
                            {
                                closeStack.Add(pathingMap.GetIndex(r, c));
                            }
                        }

                        regions.Add(span);
                    }
                }
                else
                {
                    closeStack.Add(cellIndex);
                }

                if (span.Max.Column < max.Column - 1)
                {
                    openStack.Enqueue(new GridCell(span.Min.Row, span.Max.Column + 1));
                }

                if (span.Max.Row < max.Row - 1)
                {
                    openStack.Enqueue(new GridCell(span.Max.Row + 1, span.Min.Column));
                }
            }

            return regions.ToArray();
        }

        private GridSpan FindLargestRectangleInSpan(Func<int, int, bool> isInvalid, GridCell minCell, GridCell maxCell)
        {
            GridSpan span1 = FindLargestRectangleInSpanHorizontal(isInvalid, minCell, maxCell);
            GridSpan span2 = FindLargestRectangleInSpanVertical(isInvalid, minCell, maxCell);

            float a1 = Mathf.Min(Mathf.Abs(span1.AspectRatioW - 0.5f), Mathf.Abs(span1.AspectRatioH - 0.5f));
            float a2 = Mathf.Min(Mathf.Abs(span2.AspectRatioW - 0.5f), Mathf.Abs(span2.AspectRatioH - 0.5f));

            return a1 < a2 ? span1 : span2;
            //return span1.Area > span2.Area ? span1 : span2;
        }

        private GridSpan FindLargestRectangleInSpanHorizontal(Func<int, int, bool> isInvalid, GridCell minCell, GridCell maxCell)
        {
            GridCell result = minCell;
            result.Column = maxCell.Column;
            for (int r = minCell.Row; r < maxCell.Row; ++r)
            {
                for (int c = minCell.Column; c < maxCell.Column; ++c)
                {
                    if (isInvalid(r, c))
                    {
                        return new GridSpan(minCell, result);
                    }
                }
                result.Row++;
            }
            return new GridSpan(minCell, result);
        }

        private GridSpan FindLargestRectangleInSpanVertical(Func<int, int, bool> isInvalid, GridCell minCell, GridCell maxCell)
        {
            GridCell result = minCell;
            result.Row = maxCell.Row;
            for (int c = minCell.Column; c < maxCell.Column; ++c)
            {
                for (int r = minCell.Row; r < maxCell.Row; ++r)
                {
                    if (isInvalid(r, c))
                    {
                        return new GridSpan(minCell, result);
                    }
                }
                result.Column++;
            }
            return new GridSpan(minCell, result);
        }

        public void DoWork(MpqArchive archive)
        {
            m_logger.Log("Generating spawn regions");

            string tempFileName = Path.GetTempFileName();

            try
            {
                PathingMap pathingMap;
                MapRegions mapRegions;
                DoodadFile doodads;

                using (MpqFileStream file = archive.OpenFile(ARCHIVE_TERRAIN_FILE_PATH))
                using (var reader = new BinaryReader(file))
                {
                    pathingMap = new PathingMapDeserializer().Deserialize(reader);
                }

                using (MpqFileStream file = archive.OpenFile(ARCHIVE_REGION_PLACEMENT_FILE_PATH))
                using (var reader = new BinaryReader(file))
                {
                    mapRegions = new MapRegionsBinaryDeserializer().Deserialize(reader);
                }

                Region[] oldSpawnRegions = mapRegions.Regions.Where(_ => _.Name.StartsWith(SPAWN_REGION_NAME_PREFIX)).ToArray();
                foreach (Region oldSpawnRegion in oldSpawnRegions)
                {
                    mapRegions.Regions.Remove(oldSpawnRegion);
                }

                using (MpqFileStream file = archive.OpenFile(ARCHIVE_DOCUMENT_PLACEMENT_FILE_PATH))
                using (var reader = new BinaryReader(file))
                {
                    doodads = new DoodadFileBinaryDeserializer().Deserialize(reader);
                }

                m_logger.Log($"Removed {oldSpawnRegions.Length} existing spawn regions in map");

                int maxId = mapRegions.Regions.Max(_ => _.Id) + 1;

                m_logger.Log($"Generating new spawn regions...");

                var minCell = new GridCell(0, 0);
                var maxCell = new GridCell(pathingMap.Width - 1, pathingMap.Height - 1);

                FindIslands(pathingMap);
                int largestIsland = FindLargestIsland(pathingMap);

                GridSpan[] regionSpans = BuildSpawnRegions(pathingMap, minCell, maxCell, largestIsland);
                Region[] newSpawnRegions = regionSpans.Select((span, index) =>
                {
                    return CreateRegionFromSpan(
                        pathingMap,
                        span,
                        maxId + index,
                        $"{SPAWN_REGION_NAME_PREFIX}{index}");
                }).ToArray();
                CollectionExtensions.AddRange(mapRegions.Regions, newSpawnRegions);

                m_logger.Log($"Generated {newSpawnRegions.Length} new spawn regions in map");

                m_logger.Log("Serializing regions...");
                using (Stream file = File.Create(tempFileName))
                using (var writer = new BinaryWriter(file))
                {
                    new MapRegionsBinarySerializer().Serialize(writer, mapRegions);
                }
                m_logger.Log("Done serializing regions");

                m_logger.Log($"Replacing file {ARCHIVE_REGION_PLACEMENT_FILE_PATH} in mpq");
                archive.ReplaceFile(tempFileName, ARCHIVE_REGION_PLACEMENT_FILE_PATH);

                m_logger.Log("Done generating spawn regions");
            }
            finally
            {
                if (File.Exists(tempFileName))
                {
                    File.Delete(tempFileName);
                }
            }
        }

        private static Region CreateRegionFromSpan(PathingMap pathingMap, GridSpan span, int id, string name)
        {
            int minIndex = pathingMap.GetIndex(span.Min.Row, span.Min.Column);
            int maxIndex = pathingMap.GetIndex(span.Max.Row, span.Max.Column);
            Rect minCellBounds = pathingMap.GetCellWorldBounds(minIndex);
            Rect maxCellBounds = pathingMap.GetCellWorldBounds(maxIndex);
            Rect spanBounds = minCellBounds.Encapsulate(maxCellBounds);

            return new Region
            {
                Id = id,
                Name = name,
                AmbientSound = string.Empty,
                Color = Region.DefaultColor,
                WeatherEffect = 0,
                Bounds = spanBounds
            };
        }
    }
}