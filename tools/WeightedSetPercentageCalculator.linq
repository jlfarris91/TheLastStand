<Query Kind="Program" />

void Main()
{
	Console.WriteLine("Start");
	CalculateWeights(0.5f, 5.0f, 2.0f, 0.5);
	
	Console.WriteLine("");
	Console.WriteLine("End");
	CalculateWeights(24, 32, 24, 6);
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

// You can define other methods, fields, classes and namespaces here
public void CalculateWeights(params float[] weights)
{
	var total = weights.Sum();
	Console.WriteLine($"a: {(a/total * 100)}%");
	Console.WriteLine($"b: {(b/total * 100)}%");
	Console.WriteLine($"c: {(c/total * 100)}%");
	Console.WriteLine($"d: {(d/total * 100)}%");
}
