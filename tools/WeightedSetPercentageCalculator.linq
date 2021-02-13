<Query Kind="Program" />

void Main()
{
	Console.WriteLine("Small:");
	CalculateWeights(32, 24, 8, 1);
	
	Console.WriteLine("");
	Console.WriteLine("Medium:");
	CalculateWeights(32, 32, 24, 2);

	Console.WriteLine("");
	Console.WriteLine("Large:");
	CalculateWeights(12, 24, 32, 3);
}

// You can define other methods, fields, classes and namespaces here
public void CalculateWeights(float a, float b, float c, float d)
{
	var total = a + b + c + d;
	Console.WriteLine($"a: {(a/total * 100)}%");
	Console.WriteLine($"b: {(b/total * 100)}%");
	Console.WriteLine($"c: {(c/total * 100)}%");
	Console.WriteLine($"d: {(d/total * 100)}%");
}
