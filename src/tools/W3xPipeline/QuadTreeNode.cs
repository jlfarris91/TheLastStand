namespace W3xPipeline
{
    using System.Collections;
    using System.Collections.Generic;
    using System.Numerics;

    public class QuadTreeNode<T> : IEnumerable<QuadTreeNode<T>>
    {
        private readonly QuadTreeNode<T>[] m_children = new QuadTreeNode<T>[4];

        public QuadTreeNode(QuadTreeNode<T> parent, Vector2 min, Vector2 max)
        {
            Parent = parent;
            Min = min;
            Max = max;
        }

        public QuadTreeNode<T> Parent { get; }

        public T Data { get; set; }

        public Vector2 Min { get; }

        public Vector2 Max { get; }

        public bool IsLeaf
        {
            get
            {
                return m_children[0] == null &&
                       m_children[1] == null &&
                       m_children[2] == null &&
                       m_children[3] == null;
            }
        }

        public QuadTreeNode<T> this[QuadTreeChild index]
        {
            get => m_children[(int)index];
            set => m_children[(int)index] = value;
        }

        public IEnumerator<QuadTreeNode<T>> GetEnumerator()
        {
            yield return m_children[0];
            yield return m_children[1];
            yield return m_children[2];
            yield return m_children[3];
        }

        IEnumerator IEnumerable.GetEnumerator()
        {
            return GetEnumerator();
        }
    }
}