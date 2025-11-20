
package;

import Date;

typedef MenuItemComponentDTO = {
	id:Int,
	menuItemId:Int,
	sortOrder:Int,
	type:String,
	data:Dynamic
};

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
    ,components:Array<MenuItemComponentDTO>
};
