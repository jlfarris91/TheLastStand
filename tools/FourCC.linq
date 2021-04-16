<Query Kind="Program" />

void Main()
{
	Console.WriteLine(FourCharCodeToString(1229795425));
	Console.WriteLine(FourCharCodeToString(1229795426));
	Console.WriteLine(FourCharCodeToString(1229795427));
	Console.WriteLine(FourCharCodeToString(1229795428));
}

static string FourCharCodeToString(int fourCC)
{
	return new string(new [] {
		(char)((fourCC >> 24) & 0xFF),
		(char)((fourCC >> 16) & 0xFF),
		(char)((fourCC >> 8) & 0xFF),
		(char)((fourCC >> 0) & 0xFF),
	});
}

static int StringToFourCharCode(string fourCC)
{
	return ((int)fourCC[0] << 24) + ((int)fourCC[1] << 16) + ((int)fourCC[2] << 8) + fourCC[3];
}