<Query Kind="Program" />


// Game constants
const int totalNights = 15;
const float nightTimeScale = 2.5f;
const float realSecondsPerFullDay = 480.0f;
const float realSecondsPerNight = (realSecondsPerFullDay / 2.0f) * (1.0f/nightTimeScale);

void Main()
{
	int nightIndex = 1;
	
	// Total game progress
	float gameT = (nightIndex-1) / (float)(totalNights-1);
	
	// Spawn wave and unit stats
	float maxAlive = 20.0f;
	float cooldown = 2.0f;
	float startDmgMin = 8;
	float startDmgMax = 12;
	float endDmgMin = 240;
	float endDmgMax = 260;
	
	// Damage is increased linearly each night
	float lerpedDmgMin = startDmgMin + (endDmgMin - startDmgMin) * gameT;
	float lerpedDmgMax = startDmgMax + (endDmgMax - startDmgMax) * gameT;
	
	// Dps considering max alive count
	float dmgPerSecondMin = lerpedDmgMin * maxAlive * (1.0f / cooldown);
	float dmgPerSecondMax = lerpedDmgMax * maxAlive * (1.0f / cooldown);
	
	// Estimate based on all units being alive and attacking the entire night
	float dmgPerNightMin = dmgPerSecondMin * realSecondsPerNight;
	float dmgPerNightMax = dmgPerSecondMax * realSecondsPerNight;
	
	Console.WriteLine($"Damage per second: {dmgPerSecondMin}-{dmgPerSecondMax}");
	Console.WriteLine($"Damage per night: {dmgPerNightMin}-{dmgPerNightMax}");
}
