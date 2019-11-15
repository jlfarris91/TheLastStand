namespace W3xPipeline
{
    using System;
    using System.IO;
    using WorldEditor.Common;

    public class UnitPlacementsFileSerializer
    {
        public void Serialize(BinaryWriter writer, UnitPlacements file)
        {
            writer.WriteTag(file.Tag);
            writer.Write(file.Version);
            writer.Write(file.SubVersion);

            writer.Write(file.Placements?.Count ?? 0);
            if (file.Placements != null)
            {
                foreach (UnitPlacement placement in file.Placements)
                {
                    SerializeUnitPlacement(writer, placement);
                }
            }
        }

        private void SerializeUnitPlacement(BinaryWriter writer, UnitPlacement unit)
        {
            writer.WriteTag(unit.Id);
            writer.Write(unit.Variation);
            writer.Write(unit.Position);
            writer.Write(unit.Rotation);
            writer.Write(unit.Scale);
            writer.Write(unit.Flags);
            writer.Write(unit.PlayerId);
            writer.Write(unit.Unknown1);
            writer.Write(unit.Unknown2);
            writer.Write(unit.Health);
            writer.Write(unit.Mana);
            writer.Write(unit.ItemTablePointer);

            writer.Write(unit.ItemSets?.Count ?? 0);
            if (unit.ItemSets != null)
            {
                foreach (ItemSet itemSet in unit.ItemSets)
                {
                    writer.WriteTag(itemSet.ItemId);
                    writer.Write(itemSet.DropChance);
                }
            }

            writer.Write(unit.Gold);
            writer.Write(unit.TargetAcquisition);
            writer.Write(unit.HeroLevel);
            writer.Write(unit.Strength);
            writer.Write(unit.Agility);
            writer.Write(unit.Intelligence);

            writer.Write(unit.InventoryItems?.Count ?? 0);
            if (unit.InventoryItems != null)
            {
                foreach (InventoryItemSlot itemSlot in unit.InventoryItems)
                {
                    writer.Write(itemSlot.SlotIndex);
                    writer.WriteTag(itemSlot.ItemId);
                }
            }

            writer.Write(unit.ModifiedAbilities?.Count ?? 0);
            if (unit.ModifiedAbilities != null)
            {
                foreach (ModifiedAbility modifiedAbility in unit.ModifiedAbilities)
                {
                    writer.WriteTag(modifiedAbility.AbilityId);
                    writer.Write(modifiedAbility.AutocastActive ? 1 : 0);
                    writer.Write(modifiedAbility.AbilityLevel);
                }
            }

            writer.Write(unit.PlacementType);

            PlacementTypeData placementTypeData = unit.PlacementTypeData;

            switch (unit.PlacementType)
            {
                case PlacementType.NeutralBuildingOrItem:
                    int itemLevelAndClass = (placementTypeData.ItemClass << 24) | placementTypeData.ItemLevel;
                    writer.Write(itemLevelAndClass);
                    break;

                case PlacementType.RandomUnitRandomGroup:
                    writer.Write(placementTypeData.UnitGroupTableIndex);
                    writer.Write(placementTypeData.UnitGroupPosition);
                    break;

                case PlacementType.RandomUnitCustomTable:

                    writer.Write(placementTypeData.CustomTableUnits?.Count ?? 0);
                    if (placementTypeData.CustomTableUnits != null)
                    {
                        foreach (CustomTableEntry entry in placementTypeData.CustomTableUnits)
                        {
                            writer.WriteTag(entry.UnitId);
                            writer.Write(entry.ChoiceChance);
                        }
                    }
                    break;

                default:
                    throw new ArgumentOutOfRangeException();
            }

            writer.Write(unit.CustomColor);
            writer.Write(unit.WaygateDestinationNumber);
            writer.Write(unit.CreationNumber);
        }
    }
}