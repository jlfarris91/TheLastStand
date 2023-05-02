<Query Kind="Program" />


int GuardTowerLevels = 3;
float GuardTowerDpsScalar = 0.75f;
float GuardTowerStart = 0.25f;
int GuardTowerUpLevels = 5;
float GuardTowerUpScalar = 0.5f;
int GuardTowerOpLevels = 10;
float GuardTowerOpScalar = 0.5f;
float GuardTowerFollowThroughScalar = 1.25f;
float GuardTowerAttackDamageScalar = 1.5f;

int zombieHPStart = 120;
int zombieHPEnd = 2000;

void Main()
{
	
	WriteZombieHP(zombieHPStart, zombieHPEnd, 0.0f);
	WriteZombieHP(zombieHPStart, zombieHPEnd, 1/3.0f);
	WriteZombieHP(zombieHPStart, zombieHPEnd, 0.5f);
	WriteZombieHP(zombieHPStart, zombieHPEnd, 2/3.0f);
	WriteZombieHP(zombieHPStart, zombieHPEnd, 1.0f);
	
	Console.WriteLine();
	
	WriteGuardTower(0);
	Console.WriteLine();
	
	WriteGuardTower(1);
	Console.WriteLine();
	
	WriteGuardTower(2);
	Console.WriteLine();
}

float GetStandardDPS(float t, float attackDamageScale)
{
	return Lerp(zombieHPStart, zombieHPEnd, t) * (1.0f / attackDamageScale);
}

void WriteGuardTower(int level)
{
	
	Console.WriteLine($"===== Guard Tower {level+1} =====");
	Console.WriteLine();
	
	var t = GuardTowerStart + (1.0f - GuardTowerStart) * (level / (float)GuardTowerLevels);
	var tNext = GuardTowerStart + (1.0f - GuardTowerStart) * ((level + 1) / (float)GuardTowerLevels);
	
	Console.WriteLine($"t: {Math.Floor(t * 100)}%");
	Console.WriteLine($"tN: {Math.Floor(tNext * 100)}%");
	
	var dpsBase = GetStandardDPS(t, GuardTowerAttackDamageScalar);
	var dpsNext = GetStandardDPS(tNext, GuardTowerAttackDamageScalar);
	var dpsDelta = (dpsNext - dpsBase) * GuardTowerFollowThroughScalar;
	
	Console.WriteLine();
	Console.WriteLine($"DPS Base: {dpsBase}");
	Console.WriteLine($"DPS Next: {dpsNext}");
	Console.WriteLine($"DPS Delta: {dpsDelta}");
	
	var baseScalar = GuardTowerDpsScalar;
	var upScalar = GuardTowerUpScalar / (GuardTowerUpScalar + GuardTowerOpScalar);
	var opScalar = GuardTowerOpScalar / (GuardTowerUpScalar + GuardTowerOpScalar);
	
	Console.WriteLine();
	Console.WriteLine($"Base DPS Scalar: {baseScalar}");
	Console.WriteLine($"Up DPS Scalar: {upScalar}");
	Console.WriteLine($"Op DPS Scalar: {opScalar}");
	
	var dpsBaseScaled = dpsBase * baseScalar;
	var dpsNextScaled = dpsNext * baseScalar;
	var dpsDeltaScaled = dpsDelta * baseScalar;
	
	var upBonusEnd = upScalar * dpsDeltaScaled;
	var opBonusEnd = opScalar * dpsDeltaScaled;
	var finalDps = dpsBaseScaled + opBonusEnd + upBonusEnd;
	
	Console.WriteLine();
	Console.WriteLine($"DPS Base: {dpsBaseScaled} {Math.Floor((dpsBaseScaled / finalDps) * 100)}%");
	Console.WriteLine($"DPS Up: {upBonusEnd} {Math.Floor((upBonusEnd / finalDps) * 100)}%");
	Console.WriteLine($"DPS Op: {opBonusEnd}  {Math.Floor((opBonusEnd / finalDps) * 100)}%");
	Console.WriteLine("DPS Final: " + finalDps);	
	
	Console.WriteLine();
	
	for (var i = 1; i <= GuardTowerUpLevels; ++i)
	{
		var upBonus = i * (upScalar / GuardTowerUpLevels) * dpsDeltaScaled;
		Console.WriteLine($"UP {i}: +{upBonus} -> {dpsBaseScaled + upBonus}");		
	}
	
	Console.WriteLine();

	for (var i = 1; i <= GuardTowerOpLevels; ++ i)
	{
		var opBonus = i * (opScalar / GuardTowerOpLevels) * dpsDeltaScaled;
		Console.WriteLine($"OP {i}: +{opBonus} -> {dpsBaseScaled + opBonus}");
	}
	Console.WriteLine();
	
}

void WriteZombieHP(float start, float end, float t)
{
	Console.WriteLine($"ZHP {Math.Floor(t * 100)}% : {Lerp(start, end, t)}");
}
	
float Lerp(float start, float end, float t)
{
	return start + (end - start) * t;
}

float Parameterize(float start, float end, float value)
{
	return (value - start) / (end - start);
}