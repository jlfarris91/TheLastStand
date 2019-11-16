namespace W3xPipeline
{
    using System;
    using System.Numerics;
    using WorldEditor.Common;

    public class PathingMap
    {
        private const int PIXELS_PER_CELL = 32;
        private readonly PathingType[] m_pathingData;

        public PathingMap(int width, int height)
        {
            Width = width;
            Height = height;
            m_pathingData = new PathingType[Width * Height];
        }

        public int Version { get; set; }

        public int Width { get; }

        public int Height { get; }

        public int CellSize
        {
            get => PIXELS_PER_CELL;
        }

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
            get => this[GetCell(row, column)];
            set => this[GetCell(row, column)] = value;
        }

        public int GetCell(int row, int column)
        {
            ThrowIf.ArgumentIsOutOfRange(row, 0, Height - 1, nameof(row));
            ThrowIf.ArgumentIsOutOfRange(column, 0, Width - 1, nameof(column));
            return row * Width + column;
        }

        public int GetRow(int index)
        {
            ThrowIfIndexIsOutOfRange(index);
            return index / Width;
        }

        public int GetColumn(int index)
        {
            ThrowIfIndexIsOutOfRange(index);
            return index % Width;
        }

        public int LocalToCell(Vector2 localPos)
        {
            var c = (int)Math.Floor(localPos.X / PIXELS_PER_CELL);
            var r = (int)Math.Floor(localPos.Y / PIXELS_PER_CELL);
            return GetCell(r, c);
        }

        public int WorldToCell(Vector2 worldPos)
        {
            return LocalToCell(WorldToLocal(worldPos));
        }

        public PathingType SampleLocal(Vector2 localPos)
        {
            return this[LocalToCell(localPos)];
        }

        public PathingType SampleWorld(Vector2 worldPos)
        {
            return SampleLocal(WorldToLocal(worldPos));
        }

        public Vector2 LocalToWorld(Vector2 localPos)
        {
            return localPos - new Vector2(Width, Height) * 0.5f * PIXELS_PER_CELL;
        }

        public Vector2 WorldToLocal(Vector2 worldPos)
        {
            return worldPos + new Vector2(Width, Height) * 0.5f * PIXELS_PER_CELL;
        }

        private void ThrowIfIndexIsOutOfRange(int index)
        {
            ThrowIf.ArgumentIsOutOfRange(index, 0, Width * Height - 1, nameof(index));
        }
    }
}