package snake.http;

enum abstract HTTPStatus(Int) from Int to Int {
	var OK = 200;
	var CREATED = 201;
	var FOUND = 302;
	var BAD_REQUEST = 400;
	var UNAUTHORIZED = 401;
	var FORBIDDEN = 403;
	var NOT_FOUND = 404;
	var INTERNAL_SERVER_ERROR = 500;
}
