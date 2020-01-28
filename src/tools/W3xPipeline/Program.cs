namespace W3xPipeline
{
    using System;
    using System.IO;
    using System.Linq;
    using StormLibSharp;
    using War3.Net;
    using War3.Net.Assets;
    using War3.Net.Core;
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

        private static readonly string WAR3_W3MOD_PATH = @"D:\Projects\WarcraftIII\MPQ\war3.w3mod";
        //private static readonly string WAR3_W3MOD_PATH = @"C:\War3\data\branches\v1.32.1\War3.w3mod";
        private static readonly string LOCALE_W3MOD_PATH = Path.Combine(WAR3_W3MOD_PATH, @"_locales\enus.w3mod");
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

                sLogger.Log($"Map directory: {args.InputMapDirectory.FullName}");
                sLogger.Log($"Output file path: {args.OutputMapFile.FullName}");
                sLogger.Log($"Intermediate dir: {args.IntermediateDirectory.FullName}");
            }
            catch (Exception ex)
            {
                sLogger.Log($"Failed to parse arguments: {ex.Message}");
                Environment.Exit(-1);
            }

            MpqArchive war3Archive = null;
            MpqArchive war3XArchive = null;

            // Services
            var fileSystem = new LayeredFileSystem();
            var entityLibrary = new AggregateEntityLibrary();
            var assetManager = new AssetManager(fileSystem);
            var imageCache = new ImageCache("ImageCache");
            var imageProvider = new ImageProvider(imageCache, ImageDeserializerProvider);
            var pathMapFileBinaryDeserializer = new PathMapFileBinaryDeserializer(v => new PathMapBinaryDeserializer());
            var pathMapFileBinarySerializer = new PathMapFileBinarySerializer(v => new PathMapBinarySerializer());

            try
            {
                fileSystem.AddSystem(new WindowsFileSystem(new DirectoryInfo(WAR3_W3MOD_PATH)), WAR3_PRI);
                fileSystem.AddSystem(new WindowsFileSystem(new DirectoryInfo(LOCALE_W3MOD_PATH)), LOCALE_PRI);

                if (!args.InputMapDirectory.Exists)
                {
                    throw new DirectoryNotFoundException($"Could not locate map folder {args.InputMapDirectory}");
                }

                string mapName = Path.GetFileNameWithoutExtension(args.OutputMapFile.Name);
                string mapExt = args.InputMapDirectory.Extension.ToLower();

                if (!mapExt.EndsWith("w3x") && !mapExt.EndsWith("w3m"))
                {
                    throw new InvalidDataException("Expected map folder extension to be 'w3m' or 'w3x'");
                }

                if (!args.IntermediateDirectory.Exists)
                {
                    Directory.CreateDirectory(args.IntermediateDirectory.FullName);
                }

                string intermediateMpqPath = Path.Combine(args.IntermediateDirectory.FullName, mapName);
                intermediateMpqPath = Path.ChangeExtension(intermediateMpqPath, mapExt);

                string outputMapFile = Path.ChangeExtension(args.OutputMapFile.FullName, mapExt);

                if (File.Exists(intermediateMpqPath))
                {
                    sLogger.Log($"Deleting existing intermediate map file {intermediateMpqPath}");
                    File.Delete(intermediateMpqPath);
                }

                sLogger.Log($"Creating intermediate archive {intermediateMpqPath}");

                FileInfo[] filesToAdd =
                    args.InputMapDirectory.EnumerateFiles("*.*", SearchOption.AllDirectories).ToArray();

                // Create the map file
                using (MpqArchive newMapArchive = MpqArchive.CreateNew(
                    intermediateMpqPath,
                    MpqArchiveVersion.Version1,
                    MpqFileStreamAttributes.None,
                    MpqFileStreamAttributes.None,
                    filesToAdd.Length))
                {
                    foreach (FileInfo fileInfo in filesToAdd)
                    {
                        string archiveFilePath = MakeRelativeToDirectory(args.InputMapDirectory, fileInfo);
                        newMapArchive.AddFileFromDisk(fileInfo.FullName, archiveFilePath);
                        sLogger.Log($"Added file {fileInfo.FullName} -> {archiveFilePath}");
                    }

                    // Map archive is now done being loaded
                    fileSystem.AddSystem(new MpqFileSystem(newMapArchive), MAP_PRI);
                    entityLibrary.AddLibrary(ReadDoodadLibrary(fileSystem));

                    var destructibleLibrary = (DestructibleLibrary)ReadDestructibleLibrary(fileSystem);
                    entityLibrary.AddLibrary(destructibleLibrary);

                    var unitLibrary = (UnitLibrary)ReadUnitLibrary(fileSystem);
                    entityLibrary.AddLibrary(unitLibrary);

                    var objects = new IPipelineObject[]
                    {
                        new PathMapBuildabilityModifier(pathMapFileBinaryDeserializer, pathMapFileBinarySerializer),
                        new RegionMapper(sLogger, fileSystem, entityLibrary, imageProvider, assetManager, pathMapFileBinaryDeserializer, destructibleLibrary),
                        //new SpawnPointGenerator(sLogger)
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
            }
            catch (Exception ex)
            {
                sLogger.Log($"Failed: {ex.Message}");
                Environment.Exit(-1);
            }
            finally
            {
                DisposeUtility.SafeDispose(ref war3XArchive);
                DisposeUtility.SafeDispose(ref war3Archive);
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

        private static string MakeRelativeToDirectory(DirectoryInfo dir, FileInfo file)
        {
            return file.FullName.Replace(dir.FullName, string.Empty).Trim('\\');
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
#if REFORGED
                "Doodads/DoodadSkins.txt",
#endif
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
#if REFORGED
                "Units/DestructableSkin.txt",
#endif
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
