module derail.web.rendering;

import std.string;
import std.array;

import diet.html : compileHTMLDietFile;

import derail.support.paths;

enum LAYOUT_PATH = "layout";


string renderLayout(string templateName, string layout, string caller)()
{
	enum layoutFile = [LAYOUT_PATH, layout].joinPath(".dt");

	auto outlet = makeOutlet!(templateName, caller);
	auto output = Appender!string();

	compileHTMLDietFile!(layoutFile, partial, outlet)(output);

	return output.data;
}

string renderToString(string templateName, string caller)()
{
	enum templateFile = LAYOUT_PATH ~ layout ~ ".dt";

	auto outlet = makeOutlet!(templateName, caller);
	auto output = Appender!string();

	compileHTMLDietFile!(templateFile, partial, outlet)(output);

	return output.data;
}

auto makeOutlet(string templateName, string caller)()
{
	return () => {
		enum templatePrefix = resourceNameFromCaller!(caller);
		enum templateFile = templatePrefix ~ "/" ~ templateName ~ ".dt";

		auto output = Appender!string();
		compileHTMLDietFile!(templateFile, partial)(output);

		return output.data;
	};
}

string partial(string partialName)()
{
	import derail.support.arrays;

	enum partialParts = partialName.split("/");
	enum partialFilename = "_%s.dt".format(partialParts.last);
	enum partialPath = partialParts[0 .. $ - 1] ~ partialFilename;

	auto output = Appender!string();
	compileHTMLDietFile!(partialPath.join("/"), partial)(output);

	return output.data;
}

string resourceNameFromCaller(string caller = __FUNCTION__)()
{
	// This is slightly ugly and requires us to always keep controllers in
	// "controllers.pluralname" module, maybe get a better solution.
	return caller.split(".")[1];
}
