namespace Driver
{
    using System.ComponentModel;
    using System.Diagnostics;
    using System.IO;
    using System.Text;
    using StormLibSharp;
    using War3.Net.IO;

    class Program
    {
        static void Main(string[] args)
        {
            string path1 = @"C:\Users\jlfar\OneDrive\Documents\Warcraft III\Maps\TheLastStand.w3x";
            string path2 = @"C:\Users\jlfar\OneDrive\Documents\Warcraft III\Maps\TheLastStandv0.1.71.w3x";

            DoWork(path1, "war3map.j");
            DoWork(path2, "war3mapv0.1.71.j");
        }

        private static void DoWork(string path, string outputPath)
        {
            using (var archive = new MpqArchive(path, FileAccess.Read))
            using (MpqFileStream asd = archive.OpenFile("war3map.j"))
            using (var reader = new BinaryReader(asd))
            {
                byte[] allBytes = reader.ReadAllBytes();
                string content = Encoding.Default.GetString(allBytes);
                File.WriteAllText(outputPath, content);
            }
        }
    }
}
