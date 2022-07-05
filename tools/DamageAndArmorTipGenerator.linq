<Query Kind="Statements" />


float[,] values = new float[7,8];

var attackTypeStringToIndex = new Dictionary<string, int>() {
	{ "Normal", 0 },
	{ "Pierce", 1 },
	{ "Siege", 2 },
	{ "Spells", 3 },
	{ "Chaos", 4 },
	{ "Magic", 5 },
	{ "Hero", 6 },
};

string[] indexToAttackTypeVar = new [] {
	"NORMAL",
	"PIERCE",
	"SIEGE",
	"SPELLS",
	"CHAOS",
	"MAGIC",
	"HERO",	
};

string[] indexToAttackTypeString = new [] {
	"Normal",
	"Pierce",
	"Siege",
	"Spells",
	"Chaos",
	"Magic",
	"Hero",
};

string[] indexToArmorTypeVar = new []
{
	"SMALL",
	"MEDIUM",
	"LARGE",
	"FORT",
	"NORMAL",
	"HERO",
	"DIVINE",
	"UNARMORED",
};

string[] indexToArmorTypeString = new [] {
	"Light",
	"Medium",
	"Large",
	"Fortified",
	"Normal",
	"Hero",
	"Divine",
	"Unarmored",
};

var ignoreList = new HashSet<string>()
{
	"Divine"
};

float[,] valueMinMax = new float[7,2];

for (int i = 0; i < 7; ++i)
{
	valueMinMax[i, 0] = float.MaxValue;
	valueMinMax[i, 1] = float.MinValue;
}

float[,] armorValueMinMax = new float[8,2];

for (int i = 0; i < 8; ++i)
{
	armorValueMinMax[i, 0] = float.MaxValue;
	armorValueMinMax[i, 1] = float.MinValue;
}

var lines = File.ReadLines(@"D:\Projects\WarcraftIII\TheLastStand\imports\war3mapMisc.txt");

foreach (var line in lines)
{
	if (line.StartsWith("DamageBonus"))
	{
		var segments = line.Split("=");
		var attackTypeStr = segments[0].Substring("DamageBonus".Length);
		var indexA = attackTypeStringToIndex[attackTypeStr];
		var valueSegments = segments[1].Split(",");
		var parsedValues = valueSegments.Select(float.Parse).ToArray();
		for (var i = 0; i < parsedValues.Length; ++i)
		{
			values[indexA, i] = parsedValues[i];
			if (ignoreList.Contains(attackTypeStr) == false &&
				ignoreList.Contains(indexToArmorTypeString[i]) == false)
			{
				valueMinMax[indexA,0] = Math.Min(valueMinMax[indexA,0], parsedValues[i]);
				valueMinMax[indexA,1] = Math.Max(valueMinMax[indexA,1], parsedValues[i]);
				armorValueMinMax[i, 0] = Math.Min(armorValueMinMax[i,0], parsedValues[i]);
				armorValueMinMax[i, 1] = Math.Max(armorValueMinMax[i,1], parsedValues[i]);
			}
		}
	}
}

for (int i = 0; i < 7; ++i)
{
	Console.Write(indexToAttackTypeString[i] + "=");
	for (int j = 0; j < 8; ++j)
	{
		Console.Write(values[i,j].ToString() + ",");
	}
	Console.WriteLine();
}

float Lerp(float a, float b, float t)
{
	return a + t * (b - a);
}

float Parameterize(float a, float b, float v)
{
	return (v - a) / (b - a);
}

float Clamp01(float v)
{
	return Math.Max(0.0f, Math.Min(v, 1.0f)); 
}

(float, float, float) Sample(float t, float min, float max)
{
	var a = (1.0f, 0f, 0f);
	var b = (0.6f, 0.6f, 0.6f);
	var c = (0f, 1.0f, 0f);

	if (t < 1.0f)
	{
		t = Clamp01(Parameterize(1.0f, min, t));
		return (Lerp(b.Item1, a.Item1, t), Lerp(b.Item2, a.Item2, t), Lerp(b.Item3, a.Item3, t));
	}

	if (t > 1.0f)
	{
		t = Clamp01(Parameterize(1.0f, max, t));
		return (Lerp(b.Item1, c.Item1, t), Lerp(b.Item2, c.Item2, t), Lerp(b.Item3, c.Item3, t));
	}

	return b;
}

(float, float, float) Sample2(float t, float min, float max)
{
	var a = (0f, 1.0f, 0f);
	var b = (0.6f, 0.6f, 0.6f);
	var c = (1.0f, 0f, 0f);

	if (t < 1.0f)
	{
		t = Clamp01(Parameterize(1.0f, min, t));
		return (Lerp(b.Item1, a.Item1, t), Lerp(b.Item2, a.Item2, t), Lerp(b.Item3, a.Item3, t));
	}

	if (t > 1.0f)
	{
		t = Clamp01(Parameterize(1.0f, max, t));
		return (Lerp(b.Item1, c.Item1, t), Lerp(b.Item2, c.Item2, t), Lerp(b.Item3, c.Item3, t));
	}

	return b;
}

string GetColorFormatString((float, float, float) color)
{
	var r = (int)(color.Item1 * 255);
	var g = (int)(color.Item2 * 255);
	var b = (int)(color.Item3 * 255);
	return $"|cFF{r:X2}{g:X2}{b:X2}{{0}}|r";
}

for (int i = 0; i < 7; ++i)
{
	if (ignoreList.Contains(indexToAttackTypeString[i]))
		continue;

	var list = new List<ASDF>();

	for (int j = 0; j < 8; ++j)
	{
		if (ignoreList.Contains(indexToArmorTypeString[j]))
			continue;
	
		list.Add(new ASDF() { Value = values[i,j], Index = j });
	}
	
	var sortedList = list.OrderByDescending(_ => _.Value).ToArray();
	
	var sb = new StringBuilder();
	
	int counter = 0;	
	foreach (var asdf in sortedList)
	{
		var color = Sample(asdf.Value, valueMinMax[i, 0], valueMinMax[i, 1]);
		var colorStr = GetColorFormatString(color);
		sb.Append($"{indexToArmorTypeString[asdf.Index]}: {string.Format(colorStr, $"{Math.Floor(asdf.Value * 100.0f)}%")}");
		if (counter++ < sortedList.Length - 1)
			sb.Append("|n");
	}
	
	var varName = indexToAttackTypeVar[i];
	
	Console.WriteLine($"DAMAGETIP_{varName}_V0M={sb.ToString()}");
	Console.WriteLine($"DAMAGETIP_{varName}_V0C={sb.ToString()}");	
	Console.WriteLine($"DAMAGETIP_{varName}={sb.ToString()}");
}


for (int i = 0; i < 8; ++i)
{
	if (ignoreList.Contains(indexToArmorTypeString[i]))
		continue;

	var list = new List<ASDF>();

	for (int j = 0; j < 7; ++j)
	{
		if (ignoreList.Contains(indexToAttackTypeString[j]))
			continue;
	
		list.Add(new ASDF() { Value = values[j,i], Index = j });
	}
	
	var sortedList = list.OrderBy(_ => _.Value).ToArray();
	
	var sb = new StringBuilder();
	
	int counter = 0;	
	foreach (var asdf in sortedList)
	{
		var color = Sample2(asdf.Value, armorValueMinMax[i, 0], armorValueMinMax[i, 1]);
		var colorStr = GetColorFormatString(color);
		sb.Append($"{indexToAttackTypeString[asdf.Index]}: {string.Format(colorStr, $"{Math.Floor(asdf.Value * 100.0f)}%")}");
		if (counter++ < sortedList.Length - 1)
			sb.Append("|n");
	}
	
	var varName = indexToArmorTypeVar[i];
	
	Console.WriteLine($"ARMORTIP_{varName}_V0M={sb.ToString()}");
	Console.WriteLine($"ARMORTIP_{varName}_V0C={sb.ToString()}");	
	Console.WriteLine($"ARMORTIP_{varName}={sb.ToString()}");
}

class ASDF
{
	public float Value;
	public int Index;
};
