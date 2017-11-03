module derail.app.controller;

import derail.core.http;
import derail.support.arrays;

alias FormatHandler = void delegate();

class Controller
{
	private
	{
		FormatHandler[string] formatHandlers;
	}

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

	void finalize()
	{
		import derail.exceptions;
		import std.string : split;

		string acceptHeader = request.headers["Accept"];
		string[] formats = acceptHeader.split(",");

		foreach (string format; formats)
		{
			auto handler = format in formatHandlers;

			if (handler is null)
				continue;

			return (*handler)();
		}

		throw new UnsupportedFormatException("Unsupported format(s): " ~ acceptHeader);
	}

	protected
	{
		void render(string templateName, string layout = "application", string caller = __FUNCTION__)(int status = 200)
		{

			import derail.web.rendering;

			response.writeBody(
					renderLayout!(templateName, layout, caller),
					status,
					"text/html"
			);
		}
		
		void renderJson(T)(T json)
		{
			import vibe.data.json : serializeToJson;

			response.writeJsonBody(json.serializeToJson());
		}

		void format(string acceptFormat, string caller = __FUNCTION__)(FormatHandler formatHandler)
		{
			formatHandlers[acceptFormat] = formatHandler;
		}

		@property string resourceName()
		{
			import std.string : split, toLower, chomp;

			string controllerName = this.classinfo.name;
			return controllerName
				.split(".").last
				.chomp("Controller")
				.toLower;
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
