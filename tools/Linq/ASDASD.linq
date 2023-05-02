<Query Kind="Program" />


int damagePerPrimaryPoint = 1;
float attackSpeedPerAgi = 0.02f;
int defenseBaseValue = -2;
float defenseBonusPerAgi = 0.3f;
float healthRegenPerStr = 0.05f;
int healthBonusPerStr = 25;
int manaBonusPerInt = 15;
float manaRegenPerInt = 0.05f;
int speedBonusPerAgi = 0;

struct Attr
{
	public float m_base;
	public float m_delta;
	public static bool operator==(Attr lhs, Attr rhs)
	{
		return lhs.m_base == rhs.m_base && lhs.m_delta == rhs.m_delta;
	}
	public static bool operator!=(Attr lhs, Attr rhs)
	{
		return lhs.m_base != rhs.m_base && lhs.m_delta != rhs.m_delta;
	}
	public override int GetHashCode()
	{
		return m_base.GetHashCode() ^ m_delta.GetHashCode();
	}
}

enum Attribute
{
	Strength,
	Agility,
	Intelligence
}

void Main()
{	
	int baseHP = 300;
	int finalHP = 1000;
	
	int baseDamage = 30;
	int finalDamage = 100;
	
	int baseArmor = 0;
	int finalArmor = 2;
	
	int baseMana = 100;
	int finalMana = 100;
	
	Attribute primaryAttr = Attribute.Strength;
	
	int level = 10;
	
	Dictionary<Attr, float> strengthAttrs = new Dictionary<Attr, float>();
	Dictionary<Attr, float> agilityAttrs = new Dictionary<Attr, float>();
	Dictionary<Attr, float> intelligenceAttrs = new Dictionary<Attr, float>();
	
	switch (primaryAttr)
	{
		case Attribute.Strength:
			test("damage", level, finalDamage, baseDamage, damagePerPrimaryPoint, strengthAttrs);
			break;
		case Attribute.Agility:
			test("damage", level, finalDamage, baseDamage, damagePerPrimaryPoint, agilityAttrs);
			break;
		case Attribute.Intelligence:
			test("damage", level, finalDamage, baseDamage, damagePerPrimaryPoint, intelligenceAttrs);
			break;
	}
	
	// Strength
	test("hp", level, finalHP, baseHP, healthBonusPerStr, strengthAttrs);
	
	// Agility
	testArmor("armor", level, finalArmor, baseArmor, defenseBonusPerAgi, agilityAttrs);
	
	// Intelligence
	test("mana", level, finalMana, baseMana, manaBonusPerInt, agilityAttrs);
	
	foreach (var pair in strengthAttrs)
	{
		Console.WriteLine($"Strength: base = {pair.Key.m_base} delta = {pair.Key.m_delta} count = {pair.Value}");
	}
	foreach (var pair in agilityAttrs)
	{
		Console.WriteLine($"Agility: base = {pair.Key.m_base} delta = {pair.Key.m_delta} count = {pair.Value}");
	}
	foreach (var pair in intelligenceAttrs)
	{
		Console.WriteLine($"Intelligence: base = {pair.Key.m_base} delta = {pair.Key.m_delta} count = {pair.Value}");
	}
}

void test(string stat, int level, float finalStat, float baseStat, float attrDelta, Dictionary<Attr, float> attributes)
{
	float deltaAttr;
	float baseAttr;

	testBase(stat, level, finalStat, baseStat, attrDelta, 0, out deltaAttr, out baseAttr);
	
	float deltaStr2 = deltaAttr;
	for (var i = 0; i <= deltaStr2; ++i)
	{
		if (testDelta(stat, level, finalStat, baseStat, attrDelta, i, out deltaAttr, out baseAttr))
		{
			Attr attr = new Attr();
			attr.m_base = baseAttr;
			attr.m_delta = deltaAttr;
			if (!attributes.ContainsKey(attr))
			{
				attributes.Add(attr, 0);
			}
			attributes[attr]++;
		}
	}
}

bool testDelta(string stat, int level, float finalHP, float baseHP, float attrDelta, float testDeltaStr, out float deltaStr, out float baseStr)
{
	baseStr = (float)Math.Floor((finalHP - baseHP) / attrDelta - level * testDeltaStr);
	deltaStr = (float)Math.Floor(((finalHP - baseHP) / attrDelta - baseStr) / level);
	var baseHP2 = (float)Math.Round(finalHP - (baseStr + level * deltaStr) * attrDelta);
	var finalHP2 = (float)Math.Round(baseHP + (baseStr + level * deltaStr) * attrDelta);
    //Console.WriteLine($"{stat} - delta test {testDeltaStr} : base = {baseStr} base : {baseHP2} final = {finalHP2}");
	return baseHP == baseHP2 && finalHP == finalHP2;
}

bool testBase(string stat, int level, float finalHP, float baseHP, float attrDelta, float testBaseStr, out float deltaStr, out float baseStr)
{
	deltaStr = (float)Math.Floor(((finalHP - baseHP) / (attrDelta - testBaseStr)) / level);
	baseStr = (float)Math.Floor((finalHP - baseHP) / attrDelta - level * deltaStr);
	var baseHP2 = (float)Math.Round(finalHP - (baseStr + level * deltaStr) * attrDelta);
	var finalHP2 = (float)Math.Round(baseHP + (baseStr + level * deltaStr) * attrDelta);
    //Console.WriteLine($"{stat} - base test {testBaseStr} : base = {baseStr} base : {baseHP2} final = {finalHP2}");
	return baseHP == baseHP2 && finalHP == finalHP2;
}

void testArmor(string stat, int level, float finalStat, float baseStat, float attrDelta, Dictionary<Attr, float> attributes)
{
	float deltaAttr;
	float baseAttr;

	testBaseArmor(stat, level, finalStat, baseStat, attrDelta, 0, out deltaAttr, out baseAttr);
	
	float deltaStr2 = deltaAttr;
	for (var i = 0; i <= deltaStr2; ++i)
	{
		if (testDeltaArmor(stat, level, finalStat, baseStat, attrDelta, i, out deltaAttr, out baseAttr))
		{
			Attr attr = new Attr();
			attr.m_base = baseAttr;
			attr.m_delta = deltaAttr;
			if (!attributes.ContainsKey(attr))
			{
				attributes.Add(attr, 0);
			}
			attributes[attr]++;
		}
	}
}

bool testDeltaArmor(string stat, int level, float finalHP, float baseHP, float attrDelta, float testDeltaStr, out float deltaStr, out float baseStr)
{
	baseStr = (float)Math.Floor((finalHP - baseHP - defenseBaseValue) / attrDelta - level * testDeltaStr);
	deltaStr = (float)Math.Floor(((finalHP - baseHP - defenseBaseValue) / attrDelta - baseStr) / level);
	var baseHP2 = (int)Math.Round(finalHP - defenseBaseValue - (baseStr + level * deltaStr) * attrDelta);
	var finalHP2 = (int)Math.Round(baseHP + defenseBaseValue + (baseStr + level * deltaStr) * attrDelta);
    //Console.WriteLine($"{stat} - delta test {testDeltaStr} : base = {baseStr} base : {baseHP2} final = {finalHP2}");
	return baseHP == baseHP2 && finalHP == finalHP2;
}

bool testBaseArmor(string stat, int level, float finalHP, float baseHP, float attrDelta, float testBaseStr, out float deltaStr, out float baseStr)
{
	deltaStr = (float)Math.Floor(((finalHP - baseHP - defenseBaseValue) / (attrDelta - testBaseStr)) / level);
	baseStr = (float)Math.Floor((finalHP - baseHP - defenseBaseValue) / attrDelta - level * deltaStr);
	var baseHP2 = (int)Math.Round(finalHP - defenseBaseValue - (baseStr + level * deltaStr) * attrDelta);
	var finalHP2 = (int)Math.Round(baseHP + defenseBaseValue + (baseStr + level * deltaStr) * attrDelta);
	//Console.WriteLine($"{stat} - base test {testBaseStr} : delta = {deltaStr} base = {baseStr} base : {baseHP2} final = {finalHP2}");
	return baseHP == baseHP2 && finalHP == finalHP2;
}