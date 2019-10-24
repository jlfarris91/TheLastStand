namespace W3xPipeline
{
    using System;

    [Flags]
    public enum PathingType : byte
    {
        None = 0x0,
        Unused1 = 1 << 0,
        NotWalkable = 1 << 1,
        NotFlyable = 1 << 2,
        NotBuildable = 1 << 3,
        Unused2 = 1 << 4,
        Blighted = 1 << 5,
        NotWater = 1 << 6,
        NotAmphibious = 1 << 7
    }
}