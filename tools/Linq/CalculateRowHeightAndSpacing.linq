<Query Kind="Statements" />

//var rowHeight = 0.022;
//var totalHeight = 0.34;

var rowHeight = 0.02;
var totalHeight = 0.1;

var rowsAbs = totalHeight/rowHeight;
var rowsFloor = Math.Floor(rowsAbs);
var spacing = ((rowsAbs - rowsFloor) * rowHeight) / (rowsFloor - 1);
var rowsFixedValidation = spacing != 0.0 ? totalHeight/rowHeight : (totalHeight+spacing)/(rowHeight+spacing);

Console.WriteLine($"Rows: {rowsFloor}");
Console.WriteLine($"Spacing: {spacing}");
Console.WriteLine($"Validate: {rowsFixedValidation}");
Debug.Assert(Math.Round(rowsFixedValidation) == rowsFloor);