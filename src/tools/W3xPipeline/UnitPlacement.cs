namespace W3xPipeline
{
    using System.Collections.Generic;
    using System.Numerics;
    using WorldEditor.Common;

    public class UnitPlacement
    {
        public Tag Id { get; set; }
        public int Variation { get; set; }
        public Vector3 Position { get; set; }
        public float Rotation { get; set; }
        public Vector3 Scale { get; set; }
        public UnitPlacementFlags Flags { get; set; }
        public int PlayerId { get; set; }
        public byte Unknown1 { get; set; }
        public byte Unknown2 { get; set; }
        public int Health { get; set; }
        public int Mana { get; set; }
        public int ItemTablePointer { get; set; }
        public IList<ItemSet> ItemSets { get; set; }
        public int Gold { get; set; }
        public float TargetAcquisition { get; set; }
        public int HeroLevel { get; set; }
        public int Strength { get; set; }
        public int Agility { get; set; }
        public int Intelligence { get; set; }
        public IList<InventoryItemSlot> InventoryItems { get; set; }
        public IList<ModifiedAbility> ModifiedAbilities { get; set; }
        public PlacementType PlacementType { get; set; }
        public PlacementTypeData PlacementTypeData { get; set; }
        public int CustomColor { get; set; }
        public int WaygateDestinationNumber { get; set; }
        public int CreationNumber { get; set; }
    }
}