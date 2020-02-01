namespace W3xPipeline
{
    using System.Collections.Generic;

    public class PlacementTypeData
    {
        public PlacementTypeData()
        {
            ItemLevel = 1;
            CustomTableUnits = new List<CustomTableEntry>();
        }

        public int ItemLevel { get; set; }
        public int ItemClass { get; set; }
        public int UnitGroupTableIndex { get; set; }
        public int UnitGroupPosition { get; set; }
        public IList<CustomTableEntry> CustomTableUnits { get; set; }
    }
}