<Query Kind="Statements" />

var lines = File.ReadAllLines(@"D:\Projects\WarcraftIII\TheLastStand\_build\compiled.j.txt");
//var lines = File.ReadAllLines(@"D:\Projects\WarcraftIII\MPQ\Work\war3map.j");

var badLines = 0;
var i = 0;

foreach (var line in lines)
{
	++i;
	if (line.StartsWith("function") && line.Count(c => c == ',') >= 30)
	{
		Console.WriteLine($"[Line {i}] {line}");
		badLines++;
	}
}

if (badLines == 0)
	Console.WriteLine("No bad functions");