package app.services;

import sidewinder.AutoClientAsync;
import app.services.IAuthService;
import app.services.ICmsService;
import app.services.IMegaMenuService;
import sidewinder.ICookieJar;
import sidewinder.CookieJar;

/**
 * Holds async (callback-based) service clients generated via AutoClientAsync.
 * Methods are suffixed with Async (e.g. listProjectsAsync). Fields are Dynamic because
 * generated classes do not implement the original interface directly.
 */
class AsyncServiceRegistry {
	public static var instance(default, null):AsyncServiceRegistry = new AsyncServiceRegistry(ServiceRegistry.instance.baseUrl);

	public var baseUrl(default, null):String;
	public var cookieJar(default, null):ICookieJar;

	public var auth:IAuthServiceAsync; // authentication service
	public var cms:ICmsServiceAsync; // CMS service
	public var megaMenu:IMegaMenuServiceAsync; // MegaMenu service

	public function new(baseUrl:String) {
		this.baseUrl = baseUrl;
		cookieJar = new CookieJar();
		createClients();
	}

	private function createClients():Void {
		auth = AutoClientAsync.create(IAuthService, baseUrl, cookieJar);
		cms = AutoClientAsync.create(ICmsService, baseUrl, cookieJar);
		megaMenu = AutoClientAsync.create(IMegaMenuService, baseUrl, cookieJar);
	}

	public function resetBaseUrl(newUrl:String):Void {
		if (newUrl == baseUrl)
			return;
		baseUrl = newUrl;
		createClients();
	}
}
