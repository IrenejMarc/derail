module derail.exceptions;

class DerailException : Exception
{
	this(string message)
	{
		super(message);
	}
}

class UnsupportedFormatException : Exception
{
	this(string message)
	{
		super(message);
	}
}
