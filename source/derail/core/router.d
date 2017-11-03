module derail.core.router;

import std.string : format, capitalize;

import vibe.http.router : URLRouter;
import vibe.http.server;

import derail.app.controller;
import derail.core.http;
import derail.support.paths;

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

	Router get(string path, string handler)
	{

		return this;
	}

	Router staticFiles(string prefix)
	{
		import vibe.http.fileserver : HTTPFileServerSettings, serveStaticFiles;

		auto fsettings = new HTTPFileServerSettings;
		fsettings.serverPathPrefix = "%s/".format(prefix);

		vibeRouter.get(
				"*",
				serveStaticFiles("./%s/".format(prefix), fsettings)
		);
		

		return this;
	}

	Router resource(ControllerT : Controller)(string pathPrefix)
	{
		import std.traits : hasMember;
		string memberPath = joinPath([pathPrefix.normalizePath, ":id"]);

		// GET, on collection
		static if (hasMember!(ControllerT, "index"))
			vibeRouter.get(
					pathPrefix,
					makeResourceRequestHandler!("index", ControllerT)
			);

		// POST, on collection
		static if (hasMember!(ControllerT, "create"))
			vibeRouter.post(
					pathPrefix,
					makeResourceRequestHandler!("create", ControllerT)
			);

		// GET /new, on collection
		static if (hasMember!(ControllerT, "build"))
			vibeRouter.get(
					joinPath([pathPrefix.normalizePath, "new"]),
					makeResourceRequestHandler!("build", ControllerT)
			);

		// GET request, on member
		static if (hasMember!(ControllerT, "show"))
			vibeRouter.get(
					memberPath,
					makeResourceRequestHandler!("show", ControllerT)
			);

		// PUT and PATCH requests, on member
		static if (hasMember!(ControllerT, "update"))
		{
			vibeRouter.put(
					memberPath,
					makeResourceRequestHandler!("update", ControllerT)
			);
			vibeRouter.patch(
					memberPath,
					makeResourceRequestHandler!("update", ControllerT)
			);
		}

		// DELETE request, on member
		static if (hasMember!(ControllerT, "destroy"))
			vibeRouter.delete_(
					memberPath,
					makeResourceRequestHandler!("destroy", ControllerT)
			);

		return this;
	}

	Router resource(string resourceName)()
	{
		mixin(q{import controllers.%s;}.format(resourceName));
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

auto makeResourceRequestHandler(string action, ControllerT : Controller)()
{
	void handle(HTTPServerRequest req, HTTPServerResponse res)
	{
		auto controller = new ControllerT;
		controller.initialize(action, Request(req), Response(res));

		mixin(q{controller.%s();}.format(action));
		controller.finalize();
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

