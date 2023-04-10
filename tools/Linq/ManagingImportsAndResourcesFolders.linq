<Query Kind="Program" />


// At one point I had mdls in the imports folder and I wanted instead to have all mdx files in the imports folder and a mdl representation in the resources folder

void Main()
{
	var allFiles = Directory.EnumerateFiles(@"D:\Projects\WarcraftIII\TheLastStand\imports", "*.mdx", SearchOption.AllDirectories);
	
	var converter = @"D:\Projects\WarcraftIII\Tools\MDXConverter.exe";
	
	foreach (var importsMdxFile in allFiles)
	{
		var relativeMdxFile = importsMdxFile.Substring(@"D:\Projects\WarcraftIII\TheLastStand\imports".Count());
		var importsMdlFile = Path.ChangeExtension(importsMdxFile, "mdl");
		var resourcesMdxFile = importsMdxFile.Replace(@"D:\Projects\WarcraftIII\TheLastStand\imports", @"D:\Projects\WarcraftIII\TheLastStand\resources");
		var resourcesMdlFile = Path.ChangeExtension(resourcesMdxFile, "mdl");
		
		var importsMdxFileExists = File.Exists(importsMdxFile);
		var importsMdlFileExists = File.Exists(importsMdlFile);
		var resourcesMdxFileExists = File.Exists(resourcesMdxFile);
		var resourcesMdlFileExists = File.Exists(resourcesMdlFile);
		
		var valid = importsMdxFileExists && !importsMdlFileExists && (resourcesMdxFileExists || resourcesMdlFileExists);
		
		if (!valid)
		{
			if (importsMdlFileExists)
			{
			}
			
			if (!resourcesMdxFileExists && !resourcesMdlFileExists)
			{
				File.Copy(importsMdxFile, resourcesMdxFile);
			}
		
			Console.WriteLine($"{relativeMdxFile} {importsMdlFileExists} {resourcesMdxFileExists} {resourcesMdlFileExists} ");
		}
	}
	
}

// You can define other methods, fields, classes and namespaces here