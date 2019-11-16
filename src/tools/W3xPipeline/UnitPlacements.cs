namespace W3xPipeline
{
    using System.Collections.Generic;
    using WorldEditor.Common;

    public class UnitPlacements
    {
        public Tag Tag { get; set; }
        public int Version { get; set; }
        public int SubVersion { get; set; }
        public IList<UnitPlacement> Placements { get; set; }
    }
}