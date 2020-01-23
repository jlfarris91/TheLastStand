namespace W3xPipeline
{
    using System.IO;
    using StormLibSharp;

    public class SpawnRegionGenerator : IPipelineObject
    {
        private readonly ILogger m_logger;

        public SpawnRegionGenerator(ILogger logger)
        {
            m_logger = logger;
        }

        public void DoWork(MpqArchive archive)
        {
            m_logger.Log("Generating spawn regions");

            string tempFileName = Path.GetTempFileName();

            try
            {

            }
            finally
            {
                if (File.Exists(tempFileName))
                {
                    File.Delete(tempFileName);
                }
            }
        }
    }
}
