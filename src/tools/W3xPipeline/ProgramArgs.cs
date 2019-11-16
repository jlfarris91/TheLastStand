namespace W3xPipeline
{
    using System;
    using System.IO;

    public struct ProgramArgs
    {
        public DirectoryInfo InputMapDirectory { get; set; }
        public FileInfo OutputMapFile { get; set; }
        public DirectoryInfo IntermediateDirectory { get; set; }

        public static ProgramArgs Parse(string[] args)
        {
            var result = new ProgramArgs();
            
            result.InputMapDirectory = new DirectoryInfo(args[0]);
            result.OutputMapFile = new FileInfo(args[1]);
            result.IntermediateDirectory = new DirectoryInfo(args[2]);

            return result;
        }
    }
}