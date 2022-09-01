namespace W3xPipeline
{
    using System.IO;

    public struct ProgramArgs
    {
        public DirectoryInfo SourceMapDirectory { get; set; }
        public FileInfo OutputMapFile { get; set; }
        public DirectoryInfo IntermediateDirectory { get; set; }
        public FileInfo OutputSpawnRegionScriptFile { get; set; }
        public DirectoryInfo W3ModBasePath { get; set; }
        public FileInfo OutputListFilePath { get; set; }
        public bool WriteRegionsToArchive { get; set; }

        public static ProgramArgs Parse(string[] args)
        {
            var result = new ProgramArgs();

            for (var i = 0; i < args.Length; i++)
            {
                var arg = args[i];

                switch (arg)
                {
                    case "--sourceMapDir":
                        result.SourceMapDirectory = new DirectoryInfo(args[++i]);
                        break;
                    case "--outputMapFile":
                        result.OutputMapFile = new FileInfo(args[++i]);
                        break;
                    case "--intermediateDir":
                        result.IntermediateDirectory = new DirectoryInfo(args[++i]);
                        break;
                    case "--outputSpawnRegionScriptFile":
                        result.OutputSpawnRegionScriptFile = new FileInfo(args[++i]);
                        break;
                    case "--w3modBasePath":
                        result.W3ModBasePath = new DirectoryInfo(args[++i]);
                        break;
                    case "--outputListFilePath":
                        result.OutputListFilePath = new FileInfo(args[++i]);
                        break;
                    case "--writeRegionsToArchive":
                        result.WriteRegionsToArchive = true;
                        break;
                }
            }

            return result;
        }
    }
}