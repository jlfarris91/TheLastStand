namespace W3xPipeline
{
    using System.Collections.Generic;

    public static class QuadTreeExtensions
    {
        public static IEnumerable<QuadTreeNode<T>> GetAllNodes<T>(this QuadTreeNode<T> parent)
        {
            if (parent == null)
            {
                yield break;
            }

            yield return parent;
            
            foreach (QuadTreeNode<T> child in parent)
            {
                foreach (QuadTreeNode<T> childChild in child.GetAllNodes())
                {
                    yield return childChild;
                }
            }
        }
    }
}