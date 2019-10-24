namespace W3xPipeline
{
    using StormLib.Net;

    public interface IPipelineObject
    {
        void DoWork(MpqArchive archive);
    }
}