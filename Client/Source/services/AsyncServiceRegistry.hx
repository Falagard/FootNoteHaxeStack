package services;

import sidewinder.AutoClientAsync;
import IAuthService;
import ICmsService;
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

    public var auth:Dynamic; // authentication service
    public var cms:Dynamic; // CMS service
    public var menu:Dynamic; 

    public function new(baseUrl:String) {
        this.baseUrl = baseUrl;
        cookieJar = new CookieJar();
        createClients();
    }

    private function createClients():Void {
        auth = AutoClientAsync.create(IAuthService, baseUrl, cookieJar);
        cms = AutoClientAsync.create(ICmsService, baseUrl, cookieJar);
        menu = AutoClientAsync.create(IMenuService, baseUrl, cookieJar);
    }

    public function resetBaseUrl(newUrl:String):Void {
        if (newUrl == baseUrl) return;
        baseUrl = newUrl;
        createClients();
    }
}
