package;

typedef CreateMenuRequest = {
	name:String
};

typedef CreateMenuResponse = {
	success:Bool,
	?menuId:Null<Int>,
	?error:String
};

typedef UpdateMenuRequest = {
	id:Int,
	name:String
};

typedef UpdateMenuResponse = {
	success:Bool,
	?error:String
};
