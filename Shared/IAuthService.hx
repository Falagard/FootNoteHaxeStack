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
