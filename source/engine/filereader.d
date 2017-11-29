string[] readLines(string path)
{
	import std.stdio : File;
	import std.algorithm : map;
	import std.conv : to;
	import std.array : array;
	return File(path, "r").byLine.map!(to!string).array;
}