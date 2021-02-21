globals
    // Generated
rect gg_rct_BaseUnits= null
rect gg_rct_debugSurvivorSpawn= null
sound gg_snd_GyrocopterImpactHit2= null
string gg_snd_Undead1
string gg_snd_Undead2
string gg_snd_Undead3
string gg_snd_UndeadDefeat
string gg_snd_UndeadVictory
string gg_snd_UndeadX1
sound gg_snd_QuestCompleted= null
sound gg_snd_RiflemanDeath= null
sound gg_snd_ZombieDeath1= null


//JASSHelper struct globals:

endglobals


//===========================================================================
// 
// The Last Stand v1.16
// 
//   Warcraft III map script
//   Generated by the Warcraft III World Editor
//   Map Author: Psykolambchopz
// 
//===========================================================================

//***************************************************************************
//*
//*  Global Variables
//*
//***************************************************************************


function InitGlobals takes nothing returns nothing
endfunction

//***************************************************************************
//*
//*  Custom Script Code
//*
//***************************************************************************

//***************************************************************************
//*
//*  Sound Assets
//*
//***************************************************************************

function InitSounds takes nothing returns nothing
    set gg_snd_GyrocopterImpactHit2=CreateSound("Units\\Human\\Gyrocopter\\GyrocopterImpactHit2.wav", false, true, true, 10, 10, "DefaultEAXON")
    call SetSoundDuration(gg_snd_GyrocopterImpactHit2, 891)
    call SetSoundChannel(gg_snd_GyrocopterImpactHit2, 5)
    call SetSoundVolume(gg_snd_GyrocopterImpactHit2, - 1)
    call SetSoundPitch(gg_snd_GyrocopterImpactHit2, 1.0)
    call SetSoundDistances(gg_snd_GyrocopterImpactHit2, 0.0, 10000.0)
    call SetSoundDistanceCutoff(gg_snd_GyrocopterImpactHit2, 3000.0)
    call SetSoundConeAngles(gg_snd_GyrocopterImpactHit2, 0.0, 0.0, 127)
    call SetSoundConeOrientation(gg_snd_GyrocopterImpactHit2, 0.0, 0.0, 0.0)
    set gg_snd_Undead1="Sound\\Music\\mp3Music\\Undead1.mp3"
    set gg_snd_Undead2="Sound\\Music\\mp3Music\\Undead2.mp3"
    set gg_snd_Undead3="Sound\\Music\\mp3Music\\Undead3.mp3"
    set gg_snd_UndeadDefeat="Sound\\Music\\mp3Music\\UndeadDefeat.mp3"
    set gg_snd_UndeadVictory="Sound\\Music\\mp3Music\\UndeadVictory.mp3"
    set gg_snd_UndeadX1="Sound\\Music\\mp3Music\\UndeadX1.mp3"
    set gg_snd_QuestCompleted=CreateSound("Sound\\Interface\\QuestCompleted.wav", false, false, false, 10, 10, "DefaultEAXON")
    call SetSoundDuration(gg_snd_QuestCompleted, 5154)
    call SetSoundChannel(gg_snd_QuestCompleted, 0)
    call SetSoundVolume(gg_snd_QuestCompleted, - 1)
    call SetSoundPitch(gg_snd_QuestCompleted, 1.0)
    set gg_snd_RiflemanDeath=CreateSound("Units\\Human\\Rifleman\\RiflemanDeath.wav", false, true, true, 10, 10, "DefaultEAXON")
    call SetSoundDuration(gg_snd_RiflemanDeath, 1770)
    call SetSoundChannel(gg_snd_RiflemanDeath, 0)
    call SetSoundVolume(gg_snd_RiflemanDeath, - 1)
    call SetSoundPitch(gg_snd_RiflemanDeath, 1.0)
    call SetSoundDistances(gg_snd_RiflemanDeath, 0.0, 10000.0)
    call SetSoundDistanceCutoff(gg_snd_RiflemanDeath, 3000.0)
    call SetSoundConeAngles(gg_snd_RiflemanDeath, 0.0, 0.0, 127)
    call SetSoundConeOrientation(gg_snd_RiflemanDeath, 0.0, 0.0, 0.0)
    set gg_snd_ZombieDeath1=CreateSound("Units\\Creeps\\Zombie\\ZombieDeath1.wav", false, true, true, 10, 10, "DefaultEAXON")
    call SetSoundDuration(gg_snd_ZombieDeath1, 1417)
    call SetSoundChannel(gg_snd_ZombieDeath1, 0)
    call SetSoundVolume(gg_snd_ZombieDeath1, - 1)
    call SetSoundPitch(gg_snd_ZombieDeath1, 1.0)
    call SetSoundDistances(gg_snd_ZombieDeath1, 0.0, 10000.0)
    call SetSoundDistanceCutoff(gg_snd_ZombieDeath1, 3000.0)
    call SetSoundConeAngles(gg_snd_ZombieDeath1, 0.0, 0.0, 127)
    call SetSoundConeOrientation(gg_snd_ZombieDeath1, 0.0, 0.0, 0.0)
endfunction

//***************************************************************************
//*
//*  Unit Creation
//*
//***************************************************************************

//===========================================================================
function CreateBuildingsForPlayer20 takes nothing returns nothing
    local player p= Player(20)
    local unit u
    local integer unitID
    local trigger t
    local real life

    set u=BlzCreateUnitWithSkin(p, 'h017', - 9634.8, 4327.1, 269.089, 'h017')
    set u=BlzCreateUnitWithSkin(p, 'h017', - 10637.3, 4711.9, 269.617, 'h017')
    set u=BlzCreateUnitWithSkin(p, 'h017', - 7760.8, 4291.8, 269.617, 'h017')
    set u=BlzCreateUnitWithSkin(p, 'h017', - 6783.4, 4517.1, 179.333, 'h017')
    set u=BlzCreateUnitWithSkin(p, 'h017', 846.9, - 4055.7, 1.267, 'h017')
    set u=BlzCreateUnitWithSkin(p, 'h017', 885.1, - 1004.7, 316.947, 'h017')
    set u=BlzCreateUnitWithSkin(p, 'h017', 1521.8, - 3586.3, 179.794, 'h017')
    set u=BlzCreateUnitWithSkin(p, 'h017', 7282.8, - 11604.4, 88.520, 'h017')
    set u=BlzCreateUnitWithSkin(p, 'h017', 6633.1, - 11618.1, 179.794, 'h017')
    set u=BlzCreateUnitWithSkin(p, 'h017', - 11021.1, - 8848.5, 61.344, 'h017')
    set u=BlzCreateUnitWithSkin(p, 'h017', 2169.5, - 3543.8, 212.820, 'h017')
    set u=BlzCreateUnitWithSkin(p, 'h017', - 236.5, - 2720.7, 268.946, 'h017')
    set u=BlzCreateUnitWithSkin(p, 'h017', 248.4, - 2318.9, 90.000, 'h017')
    set u=BlzCreateUnitWithSkin(p, 'h017', 3321.5, - 1651.8, 90.000, 'h017')
endfunction

//===========================================================================
function CreateUnitsForPlayer20 takes nothing returns nothing
    local player p= Player(20)
    local unit u
    local integer unitID
    local trigger t
    local real life

    set u=BlzCreateUnitWithSkin(p, 'h01L', 10722.9, - 5592.5, 84.897, 'h01L')
    set u=BlzCreateUnitWithSkin(p, 'h01L', 10348.9, - 6879.7, 174.455, 'h01L')
    set u=BlzCreateUnitWithSkin(p, 'h01L', 10174.3, - 11362.7, 80.444, 'h01L')
    set u=BlzCreateUnitWithSkin(p, 'h01K', 7708.7, - 8295.8, 87.223, 'h01K')
    set u=BlzCreateUnitWithSkin(p, 'h01U', 7600.8, - 8381.2, 316.039, 'h01U')
    set u=BlzCreateUnitWithSkin(p, 'h01K', 2059.3, - 8361.4, 58.471, 'h01K')
    set u=BlzCreateUnitWithSkin(p, 'h01J', - 7706.5, 5570.3, 269.378, 'h01J')
    set u=BlzCreateUnitWithSkin(p, 'h01J', - 10194.5, 5514.8, 0.000, 'h01J')
    set u=BlzCreateUnitWithSkin(p, 'h01J', 2815.9, - 1578.1, 312.557, 'h01J')
    set u=BlzCreateUnitWithSkin(p, 'h01H', - 10493.1, 9503.5, 261.389, 'h01H')
    set u=BlzCreateUnitWithSkin(p, 'h01M', - 7389.0, 9811.1, 270.000, 'h01M')
    set u=BlzCreateUnitWithSkin(p, 'h007', - 8258.4, 10164.4, 90.864, 'h007')
    set u=BlzCreateUnitWithSkin(p, 'h01L', - 3988.1, 9168.3, 259.656, 'h01L')
    set u=BlzCreateUnitWithSkin(p, 'h005', - 874.4, 10691.4, 314.280, 'h005')
    set u=BlzCreateUnitWithSkin(p, 'h005', 956.1, 10983.4, 292.961, 'h005')
    set u=BlzCreateUnitWithSkin(p, 'h01S', 1212.6, 11079.8, 261.547, 'h01S')
    set u=BlzCreateUnitWithSkin(p, 'h01L', - 3543.3, 4189.7, 270.000, 'h01L')
    set u=BlzCreateUnitWithSkin(p, 'h01J', 3491.9, 6650.9, 48.398, 'h01J')
    set u=BlzCreateUnitWithSkin(p, 'h01H', 4549.4, 5200.2, 270.000, 'h01H')
    set u=BlzCreateUnitWithSkin(p, 'h00B', 9173.4, - 1338.3, 270.239, 'h00B')
    set u=BlzCreateUnitWithSkin(p, 'h01T', 11016.0, - 6680.4, 216.021, 'h01T')
    set u=BlzCreateUnitWithSkin(p, 'h007', 10757.1, - 8012.3, 176.526, 'h007')
    set u=BlzCreateUnitWithSkin(p, 'h01A', 10876.8, - 7897.2, 8.438, 'h01A')
    set u=BlzCreateUnitWithSkin(p, 'h01A', 10832.8, - 7849.3, 259.131, 'h01A')
    set u=BlzCreateUnitWithSkin(p, 'h000', 10658.1, - 7500.0, 270.086, 'h000')
    set u=BlzCreateUnitWithSkin(p, 'h002', 8621.3, - 8918.8, 315.139, 'h002')
    set u=BlzCreateUnitWithSkin(p, 'h003', 8007.2, - 10501.1, 308.576, 'h003')
    set u=BlzCreateUnitWithSkin(p, 'h003', 9300.1, 4735.7, 269.873, 'h003')
    set u=BlzCreateUnitWithSkin(p, 'h006', 9595.6, 4509.6, 188.143, 'h006')
    set u=BlzCreateUnitWithSkin(p, 'h004', 9489.6, 4671.7, 232.538, 'h004')
    set u=BlzCreateUnitWithSkin(p, 'h008', 11180.8, 8650.5, 295.600, 'h008')
    set u=BlzCreateUnitWithSkin(p, 'h01A', 5922.8, 2722.5, 192.717, 'h01A')
    set u=BlzCreateUnitWithSkin(p, 'h013', 7952.5, 2878.0, 359.556, 'h013')
    set u=BlzCreateUnitWithSkin(p, 'h009', 8990.2, 4420.6, 318.637, 'h009')
    set u=BlzCreateUnitWithSkin(p, 'h00A', 8840.0, 6045.5, 207.168, 'h00A')
    set u=BlzCreateUnitWithSkin(p, 'h00B', 8611.5, 5579.1, 311.501, 'h00B')
    set u=BlzCreateUnitWithSkin(p, 'h01T', 7919.8, - 5204.1, 87.674, 'h01T')
    set u=BlzCreateUnitWithSkin(p, 'h00D', 6952.7, - 4407.1, 335.487, 'h00D')
    set u=BlzCreateUnitWithSkin(p, 'h01A', 7840.5, - 5143.7, 196.431, 'h01A')
    set u=BlzCreateUnitWithSkin(p, 'h00E', 7250.7, - 5580.9, 49.879, 'h00E')
    set u=BlzCreateUnitWithSkin(p, 'h00C', 8621.2, - 3660.6, 259.538, 'h00C')
    set u=BlzCreateUnitWithSkin(p, 'h01L', - 7840.0, - 4576.0, 270.000, 'h01L')
    set u=BlzCreateUnitWithSkin(p, 'h01K', - 7105.0, - 4588.6, 36.476, 'h01K')
    set u=BlzCreateUnitWithSkin(p, 'h00C', 9861.5, 7665.7, 208.836, 'h00C')
    set u=BlzCreateUnitWithSkin(p, 'h00F', - 3986.1, - 9693.3, 244.366, 'h00F')
    set u=BlzCreateUnitWithSkin(p, 'h00B', - 4943.2, - 8283.8, 317.505, 'h00B')
    set u=BlzCreateUnitWithSkin(p, 'h00B', - 9344.7, - 10848.1, 223.860, 'h00B')
    set u=BlzCreateUnitWithSkin(p, 'h01U', - 11286.5, - 10673.1, 251.740, 'h01U')
    set u=BlzCreateUnitWithSkin(p, 'h01A', - 11160.3, - 10700.9, 162.811, 'h01A')
    set u=BlzCreateUnitWithSkin(p, 'h01M', - 10978.9, - 6829.7, 62.280, 'h01M')
    set u=BlzCreateUnitWithSkin(p, 'h01T', - 8946.6, - 5560.0, 274.293, 'h01T')
    set u=BlzCreateUnitWithSkin(p, 'h01T', - 10748.7, - 4826.6, 355.934, 'h01T')
    set u=BlzCreateUnitWithSkin(p, 'h007', - 6686.4, - 1188.4, 87.959, 'h007')
    set u=BlzCreateUnitWithSkin(p, 'h003', - 6834.2, - 1158.2, 268.025, 'h003')
    set u=BlzCreateUnitWithSkin(p, 'h01K', - 6635.4, - 1331.5, 186.232, 'h01K')
    set u=BlzCreateUnitWithSkin(p, 'h01U', - 5698.8, 10286.6, 14.601, 'h01U')
    set u=BlzCreateUnitWithSkin(p, 'h01A', - 5797.1, 10309.8, 13.755, 'h01A')
    set u=BlzCreateUnitWithSkin(p, 'h01A', - 5771.6, 10256.7, 29.082, 'h01A')
    set u=BlzCreateUnitWithSkin(p, 'h00G', 1620.5, 1309.7, 1.717, 'h00G')
    set u=BlzCreateUnitWithSkin(p, 'h00C', 1464.0, 5549.4, 52.417, 'h00C')
    set u=BlzCreateUnitWithSkin(p, 'h00C', - 2057.1, 10002.9, 329.050, 'h00C')
    set u=BlzCreateUnitWithSkin(p, 'h01X', - 3042.9, - 10164.8, 0.394, 'h01X')
    set u=BlzCreateUnitWithSkin(p, 'h01J', 1663.7, - 4093.3, 0.000, 'h01J')
    set u=BlzCreateUnitWithSkin(p, 'h01J', 3319.0, - 2752.7, 90.000, 'h01J')
    set u=BlzCreateUnitWithSkin(p, 'h01J', - 10720.0, 8992.0, 270.000, 'h01J')
    set u=BlzCreateUnitWithSkin(p, 'h01J', - 1226.5, - 5776.7, 315.000, 'h01J')
    set u=BlzCreateUnitWithSkin(p, 'h01N', - 10658.1, - 2400.3, 270.000, 'h01N')
    set u=BlzCreateUnitWithSkin(p, 'h01H', - 11002.3, 1210.4, 38.031, 'h01H')
    set u=BlzCreateUnitWithSkin(p, 'h005', 4198.7, - 7309.4, 288.758, 'h005')
    set u=BlzCreateUnitWithSkin(p, 'h007', 4482.9, - 7427.5, 242.780, 'h007')
    set u=BlzCreateUnitWithSkin(p, 'h001', 1339.1, - 10026.5, 270.000, 'h001')
    set u=BlzCreateUnitWithSkin(p, 'h01V', - 8549.1, - 8683.0, 270.000, 'h01V')
    set u=BlzCreateUnitWithSkin(p, 'h007', - 7845.8, 6724.6, 8.734, 'h007')
    set u=BlzCreateUnitWithSkin(p, 'h01U', - 7829.0, 7464.5, 209.905, 'h01U')
    set u=BlzCreateUnitWithSkin(p, 'h006', - 9324.7, 6380.5, 270.124, 'h006')
    set u=BlzCreateUnitWithSkin(p, 'h003', - 9504.1, 6393.6, 274.448, 'h003')
    set u=BlzCreateUnitWithSkin(p, 'h01U', - 10106.6, 2413.1, 249.023, 'h01U')
    set u=BlzCreateUnitWithSkin(p, 'h01T', - 9535.0, 2413.0, 270.433, 'h01T')
    set u=BlzCreateUnitWithSkin(p, 'h009', - 6653.0, 2310.1, 357.648, 'h009')
    set u=BlzCreateUnitWithSkin(p, 'h00C', - 5686.0, 777.5, 264.366, 'h00C')
    set u=BlzCreateUnitWithSkin(p, 'h002', - 2374.9, 5052.9, 346.190, 'h002')
    set u=BlzCreateUnitWithSkin(p, 'h01U', - 1875.4, 5574.5, 261.130, 'h01U')
    set u=BlzCreateUnitWithSkin(p, 'h00E', - 1404.5, 5928.4, 342.995, 'h00E')
    set u=BlzCreateUnitWithSkin(p, 'h007', - 1865.5, 7813.9, 273.985, 'h007')
    set u=BlzCreateUnitWithSkin(p, 'h00F', 409.1, 7745.8, 271.824, 'h00F')
    set u=BlzCreateUnitWithSkin(p, 'h01L', 1509.5, 3236.3, 267.344, 'h01L')
    set u=BlzCreateUnitWithSkin(p, 'h00B', 4029.3, 4137.7, 267.665, 'h00B')
    set u=BlzCreateUnitWithSkin(p, 'h00A', - 1863.7, 1494.2, 125.469, 'h00A')
    set u=BlzCreateUnitWithSkin(p, 'h01U', - 3077.8, - 731.9, 203.580, 'h01U')
    set u=BlzCreateUnitWithSkin(p, 'h004', - 3235.3, - 659.8, 282.840, 'h004')
    set u=BlzCreateUnitWithSkin(p, 'h006', - 3391.7, - 766.3, 251.475, 'h006')
    set u=BlzCreateUnitWithSkin(p, 'h00B', - 5157.7, - 3435.2, 358.799, 'h00B')
    set u=BlzCreateUnitWithSkin(p, 'h009', 5722.5, - 1550.0, 316.833, 'h009')
    set u=BlzCreateUnitWithSkin(p, 'h007', - 3771.7, 9234.7, 241.256, 'h007')
    set u=BlzCreateUnitWithSkin(p, 'h01A', - 4122.2, 8974.0, 239.542, 'h01A')
    set u=BlzCreateUnitWithSkin(p, 'h01A', - 4126.2, 8920.9, 18.414, 'h01A')
    set u=BlzCreateUnitWithSkin(p, 'h00C', 5988.9, - 3649.4, 297.105, 'h00C')
    set u=BlzCreateUnitWithSkin(p, 'h01U', 9944.6, 1489.9, 185.620, 'h01U')
    set u=BlzCreateUnitWithSkin(p, 'h01T', 10014.0, 1533.2, 29.953, 'h01T')
    set u=BlzCreateUnitWithSkin(p, 'h01A', 3992.9, - 7532.5, 37.585, 'h01A')
    set u=BlzCreateUnitWithSkin(p, 'h01K', 9959.1, 3661.2, 245.792, 'h01K')
    set u=BlzCreateUnitWithSkin(p, 'h007', 9831.9, 3660.0, 358.373, 'h007')
    set u=BlzCreateUnitWithSkin(p, 'h01A', 9967.6, 3580.9, 28.895, 'h01A')
    set u=BlzCreateUnitWithSkin(p, 'h01N', 10799.1, 10774.0, 180.014, 'h01N')
    set u=BlzCreateUnitWithSkin(p, 'h01A', 3998.2, - 7467.6, 289.784, 'h01A')
    set u=BlzCreateUnitWithSkin(p, 'h00D', 6758.0, 6432.5, 255.710, 'h00D')
    set u=BlzCreateUnitWithSkin(p, 'h00C', 7175.8, 7947.0, 348.066, 'h00C')
    set u=BlzCreateUnitWithSkin(p, 'h01U', 10886.1, 5675.4, 217.966, 'h01U')
    set u=BlzCreateUnitWithSkin(p, 'h003', 10978.2, 5547.0, 218.485, 'h003')
    set u=BlzCreateUnitWithSkin(p, 'h001', 3356.4, - 10661.3, 129.170, 'h001')
    set u=BlzCreateUnitWithSkin(p, 'h001', - 1033.3, - 11485.7, 75.261, 'h001')
    set u=BlzCreateUnitWithSkin(p, 'h01N', - 10275.9, - 86.2, 229.428, 'h01N')
    set u=BlzCreateUnitWithSkin(p, 'h01U', - 8482.2, 282.9, 227.260, 'h01U')
    set u=BlzCreateUnitWithSkin(p, 'h01A', - 8365.1, 288.6, 349.519, 'h01A')
    set u=BlzCreateUnitWithSkin(p, 'h004', - 8624.6, 187.1, 322.441, 'h004')
    set u=BlzCreateUnitWithSkin(p, 'h001', - 11040.0, 1568.0, 358.412, 'h001')
    set u=BlzCreateUnitWithSkin(p, 'h01K', - 392.2, 4905.9, 100.462, 'h01K')
    set u=BlzCreateUnitWithSkin(p, 'h01L', 288.0, - 8480.0, 270.000, 'h01L')
    set u=BlzCreateUnitWithSkin(p, 'h007', 2179.5, - 8377.8, 236.311, 'h007')
    set u=BlzCreateUnitWithSkin(p, 'h01J', - 234.9, - 2102.9, 270.000, 'h01J')
    set u=BlzCreateUnitWithSkin(p, 'h01A', - 304.4, 4865.0, 327.985, 'h01A')
    set u=BlzCreateUnitWithSkin(p, 'h01A', - 363.2, 4828.1, 40.958, 'h01A')
    set u=BlzCreateUnitWithSkin(p, 'h001', 2465.8, 9156.5, 231.360, 'h001')
    set u=BlzCreateUnitWithSkin(p, 'h01S', - 4739.0, 10419.9, 220.390, 'h01S')
    set u=BlzCreateUnitWithSkin(p, 'h01A', 9638.1, 51.5, 312.032, 'h01A')
    set u=BlzCreateUnitWithSkin(p, 'h01A', 9687.3, 56.6, 302.331, 'h01A')
    set u=BlzCreateUnitWithSkin(p, 'h01K', 9672.6, - 24.3, 105.364, 'h01K')
    set u=BlzCreateUnitWithSkin(p, 'h01A', - 7239.7, - 4588.4, 1.384, 'h01A')
    set u=BlzCreateUnitWithSkin(p, 'h007', - 7184.4, - 4668.4, 279.369, 'h007')
    set u=BlzCreateUnitWithSkin(p, 'h01T', - 7938.6, - 4768.3, 248.002, 'h01T')
    set u=BlzCreateUnitWithSkin(p, 'h01U', - 4076.5, - 8517.5, 183.740, 'h01U')
    set u=BlzCreateUnitWithSkin(p, 'h007', - 4410.3, - 8505.8, 95.468, 'h007')
    set u=BlzCreateUnitWithSkin(p, 'h01A', - 4442.3, - 8393.3, 284.456, 'h01A')
    set u=BlzCreateUnitWithSkin(p, 'h005', - 11077.2, - 4520.5, 348.097, 'h005')
    set u=BlzCreateUnitWithSkin(p, 'h01T', - 6953.8, - 10538.6, 188.574, 'h01T')
    set u=BlzCreateUnitWithSkin(p, 'h01U', - 8660.5, - 8616.9, 281.770, 'h01U')
    set u=BlzCreateUnitWithSkin(p, 'h007', - 8129.3, - 10020.4, 216.693, 'h007')
    set u=BlzCreateUnitWithSkin(p, 'h01A', - 8206.2, - 10011.0, 95.265, 'h01A')
    set u=BlzCreateUnitWithSkin(p, 'h007', - 10622.2, - 9622.6, 274.596, 'h007')
    set u=BlzCreateUnitWithSkin(p, 'h01U', - 10689.0, - 9677.3, 67.225, 'h01U')
    set u=BlzCreateUnitWithSkin(p, 'h01K', 444.2, 7313.0, 0.615, 'h01K')
    set u=BlzCreateUnitWithSkin(p, 'h007', 554.7, 7364.6, 217.140, 'h007')
    set u=BlzCreateUnitWithSkin(p, 'h01A', 419.2, 7165.9, 39.134, 'h01A')
    set u=BlzCreateUnitWithSkin(p, 'h01V', 6016.0, 2688.0, 270.000, 'h01V')
    set u=BlzCreateUnitWithSkin(p, 'h007', 6106.1, 2555.7, 233.100, 'h007')
    set u=BlzCreateUnitWithSkin(p, 'h01A', - 3470.7, - 6610.3, 43.342, 'h01A')
    set u=BlzCreateUnitWithSkin(p, 'h01K', - 3575.7, - 6648.0, 357.495, 'h01K')
    set u=BlzCreateUnitWithSkin(p, 'h01T', - 3710.7, - 6427.4, 140.380, 'h01T')
    set u=BlzCreateUnitWithSkin(p, 'h01T', 2595.5, 9068.3, 273.610, 'h01T')
    set u=BlzCreateUnitWithSkin(p, 'h01J', 6304.0, - 10016.0, 270.000, 'h01J')
    set u=BlzCreateUnitWithSkin(p, 'h01A', 5531.9, - 11418.9, 325.744, 'h01A')
    set u=BlzCreateUnitWithSkin(p, 'h01K', 5448.5, - 11465.9, 134.221, 'h01K')
    set u=BlzCreateUnitWithSkin(p, 'h01U', 5561.5, - 10849.2, 228.510, 'h01U')
endfunction

//===========================================================================
function CreatePlayerBuildings takes nothing returns nothing
    call CreateBuildingsForPlayer20()
endfunction

//===========================================================================
function CreatePlayerUnits takes nothing returns nothing
    call CreateUnitsForPlayer20()
endfunction

//===========================================================================
function CreateAllUnits takes nothing returns nothing
    call CreateBuildingsForPlayer20() // INLINED!!
    call CreateUnitsForPlayer20() // INLINED!!
endfunction

//***************************************************************************
//*
//*  Regions
//*
//***************************************************************************

function CreateRegions takes nothing returns nothing
    local weathereffect we

    set gg_rct_BaseUnits=Rect(10944.0, - 11584.0, 11328.0, - 10816.0)
    set gg_rct_debugSurvivorSpawn=Rect(- 320.0, - 7648.0, - 128.0, - 7456.0)
endfunction

//***************************************************************************
//*
//*  Players
//*
//***************************************************************************

function InitCustomPlayerSlots takes nothing returns nothing

    // Player 0
    call SetPlayerStartLocation(Player(0), 0)
    call ForcePlayerStartLocation(Player(0), 0)
    call SetPlayerColor(Player(0), ConvertPlayerColor(0))
    call SetPlayerRacePreference(Player(0), RACE_PREF_HUMAN)
    call SetPlayerRaceSelectable(Player(0), false)
    call SetPlayerController(Player(0), MAP_CONTROL_USER)

    // Player 1
    call SetPlayerStartLocation(Player(1), 1)
    call ForcePlayerStartLocation(Player(1), 1)
    call SetPlayerColor(Player(1), ConvertPlayerColor(1))
    call SetPlayerRacePreference(Player(1), RACE_PREF_HUMAN)
    call SetPlayerRaceSelectable(Player(1), false)
    call SetPlayerController(Player(1), MAP_CONTROL_USER)

    // Player 2
    call SetPlayerStartLocation(Player(2), 2)
    call ForcePlayerStartLocation(Player(2), 2)
    call SetPlayerColor(Player(2), ConvertPlayerColor(2))
    call SetPlayerRacePreference(Player(2), RACE_PREF_HUMAN)
    call SetPlayerRaceSelectable(Player(2), false)
    call SetPlayerController(Player(2), MAP_CONTROL_USER)

    // Player 3
    call SetPlayerStartLocation(Player(3), 3)
    call ForcePlayerStartLocation(Player(3), 3)
    call SetPlayerColor(Player(3), ConvertPlayerColor(3))
    call SetPlayerRacePreference(Player(3), RACE_PREF_HUMAN)
    call SetPlayerRaceSelectable(Player(3), false)
    call SetPlayerController(Player(3), MAP_CONTROL_USER)

    // Player 4
    call SetPlayerStartLocation(Player(4), 4)
    call ForcePlayerStartLocation(Player(4), 4)
    call SetPlayerColor(Player(4), ConvertPlayerColor(4))
    call SetPlayerRacePreference(Player(4), RACE_PREF_HUMAN)
    call SetPlayerRaceSelectable(Player(4), false)
    call SetPlayerController(Player(4), MAP_CONTROL_USER)

    // Player 5
    call SetPlayerStartLocation(Player(5), 5)
    call ForcePlayerStartLocation(Player(5), 5)
    call SetPlayerColor(Player(5), ConvertPlayerColor(5))
    call SetPlayerRacePreference(Player(5), RACE_PREF_HUMAN)
    call SetPlayerRaceSelectable(Player(5), false)
    call SetPlayerController(Player(5), MAP_CONTROL_USER)

    // Player 6
    call SetPlayerStartLocation(Player(6), 6)
    call ForcePlayerStartLocation(Player(6), 6)
    call SetPlayerColor(Player(6), ConvertPlayerColor(6))
    call SetPlayerRacePreference(Player(6), RACE_PREF_HUMAN)
    call SetPlayerRaceSelectable(Player(6), false)
    call SetPlayerController(Player(6), MAP_CONTROL_USER)

    // Player 7
    call SetPlayerStartLocation(Player(7), 7)
    call ForcePlayerStartLocation(Player(7), 7)
    call SetPlayerColor(Player(7), ConvertPlayerColor(7))
    call SetPlayerRacePreference(Player(7), RACE_PREF_HUMAN)
    call SetPlayerRaceSelectable(Player(7), false)
    call SetPlayerController(Player(7), MAP_CONTROL_USER)

    // Player 8
    call SetPlayerStartLocation(Player(8), 8)
    call ForcePlayerStartLocation(Player(8), 8)
    call SetPlayerColor(Player(8), ConvertPlayerColor(8))
    call SetPlayerRacePreference(Player(8), RACE_PREF_UNDEAD)
    call SetPlayerRaceSelectable(Player(8), false)
    call SetPlayerController(Player(8), MAP_CONTROL_COMPUTER)

    // Player 9
    call SetPlayerStartLocation(Player(9), 9)
    call ForcePlayerStartLocation(Player(9), 9)
    call SetPlayerColor(Player(9), ConvertPlayerColor(9))
    call SetPlayerRacePreference(Player(9), RACE_PREF_HUMAN)
    call SetPlayerRaceSelectable(Player(9), false)
    call SetPlayerController(Player(9), MAP_CONTROL_COMPUTER)

    // Player 10
    call SetPlayerStartLocation(Player(10), 10)
    call ForcePlayerStartLocation(Player(10), 10)
    call SetPlayerColor(Player(10), ConvertPlayerColor(10))
    call SetPlayerRacePreference(Player(10), RACE_PREF_HUMAN)
    call SetPlayerRaceSelectable(Player(10), false)
    call SetPlayerController(Player(10), MAP_CONTROL_COMPUTER)

endfunction

function InitCustomTeams takes nothing returns nothing
    // Force: TRIGSTR_093
    call SetPlayerTeam(Player(0), 0)
    call SetPlayerState(Player(0), PLAYER_STATE_ALLIED_VICTORY, 1)
    call SetPlayerTeam(Player(1), 0)
    call SetPlayerState(Player(1), PLAYER_STATE_ALLIED_VICTORY, 1)
    call SetPlayerTeam(Player(2), 0)
    call SetPlayerState(Player(2), PLAYER_STATE_ALLIED_VICTORY, 1)
    call SetPlayerTeam(Player(3), 0)
    call SetPlayerState(Player(3), PLAYER_STATE_ALLIED_VICTORY, 1)
    call SetPlayerTeam(Player(4), 0)
    call SetPlayerState(Player(4), PLAYER_STATE_ALLIED_VICTORY, 1)
    call SetPlayerTeam(Player(5), 0)
    call SetPlayerState(Player(5), PLAYER_STATE_ALLIED_VICTORY, 1)
    call SetPlayerTeam(Player(6), 0)
    call SetPlayerState(Player(6), PLAYER_STATE_ALLIED_VICTORY, 1)
    call SetPlayerTeam(Player(7), 0)
    call SetPlayerState(Player(7), PLAYER_STATE_ALLIED_VICTORY, 1)
    call SetPlayerTeam(Player(9), 0)
    call SetPlayerState(Player(9), PLAYER_STATE_ALLIED_VICTORY, 1)

    //   Allied
    call SetPlayerAllianceStateAllyBJ(Player(0), Player(1), true)
    call SetPlayerAllianceStateAllyBJ(Player(0), Player(2), true)
    call SetPlayerAllianceStateAllyBJ(Player(0), Player(3), true)
    call SetPlayerAllianceStateAllyBJ(Player(0), Player(4), true)
    call SetPlayerAllianceStateAllyBJ(Player(0), Player(5), true)
    call SetPlayerAllianceStateAllyBJ(Player(0), Player(6), true)
    call SetPlayerAllianceStateAllyBJ(Player(0), Player(7), true)
    call SetPlayerAllianceStateAllyBJ(Player(0), Player(9), true)
    call SetPlayerAllianceStateAllyBJ(Player(1), Player(0), true)
    call SetPlayerAllianceStateAllyBJ(Player(1), Player(2), true)
    call SetPlayerAllianceStateAllyBJ(Player(1), Player(3), true)
    call SetPlayerAllianceStateAllyBJ(Player(1), Player(4), true)
    call SetPlayerAllianceStateAllyBJ(Player(1), Player(5), true)
    call SetPlayerAllianceStateAllyBJ(Player(1), Player(6), true)
    call SetPlayerAllianceStateAllyBJ(Player(1), Player(7), true)
    call SetPlayerAllianceStateAllyBJ(Player(1), Player(9), true)
    call SetPlayerAllianceStateAllyBJ(Player(2), Player(0), true)
    call SetPlayerAllianceStateAllyBJ(Player(2), Player(1), true)
    call SetPlayerAllianceStateAllyBJ(Player(2), Player(3), true)
    call SetPlayerAllianceStateAllyBJ(Player(2), Player(4), true)
    call SetPlayerAllianceStateAllyBJ(Player(2), Player(5), true)
    call SetPlayerAllianceStateAllyBJ(Player(2), Player(6), true)
    call SetPlayerAllianceStateAllyBJ(Player(2), Player(7), true)
    call SetPlayerAllianceStateAllyBJ(Player(2), Player(9), true)
    call SetPlayerAllianceStateAllyBJ(Player(3), Player(0), true)
    call SetPlayerAllianceStateAllyBJ(Player(3), Player(1), true)
    call SetPlayerAllianceStateAllyBJ(Player(3), Player(2), true)
    call SetPlayerAllianceStateAllyBJ(Player(3), Player(4), true)
    call SetPlayerAllianceStateAllyBJ(Player(3), Player(5), true)
    call SetPlayerAllianceStateAllyBJ(Player(3), Player(6), true)
    call SetPlayerAllianceStateAllyBJ(Player(3), Player(7), true)
    call SetPlayerAllianceStateAllyBJ(Player(3), Player(9), true)
    call SetPlayerAllianceStateAllyBJ(Player(4), Player(0), true)
    call SetPlayerAllianceStateAllyBJ(Player(4), Player(1), true)
    call SetPlayerAllianceStateAllyBJ(Player(4), Player(2), true)
    call SetPlayerAllianceStateAllyBJ(Player(4), Player(3), true)
    call SetPlayerAllianceStateAllyBJ(Player(4), Player(5), true)
    call SetPlayerAllianceStateAllyBJ(Player(4), Player(6), true)
    call SetPlayerAllianceStateAllyBJ(Player(4), Player(7), true)
    call SetPlayerAllianceStateAllyBJ(Player(4), Player(9), true)
    call SetPlayerAllianceStateAllyBJ(Player(5), Player(0), true)
    call SetPlayerAllianceStateAllyBJ(Player(5), Player(1), true)
    call SetPlayerAllianceStateAllyBJ(Player(5), Player(2), true)
    call SetPlayerAllianceStateAllyBJ(Player(5), Player(3), true)
    call SetPlayerAllianceStateAllyBJ(Player(5), Player(4), true)
    call SetPlayerAllianceStateAllyBJ(Player(5), Player(6), true)
    call SetPlayerAllianceStateAllyBJ(Player(5), Player(7), true)
    call SetPlayerAllianceStateAllyBJ(Player(5), Player(9), true)
    call SetPlayerAllianceStateAllyBJ(Player(6), Player(0), true)
    call SetPlayerAllianceStateAllyBJ(Player(6), Player(1), true)
    call SetPlayerAllianceStateAllyBJ(Player(6), Player(2), true)
    call SetPlayerAllianceStateAllyBJ(Player(6), Player(3), true)
    call SetPlayerAllianceStateAllyBJ(Player(6), Player(4), true)
    call SetPlayerAllianceStateAllyBJ(Player(6), Player(5), true)
    call SetPlayerAllianceStateAllyBJ(Player(6), Player(7), true)
    call SetPlayerAllianceStateAllyBJ(Player(6), Player(9), true)
    call SetPlayerAllianceStateAllyBJ(Player(7), Player(0), true)
    call SetPlayerAllianceStateAllyBJ(Player(7), Player(1), true)
    call SetPlayerAllianceStateAllyBJ(Player(7), Player(2), true)
    call SetPlayerAllianceStateAllyBJ(Player(7), Player(3), true)
    call SetPlayerAllianceStateAllyBJ(Player(7), Player(4), true)
    call SetPlayerAllianceStateAllyBJ(Player(7), Player(5), true)
    call SetPlayerAllianceStateAllyBJ(Player(7), Player(6), true)
    call SetPlayerAllianceStateAllyBJ(Player(7), Player(9), true)
    call SetPlayerAllianceStateAllyBJ(Player(9), Player(0), true)
    call SetPlayerAllianceStateAllyBJ(Player(9), Player(1), true)
    call SetPlayerAllianceStateAllyBJ(Player(9), Player(2), true)
    call SetPlayerAllianceStateAllyBJ(Player(9), Player(3), true)
    call SetPlayerAllianceStateAllyBJ(Player(9), Player(4), true)
    call SetPlayerAllianceStateAllyBJ(Player(9), Player(5), true)
    call SetPlayerAllianceStateAllyBJ(Player(9), Player(6), true)
    call SetPlayerAllianceStateAllyBJ(Player(9), Player(7), true)

    // Force: TRIGSTR_094
    call SetPlayerTeam(Player(8), 1)
    call SetPlayerState(Player(8), PLAYER_STATE_ALLIED_VICTORY, 1)
    call SetPlayerTeam(Player(10), 1)
    call SetPlayerState(Player(10), PLAYER_STATE_ALLIED_VICTORY, 1)

    //   Allied
    call SetPlayerAllianceStateAllyBJ(Player(8), Player(10), true)
    call SetPlayerAllianceStateAllyBJ(Player(10), Player(8), true)

    //   Shared Vision
    call SetPlayerAllianceStateVisionBJ(Player(8), Player(10), true)
    call SetPlayerAllianceStateVisionBJ(Player(10), Player(8), true)

    //   Shared Control
    call SetPlayerAllianceStateControlBJ(Player(8), Player(10), true)
    call SetPlayerAllianceStateControlBJ(Player(10), Player(8), true)

    //   Shared Advanced Control
    call SetPlayerAllianceStateFullControlBJ(Player(8), Player(10), true)
    call SetPlayerAllianceStateFullControlBJ(Player(10), Player(8), true)

endfunction

function InitAllyPriorities takes nothing returns nothing

    call SetStartLocPrioCount(0, 4)
    call SetStartLocPrio(0, 0, 2, MAP_LOC_PRIO_LOW)
    call SetStartLocPrio(0, 1, 4, MAP_LOC_PRIO_LOW)
    call SetStartLocPrio(0, 2, 5, MAP_LOC_PRIO_LOW)
    call SetStartLocPrio(0, 3, 6, MAP_LOC_PRIO_HIGH)

    call SetStartLocPrioCount(1, 5)
    call SetStartLocPrio(1, 0, 2, MAP_LOC_PRIO_HIGH)
    call SetStartLocPrio(1, 1, 3, MAP_LOC_PRIO_HIGH)
    call SetStartLocPrio(1, 2, 4, MAP_LOC_PRIO_HIGH)
    call SetStartLocPrio(1, 3, 5, MAP_LOC_PRIO_HIGH)
    call SetStartLocPrio(1, 4, 7, MAP_LOC_PRIO_LOW)

    call SetStartLocPrioCount(2, 2)
    call SetStartLocPrio(2, 0, 4, MAP_LOC_PRIO_HIGH)
    call SetStartLocPrio(2, 1, 5, MAP_LOC_PRIO_HIGH)

    call SetStartLocPrioCount(3, 1)
    call SetStartLocPrio(3, 0, 1, MAP_LOC_PRIO_HIGH)

    call SetStartLocPrioCount(4, 2)
    call SetStartLocPrio(4, 0, 2, MAP_LOC_PRIO_HIGH)
    call SetStartLocPrio(4, 1, 5, MAP_LOC_PRIO_HIGH)

    call SetStartLocPrioCount(5, 2)
    call SetStartLocPrio(5, 0, 2, MAP_LOC_PRIO_HIGH)
    call SetStartLocPrio(5, 1, 4, MAP_LOC_PRIO_HIGH)

    call SetStartLocPrioCount(6, 5)
    call SetStartLocPrio(6, 0, 0, MAP_LOC_PRIO_LOW)
    call SetStartLocPrio(6, 1, 2, MAP_LOC_PRIO_LOW)
    call SetStartLocPrio(6, 2, 4, MAP_LOC_PRIO_LOW)
    call SetStartLocPrio(6, 3, 5, MAP_LOC_PRIO_LOW)
    call SetStartLocPrio(6, 4, 7, MAP_LOC_PRIO_HIGH)

    call SetStartLocPrioCount(7, 5)
    call SetStartLocPrio(7, 0, 1, MAP_LOC_PRIO_LOW)
    call SetStartLocPrio(7, 1, 2, MAP_LOC_PRIO_HIGH)
    call SetStartLocPrio(7, 2, 4, MAP_LOC_PRIO_HIGH)
    call SetStartLocPrio(7, 3, 5, MAP_LOC_PRIO_HIGH)
    call SetStartLocPrio(7, 4, 6, MAP_LOC_PRIO_HIGH)
endfunction

//***************************************************************************
//*
//*  Main Initialization
//*
//***************************************************************************

//===========================================================================
function main takes nothing returns nothing
    call SetCameraBounds(- 11520.0 + GetCameraMargin(CAMERA_MARGIN_LEFT), - 11776.0 + GetCameraMargin(CAMERA_MARGIN_BOTTOM), 11520.0 - GetCameraMargin(CAMERA_MARGIN_RIGHT), 11264.0 - GetCameraMargin(CAMERA_MARGIN_TOP), - 11520.0 + GetCameraMargin(CAMERA_MARGIN_LEFT), 11264.0 - GetCameraMargin(CAMERA_MARGIN_TOP), 11520.0 - GetCameraMargin(CAMERA_MARGIN_RIGHT), - 11776.0 + GetCameraMargin(CAMERA_MARGIN_BOTTOM))
    call SetDayNightModels("Environment\\DNC\\DNCFelwood\\DNCFelwoodTerrain\\DNCFelwoodTerrain.mdl", "Environment\\DNC\\DNCFelwood\\DNCFelwoodUnit\\DNCFelwoodUnit.mdl")
    call SetWaterBaseColor(0, 128, 255, 255)
    call NewSoundEnvironment("Default")
    call SetAmbientDaySound("DalaranRuinsDay")
    call SetAmbientNightSound("DalaranRuinsNight")
    call SetMapMusic("Music", true, 0)
    call InitSounds()
    call CreateRegions()
    call CreateAllUnits()
    call InitBlizzard()


    call InitGlobals()

endfunction

//***************************************************************************
//*
//*  Map Configuration
//*
//***************************************************************************

function config takes nothing returns nothing
    call SetMapName("TRIGSTR_080")
    call SetMapDescription("TRIGSTR_1550")
    call SetPlayers(11)
    call SetTeams(11)
    call SetGamePlacement(MAP_PLACEMENT_TEAMS_TOGETHER)

    call DefineStartLocation(0, 11648.0, - 10880.0)
    call DefineStartLocation(1, 11648.0, - 11072.0)
    call DefineStartLocation(2, 11648.0, - 11008.0)
    call DefineStartLocation(3, 11648.0, - 11136.0)
    call DefineStartLocation(4, 11648.0, - 11008.0)
    call DefineStartLocation(5, 11648.0, - 11008.0)
    call DefineStartLocation(6, 11584.0, - 10944.0)
    call DefineStartLocation(7, 11584.0, - 11008.0)
    call DefineStartLocation(8, 11648.0, - 11008.0)
    call DefineStartLocation(9, 11648.0, - 11072.0)
    call DefineStartLocation(10, 11648.0, - 11072.0)

    // Player setup
    call InitCustomPlayerSlots()
    call InitCustomTeams()
    call InitAllyPriorities()
endfunction




//Struct method generated initializers/callers:

