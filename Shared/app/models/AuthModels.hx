package app.models;

import Date;

typedef User = {
	var id:String;
	var email:String;
	var username:Null<String>;
	var passwordHash:Null<String>;
	var createdAt:Date;
	var updatedAt:Date;
	var isActive:Bool;
	var emailVerified:Bool;
}

typedef OAuthProvider = {
	var id:String;
	var userId:String;
	var provider:String; // "google", "github", "microsoft", etc.
	var providerUserId:String;
	var accessToken:Null<String>;
	var refreshToken:Null<String>;
	var tokenExpiresAt:Null<Date>;
	var createdAt:Date;
}

typedef Session = {
	var id:String;
	var userId:String;
	var token:String;
	var expiresAt:Date;
	var createdAt:Date;
	var ipAddress:Null<String>;
	var userAgent:Null<String>;
}

typedef LoginRequest = {
	var emailOrUsername:String;
	var password:String;
}

typedef RegisterRequest = {
	var email:String;
	var password:String;
	var ?username:String;
}

typedef OAuthLoginRequest = {
	var code:String;
	var redirectUri:String;
}

typedef LoginResponse = {
	var success:Bool;
	var ?token:String;
	var ?user:UserPublic;
	var ?error:String;
}

typedef RegisterResponse = {
	var success:Bool;
	var ?user:UserPublic;
	var ?error:String;
}

// Public user info (no sensitive data)
typedef UserPublic = {
	var id:String;
	var email:String;
	var username:Null<String>;
	var emailVerified:Bool;
}

typedef ChangePasswordRequest = {
	var oldPassword:String;
	var newPassword:String;
}
