<Query Kind="Program" />

void Main()
{
	Console.WriteLine(FourCharCodeToString(1869571688));
	Console.WriteLine(StringToFourCharCode("hfoo"));
}

static string FourCharCodeToString(int fourCC)
{
	return new string(new [] {
		(char)((fourCC >> 0) & 0xFF),
		(char)((fourCC >> 8) & 0xFF),
		(char)((fourCC >> 16) & 0xFF),
		(char)((fourCC >> 24) & 0xFF),
	});
}

static int StringToFourCharCode(string fourCC)
{
	return ((int)fourCC[0] << 0) + ((int)fourCC[1] << 8) + ((int)fourCC[2] << 16) + (fourCC[3] << 24);
}