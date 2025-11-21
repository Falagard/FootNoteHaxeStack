package;

import Date;

typedef MenuDTO = {
    id:Int,
    name:String,
    slug:String,
    icon:String,
    sortOrder:Int,
    enabled:Bool,
    sections:Array<MenuSectionDTO>
};

typedef MenuSectionDTO = {
    id:Int,
    menuId:Int,
    title:String,
    layoutType:String,
    sortOrder:Int,
    enabled:Bool,
    items:Array<MenuItemDTO>
};

typedef MenuItemDTO = {
    id:Int,
    sectionId:Int,
    label:String,
    description:String,
    url:String,
    icon:String,
    itemType:String,
    customComponent:String,
    sortOrder:Int,
    enabled:Bool,
    metadata:Array<MenuItemMetadataDTO>
};

typedef MenuItemMetadataDTO = {
    id:Int,
    itemId:Int,
    keyName:String,
    value:String
};
