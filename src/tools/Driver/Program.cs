using System;
using System.IO;
using War3.Net.Data;

namespace Driver
{
    class Program
    {
        static void Main(string[] args)
        {
            DoWork();
        }

        enum ObjectTypes
        {
            Unit,
            Item,
            Destructable,
            Doodad,
            Ability,
            Buff,
            Upgrade
        }

        /*
         *
        enum ObjectTypes
        {
            Unit,
            Item,
            Destructable,
            Doodad,
            Ability,
            Buff,
            Upgrade
        }
         * */

        private static void DoWork()
        {
            var entityLibrary = new EntityLibrary();
            var entityFiles = new CustomEntityFile[7];
            var invalidHasEntryPositions = new long[7];

            using (var w3oFile = File.OpenRead("D:\\Projects\\WarcraftIII\\TheLastStand\\_build\\objectEditingOutput\\wurstCreatedObjects.w3o"))
            using (var w3oFileReader = new BinaryReader(w3oFile))
            {
                var version = w3oFileReader.ReadInt32();

                for (var i = 0; i < 7; ++i)
                {
                    if (version < 1 && i == (int)ObjectTypes.Buff)
                        continue;

                    var pos = w3oFileReader.BaseStream.Position;
                    var hasEntry = w3oFileReader.ReadUInt32();
                    if (hasEntry != 0)
                    {
                        if (w3oFileReader.BaseStream.Position == w3oFileReader.BaseStream.Length || w3oFileReader.PeekChar() == 1)
                        {
                            invalidHasEntryPositions[i] = pos;
                            continue;
                        }

                        Func<int, bool> extraInfo = (int v) => i == (int)ObjectTypes.Ability || i == (int)ObjectTypes.Upgrade || (i == (int)ObjectTypes.Doodad && v >= 2);
                        var deserializer = new CustomEntityFileBinaryDeserializer(entityLibrary) { ReadExtraInfo = extraInfo };
                        entityFiles[i] = deserializer.Deserialize(w3oFileReader);
                    }
                }
            }

            using (var w3oFile = File.OpenWrite("D:\\Projects\\WarcraftIII\\TheLastStand\\_build\\objectEditingOutput\\wurstCreatedObjects.w3o"))
            using (var w3oFileWriter = new BinaryWriter(w3oFile))
            {
                for (var i = 0; i < 7; ++i)
                {
                    if (entityFiles[i] == null)
                    {
                        w3oFileWriter.Seek((int)invalidHasEntryPositions[i], SeekOrigin.Begin);
                        w3oFileWriter.Write((uint)0);
                    }
                }
            }

        }
    }
}
