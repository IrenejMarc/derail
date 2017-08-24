module derail.app.controller;

import derail.core.http;

class Controller
{
	import std.string;
	import std.array;

	protected
	{
		string action;
		string[string] params;
		Request request;
		Response response;
	}

	void initialize(string action, Request req, Response res)
	{
		this.action = action;
		this.request = req;
		this.response = res;
		this.params = convertParams(request.params);
	}

	protected
	{
		void render(string caller = __FUNCTION__)(int status = 200)
		{
			enum action = caller.split(".")[$ - 1];

			render!(action, caller)(status);
		}

		void render(string templateName, string caller = __FUNCTION__)(int status = 200)
		{
			import diet.html : compileHTMLDietFile;

			// This is slightly ugly and requires us to always keep controllers in
			// "controllers.pluralname" module, maybe get a better solution.
			enum templatePrefix = caller.split(".")[1];
			enum templateFile = templatePrefix ~ "/" ~ templateName ~ ".dt";

			auto output = Appender!string();
			compileHTMLDietFile!templateFile(output);

			response.writeBody(output.data, status, "text/html");
		}
	}

	private
	{
		/**
			Converts params from Vibe's DictionaryList to an AA.
			Unlike DictionaryList, does not duplicate keys.

			TODO: Handle arrays in the form of array_param[] multiple times
		 */
		static string[string] convertParams(T)(T dictionary)
		{
			string[string] result;

			foreach (key, value; dictionary.byKeyValue)
			{
				result[key] = value;
			}

			return result;
		}
	}
}
