module derail.core.http;

import vibe.http.server : HTTPServerRequest;
import vibe.http.server : HTTPServerResponse;

struct Request
{
	HTTPServerRequest request;

	this(HTTPServerRequest request)
	{
		this.request = request;
	}

	alias request this;
}

struct Response
{
	HTTPServerResponse response;

	this(HTTPServerResponse response)
	{
		this.response = response;
	}

	alias response this;
}

