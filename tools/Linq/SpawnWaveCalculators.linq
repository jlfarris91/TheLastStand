<Query Kind="Statements" />


const int WAVE_COUNT = 16;

//Console.WriteLine("Max zombies:");
//Func<float, int> maxZombies = (diff) => 8 + (int)(Math.Max(Math.Floor(diff), 0) * 2);
//Print(diff => $"{diff}: {maxZombies(diff)}");

//Console.WriteLine();
//Console.WriteLine("Max elites:");
//Func<float, int> maxElites = (diff) => 2 + (int)Math.Max(Math.Ceiling((diff - 0.5) / 2.0), 0);
//Func<float, int> maxElites2 = (diff) => maxElites(diff) * 3;
//Print(diff => $"{diff}: {maxElites(diff)} {maxElites2(diff)}");

//Console.WriteLine();
//Console.WriteLine("Max bosses:");
//Func<float, int> maxBosses = (diff) => (int)(Math.Max(Math.Floor((diff - 0.5) / 2.0) + 1, 1));
//Print(diff => $"{diff}: {maxBosses(diff)}");


//Console.WriteLine();
//Console.WriteLine("Wave gold:");
//Func<float, int, int> perWaveGold = (diff, wave) => wave;
//Print(diff => $"{diff:00}:\t {string.Join(" ", Enumerable.Repeat<Func<int, int>>(wave => wave, WAVE_COUNT).Select((_, i) => $"{_(i + 1),3}").ToArray())}");
//
//
//Console.WriteLine();
//Console.WriteLine("Wave gold acc:");
//Print(diff => $"{diff:00}:\t {string.Join(" ", Enumerable.Range(1, WAVE_COUNT).Select((wave) => $"{Enumerable.Repeat<Func<float, int, int>>(perWaveGold, wave).Select((_, i) => _(diff, i + 1)).Sum(),3}") .ToArray() )}");
//
//
//Console.WriteLine();
//Console.WriteLine("Gold drop elites min:");
//Func<float, int, int> goldDropElitesMin = (diff, wave) => (int)((wave % 5) == 0 ? 0 : (wave / 5.0f) + Math.Max(Math.Floor((diff - 0.5) / 2.0) + 1, 1) * 2);
//Func<float, int, int> goldDropBossesMin = (diff, wave) => (int)((wave % 5) != 0 || wave == 0 ? 0 : (wave / 5.0f) * 5 * Math.Max(Math.Floor((diff - 0.5) / 2.0) + 1, 1));
//Func<float, int, int> goldDropPerWaveMin = (diff, wave) => (int)Math.Max(Math.Max(goldDropElitesMin(diff, wave), goldDropBossesMin(diff, wave)), 1);
//Print(diff => $"{diff:00}:\t {string.Join(" ", Enumerable.Repeat<Func<float, int, int>>(goldDropPerWaveMin, WAVE_COUNT).Select((_, i) => $"{_(diff, i + 1),3}").ToArray())}");
//
//
//Console.WriteLine();
//Console.WriteLine("Gold drop elites min acc:");
//Print(diff => $"{diff:00}:\t {string.Join(" ", Enumerable.Range(1, WAVE_COUNT).Select((wave) => $"{Enumerable.Repeat<Func<float, int, int>>(goldDropPerWaveMin, wave).Select((_, i) => _(diff, i + 1)).Sum(),3}") .ToArray() )}");
//
//
//Console.WriteLine();
//Console.WriteLine("Gold drop elites max:");
//Func<float, int, int> goldDropElitesMax = (diff, wave) => (int)((wave % 5) == 0 ? 0.0f : (wave / 5.0f) + (float)Math.Max(Math.Floor((diff - 0.5) / 2.0) + 1, 1) * 6);
//Func<float, int, int> goldDropBossesMax = (diff, wave) => (int)((wave % 5) != 0 || wave == 0 ? 0 : (wave / 5.0f) * 5 * Math.Max(Math.Floor((diff - 0.5) / 2.0) + 1, 1));
//Func<float, int, int> goldDropPerWaveMax = (diff, wave) => (int)Math.Max(Math.Max(goldDropElitesMax(diff, wave), goldDropBossesMax(diff, wave)), 1);
//Print(diff => $"{diff:00}:\t {string.Join(" ", Enumerable.Repeat<Func<float, int, int>>(goldDropPerWaveMax, WAVE_COUNT).Select((_, i) => $"{_(diff, i + 1),3}").ToArray())}");
//
//
//Console.WriteLine();
//Console.WriteLine("Gold drop elites max acc:");
//Print(diff => $"{diff:00}:\t {string.Join(" ", Enumerable.Range(1, WAVE_COUNT).Select((wave) => $"{Enumerable.Repeat<Func<float, int, int>>(goldDropPerWaveMax, wave).Select((_, i) => _(diff, i + 1)).Sum(),3}") .ToArray() )}");


const int totalGold = 100;
const int goldPerDiff = 25;
const int goldPerBoss = 5;
const int bossWaveTotalScalar = 1 + 2 + 3;
float[] goldPercWeights = new float[] { 1, 2, 3 };
float[] goldPercs = goldPercWeights.Select(_ => _ / goldPercWeights.Sum()).ToArray();

Console.WriteLine();
Console.WriteLine("ASDF:");
Func<float, int, int> asdf = (diff, wave) =>
{
	if (wave == WAVE_COUNT)
		return 0;

	var bossGoldAmountPerWave = goldPerBoss * Math.Max(Math.Floor((diff - 0.5) / 2.0) + 1, 1);	
	var bossGoldAmount = (int)Math.Round((wave / 5.0f) * bossGoldAmountPerWave);	
	var bossGoldAmountTotal = bossGoldAmountPerWave * bossWaveTotalScalar;

	if (wave % 5 == 0 || wave == 0)
		return bossGoldAmount;
		
	var goldDrops = (int)((wave / 5.0f) + (float)Math.Max(Math.Floor((diff - 0.5) / 2.0) + 1, 1));
	var minGoldDrops = goldDrops * 0;
	var expectedGoldDrops = goldDrops * 1;
	var averageGoldDrops = goldDrops * 2;
	var maxGoldDrops = goldDrops * 4;
	
	var totalGoldDiffAdjusted = totalGold + Math.Max(Math.Floor(diff - 1), 0) * goldPerDiff;
	totalGoldDiffAdjusted -= bossGoldAmountTotal;
	
	var waveSectionIndex = Math.Max(Math.Min((int)Math.Floor((wave - 1) / 5.0f), 2), 0);
	var goldPerc = goldPercs[waveSectionIndex];
	var baseGoldReward = (int)((totalGoldDiffAdjusted * goldPerc) / 4) - expectedGoldDrops;
	
	return baseGoldReward;// + expectedGoldDrops;
};
Print(diff => $"{diff:00}:\t {string.Join(" ", Enumerable.Repeat<Func<float, int, int>>(asdf, WAVE_COUNT).Select((_, i) => $"{_(diff, i + 1),3}").ToArray())} = {Enumerable.Repeat<Func<float, int, int>>(asdf, WAVE_COUNT).Select((_, i) => _(diff, i + 1)).Sum()}");

Console.WriteLine();
Console.WriteLine("ASDF:");
Func<float, int, int> asdf2 = (diff, wave) => (int)((wave / 5.0f) + (float)Math.Max(Math.Floor((diff - 0.5) / 2.0) + 1, 1));
Print(diff => $"{diff:00}:\t {string.Join(" ", Enumerable.Repeat<Func<float, int, int>>(asdf2, WAVE_COUNT).Select((_, i) => $"{_(diff, i + 1),3}").ToArray())} = {Enumerable.Repeat<Func<float, int, int>>(asdf2, WAVE_COUNT).Select((_, i) => _(diff, i + 1)).Sum()}");


void Print(Func<float, string> printCallback)
{
	for (var i = 0; i <= 5; ++i)
	{
		var diff = i == 0 ? 0.5f : i;
		Console.WriteLine(printCallback(diff));
	}
}