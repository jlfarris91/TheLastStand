<Query Kind="Program" />

void Main()
{
	Console.WriteLine("Small");
	CalculateWeights(0.2f, 5.0f, 2.0f);
	
	Console.WriteLine("\nMedium");
	CalculateWeights(0.3f, 5.0f, 2.0f, 0.4f, 0.5f);
	
	Console.WriteLine("\nLarge");
	CalculateWeights(0.6f, 5.0f, 2.0f, 0.5f, 1.0f);
}

// You can define other methods, fields, classes and namespaces here
public void CalculateWeights(params float[] weights)
{
	var total = weights.Sum();
	int i = 0;
	foreach (var w in weights)
	{
		Console.WriteLine($"{i++:00}: {(w/total * 100)}%");
	}
}
