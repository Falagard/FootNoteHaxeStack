package;

import Date;

typedef MenuDTO = {
	id:Int,
	name:String,
	createdAt:Date,
	items:Array<MenuItemDTO>
};

typedef MenuItemDTO = {
	id:Int,
	menuId:Int,
	parentId:Null<Int>,
	title:String,
	pageId:Null<Int>,
	externalUrl:Null<String>,
	sortOrder:Int,
	createdAt:Date,
	children:Array<MenuItemDTO>
};
