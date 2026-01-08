package core;

class ServerConfig {
	public var protocol:String;
	public var host:String;
	public var port:Int;
	public var corsEnabled:Bool;
	public var cacheEnabled:Bool;
	public var silent:Bool;
	public var directory:String;

	public function new() {
		protocol = "HTTP/1.0";
		host = "127.0.0.1";
		port = 8000;
		corsEnabled = false;
		cacheEnabled = true;
		silent = true;
		directory = null;
	}
}
