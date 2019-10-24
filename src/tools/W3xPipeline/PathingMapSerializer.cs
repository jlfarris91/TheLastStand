namespace W3xPipeline
{
    using System.IO;
    using WorldEditor.Common;

    public class PathingMapSerializer
    {
        private static readonly Tag MP3QW_TAG = Tag.FromString("MP3W");

        public void Serialize(BinaryWriter writer, PathingMap pathingMap)
        {
            writer.WriteTag(MP3QW_TAG);
            writer.Write((uint)pathingMap.Version);
            writer.Write(pathingMap.Width);
            writer.Write(pathingMap.Height);

            for (var i = 0; i < pathingMap.Width * pathingMap.Height; ++i)
            {
                writer.Write((byte)pathingMap[i]);
            }
        }
    }
}