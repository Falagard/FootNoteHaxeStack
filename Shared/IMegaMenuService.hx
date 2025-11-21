package;

import MegaMenuModels;
import hx.injection.Service;

interface IMegaMenuService extends Service {
    // Menus
    @get("/pub/menus")
    function listMenus():Array<MenuDTO>;
    
    @get("/api/menu/:id")
    function getMenu(id:Int):MenuDTO;
    @post("/api/menu")
    function createMenu(menu:MenuDTO):Int;
    @put("/api/menu/:id")
    function updateMenu(id:Int, menu:MenuDTO):Bool;
    @delete("/api/menu/:id")
    function deleteMenu(id:Int):Bool;

    // Sections
    @get("/api/menu/:menuId/sections")
    function listSections(menuId:Int):Array<MenuSectionDTO>;
    @post("/api/menu/:menuId/section")
    function createSection(menuId:Int, section:MenuSectionDTO):Int;
    @put("/api/menu/section/:id")
    function updateSection(id:Int, section:MenuSectionDTO):Bool;
    @delete("/api/menu/section/:id")
    function deleteSection(id:Int):Bool;

    // Items
    @get("/api/menu/section/:sectionId/items")
    function listItems(sectionId:Int):Array<MenuItemDTO>;
    @post("/api/menu/section/:sectionId/item")
    function createItem(sectionId:Int, item:MenuItemDTO):Int;
    @put("/api/menu/item/:id")
    function updateItem(id:Int, item:MenuItemDTO):Bool;
    @delete("/api/menu/item/:id")
    function deleteItem(id:Int):Bool;

    // Metadata
    @get("/api/menu/item/:itemId/metadata")
    function listMetadata(itemId:Int):Array<MenuItemMetadataDTO>;
    @post("/api/menu/item/:itemId/metadata")
    function createMetadata(itemId:Int, metadata:MenuItemMetadataDTO):Int;
    @put("/api/menu/metadata/:id")
    function updateMetadata(id:Int, metadata:MenuItemMetadataDTO):Bool;
    @delete("/api/menu/metadata/:id")
    function deleteMetadata(id:Int):Bool;
}

typedef IMegaMenuServiceAsync = {
    // Menus
    function listMenusAsync(success:Array<MenuDTO>->Void, failure:Dynamic->Void):Void;
    function getMenuAsync(id:Int, success:MenuDTO->Void, failure:Dynamic->Void):Void;
    function createMenuAsync(menu:MenuDTO, success:Int->Void, failure:Dynamic->Void):Void;
    function updateMenuAsync(id:Int, menu:MenuDTO, success:Bool->Void, failure:Dynamic->Void):Void;
    function deleteMenuAsync(id:Int, success:Bool->Void, failure:Dynamic->Void):Void;

    // Sections
    function listSectionsAsync(menuId:Int, success:Array<MenuSectionDTO>->Void, failure:Dynamic->Void):Void;
    function createSectionAsync(menuId:Int, section:MenuSectionDTO, success:Int->Void, failure:Dynamic->Void):Void;
    function updateSectionAsync(id:Int, section:MenuSectionDTO, success:Bool->Void, failure:Dynamic->Void):Void;
    function deleteSectionAsync(id:Int, success:Bool->Void, failure:Dynamic->Void):Void;

    // Items
    function listItemsAsync(sectionId:Int, success:Array<MenuItemDTO>->Void, failure:Dynamic->Void):Void;
    function createItemAsync(sectionId:Int, item:MenuItemDTO, success:Int->Void, failure:Dynamic->Void):Void;
    function updateItemAsync(id:Int, item:MenuItemDTO, success:Bool->Void, failure:Dynamic->Void):Void;
    function deleteItemAsync(id:Int, success:Bool->Void, failure:Dynamic->Void):Void;

    // Metadata
    function listMetadataAsync(itemId:Int, success:Array<MenuItemMetadataDTO>->Void, failure:Dynamic->Void):Void;
    function createMetadataAsync(itemId:Int, metadata:MenuItemMetadataDTO, success:Int->Void, failure:Dynamic->Void):Void;
    function updateMetadataAsync(id:Int, metadata:MenuItemMetadataDTO, success:Bool->Void, failure:Dynamic->Void):Void;
    function deleteMetadataAsync(id:Int, success:Bool->Void, failure:Dynamic->Void):Void;
}
