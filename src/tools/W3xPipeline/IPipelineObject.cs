namespace W3xPipeline
{
    using StormLibSharp;

    public interface IPipelineObject
    {
        void DoWork(MpqArchive archive);
    }
}