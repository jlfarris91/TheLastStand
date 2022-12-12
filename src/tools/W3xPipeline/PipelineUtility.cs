namespace W3xPipeline
{
    using System;
    using System.Collections.Generic;
    using System.IO;
    using System.Linq;
    using War3.Net;
    using War3.Net.Data;
    using War3.Net.Data.Units;
    using War3.Net.Doodads;
    using War3.Net.Imaging;
    using War3.Net.Imaging.Blp;
    using War3.Net.Imaging.Targa;
    using War3.Net.IO;
    using War3.Net.Slk;

    public static class PipelineUtility
    {
        public static IDataDeserializer<Stream, IImage> ImageDeserializerProvider(AssetReference arg)
        {
            string ext = Path.GetExtension(arg.RelativePath).ToLower().Trim('.');

            switch (ext)
            {
                case "blp":
                    return new BlpImageDeserializer();
                case "tga":
                    return new TargaImageDeserializer();
            }

            return null;
        }

        public static string MakeRelativeToDirectory(string dir, string file)
        {
            return file.Replace(dir, string.Empty).Replace('/', '\\').Trim('\\');
        }

        public static IEnumerable<IEntityLibrary> LoadCustomObjectLibraries(IReadOnlyFileSystem fileSystem, ILogger logger)
        {
            var deserializer = new WarcraftDataLibrarySerializer(ObjectSerializationHelper.DeserializeObject);

            var baseDestructableLibrary = new EntityLibrary();

            logger.Log($"Reading destructible data...");
            StringDataTable destructibleData = ReadSlk(fileSystem, "Units/DestructableData.slk", "DestructableID", logger);
            StringDataTable destructibleMetadata = ReadSlk(fileSystem, "Units/DestructableMetaData.slk", "ID", logger);
            deserializer.LoadLibrary(baseDestructableLibrary, destructibleData, destructibleMetadata, typeof(DestructibleEntity));

            ReadSkinFiles(fileSystem, baseDestructableLibrary, new string[]
            {
                "Units/DestructableSkin.txt",
            }, logger);

            var customDestructableLibrary = new EntityLibrary(baseDestructableLibrary);
            LoadCustomEntityLibrary(fileSystem, customDestructableLibrary, "w3b", typeof(DestructibleEntity));

            yield return customDestructableLibrary;

            var baseDoodadLibrary = new EntityLibrary();

            StringDataTable doodadData = ReadSlk(fileSystem, "Doodads/Doodads.slk", "doodID", logger);
            StringDataTable doodadMetadata = ReadSlk(fileSystem, "Doodads/DoodadMetaData.slk", "ID", logger);
            deserializer.LoadLibrary(baseDoodadLibrary, doodadData, doodadMetadata, typeof(DoodadEntity));

            ReadSkinFiles(fileSystem, baseDoodadLibrary, new string[]
            {
                "Doodads/DoodadSkins.txt",
            }, logger);

            var customDoodadLibrary = new EntityLibrary(baseDoodadLibrary);
            LoadCustomEntityLibrary(fileSystem, customDoodadLibrary, "w3d", typeof(DoodadEntity));

            yield return customDoodadLibrary;

            var baseUnitLibrary = new EntityLibrary();

            StringDataTable unitDataMetadataTable = ReadSlk(fileSystem, "Units/UnitMetaData.slk", "ID", logger);

            StringDataTable unitDataTable = ReadSlk(fileSystem, "Units/UnitData.slk", "unitID", logger);
            deserializer.LoadLibrary(baseUnitLibrary, unitDataTable, unitDataMetadataTable, typeof(UnitEntity));

            StringDataTable unitWeaponDataTable = ReadSlk(fileSystem, "Units/UnitWeapons.slk", "unitWeaponID", logger);
            deserializer.LoadLibrary(baseUnitLibrary, unitWeaponDataTable, unitDataMetadataTable, typeof(UnitEntity));

            StringDataTable unitBalanceDataTable = ReadSlk(fileSystem, "Units/UnitBalance.slk", "unitBalanceID", logger);
            deserializer.LoadLibrary(baseUnitLibrary, unitBalanceDataTable, unitDataMetadataTable, typeof(UnitEntity));

            StringDataTable unitArtDataTable = ReadSlk(fileSystem, "Units/UnitUI.slk", "unitUIID", logger);
            deserializer.LoadLibrary(baseUnitLibrary, unitArtDataTable, unitDataMetadataTable, typeof(UnitEntity));

            ReadSkinFiles(fileSystem, baseUnitLibrary, new string[]
            {
                "Units/CampaignUnitFunc.txt",
                "Units/CampaignUnitStrings.txt",
                "Units/HumanUnitFunc.txt",
                "Units/HumanUnitStrings.txt",
                "Units/NeutralUnitFunc.txt",
                "Units/NeutralUnitStrings.txt",
                "Units/NightElfUnitFunc.txt",
                "Units/NightElfUnitStrings.txt",
                "Units/OrcUnitFunc.txt",
                "Units/OrcUnitStrings.txt",
                "Units/UndeadUnitFunc.txt",
                "Units/UndeadUnitStrings.txt",
            }, logger);

            var customUnitLibrary = new EntityLibrary(baseUnitLibrary);
            LoadCustomEntityLibrary(fileSystem, customUnitLibrary, "w3u", typeof(UnitEntity));

            yield return customUnitLibrary;
        }

        private static void ReadSkinFiles(IReadOnlyFileSystem fileSystem, IEntityLibrary library, string[] skinFiles, ILogger logger)
        {
            foreach (string skinFile in skinFiles)
            {
                try
                {
                    logger.Log($"Reading adjustment file {skinFile}...");
                    using (Stream file = fileSystem.OpenRead(skinFile))
                    using (var reader = new StreamReader(file))
                    {
                        new ProfileFileDeserializer().ReadProfile(library, reader);
                    }
                }
                catch (Exception ex)
                {
                    logger.Log($"Unable to read adjustment file {skinFile}: {ex.Message}");
                }
            }
        }

        private static void LoadCustomEntityLibrary(IReadOnlyFileSystem fileSystem, IEntityLibrary library, string customDataExtension, Type entityType)
        {
            bool extraInfo(int version) => customDataExtension == "w3a" || customDataExtension == "w3q" || (customDataExtension == "w3d" && version >= 2);
            var deserializer = new CustomEntityFileBinaryDeserializer(library) { ReadExtraInfo = extraInfo };

            void ReadEntityFile(string filePath)
            {
                CustomEntityFile entityFile;
                using (var file = fileSystem.OpenRead(filePath))
                using (var reader = new BinaryReader(file))
                {
                    entityFile = deserializer.Deserialize(reader);
                }
                foreach (var originalEntity in entityFile.OriginalEntries)
                {
                    var entity = library.GetEntity(originalEntity.BaseId) ?? library.AddEntity(Tag.Invalid, originalEntity.BaseId, entityType);

                    // TODO: not sure what to do with these variations atm so for now stomp with last
                    foreach (var field in originalEntity.Variations.SelectMany(_ => _))
                    {
                        entity.SetValue(field.Id, field.Value);
                    }
                }
                foreach (var customEntity in entityFile.CustomEntries)
                {
                    var entity = library.GetEntity(customEntity.NewId) ?? library.AddEntity(customEntity.NewId, customEntity.BaseId, entityType);

                    // TODO: not sure what to do with these variations atm so for now stomp with last
                    foreach (var field in customEntity.Variations.SelectMany(_ => _))
                    {
                        entity.SetValue(field.Id, field.Value);
                    }
                }
            }

            var war3mapFilePath = $"war3map.{customDataExtension}";
            if (fileSystem.FileExists(war3mapFilePath)) ReadEntityFile(war3mapFilePath);

            var war3mapSkinFilePath = $"war3mapSkin.{customDataExtension}";
            if (fileSystem.FileExists(war3mapSkinFilePath)) ReadEntityFile(war3mapSkinFilePath);
        }

        private static StringDataTable ReadSlk(IReadOnlyFileSystem fileSystem, string filePath, string primaryKey, ILogger logger)
        {
            try
            {
                logger.Log($"Reading slk file {filePath}...");
                using (Stream file = fileSystem.OpenRead(filePath))
                using (var reader = new SlkTextReader(file, SlkRecordDeserializerFactory))
                {
                    SlkFile slkFile = new SlkFileDeserializer().Deserialize(reader);
                    SlkTable slkTable = new SlkTableDeserializer().Deserialize(slkFile);
                    StringDataTable dataTable = new StringDataTableSlkDeserializer().Deserialize(slkTable);
                    dataTable.PrimaryKeyColumn = primaryKey;
                    return dataTable;
                }
            }
            catch (Exception)
            {
                throw;
            }
        }

        private static IDataDeserializer<SlkTextReader, SlkRecord> SlkRecordDeserializerFactory(string recordType)
        {
            switch (recordType)
            {
                case "ID":
                    return new IdRecordDeserializer();
                case "B":
                    return new BRecordDeserializer();
                case "C":
                    return new CRecordDeserializer();
                case "F":
                    return new FRecordDeserializer();
                default:
                    return new GenericRecordDeserializer(recordType);
            }
        }
    }
}
