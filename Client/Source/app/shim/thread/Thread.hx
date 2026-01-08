package app.shim.thread;

import haxe.Timer;

class Thread {
	public static function create(job:Void->Void):Thread {
		Timer.delay(job, 1);
		return new Thread();
	}

	public function new() {}

	public static function readMessage(block:Bool = true):Dynamic {
		return null;
	}

	public static function sendMessage(msg:Dynamic):Void {}

	public static function current():Thread {
		return new Thread();
	}
}
