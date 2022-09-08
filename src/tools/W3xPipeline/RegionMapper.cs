namespace W3xPipeline
{
    using System;
    using System.Collections.Generic;
    using System.IO;
    using System.Linq;
    using System.Numerics;
    using System.Text;
    using StormLibSharp;
    using War3.Net;
    using War3.Net.Assets;
    using War3.Net.Data;
    using War3.Net.Data.Units;
    using War3.Net.Doodads;
    using War3.Net.Imaging;
    using War3.Net.IO;
    using War3.Net.Maps;
    using War3.Net.Maps.Doodads;
    using War3.Net.Maps.Pathing;
    using War3.Net.Maps.Regions;
    using War3.Net.Math;
    using Color = System.Drawing.Color;

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
        private readonly IImageProvider m_imageProvider;
        private readonly IAssetManager m_assetManager;
        private readonly IDataDeserializer<BinaryReader, PathMapFile> m_pathMapFileDeserializer;
        private readonly string m_generatedScriptFile;

        public RegionMapper(ILogger logger,
                            IReadOnlyFileSystem fileSystem,
                            IReadOnlyEntityLibrary objectLibrary,
                            IImageProvider imageProvider,
                            IAssetManager assetManager,
                            IDataDeserializer<BinaryReader, PathMapFile> pathMapFileDeserializer,
                            string generatedScriptFile)
        {
            m_logger = logger;
            m_fileSystem = fileSystem;
            m_objectLibrary = objectLibrary;
            m_imageProvider = imageProvider;
            m_assetManager = assetManager;
            m_pathMapFileDeserializer = pathMapFileDeserializer;
            m_generatedScriptFile = generatedScriptFile;
        }

        public bool WriteRegionsToArchive { get; set; }

        public void FindIslands(PathMap map)
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

        private int FindLargestIsland(PathMap pathMap)
        {
            var islandMap = new Dictionary<int, int>();
            int largestIsland = -1;
            int largestIslandCount = -1;
            foreach (GridCell cell in pathMap)
            {
                int cellIsland = pathMap.GetIsland(cell.Row, cell.Column);
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

        public GridSpan[] BuildSpawnRegions(PathMap pathMap, GridCell min, GridCell max, int island, int step)
        {
            var openStack = new Queue<GridCell>();
            var regions = new List<GridSpan>();
            var closeStack = new HashSet<int>();

            int width = max.Column - min.Column;
            int height = max.Row - min.Row;
            var spans = new int[width * height];

            bool IsCellInvalid(int r, int c)
            {
                return pathMap.GetIsland(r, c) != island ||
                       !pathMap.IsWalkable(r, c) ||
                       closeStack.Contains(pathMap.GetIndex(r, c));
            }

            openStack.Enqueue(min);

            while (openStack.Any())
            {
                GridCell minCell = openStack.Dequeue();
                var span = new GridSpan(minCell, minCell);

                int cellIndex = pathMap.GetIndex(minCell.Row, minCell.Column);

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
                                closeStack.Add(pathMap.GetIndex(r, c));
                                spans[r * width + c] = regions.Count;
                            }
                        }

                        regions.Add(span);
                    }
                }
                else
                {
                    closeStack.Add(cellIndex);
                }

                int nextColumn = span.Max.Column + step;
                int nextRow = span.Max.Row + step;

                if (nextColumn < max.Column - 1)
                {
                    openStack.Enqueue(new GridCell(span.Min.Row, nextColumn));
                }

                if (nextRow < max.Row - 1)
                {
                    openStack.Enqueue(new GridCell(nextRow, span.Min.Column));
                }
            }

            GridCell ToLocalArea(GridCell cell)
            {
                return new GridCell(cell.Row - min.Row, cell.Column - min.Column);
            }

            bool ValidGridSpan(GridSpan span)
            {
                return true;
                //return span.Width > 2 && span.Height > 2 && span.Area > 4 * 4;
            }

            //var finalSpans = new List<int>();

            //for (var i = 0; i < regions.Count; ++i)
            //{
            //    GridSpan span = regions[i];

            //    if (ValidGridSpan(span))
            //    {
            //        finalSpans.Add(i);
            //        continue;
            //    }

            //    var neighborIds = new HashSet<int>();

            //    for (int c = span.Min.Column - 1; c < span.Max.Column + 1; ++c)
            //    {
            //        int r1 = span.Min.Row - 1;
            //        GridCell cell1 = ToLocalArea(new GridCell(r1, c));
            //        neighborIds.Add(spans[cell1.Row * width + cell1.Column]);

            //        int r2 = span.Max.Row + 1;
            //        GridCell cell2 = ToLocalArea(new GridCell(r2, c));
            //        neighborIds.Add(spans[cell2.Row * width + cell2.Column]);
            //    }

            //    for (int r = span.Min.Row; r < span.Max.Row; ++r)
            //    {
            //        int c1 = span.Min.Column;
            //        GridCell cell1 = ToLocalArea(new GridCell(r, c1));
            //        neighborIds.Add(spans[cell1.Row * width + cell1.Column]);

            //        int c2 = span.Max.Column;
            //        GridCell cell2 = ToLocalArea(new GridCell(r, c2));
            //        neighborIds.Add(spans[cell2.Row * width + cell2.Column]);
            //    }

            //    IOrderedEnumerable<int> neighborIdsLargestToSmallest = neighborIds
            //        .ToList()
            //        .OrderByDescending(id => regions[id].Area);

            //    foreach (int neighborId in neighborIdsLargestToSmallest)
            //    {
            //        GridSpan neighbor = regions[neighborId];
            //        GridCell neighborMin = neighbor.Min;
            //        GridCell neighborMax = neighbor.Max;

            //        var absorbedRegion = false;

            //        if (neighbor.Width <= span.Width)
            //        {
            //            if (span.Min.Row < neighborMin.Row)
            //            {
            //                neighborMin.Row = span.Min.Row;
            //                absorbedRegion = true;
            //            }

            //            if (span.Max.Row > neighborMax.Row)
            //            {
            //                neighborMax.Row = span.Max.Row;
            //                absorbedRegion = true;
            //            }
            //        }

            //        if (neighbor.Height <= span.Height)
            //        {
            //            if (span.Min.Column < neighborMin.Column)
            //            {
            //                neighborMin.Column = span.Min.Column;
            //                absorbedRegion = true;
            //            }

            //            if (span.Max.Column > neighborMax.Column)
            //            {
            //                neighborMax.Column = span.Max.Column;
            //                absorbedRegion = true;
            //            }
            //        }

            //        regions[neighborId] = new GridSpan(neighborMin, neighborMax);

            //        if (absorbedRegion)
            //        {
            //            break;
            //        }
            //    }
            //}

            //return finalSpans.Select(id => regions[id]).ToArray();

            return regions.ToArray();
        }

        private static GridSpan FindLargestRectangleInSpan(Func<int, int, bool> isInvalid, GridCell minCell, GridCell maxCell)
        {
            GridSpan span1 = FindLargestRectangleInSpanHorizontal(isInvalid, minCell, maxCell);
            GridSpan span2 = FindLargestRectangleInSpanVertical(isInvalid, minCell, maxCell);

            float a1 = Mathf.Min(Mathf.Abs(span1.AspectRatioW - 0.5f), Mathf.Abs(span1.AspectRatioH - 0.5f));
            float a2 = Mathf.Min(Mathf.Abs(span2.AspectRatioW - 0.5f), Mathf.Abs(span2.AspectRatioH - 0.5f));

            return a1 < a2 ? span1 : span2;
        }

        private static GridSpan FindLargestRectangleInSpanHorizontal(Func<int, int, bool> isInvalid, GridCell minCell, GridCell maxCell)
        {
            GridCell result = minCell;
            result.Column = maxCell.Column;
            for (int r = minCell.Row; r < maxCell.Row; ++r)
            {
                for (int c = minCell.Column; c < maxCell.Column; ++c)
                {
                    if (isInvalid(r, c))
                    {
                        result.Row--;
                        return new GridSpan(minCell, result);
                    }
                }
                result.Row++;
            }
            return new GridSpan(minCell, result);
        }

        private static GridSpan FindLargestRectangleInSpanVertical(Func<int, int, bool> isInvalid, GridCell minCell, GridCell maxCell)
        {
            GridCell result = minCell;
            result.Row = maxCell.Row;
            for (int c = minCell.Column; c < maxCell.Column; ++c)
            {
                for (int r = minCell.Row; r < maxCell.Row; ++r)
                {
                    if (isInvalid(r, c))
                    {
                        result.Column--;
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
                MapRegions mapRegions;
                DoodadFile doodads;
                PathMap pathMap;

                using (MpqFileStream file = archive.OpenFile(ARCHIVE_TERRAIN_FILE_PATH))
                using (var reader = new BinaryReader(file))
                {
                    pathMap = m_pathMapFileDeserializer.Deserialize(reader).Map;
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

                UpdatePathingMap(doodads, pathMap);

                m_logger.Log($"Removed {oldSpawnRegions.Length} existing spawn regions in map");

                int maxId = mapRegions.Regions.Max(_ => _.Id) + 1;

                m_logger.Log($"Generating new spawn regions...");

                var minCell = new GridCell(0, 0);
                var maxCell = new GridCell(pathMap.Width - 1, pathMap.Height - 1);

                FindIslands(pathMap);
                int largestIsland = FindLargestIsland(pathMap);

                GridSpan[] regionSpans = BuildSpawnRegions(pathMap, minCell, maxCell, largestIsland, 1);

                Region[] newSpawnRegions = regionSpans
                    .Select((span, index) =>
                    {
                        return CreateRegionFromSpan(
                            pathMap,
                            span,
                            maxId + index,
                            $"{SPAWN_REGION_NAME_PREFIX}{index}");
                    }).ToArray();

                mapRegions.Regions.AddRange(newSpawnRegions);

                m_logger.Log($"Generated {newSpawnRegions.Length} new spawn regions in map");

                if (WriteRegionsToArchive)
                {
                    m_logger.Log("Serializing regions...");
                    using (Stream file = File.Create(tempFileName))
                    using (var writer = new BinaryWriter(file))
                    {
                        new MapRegionsBinarySerializer().Serialize(writer, mapRegions);
                    }

                    m_logger.Log("Done serializing regions");

                    m_logger.Log($"Replacing file {ARCHIVE_REGION_PLACEMENT_FILE_PATH} in mpq");
                    archive.ReplaceFile(tempFileName, ARCHIVE_REGION_PLACEMENT_FILE_PATH);
                }

                string generatedScriptFileContents = GenerateSpawnRegionsWurstScript(mapRegions);
                File.WriteAllText(m_generatedScriptFile, generatedScriptFileContents);

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

        private void UpdatePathingMap(DoodadFile doodads, PathMap pathMap)
        {
            foreach (DoodadPlacement doodadPlacement in doodads.Placements.Placements)
            {
                UpdatePathingMap(doodadPlacement, pathMap);
            }
        }

        private void UpdatePathingMap(Placement placement, PathMap pathMap)
        {
            IReadOnlyEntityObject entity = m_objectLibrary.GetEntity(placement.Id);
            if (!(entity is IAffectsPathing affectsPathing))
            {
                return;
            }

            string pt = affectsPathing.PathingTexture;

            if (string.IsNullOrEmpty(pt) || string.IsNullOrWhiteSpace(pt) || pt == "none" || pt == "_")
                return;

            try
            {
                var assetRef = m_assetManager.FindAsset(pt);
                if (!assetRef.IsValid)
                {
                    m_logger.Log($"Failed to update pathing map for placement {placement.Id} with pathing texture {pt}");
                    return;
                }

                var image = m_imageProvider.GetImage(assetRef);
                UpdatePathMap(image);
            }
            catch (Exception)
            {
                m_logger.Log($"Failed to update pathing map for placement {placement.Id} with pathing texture {pt}");
                throw;
            }

            //Color GetPixel(IImage image, int x, int y, int div90)
            //{
            //    int GetX(int index) { return index % image.Width; }
            //    int GetY(int index) { return index / image.Width; }
            //    Color GetPixelByIndex(int index) { return image.GetPixel(GetX(index), GetY(index)); }
            //    switch (div90)
            //    {
            //        case 0: // 0 degrees
            //            return GetPixelByIndex(y * image.Width + x);
            //        case 1: // 90 degrees
            //            return GetPixelByIndex(y * image.Width + (image.Width - 1 - x));
            //        case 2: // 180 degrees
            //            return GetPixelByIndex((image.Width - 1 - x) * image.Height + (image.Height - 1 - y));
            //        case 3: // 270 degrees
            //            return GetPixelByIndex((image.Height - 1 - y) * image.Width + x);
            //        default:
            //            throw new ArgumentOutOfRangeException(nameof(div90));
            //    }
            //}

            void UpdatePathMap(IImage image)
            {
                float rotDeg;

                if (entity is DoodadEntity doodadEntity &&
                    !doodadEntity.FixedRotation.IsApproximatelyEqual(-1.0f))
                {
                    rotDeg = doodadEntity.FixedRotation;
                }
                else if (entity is DestructibleEntity destructibleEntity &&
                         !destructibleEntity.FixedRotation.IsApproximatelyEqual(-1.0f))
                {
                    rotDeg = destructibleEntity.FixedRotation;
                }
                else
                {
                    rotDeg = placement.Rotation * Mathf.Rad2Deg;
                }

                rotDeg = Mathf.WrapAngleDegrees((int)(rotDeg / 90.0f) * 90.0f + 90.0f);
                float rotRad = rotDeg * Mathf.Deg2Rad;

                Vector2 pos = placement.Position.XY();

                var imageSize = new Vector2(image.Width, image.Height);
                Vector2 halfImageSize = imageSize / 2.0f;

                var cellOffset = new Vector2
                {
                    X = image.Width % 2 == 0 ? PathMap.PATH_CELL_PER_CELL * 0.5f : 0.0f,
                    Y = image.Height % 2 == 0 ? PathMap.PATH_CELL_PER_CELL * 0.5f : 0.0f,
                };

                Matrix3x2 rotMtx = Matrix3x2.CreateRotation(rotRad);

                cellOffset = Vector2.Transform(cellOffset, rotMtx);

                Matrix3x2 imageToPathMapMtx =
                    Matrix3x2.CreateTranslation(-halfImageSize) *
                    Matrix3x2.CreateScale(PathMap.PATH_CELL_SIZE) *
                    rotMtx *
                    Matrix3x2.CreateTranslation(pos + cellOffset);

                for (var y = 0; y < image.Height; ++y)
                for (var x = 0; x < image.Width; ++x)
                {
                    int flippedY = image.Height - 1 - y;
                    Color pixel = image.GetPixel(x, flippedY);
                    Vector2 posWS = Vector2.Transform(new Vector2(x, y), imageToPathMapMtx);
                    int cell = pathMap.WorldToCell(posWS);
                    if (cell < 0 || cell >= pathMap.Width * pathMap.Height)
                        continue;
                    pathMap[cell] |= GetPathingValueFromColor(pixel);
                }
            }
        }

        private PathType GetPathingValueFromColor(Color color)
        {
            var pathingType = PathType.None;

            if (color.R == 255) pathingType = pathingType.SetFlag(PathType.NotWalkable);
            if (color.G == 255) pathingType = pathingType.SetFlag(PathType.NotFlyable);
            if (color.B == 255) pathingType = pathingType.SetFlag(PathType.NotBuildable);

            return pathingType;
        }

        private Color GetColorFromPathingType(PathType pathingType)
        {
            return Color.FromArgb(
                255,
                pathingType.HasFlag(PathType.NotWalkable) ? 255 : 0,
                pathingType.HasFlag(PathType.NotFlyable) ? 255 : 0,
                pathingType.HasFlag(PathType.NotBuildable) ? 255 : 0
                );
        }

        private static Region CreateRegionFromSpan(PathMap pathingMap, GridSpan span, int id, string name)
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

        private static string GenerateSpawnRegionsWurstScript(MapRegions regions)
        {
            var sb = new StringBuilder();

            const string indentStr = "  ";
            const string spawnRegionPackageName = "SpawnRegion";
            const string spawnRegionInitPackageName = "SpawnRegionInit";

            sb.AppendLine("// This file is generated. Any changes will be lost.");
            sb.AppendLine($"// Last generated {DateTime.Now}");
            sb.AppendLine($"package {spawnRegionInitPackageName}");
            sb.AppendLine($"import {spawnRegionPackageName}");
            sb.AppendLine();
            sb.AppendLine("public function registerSpawnRegionRects()");
            sb.AppendLine($"{indentStr}Log.debug(\"Creating spawn region...\")");

            int i = 1;
            foreach (Region region in regions.Regions)
            {
                sb.AppendLine($"{indentStr}/* {i++,-4} */ addSpawnRect(Rect({region.Bounds.Min.X}, {region.Bounds.Min.Y}, {region.Bounds.Max.X}, {region.Bounds.Max.Y}))");
            }

            sb.AppendLine($"{indentStr}Log.debug(\"Done creating spawn region.\")");

            return sb.ToString();
        }
    }
}