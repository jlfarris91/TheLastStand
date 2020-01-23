namespace W3xPipeline
{
    using System;
    using System.Collections;
    using System.Collections.Generic;
    using System.Linq;
    using System.Numerics;
    using War3.Net;

    public class PathingMap : IEnumerable<GridCell>
    {
        private const int PIXELS_PER_CELL = 32;
        private readonly PathingType[] m_pathingData;
        private readonly int[] m_islands;

        public PathingMap(int width, int height)
        {
            Width = width;
            Height = height;
            m_pathingData = new PathingType[Width * Height];
            m_islands = Enumerable.Repeat(-1, width * height).ToArray();
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
            get => this[GetIndex(row, column)];
            set => this[GetIndex(row, column)] = value;
        }

        public PathingType this[GridCell cell]
        {
            get => this[GetIndex(cell.Row, cell.Column)];
            set => this[GetIndex(cell.Row, cell.Column)] = value;
        }

        public bool IsWalkable(int row, int column)
        {
            return !this[row, column].HasFlag(PathingType.NotWalkable);
        }

        public int GetIsland(int r, int c)
        {
            return m_islands[GetIndex(r, c)];
        }

        public void SetIsland(int r, int c, int id)
        {
            m_islands[GetIndex(r, c)] = id;
        }

        public int GetIndex(int row, int column)
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

        public IEnumerable<GridCell> GetNeighboringCells(GridCell cell)
        {
            if (cell.Column < Width - 1)    yield return new GridCell(cell.Row, cell.Column + 1);
            if (cell.Row > 0)               yield return new GridCell(cell.Row - 1, cell.Column);
            if (cell.Column > 0)            yield return new GridCell(cell.Row, cell.Column - 1);
            if (cell.Row < Height - 1)      yield return new GridCell(cell.Row + 1, cell.Column);
        }

        public int LocalToCell(Vector2 localPos)
        {
            var c = (int)Math.Floor(localPos.X / PIXELS_PER_CELL);
            var r = (int)Math.Floor(localPos.Y / PIXELS_PER_CELL);
            return GetIndex(r, c);
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

        public Rect GetCellLocalBounds(int index)
        {
            int r = GetRow(index);
            int c = GetColumn(index);
            return new Rect
            {
                Min = new Vector2(c * PIXELS_PER_CELL, r * PIXELS_PER_CELL),
                Max = new Vector2((c + 1) * PIXELS_PER_CELL, (r + 1) * PIXELS_PER_CELL)
            };
        }

        public Rect GetCellWorldBounds(int index)
        {
            int r = GetRow(index);
            int c = GetColumn(index);
            return new Rect
            {
                Min = LocalToWorld(new Vector2(c * PIXELS_PER_CELL, r * PIXELS_PER_CELL)),
                Max = LocalToWorld(new Vector2((c + 1) * PIXELS_PER_CELL, (r + 1) * PIXELS_PER_CELL))
            };
        }

        private void ThrowIfIndexIsOutOfRange(int index)
        {
            ThrowIf.ArgumentIsOutOfRange(index, 0, Width * Height - 1, nameof(index));
        }

        public IEnumerator<GridCell> GetEnumerator()
        {
            for (var i = 0; i < Width * Height; ++i)
            {
                yield return new GridCell(GetRow(i), GetColumn(i));
            }
        }

        IEnumerator IEnumerable.GetEnumerator()
        {
            return GetEnumerator();
        }
    }
}