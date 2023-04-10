<Query Kind="Program" />

void Main()
{
	var wave = new Wave
	{
		goldRange = 15
	};
	var waveCount = 50;
	for (var i = 1; i <= waveCount; ++i)
	{
		Console.Write($"{i:00}: ");
		wave.waveProgress = (i / (float)waveCount) * 1.1f;
		if (wave.GiveCoins(out int coinsToGive))
		{
			wave.goldAwarded += coinsToGive;
		}
	}
}

class Wave
{
	Random random = new Random();
	public int goldRange;
	public int goldAwarded;
	public float chanceMin = 0.01f;
	public float chanceMax = 1.0f;
	public float waveProgress = 0.1f;
	
	public bool GiveCoins(out int goldToGive)
	{
		if (goldRange == goldAwarded)
		{
			goldToGive = 0;
			return false;
		}
		Console.Write($"G: {goldAwarded}/{goldRange} ");
		float goldAwardedProgress = Math.Min(Math.Max(goldAwarded / goldRange, 0.0f), 1.0f);
		var chance = chanceMin + (chanceMax - chanceMin) * waveProgress;
		Console.Write($"Chance: {chance} ");
		if (random.NextDouble() > chance)
		{
			Console.WriteLine();
			goldToGive = 0;
			return false;
		}
		var goldRemaining = goldRange - goldAwarded;
		var goldToGive2 = goldRemaining * waveProgress;
		if (goldToGive2 == 0)
		{
			Console.WriteLine("No gold left to give");
			goldToGive = 0;
			return false;
		}
		var goldToGiveClamped = (int)Math.Max(goldToGive2, 1);
		goldToGiveClamped = RoundToCoinItem(goldToGiveClamped);
		Console.WriteLine($"Gold: {goldToGiveClamped} ");
		goldToGive = goldToGiveClamped;
		return true;
	}
	
	private int RoundToCoinItem(int gold)
	{
		if (gold >= 1 && gold < 3)
			return 1;
		if (gold >= 3 && gold < 6)
			return 3;
		if (gold >= 6 && gold < 10)
			return 6;
		if (gold >= 10)
			return 10;
		return 0;
	}
}