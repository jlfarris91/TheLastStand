namespace W3xPipeline
{
    using System;
    using System.IO;
    using System.Linq;
    using StormLibSharp;
    using War3.Net;
    using War3.Net.Mpq;

    class Program
    {
        private static ILogger sLogger;

        private static readonly string WAR3_MPQ_PATH = @"D:\Projects\WarcraftIII\MPQ\War3.mpq";
        private static readonly string WAR3X_MPQ_PATH = @"D:\Projects\WarcraftIII\MPQ\War3x.mpq";
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
            var mountedArchives = new LayeredFileSystem();

            try
            {
                war3Archive = new MpqArchive(WAR3_MPQ_PATH, FileAccess.Read);
                war3XArchive = new MpqArchive(WAR3X_MPQ_PATH, FileAccess.Read);

                mountedArchives.AddSystem(new MpqFileSystem(war3Archive), WAR3_PRI);
                mountedArchives.AddSystem(new MpqFileSystem(war3XArchive), WAR3X_PRI);

                var objects = new IPipelineObject[]
                {
                    new PathingMapBuildabilityModifier(),
                    new RegionMapper(sLogger, mountedArchives),
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

                    mountedArchives.AddSystem(new MpqFileSystem(newMapArchive), MAP_PRI);

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
    }
}
