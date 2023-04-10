<Query Kind="Program" />

void Main()
{
	CalculateDamageReduction(32);
}

void CalculateDamageReduction(int armor)
{
	if (armor < 0)
	{
		for (int i = 0; i >= armor; --i)
		{
			var damageReduction = 2 - Math.Pow(0.94f, -i);
			Console.WriteLine($"{i:00} : {damageReduction * 100.0f:##}%");
		}
	}
	else
	{
		float lastDamageRed = 0;
		for (int i = 0; i <= armor; ++i)
		{
			var damageReduction = i * 0.06f / (1 + i * 0.06f);
			Console.WriteLine($"{i:00} : {damageReduction * 100.0f:.##}%    -> {(damageReduction - lastDamageRed) * 100.0f:.##}");
			lastDamageRed = damageReduction;
		}
	}
}