module derail.support.paths;

import std.string;

string joinPath(string[] pathParts, string extension = "")
{
	string fullPath = pathParts.join("/");

	if (extension != "")
		fullPath ~= extension;

	return fullPath;
}

string normalizePath(string path)
{
	return path.chomp("/");
}

