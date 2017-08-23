module derail.router;

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
		vibeRouter.getAllRoutes();
	}

	Router get(Handler)(string path, Handler handler)
	{
		vibeRouter.get(path, makeRequestHandler(handler));

		return this;
	}

	void listen(ushort port)
	{
		auto settings = new HTTPServerSettings;
		settings.port = 8080;

		listenHTTP(settings, vibeRouter);
	}
}

auto makeRequestHandler(Handler)(Handler handler)
{
	void requestHandler(HTTPServerRequest req, HTTPServerResponse res)
	{
		handler(Request(req), Response(res));
	}

	return &requestHandler;
}
