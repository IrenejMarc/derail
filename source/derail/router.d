module derail.router;

import std.string;

import vibe.http.router : URLRouter;
import vibe.http.server;

import derail.controller;
import derail.core.http;

class Router
{
	private
	{
		URLRouter vibeRouter;
	}

	this()
	{
		vibeRouter = new URLRouter;
	}

	@property auto routes()
	{
		return vibeRouter.getAllRoutes();
	}

	Router get(Handler)(string path, Handler handler)
	{
		vibeRouter.get(path, makeRequestHandler(handler));

		return this;
	}

	Router resource(ControllerT : Controller)(string pathPrefix)
	{
		import std.traits : hasMember;
		string memberPath = joinPath([pathPrefix.normalizePath, ":id"]);

		static if (hasMember!(ControllerT, "index"))
			vibeRouter.get(pathPrefix, makeResourceRequestHandler!("index", ControllerT));

		static if (hasMember!(ControllerT, "show"))
		{
			vibeRouter.get(memberPath, makeResourceRequestHandler!("show", ControllerT));
		}

		return this;
	}

	Router resource(string resourceName)()
	{
		mixin("import controllers.%s;".format(resourceName));
		resource!(mixin(resourceName.capitalize ~ "Controller"))("/" ~ resourceName ~ "/");

		return this;
	}

	void listen(ushort port)
	{
		auto settings = new HTTPServerSettings;
		settings.port = 8080;

		listenHTTP(settings, vibeRouter);
	}
}

string joinPath(string[] pathParts)
{
	return pathParts.join("/");
}

string normalizePath(string path)
{
	return path.chomp("/");
}


auto makeResourceRequestHandler(string action, ControllerT : Controller)()
{
	void handle(HTTPServerRequest req, HTTPServerResponse res)
	{
		auto controller = new ControllerT;
		auto request = Request(req);
		auto response = Response(res);
		mixin(q{controller.%s(request, response);}.format(action));
	}

	return &handle;
}

auto makeRequestHandler(Handler)(Handler handler)
{
	void requestHandler(HTTPServerRequest req, HTTPServerResponse res)
	{
		handler(Request(req), Response(res));
	}

	return &requestHandler;
}
