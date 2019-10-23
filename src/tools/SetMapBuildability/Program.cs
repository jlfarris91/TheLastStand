namespace SetMapBuildability
{
    using System;
    using System.IO;
    using StormLib.Net;
    using WorldEditor.Common;

    class Program
    {
        static int Main(string[] args)
        {
            const string archivedName = "war3map.wpm";

            string mapName = args[0];

            string tempFileName = Path.GetTempFileName();

            try
            {
                using (MpqArchive archive = MpqArchive.Load(mapName, FileAccess.ReadWrite))
                {
                    PathingMap pathingMap;

                    using (MpqFileStream file = archive.OpenFile(archivedName))
                    using (var reader = new BinaryReader(file))
                    {
                        pathingMap = new PathingMapDeserializer().Deserialize(reader);
                    }

                    for (var i = 0; i < pathingMap.Width * pathingMap.Height; ++i)
                    {
                        PathingType pt = pathingMap[i];
                        if (pt.HasFlag(PathingType.NotBuildable) && !pt.HasFlag(PathingType.NotWalkable))
                        {
                            pt = pt.ClearFlag(PathingType.NotBuildable);
                            pathingMap[i] = pt;
                        }
                    }

                    using (Stream file = File.Create(tempFileName))
                    using (var writer = new BinaryWriter(file))
                    {
                        new PathingMapSerializer().Serialize(writer, pathingMap);
                    }

                    archive.ReplaceFile(tempFileName, archivedName);
                    archive.Flush();
                }
            }
            catch (Exception ex)
            {
                Console.WriteLine("Failed: " + ex.Message);
                Environment.Exit(-1);
            }
            finally
            {
                if (File.Exists(tempFileName))
                {
                    File.Delete(tempFileName);
                }
            }

            return 0;
        }
    }

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

            var pathingMap = new PathingMap(version, width, height);

            for (var i = 0; i < width * height; ++i)
            {
                pathingMap[i] = (PathingType)reader.ReadByte();
            }

            return pathingMap;
        }
    }

    public class PathingMap
    {
        private readonly PathingType[] m_pathingData;

        public PathingMap(int version, int width, int height)
        {
            Version = version;
            Width = width;
            Height = height;
            m_pathingData = new PathingType[Width * Height];
        }

        public int Version { get; }

        public int Width { get; }

        public int Height { get; }

        public PathingType this[int index]
        {
            get
            {
                ThrowIfIndexIsOutOfRange(index);
                return m_pathingData[index];
            }

            set
            {
                ThrowIfIndexIsOutOfRange(index);
                m_pathingData[index] = value;
            }
        }

        public PathingType this[int row, int column]
        {
            get => this[CellToIndex(row, column)];
            set => this[CellToIndex(row, column)] = value;
        }

        private int CellToIndex(int row, int column)
        {
            if (row < 0 || row >= Height)
            {
                throw new ArgumentOutOfRangeException(nameof(row), row, $"Argument {nameof(row)} is out of bounds.");
            }

            if (column < 0 || column >= Width)
            {
                throw new ArgumentOutOfRangeException(nameof(column), column, $"Argument {nameof(column)} is out of bounds.");
            }

            return row * Width + column;
        }

        private void ThrowIfIndexIsOutOfRange(int index)
        {
            if (index < 0 || index >= Width * Height)
            {
                throw new ArgumentOutOfRangeException(nameof(index), index, $"Argument {nameof(index)} is out of bounds.");
            }
        }
    }

    [Flags]
    public enum PathingType : byte
    {
        None = 0x0,
        Unused1 = 1 << 0,
        NotWalkable = 1 << 1,
        NotFlyable = 1 << 2,
        NotBuildable = 1 << 3,
        Unused2 = 1 << 4,
        Blighted = 1 << 5,
        NotWater = 1 << 6,
        NotAmphibious = 1 << 7
    }
}
