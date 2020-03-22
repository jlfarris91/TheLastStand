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

        public static ProgramArgs Parse(string[] args)
        {
            var result = new ProgramArgs();
            
            result.SourceMapDirectory = new DirectoryInfo(args[0]);
            result.OutputMapFile = new FileInfo(args[1]);
            result.IntermediateDirectory = new DirectoryInfo(args[2]);
            result.OutputSpawnRegionScriptFile = new FileInfo(args[3]);
            result.W3ModBasePath = new DirectoryInfo(args[4]);

            if (args.Length >= 6)
                result.OutputListFilePath = new FileInfo(args[5]);

            return result;
        }
    }
}