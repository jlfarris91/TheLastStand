<Query Kind="Statements" />



string originalFilePath = @"D:\Projects\WarcraftIII\TheLastStand\resources\abilities\SurvivorJobOverhead.mdl";

var mappings = new Dictionary<string, string>()
{
	{ "Builder", "BTNPeasant.blp" },
	{ "Militia1", "BTNMilitia.blp" },
	{ "Militia2", "BTNFootman.blp" },
	{ "Militia3", "BTNTheCaptain.blp" },
	{ "Spearman1", "BTNBrigand.dds" },
	{ "Spearman2", "BTNBanditSpearThrower.blp" },
	{ "Engineer", "BTNBloodElfPeasant.blp" },
	{ "Marksman1", "BTNRifleman.blp" },
	{ "Priest1", "BTNPriest.blp" },
};

foreach (var pair in mappings)
{
	var filename = $"SurvivorJobOverhead_{pair.Key}.mdl";
	var filepath = Path.Combine(@"D:\Projects\WarcraftIII\TheLastStand\imports\abilities", filename);
	
	if (File.Exists(filepath))
		File.Delete(filepath);
	
	File.Copy(originalFilePath, filepath);
	
	if (!File.Exists(filepath))
		throw new Exception("Failed to copy file!");
		
	var alltext = File.ReadAllText(filepath);

	alltext = alltext.Replace("%0", pair.Key);
	alltext = alltext.Replace("%1", pair.Value);
	
	File.WriteAllText(filepath, alltext);
}