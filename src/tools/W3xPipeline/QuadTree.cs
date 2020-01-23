namespace W3xPipeline
{
    using System.Numerics;

    public class QuadTree<T> : QuadTreeNode<T>
    {
        public QuadTree(Vector2 min, Vector2 max)
            : base(null, min, max)
        {
        }
    }
}