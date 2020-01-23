﻿namespace W3xPipeline
{
    using System;
    using System.IO;
    using System.Linq;
    using StormLibSharp;
    using War3.Net;
    using War3.Net.Data;
    using War3.Net.Data.Units;
    using War3.Net.Doodads;
    using War3.Net.IO;
    using War3.Net.Mpq;
    using War3.Net.Slk;

    class Program
    {
        private static ILogger sLogger;

        private static readonly string WAR3_MPQ_PATH = @"C:\Users\jfarris\Desktop\Projects\MpqEditor\War3.mpq";
        private static readonly string WAR3X_MPQ_PATH = @"C:\Users\jfarris\Desktop\Projects\MpqEditor\War3x.mpq";
        private static int WAR3_PRI = 100;
        private static int WAR3X_PRI = 200;
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
            var fileSystem = new LayeredFileSystem();
            var entityLibrary = new AggregateEntityLibrary();

            try
            {
                war3Archive = new MpqArchive(WAR3_MPQ_PATH, FileAccess.Read);
                war3XArchive = new MpqArchive(WAR3X_MPQ_PATH, FileAccess.Read);

                fileSystem.AddSystem(new MpqFileSystem(war3Archive), WAR3_PRI);
                fileSystem.AddSystem(new MpqFileSystem(war3XArchive), WAR3X_PRI);

                var objects = new IPipelineObject[]
                {
                    new PathingMapBuildabilityModifier(),
                    new RegionMapper(sLogger, fileSystem, entityLibrary),
                    //new SpawnPointGenerator(sLogger)
                };

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
                    entityLibrary.AddLibrary(ReadDestructibleLibrary(fileSystem));
                    entityLibrary.AddLibrary(ReadUnitLibrary(fileSystem));

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

        private static string MakeRelativeToDirectory(DirectoryInfo dir, FileInfo file)
        {
            return file.FullName.Replace(dir.FullName, string.Empty).Trim('\\');
        }

        private static IEntityLibrary ReadDoodadLibrary(IReadOnlyFileSystem fileSystem)
        {
            StringDataTable doodadData = ReadSlk(fileSystem, "Doodads/Doodads.slk", "doodID");
            StringDataTable doodadMetadata = ReadSlk(fileSystem, "Doodads/DoodadMetaData.slk", "ID");
            var deserializer = new DoodadLibrarySerializer(ObjectSerializationHelper.DeserializeObject);
            return deserializer.LoadLibrary(doodadData, doodadMetadata);
        }

        private static IEntityLibrary ReadDestructibleLibrary(IReadOnlyFileSystem fileSystem)
        {
            StringDataTable destructibleData = ReadSlk(fileSystem, "Units/DestructableData.slk", "DestructableID");
            StringDataTable destructibleMetadata = ReadSlk(fileSystem, "Units/DestructableMetaData.slk", "ID");
            var deserializer = new DestructibleLibrarySerializer(ObjectSerializationHelper.DeserializeObject);
            return deserializer.LoadLibrary(destructibleData, destructibleMetadata);
        }

        private static IEntityLibrary ReadUnitLibrary(LayeredFileSystem fileSystem)
        {
            StringDataTable unitDataTable = ReadSlk(fileSystem, "Units/UnitData.slk", "unitID");
            StringDataTable unitWeaponDataTable = ReadSlk(fileSystem, "Units/UnitWeapons.slk", "unitWeapID");
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
                using (Stream file = fileSystem.OpenRead(filePath))
                using (var reader = new StreamReader(file))
                {
                    new AdjustmentFileDeserializer().ReadAdjustmentFile(library, reader);
                }
            }
            catch (Exception)
            {
                throw;
            }
        }

        private static StringDataTable ReadSlk(IReadOnlyFileSystem fileSystem, string filePath, string primaryKey)
        {
            try
            {
                using (Stream file = fileSystem.OpenRead(filePath))
                using (var reader = new SlkTextReader(file))
                {
                    SlkTable slkTable = new SlkDeserializer().Deserialize(reader);
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
    }
}
