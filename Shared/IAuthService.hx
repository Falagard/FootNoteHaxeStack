package;

import AuthModels;
import hx.injection.Service;

interface IAuthService extends Service {
	// Local authentication endpoints
	@post("/api/auth/register")
	public function register(request:RegisterRequest):RegisterResponse;
	
    @post("/api/auth/login")
	public function login(request:LoginRequest):LoginResponse;
	
	@post("/api/auth/logout")
	public function logout():Bool;
	
	@get("/api/auth/me")
	public function getCurrentUser():Null<UserPublic>;
	
	// OAuth endpoints
	@post("/api/auth/oauth/:provider")
	public function oauthLogin(provider:String, request:OAuthLoginRequest):LoginResponse;
	
	@post("/api/auth/link-oauth/:provider")
	public function linkOAuthProvider(provider:String, request:OAuthLoginRequest):Bool;
	
	// Password management
	@post("/api/auth/change-password")
	public function changePassword(request:ChangePasswordRequest):Bool;
	
	@post("/api/auth/reset-password")
	public function requestPasswordReset(email:String):Bool;
	
	@post("/api/auth/verify-email")
	public function verifyEmail(code:String):Bool;
	
	// Session management
	@post("/api/auth/refresh")
	public function refreshSession():Null<Session>;
}

typedef IAuthServiceAsync = {
    // Local authentication endpoints
    function registerAsync(request:RegisterRequest, success:RegisterResponse->Void, failure:Dynamic->Void):Void;
    function loginAsync(request:LoginRequest, success:LoginResponse->Void, failure:Dynamic->Void):Void;
    function logoutAsync(success:Bool->Void, failure:Dynamic->Void):Void;
    function getCurrentUserAsync(success:Null<UserPublic>->Void, failure:Dynamic->Void):Void;

    // OAuth endpoints
    function oauthLoginAsync(provider:String, request:OAuthLoginRequest, success:LoginResponse->Void, failure:Dynamic->Void):Void;
    function linkOAuthProviderAsync(provider:String, request:OAuthLoginRequest, success:Bool->Void, failure:Dynamic->Void):Void;

    // Password management
    function changePasswordAsync(request:ChangePasswordRequest, success:Bool->Void, failure:Dynamic->Void):Void;
    function requestPasswordResetAsync(email:String, success:Bool->Void, failure:Dynamic->Void):Void;
    function verifyEmailAsync(code:String, success:Bool->Void, failure:Dynamic->Void):Void;

    // Session management
    function refreshSessionAsync(success:Null<Session>->Void, failure:Dynamic->Void):Void;
}