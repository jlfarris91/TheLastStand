<Query Kind="Program" />

void Main()
{
	Console.WriteLine("\nSpike Durability");
	CalculateUpgradePerc(4, 0.12f, 0.12f, 0, 1, 320, 320);
	
	Console.WriteLine("\nCamp Defenses - Armor");
	CalculateUpgrade(6, 2, 2, 0, 1, 300, 300);
	
	Console.WriteLine("\nCamp Defenses - HP");
	CalculateUpgradePerc(6, 0.25f, 0.25f, 0, 1, 300, 300);

	Console.WriteLine("\nAttack Damage");
	CalculateUpgrade(6, 10, 10, 0, 1, 300, 300);
	
	Console.WriteLine("\nAttack Speed");
	CalculateUpgradePerc(6, 0.25f, 0.25f, 0, 1, 400, 400);
	
	Console.WriteLine("\nArmor");
	CalculateUpgrade(6, 2, 2, 0, 1, 200, 100);
}

void CalculateUpgrade(int levels, int statBase, int statInc, int goldBase, int goldInc, int lumBase, int lumInc)
{
	int stat = statBase;
	int gold = goldBase;
	int lum = lumBase;
	
	int totalStat = stat;
	int totalGold = gold;
	int totalLum = lum;
	
	for (int i = 0; i < levels; ++i)
	{
		Console.WriteLine($"{i+1}: {stat} {gold}g {lum}L \t-> Total: {totalStat} {totalGold}g {totalLum}L");
		stat += statInc;
		gold += goldInc;
		lum += lumInc;
		
		totalStat = stat;
		totalGold += gold;
		totalLum += lum;
	}
}

void CalculateUpgradePerc(int levels, float statBase, float statInc, int goldBase, int goldInc, int lumBase, int lumInc)
{
	float stat = statBase;
	int gold = goldBase;
	int lum = lumBase;
	
	float totalStat = stat;
	int totalGold = gold;
	int totalLum = lum;
	
	for (int i = 0; i < levels; ++i)
	{
		Console.WriteLine($"{i+1}: {stat*100.0f:##}% {gold}g {lum}L \t-> Total: {totalStat*100.0f:##}% {totalGold}g {totalLum}L");
		stat += statInc;
		gold += goldInc;
		lum += lumInc;
		
		totalStat = stat;
		totalGold += gold;
		totalLum += lum;
	}
}