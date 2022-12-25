using StormLibSharp;
using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Text;
using War3.Net;
using War3.Net.Assets;
using War3.Net.Data;
using War3.Net.Maps.Doodads;
using War3.Net.Maps.Terrain;
using War3.Net.Maps.Units;
using War3.Net.Mpq;

namespace W3xPipeline
{
    internal class EventMapTemplateBuilder : IPipelineObject
    {
        private static int EVENT_MAP_TEMPLATE_PRI = 400;
        private static Tag IGNORE_TILESET_ID_TAG = Tag.FromString("Ztil");
        private static Tag UNIT_NAME_FIELD_ID = Tag.FromString("unam");
        private static Tag DEST_NAME_FIELD_ID = Tag.FromString("bnam");
        private static Tag PLAYER_START_LOCATION_ID = Tag.FromString("sloc");

        private readonly ILogger m_logger;
        private readonly IReadOnlyEntityLibrary m_entityLibrary;
        private readonly UnitPlacementFileBinaryDeserializer m_unitPlacementFileBinaryDeserializer;
        private readonly DoodadPlacementFileBinaryDeserializer m_doodadPlacementFileBinaryDeserializer;
        private readonly TerrainFileBinaryDeserializer m_terrainFileBinaryDeserializer;

        public EventMapTemplateBuilder(
            ILogger logger,
            IReadOnlyEntityLibrary entityLibrary,
            UnitPlacementFileBinaryDeserializer unitPlacementFileBinaryDeserializer,
            DoodadPlacementFileBinaryDeserializer doodadPlacementFileBinaryDeserializer,
            TerrainFileBinaryDeserializer terrainFileBinaryDeserializer)
        {
            m_logger = logger;
            m_entityLibrary = entityLibrary;
            m_unitPlacementFileBinaryDeserializer = unitPlacementFileBinaryDeserializer;
            m_doodadPlacementFileBinaryDeserializer = doodadPlacementFileBinaryDeserializer;
            m_terrainFileBinaryDeserializer = terrainFileBinaryDeserializer;
        }

        public void DoWork(MpqArchive archive)
        {
            var eventMapTemplateDirs = Directory.EnumerateDirectories(@"D:\Projects\WarcraftIII\TheLastStand\maps\MapEventTemplates")
                .Where(dir => Path.GetExtension(dir) == ".w3x")
                .ToArray();

            m_logger.Log($"Building {eventMapTemplateDirs.Length} event maps...");

            var mapEventTemplates = new List<MapEventTemplate>();

            foreach (var mapEventTemplateMapDir in eventMapTemplateDirs)
            {
                m_logger.Log($"Building {Path.GetFileNameWithoutExtension(mapEventTemplateMapDir)}...");

                var mapEventTemplateMapDirInfo = new DirectoryInfo(mapEventTemplateMapDir);
                var mapEventTemplateMapFileSystem = new MpqFolderFileSystem(mapEventTemplateMapDirInfo);

                var mapEventTemplate = new MapEventTemplate
                {
                    MapFilePath = mapEventTemplateMapDirInfo.Name
                };

                using (var unitPlacementsfile = mapEventTemplateMapFileSystem.OpenRead(MapFiles.UNIT_PLACEMENTS_FILE_PATH))
                using (var unitPlacementsFileReader = new BinaryReader(unitPlacementsfile))
                {
                    mapEventTemplate.UnitPlacementFile = m_unitPlacementFileBinaryDeserializer.Deserialize(unitPlacementsFileReader);
                }

                using (var doodadPlacementsfile = mapEventTemplateMapFileSystem.OpenRead(MapFiles.DOODAD_PLACEMENTS_FILE_PATH))
                using (var doodadPlacementsFileReader = new BinaryReader(doodadPlacementsfile))
                {
                    mapEventTemplate.DoodadPlacementFile = m_doodadPlacementFileBinaryDeserializer.Deserialize(doodadPlacementsFileReader);
                }

                using (var terrainFile = mapEventTemplateMapFileSystem.OpenRead(MapFiles.TERRAIN_FILE_PATH))
                using (var terrainFileReader = new BinaryReader(terrainFile))
                {
                    mapEventTemplate.TerrainFile = m_terrainFileBinaryDeserializer.Deserialize(terrainFileReader);
                }

                mapEventTemplates.Add(mapEventTemplate);

                m_logger.Log($"Done building {Path.GetDirectoryName(mapEventTemplateMapDir)}");
            }

            var outputFilePath = $"D:\\Projects\\WarcraftIII\\TheLastStand\\wurst\\World\\MapEventsInit.wurst";

            File.WriteAllText(outputFilePath, GenerateWurst(mapEventTemplates));

            m_logger.Log($"Done building {eventMapTemplateDirs.Length} event maps.");
        }

        private string GenerateWurst(ICollection<MapEventTemplate> mapEventTemplates)
        {
            var sb = new StringBuilder();

            const string indentStr = "  ";
            const string indentStr2 = "    ";

            sb.AppendLine("// This file is generated. Any changes will be lost.");
            sb.AppendLine($"// Last generated {DateTime.Now}");
            sb.AppendLine($"package MapEventsInit");
            sb.AppendLine($"import MapEvents");
            sb.AppendLine();
            sb.AppendLine("// ============================================================================");
            sb.AppendLine("public function registerMapEventTemplates()");
            sb.AppendLine($"{indentStr}Log.debug(\"Registering {mapEventTemplates.Count} map event templates...\")");

            int i = 1;
            foreach (MapEventTemplate mapEventTemplate in mapEventTemplates)
            {
                var tilePoints = new List<TilePoint>();

                for (var x = 0; x < mapEventTemplate.TerrainFile.Terrain.Width; ++x)
                {
                    for (var y = 0; y < mapEventTemplate.TerrainFile.Terrain.Height; ++y)
                    {
                        var tilePoint = mapEventTemplate.TerrainFile.Terrain.GetPoint(x, y);
                        var tilesetId = mapEventTemplate.TerrainFile.Terrain.GroundTilesetIds[tilePoint.GroundTextureId];
                        if (tilesetId != IGNORE_TILESET_ID_TAG)
                        {
                            tilePoints.Add(tilePoint);
                        }
                    }
                }

                var unitSpawnerCount = mapEventTemplate.UnitPlacementFile.Placements.Count;
                var destSpawnerCount = mapEventTemplate.DoodadPlacementFile.Placements.Destructables.Count;
                var tileSpawnerCount = tilePoints.Count;

                sb.AppendLine($"{indentStr}");
                sb.AppendLine($"{indentStr}// --------------------------------------------------------------------------");
                sb.AppendLine($"{indentStr}// Generated from {mapEventTemplate.MapFilePath} ");
                sb.AppendLine($"{indentStr}// Unit Spawners: {unitSpawnerCount}");
                sb.AppendLine($"{indentStr}// Dest Spawners: {destSpawnerCount}");
                sb.AppendLine($"{indentStr}// Tile Spawners: {tileSpawnerCount}");
                sb.AppendLine($"{indentStr}// --------------------------------------------------------------------------");
                sb.AppendLine($"{indentStr}MapEventTemplate.createMapEventTemplate(\"{Path.GetFileNameWithoutExtension(mapEventTemplate.MapFilePath)}\")");

                foreach (var unitPlacement in mapEventTemplate.UnitPlacementFile.Placements)
                {
                    if (unitPlacement.Id == Tag.Invalid || unitPlacement.Id == PLAYER_START_LOCATION_ID)
                        continue;

                    var localPos = unitPlacement.Position;
                    var localYaw = unitPlacement.RotationInRadians;
                    
                    var suffix = "";
                    string entityNameObj = m_entityLibrary.GetValue(unitPlacement.Id, UNIT_NAME_FIELD_ID, 0) as string;
                    if (entityNameObj is string entityName)
                    {
                        suffix = $" // {entityName}";
                    }

                    sb.AppendLine($"{indentStr2}..registerUnitSpawner('{unitPlacement.Id}', vec3({localPos.X}, {localPos.Y}, {localPos.Z}), angle({localYaw})) {suffix}");
                }

                foreach (var destPlacement in mapEventTemplate.DoodadPlacementFile.Placements.Destructables)
                {
                    var localPos = destPlacement.Position;
                    var localYaw = destPlacement.RotationInRadians;
                    var localScale = destPlacement.Scale;

                    var suffix = "";
                    string entityNameObj = m_entityLibrary.GetValue(destPlacement.Id, DEST_NAME_FIELD_ID, 0) as string;
                    if (entityNameObj is string entityName)
                    {
                        suffix = $" // {entityName}";
                    }

                    sb.AppendLine($"{indentStr2}..registerDestSpawner('{destPlacement.Id}', {destPlacement.Variation}, vec3({localPos.X}, {localPos.Y}, {localPos.Z}), angle({localYaw}), {localScale.X}){suffix}");
                }

                int centerTileX = (int)Math.Floor(mapEventTemplate.TerrainFile.Terrain.Width / 2.0f);
                int centerTileY = (int)Math.Floor(mapEventTemplate.TerrainFile.Terrain.Height / 2.0f);

                foreach (var tilePoint in tilePoints)
                {
                    var localTileCornerX = tilePoint.X - centerTileX;
                    var localTileCornerY = tilePoint.Y - centerTileY;
                    var tilesetId = mapEventTemplate.TerrainFile.Terrain.GroundTilesetIds[tilePoint.GroundTextureId];
                    sb.AppendLine($"{indentStr2}..registerTileSpawner('{tilesetId}', {tilePoint.GroundVariation}, {localTileCornerX}, {localTileCornerY})");
                }
            }

            sb.AppendLine();
            sb.AppendLine($"{indentStr}Log.debug(\"Done creating map event templates.\")");

            return sb.ToString();
        }
    }

    public class MapEventTemplate
    {
        public string MapFilePath { get; set; }
        public UnitPlacementFile UnitPlacementFile { get; set; }
        public DoodadPlacementFile DoodadPlacementFile { get; set; }
        public TerrainFile TerrainFile { get; set; }
    }
}
