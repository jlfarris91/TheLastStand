namespace W3xPipeline
{
    using System;
    using System.IO;
    using War3.Net;
    using War3.Net.IO;

    public class RecordReferencedWindowsFileSystem : IFileSystem
    {
        private readonly DirectoryInfo m_root;
        private readonly Action<string> m_recordReferencedPath;

        public RecordReferencedWindowsFileSystem(DirectoryInfo root, Action<string> recordReferencedPath)
        {
            ThrowIf.ArgumentIsNull(root, nameof(root));
            ThrowIf.ArgumentIsNull(recordReferencedPath, nameof(recordReferencedPath));

            if (!root.Exists)
            {
                throw new DirectoryNotFoundException($"Directory '{root.FullName}' for file system does not exist");
            }

            m_root = root;
            m_recordReferencedPath = recordReferencedPath;
        }

        public Stream Create(string path)
        {
            RecordReferencePath(path);
            return File.Create(MakeAbsolutePath(path));
        }

        public Stream OpenRead(string path)
        {
            RecordReferencePath(path);
            return File.OpenRead(MakeAbsolutePath(path));
        }

        public Stream OpenWrite(string path)
        {
            RecordReferencePath(path);
            return File.OpenWrite(MakeAbsolutePath(path));
        }

        public bool Exists(string path)
        {
            RecordReferencePath(path);
            return File.Exists(MakeAbsolutePath(path));
        }

        public void Delete(string path)
        {
            RecordReferencePath(path);
            File.Delete(MakeAbsolutePath(path));
        }

        public void Copy(string sourcePath, string destinationPath)
        {
            File.Copy(MakeAbsolutePath(sourcePath), MakeAbsolutePath(destinationPath));
        }

        private string MakeAbsolutePath(string relativePath)
        {
            return Path.Combine(m_root.FullName, relativePath);
        }

        private void RecordReferencePath(string relativePath)
        {
            string absolutePath = MakeAbsolutePath(relativePath);
            if (File.Exists(absolutePath))
            {
                m_recordReferencedPath(absolutePath);
            }
        }
    }
}