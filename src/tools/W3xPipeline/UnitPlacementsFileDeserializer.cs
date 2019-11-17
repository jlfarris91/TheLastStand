namespace W3xPipeline
{
    using System;
    using System.Collections.Generic;
    using System.IO;
    using WorldEditor.Common;

    public class UnitPlacementsFileDeserializer
    {
        private static readonly Tag Tag = Tag.FromString("W3do");

        public UnitPlacements Deserialize(BinaryReader reader)
        {
            var file = new UnitPlacements
            {
                Tag = reader.ReadTag(Tag),
                Version = reader.ReadInt32(),
                SubVersion = reader.ReadInt32()
            };

            int numberOfUnits = reader.ReadInt32();
            var list = new List<UnitPlacement>();

            for (var i = 0; i < numberOfUnits; ++i)
            {
                list.Add(ReadUnitPlacement(reader));
            }

            file.Placements = list;

            return file;
        }

        private UnitPlacement ReadUnitPlacement(BinaryReader reader)
        {
            var unit = new UnitPlacement
            {
                Id = reader.ReadTag(),
                Variation = reader.ReadInt32(),
                Position = reader.ReadVector3(),
                Rotation = reader.ReadSingle(),
                Scale = reader.ReadVector3(),
                Flags = reader.Read<UnitPlacementFlags>(),
                PlayerId = reader.ReadInt32(),
                Unknown1 = reader.ReadByte(),
                Unknown2 = reader.ReadByte(),
                Health = reader.ReadInt32(),
                Mana = reader.ReadInt32(),
                ItemTablePointer = reader.ReadInt32(),
            };

            unit.ItemSets = new List<ItemSet>();

            int numberOfItemSets = reader.ReadInt32();
            for (var i = 0; i < numberOfItemSets; ++i)
            {
                unit.ItemSets.Add(new ItemSet
                {
                    ItemId = reader.ReadTag(),
                    DropChance = reader.ReadInt32()
                });
            }

            unit.Gold = reader.ReadInt32();
            unit.TargetAcquisition = reader.ReadSingle();
            unit.HeroLevel = reader.ReadInt32();
            unit.Strength = reader.ReadInt32();
            unit.Agility = reader.ReadInt32();
            unit.Intelligence = reader.ReadInt32();

            unit.InventoryItems = new List<InventoryItemSlot>();

            int numberOfInventorySlots = reader.ReadInt32();
            for (var i = 0; i < numberOfInventorySlots; ++i)
            {
                unit.InventoryItems.Add(new InventoryItemSlot
                {
                    SlotIndex = reader.ReadInt32(),
                    ItemId = reader.ReadTag()
                });
            }

            unit.ModifiedAbilities = new List<ModifiedAbility>();

            int numberOfModifiedAbilities = reader.ReadInt32();
            for (var i = 0; i < numberOfModifiedAbilities; ++i)
            {
                unit.ModifiedAbilities.Add(new ModifiedAbility
                {
                    AbilityId = reader.ReadTag(),
                    AutocastActive = reader.ReadInt32() != 0,
                    AbilityLevel = reader.ReadInt32()
                });
            }

            unit.PlacementType = reader.Read<PlacementType>();
            var placementTypeData = new PlacementTypeData();

            switch (unit.PlacementType)
            {
                case PlacementType.NeutralBuildingOrItem:
                    int itemLevelAndClass = reader.ReadInt32();
                    placementTypeData.ItemLevel = itemLevelAndClass & 0xFFFFFF;
                    placementTypeData.ItemClass = itemLevelAndClass >> 24;
                    break;

                case PlacementType.RandomUnitRandomGroup:
                    placementTypeData.UnitGroupTableIndex = reader.ReadInt32();
                    placementTypeData.UnitGroupPosition = reader.ReadInt32();
                    break;

                case PlacementType.RandomUnitCustomTable:
                    placementTypeData.CustomTableUnits = new List<CustomTableEntry>();
                    int numberOfAvailableUnits = reader.ReadInt32();
                    for (var i = 0; i < numberOfAvailableUnits; ++i)
                    {
                        placementTypeData.CustomTableUnits.Add(
                            new CustomTableEntry
                            {
                                UnitId = reader.ReadTag(),
                                ChoiceChance = reader.ReadInt32()
                            });
                    }
                    break;

                default:
                    throw new ArgumentOutOfRangeException();
            }

            unit.PlacementTypeData = placementTypeData;

            unit.CustomColor = reader.ReadInt32();
            unit.WaygateRegionId = reader.ReadInt32();
            unit.CreationNumber = reader.ReadInt32();

            return unit;
        }
    }
}