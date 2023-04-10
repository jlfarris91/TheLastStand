<Query Kind="Statements" />

var lines = File.ReadAllLines(@"C:\Users\jlfar\OneDrive\Desktop\changelist.txt");

var sb = new StringBuilder();

var versionRegex = new Regex("(?:@here\\s+)(v\\d+\\.\\d+\\.\\d+)(?:\\s)");

bool listing = false;

foreach (var line in lines)
{
	if (line.StartsWith("@here"))
	{
		var version = versionRegex.Match(line).Groups[1].Captures[0].Value;
		sb.AppendLine($"[TR][TH][SIZE=7]{version}[/SIZE][/TH][/TR]");
		sb.AppendLine("[TR][TD]");
	}

	if (line.StartsWith("__"))
	{
		sb.AppendLine($"[SIZE=5]{line.Trim('_')}[/SIZE]");
		sb.AppendLine("[LIST]");
		listing = true;
		continue;
	}
	
	if (listing && line == "")
	{
		sb.AppendLine("[/LIST]");
		sb.AppendLine();
		listing = false;
	}
	
	if (listing)
	{
		sb.AppendLine($"[*]{line.Trim('·', ' ')}");
	}
}

if (listing)
{
	sb.AppendLine("[/LIST]");	
}

sb.AppendLine("[/TD][/TR]");

Console.WriteLine(sb.ToString());