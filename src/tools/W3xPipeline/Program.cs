namespace W3xPipeline
{
    using System;
    using System.Collections.Generic;
    using System.IO;
    using System.Linq;
    using StormLibSharp;
    using War3.Net.Assets;
    using War3.Net.Data;
    using War3.Net.Imaging;
    using War3.Net.Maps.Doodads;
    using War3.Net.Maps.Pathing;
    using War3.Net.Maps.Regions;
    using War3.Net.Maps.Terrain;
    using War3.Net.Maps.Units;
    using War3.Net.Mpq;

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
            var imageProvider = new ImageProvider(imageCache, PipelineUtility.ImageDeserializerProvider);
            var pathMapFileBinaryDeserializer = new PathMapFileBinaryDeserializer(v => new PathMapBinaryDeserializer());
            var pathMapFileBinarySerializer = new PathMapFileBinarySerializer(v => new PathMapBinarySerializer());
            var unitPlacementBinaryDeserializer = new UnitPlacementBinaryDeserializer();
            var unitPlacementFileBinaryDeserializer = new UnitPlacementFileBinaryDeserializer((v, sv) => unitPlacementBinaryDeserializer);
            var unitPlacementBinarySerializer = new UnitPlacementBinarySerializer();
            var unitPlacementFileBinarySerializer = new UnitPlacementFileBinarySerializer((v, sv) => unitPlacementBinarySerializer);
            var doodadPlacementFileBinaryDeserializer = new DoodadPlacementFileBinaryDeserializer();
            var terrainBinaryDeserializer = new TerrainBinaryDeserializer();
            var terrainFileBinaryDeserializer = new TerrainFileBinaryDeserializer(v => terrainBinaryDeserializer);
            var regionsBinaryDeserializer = new RegionsFileBinaryDeserializer();
            var regionsBinarySerializer = new RegionsFileBinarySerializer();

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
                        string archiveFilePath = PipelineUtility.MakeRelativeToDirectory(args.SourceMapDirectory.FullName, fileInfo.FullName);
                        newMapArchive.AddFileFromDisk(fileInfo.FullName, archiveFilePath);
                        sLogger.Log($"Added file {fileInfo.FullName} -> {archiveFilePath}");
                    }

                    // Map archive is now done being loaded
                    sLogger.Log($"Mounting archive '{intermediateMpqPath}' at priority {MAP_PRI}");
                    var mapArchiveFileSystem = new MpqArchiveFileSystem(newMapArchive);
                    fileSystem.AddSystem(mapArchiveFileSystem, MAP_PRI);

                    sLogger.Log($"Loading base object data...");
                    var libraries = PipelineUtility.LoadCustomObjectLibraries(fileSystem, sLogger);

                    var objectLibrary = new AggregateEntityLibrary(libraries);

                    var objects = new List<IPipelineObject>
                    {
                        new BaseBuilder(
                            mapArchiveFileSystem,
                            sLogger,
                            objectLibrary,
                            unitPlacementFileBinaryDeserializer,
                            unitPlacementFileBinarySerializer,
                            regionsBinaryDeserializer,
                            regionsBinarySerializer),
                        new PathMapBuildabilityModifier(pathMapFileBinaryDeserializer, pathMapFileBinarySerializer),
                        new RegionMapper(sLogger,
                            fileSystem,
                            objectLibrary,
                            imageProvider,
                            assetManager,
                            pathMapFileBinaryDeserializer,
                            args.OutputSpawnRegionScriptFile.FullName) { WriteRegionsToArchive = args.WriteRegionsToArchive },
                        new EventMapTemplateBuilder(
                            sLogger,
                            objectLibrary,
                            unitPlacementFileBinaryDeserializer,
                            doodadPlacementFileBinaryDeserializer,
                            terrainFileBinaryDeserializer),
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
                            PipelineUtility.MakeRelativeToDirectory(args.W3ModBasePath.FullName, absolutePath))
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
    }
}
