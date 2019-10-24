namespace W3xPipeline
{
    using System;
    using System.IO;
    using StormLib.Net;

    class Program
    {
        private static int Main(string[] args)
        {
            string mapName = args[0];

            var objects = new IPipelineObject[]
            {
                new PathingMapBuildabilityModifier()
            };

            try
            {
                if (!File.Exists(mapName))
                {
                    throw new FileNotFoundException($"Could not locate map file {mapName}", mapName);
                }

                using (MpqArchive archive = MpqArchive.Load(mapName, FileAccess.ReadWrite))
                {
                    foreach (IPipelineObject pipelineObject in objects)
                    {
                        pipelineObject.DoWork(archive);
                    }

                    archive.Flush();
                }
            }
            catch (Exception ex)
            {
                Console.WriteLine("Failed: " + ex.Message);
                Environment.Exit(-1);
            }

            return 0;
        }
    }
}
