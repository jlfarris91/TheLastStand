namespace W3xPipeline
{
    using System;

    public class PathingMap
    {
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
}