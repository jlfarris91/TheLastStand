namespace W3xPipeline
{
    using System;
    using System.IO;
    using WorldEditor.Common;

    public class PathingMapDeserializer
    {
        private static readonly Tag MP3QW_TAG = Tag.FromString("MP3W");

        public PathingMap Deserialize(BinaryReader reader)
        {
            reader.ReadTag(MP3QW_TAG);

            int version = (int)reader.ReadUInt32();
            if (version != 0)
            {
                throw new Exception($"Incompatible version number {version}");
            }

            int width = reader.ReadInt32();
            int height = reader.ReadInt32();

            var pathingMap = new PathingMap(width, height)
            {
                Version = version
            };

            for (var i = 0; i < width * height; ++i)
            {
                pathingMap[i] = (PathingType)reader.ReadByte();
            }

            return pathingMap;
        }
    }
}