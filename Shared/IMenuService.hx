package;

import MenuModels;
import hx.injection.Service;

interface IMenuService extends Service {
    @post("/api/menu")
    function createMenu(name:String):Int;

    @put("/api/menu/:id")
    function updateMenu(id:Int, name:String):Bool;

    @delete("/api/menu/:id")
    function deleteMenu(id:Int):Bool;

    @get("/api/menu/:id")
    function getMenu(id:Int):MenuDTO;

    @get("/api/menus")
    function listMenus():Array<MenuDTO>;

    @post("/api/menu/item")
    function createMenuItem(item:MenuItemDTO):Int;

    @put("/api/menu/item/:id")
    function updateMenuItem(item:MenuItemDTO):Bool;

    @delete("/api/menu/item/:id")
    function deleteMenuItem(id:Int):Bool;

    @get("/api/menu/item/:id")
    function getMenuItem(id:Int):MenuItemDTO;

    @get("/api/menu/:menuId/items")
    function listMenuItems(menuId:Int):Array<MenuItemDTO>;
}
