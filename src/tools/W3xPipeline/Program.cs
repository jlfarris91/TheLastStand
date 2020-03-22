namespace W3xPipeline
{
    using System;
    using System.Collections.Generic;
    using System.IO;
    using System.Linq;
    using StormLibSharp;
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

                sLogger.Log("------------------------");
            }
            catch (Exception ex)
            {
                sLogger.Log($"Failed to parse arguments: {ex.Message}");
                Environment.Exit(-1);
            }

            // Services
            var fileSystem = new LayeredFileSystem();
            var entityLibrary = new AggregateEntityLibrary();
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

                FileInfo[] filesToAdd =
                    args.SourceMapDirectory.EnumerateFiles("*.*", SearchOption.AllDirectories).ToArray();

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
                        string archiveFilePath =
                            MakeRelativeToDirectory(args.SourceMapDirectory.FullName, fileInfo.FullName);
                        newMapArchive.AddFileFromDisk(fileInfo.FullName, archiveFilePath);
                        sLogger.Log($"Added file {fileInfo.FullName} -> {archiveFilePath}");
                    }

                    // Map archive is now done being loaded
                    sLogger.Log($"Mounting archive '{intermediateMpqPath}' at priority {MAP_PRI}");
                    fileSystem.AddSystem(new MpqFileSystem(newMapArchive), MAP_PRI);
                    entityLibrary.AddLibrary(ReadDoodadLibrary(fileSystem));

                    // Build the entity library
                    var destructibleLibrary = (DestructibleLibrary) ReadDestructibleLibrary(fileSystem);
                    entityLibrary.AddLibrary(destructibleLibrary);

                    var unitLibrary = (UnitLibrary) ReadUnitLibrary(fileSystem);
                    entityLibrary.AddLibrary(unitLibrary);

                    var objects = new IPipelineObject[]
                    {
                        new PathMapBuildabilityModifier(pathMapFileBinaryDeserializer, pathMapFileBinarySerializer),
                        new RegionMapper(sLogger,
                            fileSystem,
                            entityLibrary,
                            imageProvider,
                            assetManager,
                            pathMapFileBinaryDeserializer,
                            destructibleLibrary,
                            args.OutputSpawnRegionScriptFile.FullName)
                    };

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
                    return new TargaBitmapDeserializer();
            }

            return null;
        }

        private static string MakeRelativeToDirectory(string dir, string file)
        {
            return file.Replace(dir, string.Empty).Replace('/', '\\').Trim('\\');
        }

        private static IEntityLibrary ReadDoodadLibrary(IReadOnlyFileSystem fileSystem)
        {
            sLogger.Log($"Reading doodad library...");
            StringDataTable doodadData = ReadSlk(fileSystem, "Doodads/Doodads.slk", "doodID");
            StringDataTable doodadMetadata = ReadSlk(fileSystem, "Doodads/DoodadMetaData.slk", "ID");
            var deserializer = new DoodadLibrarySerializer(ObjectSerializationHelper.DeserializeObject);
            DoodadLibrary library = deserializer.LoadLibrary(doodadData, doodadMetadata);

            var adjustmentFiles = new string[]
            {
                "Doodads/DoodadSkins.txt",
            };

            foreach (string file in adjustmentFiles)
            {
                ReadAdjustmentFile(fileSystem, library, file);
            }

            return library;
        }

        private static IEntityLibrary ReadDestructibleLibrary(IReadOnlyFileSystem fileSystem)
        {
            sLogger.Log($"Reading destructible library...");
            StringDataTable destructibleData = ReadSlk(fileSystem, "Units/DestructableData.slk", "DestructableID");
            StringDataTable destructibleMetadata = ReadSlk(fileSystem, "Units/DestructableMetaData.slk", "ID");
            var deserializer = new DestructibleLibrarySerializer(ObjectSerializationHelper.DeserializeObject);
            DestructibleLibrary library = deserializer.LoadLibrary(destructibleData, destructibleMetadata);

            var adjustmentFiles = new string[]
            {
                "Units/DestructableSkin.txt",
            };

            foreach (string file in adjustmentFiles)
            {
                ReadAdjustmentFile(fileSystem, library, file);
            }

            return library;
        }

        private static IEntityLibrary ReadUnitLibrary(IReadOnlyFileSystem fileSystem)
        {
            sLogger.Log($"Reading unit library...");
            StringDataTable unitDataTable = ReadSlk(fileSystem, "Units/UnitData.slk", "unitID");
            StringDataTable unitWeaponDataTable = ReadSlk(fileSystem, "Units/UnitWeapons.slk", "unitWeaponID");
            StringDataTable unitBalanceDataTable = ReadSlk(fileSystem, "Units/UnitBalance.slk", "unitBalanceID");
            StringDataTable unitArtDataTable = ReadSlk(fileSystem, "Units/UnitUI.slk", "unitUIID");

            unitDataTable.Join(unitWeaponDataTable, unitBalanceDataTable, unitArtDataTable);

            StringDataTable unitDataMetadataTable = ReadSlk(fileSystem, "Units/UnitMetaData.slk", "ID");

            var deserializer = new UnitLibrarySerializer(ObjectSerializationHelper.DeserializeObject);
            UnitLibrary library = deserializer.LoadLibrary(
                unitDataTable,
                unitDataMetadataTable,
                unitWeaponDataTable,
                unitBalanceDataTable,
                unitArtDataTable);

            var adjustmentFiles = new[]
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
            };

            foreach (string file in adjustmentFiles)
            {
                ReadAdjustmentFile(fileSystem, library, file);
            }

            return library;
        }

        private static void ReadAdjustmentFile(IReadOnlyFileSystem fileSystem, IEntityLibrary library, string filePath)
        {

            try
            {
                sLogger.Log($"Reading adjustment file {filePath}...");
                using (Stream file = fileSystem.OpenRead(filePath))
                using (var reader = new StreamReader(file))
                {
                    new ProfileFileDeserializer().ReadProfile(library, reader);
                }
            }
            catch (Exception ex)
            {
                sLogger.Log($"Unable to read adjustment file {filePath}: {ex.Message}");
            }
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
