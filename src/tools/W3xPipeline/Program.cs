namespace W3xPipeline
{
    using System;
    using System.Collections.Generic;
    using System.IO;
    using System.Linq;
    using System.Text;
    using StormLibSharp;

    class Program
    {
        private static int Main(string[] rawArgs)
        {
            ProgramArgs args = new ProgramArgs();

            try
            {
                args = ProgramArgs.Parse(rawArgs);

                Log($"Map directory: {args.InputMapDirectory.FullName}");
                Log($"Output file path: {args.OutputMapFile.FullName}");
                Log($"Intermediate dir: {args.IntermediateDirectory.FullName}");
            }
            catch (Exception ex)
            {
                Log($"Failed to parse arguments: {ex.Message}");
                Environment.Exit(-1);
            }

            var objects = new IPipelineObject[]
            {
                new PathingMapBuildabilityModifier(),
                new SpawnPointGenerator()
            };

            try
            {
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
                    Log($"Deleting existing intermediate map file {intermediateMpqPath}");
                    File.Delete(intermediateMpqPath);
                }
                
                Log($"Creating intermediate archive {intermediateMpqPath}");

                FileInfo[] filesToAdd = args.InputMapDirectory.EnumerateFiles("*.*", SearchOption.AllDirectories).ToArray();

                // Create the map file
                using (MpqArchive archive = MpqArchive.CreateNew(
                    intermediateMpqPath,
                    MpqArchiveVersion.Version1,
                    MpqFileStreamAttributes.None,
                    MpqFileStreamAttributes.None,
                    filesToAdd.Length))
                {
                    var listFileContents = new List<string>();

                    foreach (FileInfo fileInfo in filesToAdd)
                    {
                        string archiveFilePath = MakeRelativeToDirectory(args.InputMapDirectory, fileInfo);
                        archive.AddFileFromDisk(fileInfo.FullName, archiveFilePath);
                        listFileContents.Add(archiveFilePath);
                        Log($"Added file {fileInfo.FullName} -> {archiveFilePath}");
                    }

                    Log($"{listFileContents.Count} files added to mpq");

                    archive.AddListFile(string.Join("\n", listFileContents));

                    Log("Running pipeline...");
                    foreach (IPipelineObject pipelineObject in objects)
                    {
                        pipelineObject.DoWork(archive);
                    }
                    Log("Done running pipeline");

                    Log("Flushing archive...");
                    archive.Flush();
                    Log("Done flushing archive");
                }

                if (File.Exists(outputMapFile))
                {
                    Log($"Deleting existing map file {outputMapFile}");
                    File.Delete(outputMapFile);
                }
                
                Log($"Moving intermediate map {intermediateMpqPath} -> {outputMapFile}");
                File.Copy(intermediateMpqPath, outputMapFile);
            }
            catch (Exception ex)
            {
                Log($"Failed: {ex.Message}");
                Environment.Exit(-1);
            }

            Log("Succeeded.");

            return 0;
        }

        private static void Log(string message)
        {
            Console.WriteLine($"[{DateTime.UtcNow:O}] {message}");
        }

        private static string MakeRelativeToDirectory(DirectoryInfo dir, FileInfo file)
        {
            return file.FullName.Replace(dir.FullName, string.Empty).Trim('\\');
        }
    }
}
