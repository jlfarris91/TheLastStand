using System.Collections.Generic;

namespace W3xPipeline
{
    using System.IO;
    using WorldEditor.Common;

    public class MapRegions
    {
        public int Version { get; set; }
        public IList<Region> Regions { get; set; }
    }

    public struct Bounds
    {
        public float Left { get; set; }
        public float Bottom { get; set; }
        public float Right { get; set; }
        public float Top { get; set; }
    }

    public class Region
    {
        public string Name { get; set; }
        public int Id { get; set; }
        public Bounds Bounds { get; set; }
        public Tag WeatherEffect { get; set; }
        public string AmbientSound { get; set; }
        public Color Color { get; set; }
    }

    public class MapRegionsBinaryDeserializer
    {
        public MapRegions Deserialize(BinaryReader reader)
        {
            var mapRegions = new MapRegions();

            mapRegions.Version = reader.ReadInt32();

            int numberOfRegions = reader.ReadInt32();
            for (var i = 0; i < numberOfRegions; ++i)
            {
                mapRegions.Regions.Add(DeserializeRegion(reader));
            }

            return mapRegions;
        }

        private Region DeserializeRegion(BinaryReader reader)
        {
            var region = new Region();

            Bounds bounds = new Bounds();
            bounds.Left = reader.ReadSingle();
            bounds.Bottom = reader.ReadSingle();
            bounds.Right = reader.ReadSingle();
            bounds.Top = reader.ReadSingle();

            region.Bounds = bounds;

            region.Name = reader.ReadString();
            region.Id = reader.ReadInt32();
            region.WeatherEffect = reader.ReadTag();
            region.AmbientSound = reader.ReadString();
            region.Color = reader.ReadColorBgr();

            reader.ReadByte();

            return region;
        }
    }

    public class MapRegionsBinarySerializer
    {
        public void Serialize(BinaryWriter writer, MapRegions mapRegions)
        {
            writer.Write(mapRegions.Version);

            writer.Write(mapRegions.Regions?.Count ?? 0);
            if (mapRegions.Regions != null)
            {
                foreach (Region region in mapRegions.Regions)
                {
                    SerializeRegion(writer, region);
                }
            }
        }

        private Region SerializeRegion(BinaryWriter writer, Region region)
        {
            Bounds bounds = region.Bounds;

            writer.Write(bounds.Left);
            writer.Write(bounds.Bottom);
            writer.Write(bounds.Right);
            writer.Write(bounds.Top);
            writer.Write(region.Name);
            writer.Write(region.Id);
            writer.WriteTag(region.WeatherEffect);
            writer.Write(region.AmbientSound);
            writer.WriteColorBgr(region.Color);
            writer.Write((byte)0);

            return region;
        }
    }
}
