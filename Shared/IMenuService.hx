package;

import MenuApiModels;

import MenuModels;
import hx.injection.Service;

interface IMenuService extends Service {

    @get("/pub/menu/name/:name")
    function getMenuByName(name:String):MenuDTO;

    @post("/api/menu")
    @requiresAuth
    function createMenu(request:CreateMenuRequest):CreateMenuResponse;

    @put("/api/menu/:menuId")
    @requiresAuth
    function updateMenu(menuId:Int, request:UpdateMenuRequest):UpdateMenuResponse;

    @delete("/api/menu/:id")
    @requiresAuth
    function deleteMenu(id:Int):Bool;

    @get("/api/menu/:id")
    function getMenu(id:Int):MenuDTO;

    @get("/api/menus")
    function listMenus():Array<MenuDTO>;

    @post("/api/menu/item")
    @requiresAuth
    function createMenuItem(item:MenuItemDTO):Int;

    @put("/api/menu/item/:menuItemId")
    @requiresAuth
    function updateMenuItem(menuItemId:Int, item:MenuItemDTO):Bool;

    @delete("/api/menu/item/:id")
    @requiresAuth
    function deleteMenuItem(id:Int):Bool;

    @get("/api/menu/item/:id")
    function getMenuItem(id:Int):MenuItemDTO;

    @get("/api/menu/:menuId/items")
    function listMenuItems(menuId:Int):Array<MenuItemDTO>;
}
