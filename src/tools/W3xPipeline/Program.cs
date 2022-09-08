namespace W3xPipeline
{
    using System;
    using System.Collections.Generic;
    using System.IO;
    using System.Linq;
    using StormLibSharp;
    using War3.Net;
    using War3.Net.Assets;
    using War3.Net.Data;
    using War3.Net.Data.Units;
    using War3.Net.Doodads;
    using War3.Net.Imaging;
    using War3.Net.Imaging.Blp;
    using War3.Net.Imaging.Targa;
    using War3.Net.IO;
    using War3.Net.Maps.Pathing;
    using War3.Net.Mpq;
    using War3.Net.Slk;

    class Program
    {
        private static ILogger sLogger;

        private static int WAR3_PRI = 100;
        private static int LOCALE_PRI = 200;
        private static int MAP_PRI = 300;

        private static int Main(string[] rawArgs)
        {
            ProgramArgs args = new ProgramArgs();

            sLogger = new ConsoleLogger();

            try
            {
                args = ProgramArgs.Parse(rawArgs);

                sLogger.Log("----- Program Args -----");
                sLogger.Log($"Source Map directory: {args.SourceMapDirectory.FullName}");
                sLogger.Log($"Output file path: {args.OutputMapFile.FullName}");
                sLogger.Log($"Intermediate dir: {args.IntermediateDirectory.FullName}");
                sLogger.Log($"Output Spawn Region Script File: {args.OutputSpawnRegionScriptFile.FullName}");
                sLogger.Log($"War3 Archive dir: {args.W3ModBasePath.FullName}");

                if (args.OutputListFilePath != null)
                    sLogger.Log($"Output List File: {args.OutputListFilePath.FullName}");

                if (args.WriteRegionsToArchive)
                    sLogger.Log($"Write regions to archive");

                if (args.MergeWar3MapSkinFiles)
                    sLogger.Log($"Merge custom data files");

                sLogger.Log("------------------------");
            }
            catch (Exception ex)
            {
                sLogger.Log($"Failed to parse arguments: {ex.Message}");
                Environment.Exit(-1);
            }

            // Services
            var fileSystem = new LayeredFileSystem();
            var assetManager = new AssetManager(fileSystem);
            var imageCache = new ImageCache("ImageCache");
            var imageProvider = new ImageProvider(imageCache, ImageDeserializerProvider);
            var pathMapFileBinaryDeserializer = new PathMapFileBinaryDeserializer(v => new PathMapBinaryDeserializer());
            var pathMapFileBinarySerializer = new PathMapFileBinarySerializer(v => new PathMapBinarySerializer());

            var referencedFilePaths = new List<string>();

            void RecordReferencedPath(string path)
            {
                if (!string.IsNullOrEmpty(path))
                {
                    referencedFilePaths.Add(path);
                }
            }

            string mapName = Path.GetFileNameWithoutExtension(args.OutputMapFile.Name);
            string mapExt = args.SourceMapDirectory.Extension.ToLower();

            string intermediateMpqPath = Path.Combine(args.IntermediateDirectory.FullName, mapName);
            if (!intermediateMpqPath.ToLower().EndsWith(mapExt))
                intermediateMpqPath = intermediateMpqPath.Trim('.') + mapExt;

            string outputMapFile = args.OutputMapFile.FullName;
            if (!outputMapFile.ToLower().EndsWith(mapExt))
                outputMapFile = outputMapFile.Trim('.') + mapExt;

            try
            {
                if (!args.SourceMapDirectory.Exists)
                {
                    throw new DirectoryNotFoundException($"Could not locate map folder {args.SourceMapDirectory}");
                }

                if (!mapExt.EndsWith("w3x") && !mapExt.EndsWith("w3m"))
                {
                    throw new InvalidDataException("Expected map folder extension to be 'w3m' or 'w3x'");
                }

                if (!args.IntermediateDirectory.Exists)
                {
                    Directory.CreateDirectory(args.IntermediateDirectory.FullName);
                }

                string baseWar3ArchivePath = args.W3ModBasePath.FullName;
                string localizedArchivePath = Path.Combine(baseWar3ArchivePath, @"_locales\enus.w3mod");

                // Mount the base war3 archive
                sLogger.Log($"Mounting archive '{baseWar3ArchivePath}' at priority {WAR3_PRI}");
                fileSystem.AddSystem(
                    new RecordReferencedWindowsFileSystem(new DirectoryInfo(baseWar3ArchivePath), RecordReferencedPath),
                    WAR3_PRI);

                // Mount the localized archive
                sLogger.Log($"Mounting archive '{localizedArchivePath}' at priority {LOCALE_PRI}");
                fileSystem.AddSystem(
                    new RecordReferencedWindowsFileSystem(new DirectoryInfo(localizedArchivePath),
                        RecordReferencedPath), LOCALE_PRI);

                if (File.Exists(intermediateMpqPath))
                {
                    sLogger.Log($"Deleting existing intermediate map file {intermediateMpqPath}");
                    File.Delete(intermediateMpqPath);
                }

                sLogger.Log($"Creating intermediate archive {intermediateMpqPath}");

                FileInfo[] filesToAdd = args.SourceMapDirectory.EnumerateFiles("*.*", SearchOption.AllDirectories).ToArray();

                // Create the map file
                using (MpqArchive newMapArchive = MpqArchive.CreateNew(
                    intermediateMpqPath,
                    MpqArchiveVersion.Version1,
                    MpqFileStreamAttributes.None,
                    MpqFileStreamAttributes.None,
                    filesToAdd.Length))
                {
                    // Add each file from the source map dir into the archive
                    foreach (FileInfo fileInfo in filesToAdd)
                    {
                        string archiveFilePath = MakeRelativeToDirectory(args.SourceMapDirectory.FullName, fileInfo.FullName);
                        newMapArchive.AddFileFromDisk(fileInfo.FullName, archiveFilePath);
                        sLogger.Log($"Added file {fileInfo.FullName} -> {archiveFilePath}");
                    }

                    // Map archive is now done being loaded
                    sLogger.Log($"Mounting archive '{intermediateMpqPath}' at priority {MAP_PRI}");
                    fileSystem.AddSystem(new MpqArchiveFileSystem(newMapArchive), MAP_PRI);

                    sLogger.Log($"Loading base object data...");
                    var libraries = LoadCustomObjectLibraries(fileSystem);

                    var objectLibrary = new AggregateEntityLibrary(libraries);

                    var objects = new List<IPipelineObject>
                    {
                        new PathMapBuildabilityModifier(pathMapFileBinaryDeserializer, pathMapFileBinarySerializer),
                        new RegionMapper(sLogger,
                            fileSystem,
                            objectLibrary,
                            imageProvider,
                            assetManager,
                            pathMapFileBinaryDeserializer,
                            args.OutputSpawnRegionScriptFile.FullName) { WriteRegionsToArchive = args.WriteRegionsToArchive },
                    };

                    if (args.MergeWar3MapSkinFiles)
                        objects.Add(new War3MapSkinMerger(sLogger, args.IntermediateDirectory.FullName));

                    // Run all of the pipeline steps
                    sLogger.Log("Running pipeline...");
                    foreach (IPipelineObject pipelineObject in objects)
                    {
                        pipelineObject.DoWork(newMapArchive);
                    }

                    sLogger.Log("Done running pipeline");

                    sLogger.Log("Flushing archive...");
                    newMapArchive.Flush();
                    sLogger.Log("Done flushing archive");
                }

                if (File.Exists(outputMapFile))
                {
                    sLogger.Log($"Deleting existing map file {outputMapFile}");
                    File.Delete(outputMapFile);
                }

                sLogger.Log($"Moving intermediate map {intermediateMpqPath} -> {outputMapFile}");
                File.Copy(intermediateMpqPath, outputMapFile);

                // Write distinct referenced paths to output list file
                if (args.OutputListFilePath != null)
                {
                    string[] distinctReferencedPaths = referencedFilePaths.Select(absolutePath =>
                            MakeRelativeToDirectory(args.W3ModBasePath.FullName, absolutePath))
                        .Distinct().ToArray();

                    sLogger.Log(
                        $"Writing {distinctReferencedPaths.Length} referenced files to path: {args.OutputListFilePath.FullName}");
                    File.WriteAllLines(args.OutputListFilePath.FullName, distinctReferencedPaths);
                }
            }
            catch (Exception ex)
            {
                sLogger.Log($"Failed: {ex.Message}");
                sLogger.Log(ex.StackTrace);
                Environment.Exit(-1);
            }
            finally
            {
                if (File.Exists(intermediateMpqPath))
                {
                    sLogger.Log($"Deleting intermediate map {intermediateMpqPath}");
                    File.Delete(intermediateMpqPath);
                }
            }

            sLogger.Log("Succeeded.");

            return 0;
        }

        private static IDataDeserializer<Stream, IImage> ImageDeserializerProvider(AssetReference arg)
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

        private static string MakeRelativeToDirectory(string dir, string file)
        {
            return file.Replace(dir, string.Empty).Replace('/', '\\').Trim('\\');
        }

        private static IEnumerable<IEntityLibrary> LoadCustomObjectLibraries(IReadOnlyFileSystem fileSystem)
        {
            var deserializer = new WarcraftDataLibrarySerializer(ObjectSerializationHelper.DeserializeObject);

            var baseDestructableLibrary = new EntityLibrary();

            sLogger.Log($"Reading destructible data...");
            StringDataTable destructibleData = ReadSlk(fileSystem, "Units/DestructableData.slk", "DestructableID");
            StringDataTable destructibleMetadata = ReadSlk(fileSystem, "Units/DestructableMetaData.slk", "ID");
            deserializer.LoadLibrary(baseDestructableLibrary, destructibleData, destructibleMetadata, typeof(DestructibleEntity));

            ReadSkinFiles(fileSystem, baseDestructableLibrary, new string[]
            {
                "Units/DestructableSkin.txt",
            });

            var customDestructableLibrary = new EntityLibrary(baseDestructableLibrary);
            LoadCustomEntityLibrary(fileSystem, customDestructableLibrary, "w3b", typeof(DestructibleEntity));

            yield return customDestructableLibrary;

            var baseDoodadLibrary = new EntityLibrary();

            StringDataTable doodadData = ReadSlk(fileSystem, "Doodads/Doodads.slk", "doodID");
            StringDataTable doodadMetadata = ReadSlk(fileSystem, "Doodads/DoodadMetaData.slk", "ID");
            deserializer.LoadLibrary(baseDoodadLibrary, doodadData, doodadMetadata, typeof(DoodadEntity));

            ReadSkinFiles(fileSystem, baseDoodadLibrary, new string[]
            {
                "Doodads/DoodadSkins.txt",
            });

            var customDoodadLibrary = new EntityLibrary(baseDoodadLibrary);
            LoadCustomEntityLibrary(fileSystem, customDoodadLibrary, "w3d", typeof(DoodadEntity));

            yield return customDoodadLibrary;

            var baseUnitLibrary = new EntityLibrary();

            StringDataTable unitDataMetadataTable = ReadSlk(fileSystem, "Units/UnitMetaData.slk", "ID");

            StringDataTable unitDataTable = ReadSlk(fileSystem, "Units/UnitData.slk", "unitID");
            deserializer.LoadLibrary(baseUnitLibrary, unitDataTable, unitDataMetadataTable, typeof(UnitEntity));

            StringDataTable unitWeaponDataTable = ReadSlk(fileSystem, "Units/UnitWeapons.slk", "unitWeaponID");
            deserializer.LoadLibrary(baseUnitLibrary, unitWeaponDataTable, unitDataMetadataTable, typeof(UnitEntity));

            StringDataTable unitBalanceDataTable = ReadSlk(fileSystem, "Units/UnitBalance.slk", "unitBalanceID");
            deserializer.LoadLibrary(baseUnitLibrary, unitBalanceDataTable, unitDataMetadataTable, typeof(UnitEntity));

            StringDataTable unitArtDataTable = ReadSlk(fileSystem, "Units/UnitUI.slk", "unitUIID");
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
            });

            var customUnitLibrary = new EntityLibrary(baseUnitLibrary);
            LoadCustomEntityLibrary(fileSystem, customUnitLibrary, "w3u", typeof(UnitEntity));
            
            yield return customUnitLibrary;
        }

        private static void ReadSkinFiles(IReadOnlyFileSystem fileSystem, IEntityLibrary library, string[] skinFiles)
        {
            foreach (string skinFile in skinFiles)
            {
                try
                {
                    sLogger.Log($"Reading adjustment file {skinFile}...");
                    using (Stream file = fileSystem.OpenRead(skinFile))
                    using (var reader = new StreamReader(file))
                    {
                        new ProfileFileDeserializer().ReadProfile(library, reader);
                    }
                }
                catch (Exception ex)
                {
                    sLogger.Log($"Unable to read adjustment file {skinFile}: {ex.Message}");
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

        private static StringDataTable ReadSlk(IReadOnlyFileSystem fileSystem, string filePath, string primaryKey)
        {
            try
            {
                sLogger.Log($"Reading slk file {filePath}...");
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
