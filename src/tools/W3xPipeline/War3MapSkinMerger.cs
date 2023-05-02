
namespace W3xPipeline
{
    using StormLibSharp;
    using System;
    using System.Collections.Generic;
    using System.IO;
    using System.Linq;
    using War3.Net.Data;

    internal class War3MapSkinMerger : IPipelineObject
    {
        static readonly string[] s_customDataExtensions = new[] {
            "w3a", // Abilities
            "w3b", // Destructables
            "w3d", // Doodads
            "w3h", // Buffs
            "w3q", // Upgrades
            "w3t", // Items
            "w3u"  // Units
        };
        private readonly ILogger m_logger;
        private readonly string m_intermediateDir;

        public War3MapSkinMerger(ILogger logger, string intermediateDir)
        {
            m_logger = logger;
            m_intermediateDir = intermediateDir;
        }

        public void DoWork(MpqArchive archive)
        {
            foreach (var customDataExtension in s_customDataExtensions)
            {
                var war3mapFilePath = $"war3map.{customDataExtension}";
                var war3mapSkinFilePath = $"war3mapSkin.{customDataExtension}";
                if (archive.HasFile(war3mapSkinFilePath) && archive.VerifyFile(war3mapSkinFilePath) == MpqFileVerificationResults.Verified)
                {
                    Func<int, bool> extraInfo = (int version) => customDataExtension == "w3a" || customDataExtension == "w3q" || (customDataExtension == "w3d" && version >= 2); 

                    var entityLibrary = new EntityLibrary();

                    CustomEntityFile war3mapEntityFile;
                    CustomEntityFile war3mapSkinEntityFile;

                    using (var war3mapFile = archive.OpenFile(war3mapFilePath))
                    using (var war3mapSkinFile = archive.OpenFile(war3mapSkinFilePath))
                    using (var war3mapReader = new BinaryReader(war3mapFile))
                    using (var war3mapSkinReader = new BinaryReader(war3mapSkinFile))
                    {
                        var deserializer = new CustomEntityFileBinaryDeserializer(entityLibrary) { ReadExtraInfo = extraInfo };
                        war3mapEntityFile = deserializer.Deserialize(war3mapReader);
                            war3mapSkinEntityFile = deserializer.Deserialize(war3mapSkinReader);
                    }

                    foreach (var entitySkin in war3mapSkinEntityFile.OriginalEntries)
                    {
                        var entityBase = war3mapEntityFile.OriginalEntries.FirstOrDefault(entry => entry.BaseId == entitySkin.BaseId);

                        if (!entityBase.Variations.Any())
                            entityBase.Variations = new[] { new List<CustomEntityField>() };

                        foreach (var modSkin in entitySkin.Variations.SelectMany(_ => _))
                        {
                            var modBase = entityBase.Variations[0].FirstOrDefault(mod => mod.Id == modSkin.Id);
                            if (modBase == null)
                            {
                                modBase = new CustomEntityField(modSkin);
                                entityBase.Variations[0].Add(modBase);
                            }
                            if (modBase != null)
                                modBase.Value = modSkin.Value;
                        }
                    }

                    foreach (var entitySkin in war3mapSkinEntityFile.CustomEntries)
                    {
                        var entityBase = war3mapEntityFile.CustomEntries.FirstOrDefault(entry => entry.NewId == entitySkin.NewId);

                        if (!entityBase.Variations.Any())
                            entityBase.Variations = new[] { new List<CustomEntityField>() };

                        foreach (var modSkin in entitySkin.Variations.SelectMany(_ => _))
                        {
                            var modBase = entityBase.Variations[0].FirstOrDefault(mod => mod.Id == modSkin.Id);
                            if (modBase == null)
                            {
                                modBase = new CustomEntityField(modSkin);
                                entityBase.Variations[0].Add(modBase);
                            }
                            if (modBase != null)
                                modBase.Value = modSkin.Value;
                        }
                    }

                    //war3mapSkinEntityFile.OriginalEntries.Clear();
                    //war3mapSkinEntityFile.CustomEntries.Clear();

                    var intermediateFileName = Path.Combine(m_intermediateDir, war3mapFilePath);
                    if (File.Exists(intermediateFileName))
                        File.Delete(intermediateFileName);

                    using (var war3mapTempFile = File.OpenWrite(intermediateFileName))
                    using (var war3mapWriter = new BinaryWriter(war3mapTempFile))
                    {
                        var serializer = new CustomEntityFileBinarySerializer(3) {  WriteExtraInfo = extraInfo };
                        serializer.Serialize(war3mapWriter, war3mapEntityFile);
                    }

                    archive.ReplaceFile(intermediateFileName, war3mapFilePath);

                    //if (File.Exists(intermediateFileName))
                    //    File.Delete(intermediateFileName);

                    //intermediateFileName = Path.Combine(m_intermediateDir, war3mapSkinFilePath);
                    //if (File.Exists(intermediateFileName))
                    //    File.Delete(intermediateFileName);

                    //using (var war3mapSkinTempFile = File.OpenWrite(intermediateFileName))
                    //using (var war3mapSkinWriter = new BinaryWriter(war3mapSkinTempFile))
                    //{
                    //    var serializer = new CustomEntityFileBinarySerializer(3) { WriteExtraInfo = extraInfo };
                    //    serializer.Serialize(war3mapSkinWriter, war3mapSkinEntityFile);
                    //}

                    //archive.ReplaceFile(intermediateFileName, war3mapSkinFilePath);

                    //if (File.Exists(intermediateFileName))
                    //    File.Delete(intermediateFileName);
                }
            }
        }
    }
}
