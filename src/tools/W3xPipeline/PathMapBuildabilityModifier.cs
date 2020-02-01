namespace W3xPipeline
{
    using System.IO;
    using StormLibSharp;
    using War3.Net;
    using War3.Net.IO;
    using War3.Net.Maps.Pathing;

    public class PathMapBuildabilityModifier : IPipelineObject
    {
        private const string ARCHIVE_TERRAIN_FILE_PATH = "war3map.wpm";
        private readonly IDataDeserializer<BinaryReader, PathMapFile> m_pathMapDeserializer;
        private readonly IDataSerializer<BinaryWriter, PathMapFile> m_pathMapSerializer;

        public PathMapBuildabilityModifier(
            IDataDeserializer<BinaryReader, PathMapFile> pathMapDeserializer,
            IDataSerializer<BinaryWriter, PathMapFile> pathMapSerializer)
        {
            m_pathMapDeserializer = pathMapDeserializer;
            m_pathMapSerializer = pathMapSerializer;
        }

        public void DoWork(MpqArchive archive)
        {
            string tempFileName = Path.GetTempFileName();

            try
            {
                PathMapFile pathMapFile;

                using (MpqFileStream file = archive.OpenFile(ARCHIVE_TERRAIN_FILE_PATH))
                using (var reader = new BinaryReader(file))
                {
                    pathMapFile = m_pathMapDeserializer.Deserialize(reader);
                }

                MakeAllWalkableTerrainBuildable(pathMapFile.Map);

                using (Stream file = File.Create(tempFileName))
                using (var writer = new BinaryWriter(file))
                {
                    m_pathMapSerializer.Serialize(writer, pathMapFile);
                }

                archive.ReplaceFile(tempFileName, ARCHIVE_TERRAIN_FILE_PATH);
            }
            finally
            {
                if (File.Exists(tempFileName))
                {
                    File.Delete(tempFileName);
                }
            }
        }

        private static void MakeAllWalkableTerrainBuildable(PathMap pathMap)
        {
            for (var i = 0; i < pathMap.Width * pathMap.Height; ++i)
            {
                PathType pt = pathMap[i];
                if (pt.HasFlag(PathType.NotBuildable) && !pt.HasFlag(PathType.NotWalkable))
                {
                    pt = pt.ClearFlag(PathType.NotBuildable);
                    pathMap[i] = pt;
                }
            }
        }
    }
}