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
