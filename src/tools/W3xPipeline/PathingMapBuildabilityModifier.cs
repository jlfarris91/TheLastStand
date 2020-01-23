namespace W3xPipeline
{
    using System.IO;
    using StormLibSharp;
    using War3.Net;

    public class PathingMapBuildabilityModifier : IPipelineObject
    {
        private const string ARCHIVE_TERRAIN_FILE_PATH = "war3map.wpm";

        public void DoWork(MpqArchive archive)
        {
            string tempFileName = Path.GetTempFileName();

            try
            {
                PathingMap pathingMap;

                using (MpqFileStream file = archive.OpenFile(ARCHIVE_TERRAIN_FILE_PATH))
                using (var reader = new BinaryReader(file))
                {
                    pathingMap = new PathingMapDeserializer().Deserialize(reader);
                }

                MakeAllWalkableTerrainBuildable(pathingMap);

                using (Stream file = File.Create(tempFileName))
                using (var writer = new BinaryWriter(file))
                {
                    new PathingMapSerializer().Serialize(writer, pathingMap);
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

        private static void MakeAllWalkableTerrainBuildable(PathingMap pathingMap)
        {
            for (var i = 0; i < pathingMap.Width * pathingMap.Height; ++i)
            {
                PathingType pt = pathingMap[i];
                if (pt.HasFlag(PathingType.NotBuildable) && !pt.HasFlag(PathingType.NotWalkable))
                {
                    pt = pt.ClearFlag(PathingType.NotBuildable);
                    pathingMap[i] = pt;
                }
            }
        }
    }
}