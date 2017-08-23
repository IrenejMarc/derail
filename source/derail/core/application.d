module derail.core.application;

import derail.core.router;

class Application
{
	Router router;

	this()
	{
		router = new Router;
	}

	void run()
	{
		import vibe.core.core : runApplication;

		router.listen(8080);
		runApplication();
	}
}
