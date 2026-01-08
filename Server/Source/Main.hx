package;

import app.ServerApp;

class Main extends ServerApp {
	public function new() {
		super();
	}
	
	public static function main() {
		var app = new Main();
		app.exec();
	}
}
