using StormLibSharp;
using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Numerics;
using System.Text;
using System.Text.RegularExpressions;
using War3.Net;
using War3.Net.Data;
using War3.Net.Maps.Regions;
using War3.Net.Maps.Units;
using War3.Net.Mpq;

namespace W3xPipeline
{
    public class BaseBuilder : IPipelineObject
    {
        private const int BASE_UNIT_PLAYER_ID = 10;
        private static readonly Tag BASE_EASY_UNIT_ID = Tag.FromString("h00H");
        private static readonly Tag BASE_MED_UNIT_ID = Tag.FromString("h00J");
        private static readonly Tag BASE_HARD_UNIT_ID = Tag.FromString("h00K");
        private static Tag UNIT_NAME_FIELD_ID = Tag.FromString("unam");

        private readonly IMpqFileSystem m_fileSystem;
        private readonly ILogger m_logger;
        private readonly IReadOnlyEntityLibrary m_entityLibrary;
        private readonly UnitPlacementFileBinaryDeserializer m_unitPlacementFileBinaryDeserializer;
        private readonly UnitPlacementFileBinarySerializer m_unitPlacementFileBinarySerializer;
        private readonly RegionsFileBinaryDeserializer m_regionsBinaryDeserializer;
        private readonly RegionsFileBinarySerializer m_regionsBinarySerializer;

        public BaseBuilder(
            IMpqFileSystem fileSystem,
            ILogger logger,
            IReadOnlyEntityLibrary entityLibrary,
            UnitPlacementFileBinaryDeserializer unitPlacementFileBinaryDeserializer,
            UnitPlacementFileBinarySerializer unitPlacementFileBinarySerializer,
            RegionsFileBinaryDeserializer regionsBinaryDeserializer,
            RegionsFileBinarySerializer regionsBinarySerializer)
        {
            m_fileSystem = fileSystem;
            m_logger = logger;
            m_entityLibrary = entityLibrary;
            m_unitPlacementFileBinaryDeserializer = unitPlacementFileBinaryDeserializer;
            m_unitPlacementFileBinarySerializer = unitPlacementFileBinarySerializer;
            m_regionsBinaryDeserializer = regionsBinaryDeserializer;
            m_regionsBinarySerializer = regionsBinarySerializer;
        }

        public void DoWork(MpqArchive archive)
        {
            m_logger.Log($"Building bases...");

            UnitPlacementFile unitPlacementFile;
            using (var unitPlacementFileStream = m_fileSystem.OpenRead(MapFiles.UNIT_PLACEMENTS_FILE_PATH))
            using (var unitPlacementFileReader = new BinaryReader(unitPlacementFileStream))
            {
                unitPlacementFile = m_unitPlacementFileBinaryDeserializer.Deserialize(unitPlacementFileReader);
            }

            RegionsFile regionsFile;
            using (var regionsFileStream = m_fileSystem.OpenRead(MapFiles.REGION_PLACEMENT_FILE_PATH))
            using (var regionsFileReader = new BinaryReader(regionsFileStream))
            {
                regionsFile = m_regionsBinaryDeserializer.Deserialize(regionsFileReader);
            }

            var baseNameRegex = new Regex(@"Base\s+(\d*)\s*(.*)");

            var regionsByBaseId = new Dictionary<int, List<Region>>();

            foreach (var region in regionsFile.Regions)
            {
                var matches = baseNameRegex.Match(region.Name);

                if (matches.Groups.Count == 0)
                    continue;

                var regionBaseIdStr = matches.Groups[1].Value;
                if (string.IsNullOrEmpty(regionBaseIdStr))
                    continue;

                var regionBaseId = int.Parse(regionBaseIdStr);

                if (!regionsByBaseId.TryGetValue(regionBaseId, out List<Region> regions))
                {
                    regions = new List<Region>();
                    regionsByBaseId.Add(regionBaseId, regions);
                }

                regions.Add(region);
            }

            var bases = new List<BaseDefinition>();

            var allUnits = unitPlacementFile.Placements.ToArray();

            foreach (var unitPlacement in allUnits)
            {
                if (unitPlacement.Id != BASE_EASY_UNIT_ID &&
                    unitPlacement.Id != BASE_MED_UNIT_ID &&
                    unitPlacement.Id != BASE_HARD_UNIT_ID)
                {
                    continue;
                }

                var pos = unitPlacement.Position;
                var rot = unitPlacement.RotationInRadians;

                var region = regionsFile.Regions.FirstOrDefault(reg => reg.Name.StartsWith("Base") && reg.Bounds.Contains(pos));

                var baseDef = new BaseDefinition();
                bases.Add(baseDef);

                baseDef.Id = $"base_{bases.Count:000}";
                baseDef.UnitPlacement = unitPlacement;
                baseDef.Position = pos;
                baseDef.RotationInRadians = rot;

                if (region != null)
                {
                    var matches = baseNameRegex.Match(region.Name);

                    var regionBaseId = int.Parse(matches.Groups[1].Value);

                    if (matches.Groups.Count > 1)
                    {
                        baseDef.DisplayName = matches.Groups[2].Value;
                    }

                    foreach (var otherUnitPlacement in allUnits)
                    {
                        if (otherUnitPlacement == unitPlacement)
                            continue;

                        if (otherUnitPlacement.PlayerId != BASE_UNIT_PLAYER_ID)
                            continue;

                        if (!region.Bounds.Contains(otherUnitPlacement.Position))
                            continue;

                        baseDef.UnitPlacements.Add(otherUnitPlacement);

                        unitPlacementFile.Placements.Remove(otherUnitPlacement);
                    }

                    if (regionsByBaseId.TryGetValue(regionBaseId, out List<Region> regions))
                    {
                        baseDef.Regions.AddRange(regions);

                        foreach (var reg in regions)
                        {
                            regionsFile.Regions.Remove(reg);
                        }
                    }
                }

                unitPlacementFile.Placements.Remove(unitPlacement);
            }

            var outputFilePath = $"D:\\Projects\\WarcraftIII\\TheLastStand\\wurst\\World\\BasesInit.wurst";

            File.WriteAllText(outputFilePath, GenerateWurst(bases));

            string tempFileName = Path.GetTempFileName();

            {
                m_logger.Log("Serializing unit placements file...");
                using (var file = File.Create(tempFileName))
                using (var writer = new BinaryWriter(file))
                {
                    m_unitPlacementFileBinarySerializer.Serialize(writer, unitPlacementFile);
                }

                m_logger.Log("Done serializing unit placements.");

                m_logger.Log($"Replacing file {MapFiles.UNIT_PLACEMENTS_FILE_PATH} in mpq");
                archive.ReplaceFile(tempFileName, MapFiles.UNIT_PLACEMENTS_FILE_PATH);
            }

            {
                m_logger.Log("Serializing regions file...");
                using (var file = File.Create(tempFileName))
                using (var writer = new BinaryWriter(file))
                {
                    m_regionsBinarySerializer.Serialize(writer, regionsFile);
                }

                m_logger.Log("Done serializing regions.");

                m_logger.Log($"Replacing file {MapFiles.REGION_PLACEMENT_FILE_PATH} in mpq");
                archive.ReplaceFile(tempFileName, MapFiles.REGION_PLACEMENT_FILE_PATH);
            }

            if (File.Exists(tempFileName))
            {
                File.Delete(tempFileName);
            }

            m_logger.Log($"Done building {bases.Count} bases.");
        }

        private string GenerateWurst(ICollection<BaseDefinition> bases)
        {
            var sb = new StringBuilder();

            const string indentStr = "  ";
            const string indentStr2 = "    ";

            sb.AppendLine("// This file is generated. Any changes will be lost.");
            sb.AppendLine($"// Last generated {DateTime.Now}");
            sb.AppendLine($"package BasesInit");
            sb.AppendLine($"import Bases");
            sb.AppendLine();
            sb.AppendLine("// ============================================================================");
            sb.AppendLine("public function registerBases()");
            sb.AppendLine($"{indentStr}Log.debug(\"Registering {bases.Count} bases...\")");

            foreach (BaseDefinition baseDef in bases)
            {
                var pos = baseDef.Position;
                var rot = baseDef.RotationInRadians;

                string baseDifficulty = "";

                if (baseDef.UnitPlacement.Id == BASE_EASY_UNIT_ID)
                {
                    baseDifficulty = "BaseDifficulty.EASY";
                }
                else if (baseDef.UnitPlacement.Id == BASE_MED_UNIT_ID)
                {
                    baseDifficulty = "BaseDifficulty.MEDIUM";
                }
                else if (baseDef.UnitPlacement.Id == BASE_HARD_UNIT_ID)
                {
                    baseDifficulty = "BaseDifficulty.HARD";
                }

                sb.AppendLine($"{indentStr}");
                sb.AppendLine($"{indentStr}Bases.registerBase(\"{baseDef.Id}\", {baseDifficulty}, vec3({pos.X}, {pos.Y}, {pos.Z}), angle({rot}), \"{baseDef.DisplayName}\")");

                foreach (var unitPlacement in baseDef.UnitPlacements)
                {
                    var localPos = unitPlacement.Position - pos;
                    var localYaw = unitPlacement.RotationInRadians - rot;
                    
                    var suffix = "";
                    string entityNameObj = m_entityLibrary.GetValue(unitPlacement.Id, UNIT_NAME_FIELD_ID, 0) as string;
                    if (entityNameObj is string entityName)
                    {
                        suffix = $" // {entityName}";
                    }

                    sb.AppendLine($"{indentStr2}..registerUnitSpawner('{unitPlacement.Id}', vec3({localPos.X}, {localPos.Y}, {localPos.Z}), angle({localYaw})) {suffix}");
                }

                foreach (var region in baseDef.Regions)
                {
                    sb.AppendLine($"{indentStr2}..addRect({region.Bounds.Left}, {region.Bounds.Bottom}, {region.Bounds.Right}, {region.Bounds.Top})");
                }
            }

            sb.AppendLine();
            sb.AppendLine($"{indentStr}Log.debug(\"Done creating bases.\")");

            return sb.ToString();
        }
    }

    public class BaseDefinition
    {
        public string Id;
        public string DisplayName;
        public UnitPlacement UnitPlacement;
        public List<UnitPlacement> UnitPlacements = new List<UnitPlacement>();
        public List<Region> Regions = new List<Region>();
        public Vector3 Position;
        public float RotationInRadians;
    }
}
