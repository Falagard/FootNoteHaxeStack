package core.middleware;

import sidewinder.App;
import sidewinder.HybridLogger;

class LoggingMiddleware {
	public static function use() {
		App.use((req, res, next) -> {
			HybridLogger.info('${req.method} ${req.path} ' + Sys.time());
			next();
		});
	}
}
