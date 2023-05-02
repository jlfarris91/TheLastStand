using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;

namespace Driver
{
    class Program
    {
        static void Main(string[] args)
        {
            DoWork();
        }

        private static void DoWork()
        {

            var eventMapTemplateDirs = Directory.EnumerateDirectories(@"D:\Projects\WarcraftIII\TheLastStand\maps\MapEventTemplates")
                .Where(dir => Path.GetExtension(dir) == ".w3x")
                .ToArray();


            foreach (var mapEventTemplateMapDir in eventMapTemplateDirs)
            {
                var mapEventTemplateMapDirInfo = new DirectoryInfo(mapEventTemplateMapDir);
            }

        }
    }
}
