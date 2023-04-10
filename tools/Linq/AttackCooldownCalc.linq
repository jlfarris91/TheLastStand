<Query Kind="Statements" />



for (var d = 0; d <= 5; d++)
{
	var diff = d == 0 ? 0.5f : d;
	Console.Write($"{diff,3}: ");
	for (var t = 0; t < 3; ++t)
	{
		Console.Write($"{(diff + t + 1) * 0.5,5} ");
	}
	Console.WriteLine();
}

Console.WriteLine();

const float ELITE_DIFF_ATTACK_COOLDOWN_SCALAR = 0.1f;
const float ELITE_TIER_ATTACK_COOLDOWN_SCALAR = 0.1f;
const float ELITE_ATTACK_COOLDOWN_SCALAR = 2.0f / 3.0f;

float DiffFunc(float diff, float tier)
{
	return (diff + tier + 1) / 2.0f;
}

void ASDF(float cooldownInitial, float cooldownScale)
{
	Console.WriteLine($"Cooldown {cooldownInitial} scaled by {cooldownScale}");

	for (var d = 0; d <= 5; d++)
	{
		var diff = d == 0 ? 0.5f : d;
		Console.Write($"{diff,3}: ");
		for (var t = 0; t < 3; ++t)
		{
			var cooldown = cooldownInitial;
			var diffScalar = DiffFunc(diff, t);
			var s = (1.0f + ((1.0f / diffScalar) - 1.0f) * ELITE_ATTACK_COOLDOWN_SCALAR) * cooldownScale;
			cooldown *= s;
			Console.Write($"{cooldown,11} {$"({s})",-12} ");
		}
		Console.WriteLine();
	}
	Console.WriteLine();
}

ASDF(2.0f, 0.5f);
ASDF(2.0f, 1.0f);
ASDF(2.0f, 2.0f);