package core.util;

import haxe.ui.Toolkit;
import haxe.Timer;

/** Utility to run blocking service calls off the UI thread (no-op on single threaded targets, uses Timer to defer) */
class AsyncExec {
	public static function run<T>(fn:Void->T, callback:T->Void, ?error:(Dynamic->Void)):Void {
		// Generic fallback: Defer execution to allow UI update, but run on same thread.
		Timer.delay(function() {
			var result:T = null;
			try {
				result = fn();
			} catch (e:Dynamic) {
				if (error != null)
					error(e);
				else
					trace('AsyncExec error: ' + e);
				return;
			}
			Toolkit.callLater(function() callback(result));
		}, 1);
	}
}
