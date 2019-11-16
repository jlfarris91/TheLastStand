namespace W3xPipeline
{
    using System.Collections.Generic;

    public struct PlacementTypeData
    {
        public int ItemLevel { get; set; }
        public int ItemClass { get; set; }
        public int UnitGroupTableIndex { get; set; }
        public int UnitGroupPosition { get; set; }
        public IList<CustomTableEntry> CustomTableUnits { get; set; }
    }
}