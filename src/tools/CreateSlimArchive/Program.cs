namespace CreateSlimArchive
{
    using System;
    using System.Diagnostics;
    using System.IO;
    using War3.Net.IO;
    using War3.Net.Mpq;

    public class Program
    {
        private static ILogger sLogger;

        private static void Main(string[] rawArgs)
        {
            var args = new ProgramArgs();

            sLogger = new ConsoleLogger();

            try
            {
                args = ProgramArgs.Parse(rawArgs);

                sLogger.Log("----- Program Args -----");
                sLogger.Log($"Source archive directory: {args.SourceArchiveDir.FullName}");
                sLogger.Log($"Destination archive directory: {args.DestinationArchiveDir.FullName}");
                sLogger.Log($"List file: {args.ListFile.FullName}");
                sLogger.Log("------------------------");
            }
            catch (Exception ex)
            {
                sLogger.Log($"Failed to parse arguments: {ex.Message}");
                Environment.Exit(-1);
            }

            try
            {
                if (args.DestinationArchiveDir.Exists)
                {
                    sLogger.Log($"Recursively deleting existing destination archive dir: {args.DestinationArchiveDir.FullName}");

                    foreach (FileInfo file in args.DestinationArchiveDir.EnumerateFiles("*.*", SearchOption.AllDirectories))
                    {
                        sLogger.Log($"Deleting file: {file.FullName}");
                        file.Delete();
                    }
                }
                else
                {
                    // Make sure the destination dir exists
                    sLogger.Log($"Creating destination archive dir: {args.DestinationArchiveDir.FullName}");
                    Directory.CreateDirectory(args.DestinationArchiveDir.FullName);
                }

                // Need to refresh the DirectoryInfo
                args.DestinationArchiveDir.Refresh();

                var sourceFileSystem = new LayeredFileSystem();

                // Mount the base war3 archive
                sLogger.Log($"Mounting source archive: {args.SourceArchiveDir.FullName}");
                sourceFileSystem.AddSystem(new WindowsFileSystem(args.SourceArchiveDir), 0);

                // Mount the localized archive
                sLogger.Log($"Mounting destination archive: {args.DestinationArchiveDir.FullName}");
                var destFileSystem = new WindowsFileSystem(args.DestinationArchiveDir);

                string[] filesToCopy = File.ReadAllLines(args.ListFile.FullName);
                foreach (string relativeFilePath in filesToCopy)
                {
                    sLogger.Log($"Copying file {relativeFilePath}...");
                    try
                    {
                        string relativeFileDir = Path.GetDirectoryName(relativeFilePath);

                        // TODO: Add CreateDirectory to IFileSystem
                        string destFileDir = Path.Combine(args.DestinationArchiveDir.FullName, relativeFileDir);
                        if (!Directory.Exists(destFileDir))
                        {
                            Directory.CreateDirectory(destFileDir);
                        }

                        using (Stream sourceFile = sourceFileSystem.OpenRead(relativeFilePath))
                        using (Stream destFile = destFileSystem.OpenWrite(relativeFilePath))
                        using (var sourceReader = new BinaryReader(sourceFile))
                        using (var destWriter = new BinaryWriter(destFile))
                        {
                            var buffer = new byte[1024];
                            int bytesRead;
                            while ((bytesRead = sourceReader.Read(buffer, 0, buffer.Length)) > 0)
                            {
                                destWriter.Write(buffer, 0, bytesRead);
                            }
                        }
                    }
                    catch (Exception ex)
                    {
                        sLogger.Log($"Failed to copy file: {ex.Message}");
                    }
                }
            }
            catch (Exception ex)
            {
                sLogger.Log($"Failed: {ex.Message}");
                Environment.Exit(-1);
            }
        }
    }

    public struct ProgramArgs
    {
        public DirectoryInfo SourceArchiveDir { get; set; }
        public DirectoryInfo DestinationArchiveDir { get; set; }
        public FileInfo ListFile { get; set; }

        public static ProgramArgs Parse(string[] args)
        {
            var result = new ProgramArgs();
            
            result.SourceArchiveDir = new DirectoryInfo(args[0]);
            result.DestinationArchiveDir = new DirectoryInfo(args[1]);
            result.ListFile = new FileInfo(args[2]);

            return result;
        }
    }

    public interface ILogger
    {
        void Log(string message);
    }

    public class ConsoleLogger : ILogger
    {
        public void Log(string message)
        {
            Console.WriteLine($"[{DateTime.UtcNow:O}] {message}");
            Debug.WriteLine($"[{DateTime.UtcNow:O}] {message}");
        }
    }
}
