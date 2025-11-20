package;

import MenuApiModels;

import MenuModels;
import IMenuService;
import sidewinder.Database;
import haxe.Json;

class MenuService implements IMenuService {

	public function new() {}

    public function getMenuByName(name:String):MenuDTO {
		var conn = Database.acquire();
		var params = new Map<String, Dynamic>();
		params.set("name", name);
		var sql = "SELECT * FROM menus WHERE name = @name";
		var rs = conn.request(Database.buildSql(sql, params));
		if (!rs.hasNext()) {
			Database.release(conn);
			return null;
		}
		var menu = rs.next();
		var items = listMenuItems(menu.id);
		Database.release(conn);
		return {
			id: menu.id,
			name: menu.name,
			createdAt: Date.fromString(menu.created_at),
			items: items
		};
	}

	public function createMenu(request:CreateMenuRequest):CreateMenuResponse {
		var conn = Database.acquire();
		var params = new Map<String, Dynamic>();
		params.set("name", request.name);
		// Check for duplicate name
		var sql = "SELECT id FROM menus WHERE name = @name";
		var rs = conn.request(Database.buildSql(sql, params));
		if (rs.hasNext()) {
			Database.release(conn);
			return {success: false, error: "Duplicate menu name"};
		}
		sql = "INSERT INTO menus (name) VALUES (@name)";
		conn.request(Database.buildSql(sql, params));
		var id = conn.lastInsertId();
		Database.release(conn);
		return {success: true, menuId: id};
	}

	public function updateMenu(menuId:Int, request:UpdateMenuRequest):UpdateMenuResponse {
		var conn = Database.acquire();
		var params = new Map<String, Dynamic>();
		params.set("id", menuId);
		params.set("name", request.name);
		// Check for duplicate name (exclude current menu)
		var sql = "SELECT id FROM menus WHERE name = @name AND id != @id";
		var rs = conn.request(Database.buildSql(sql, params));
		if (rs.hasNext()) {
			Database.release(conn);
			return {success: false, error: "Duplicate menu name"};
		}
		sql = "UPDATE menus SET name = @name WHERE id = @id";
		conn.request(Database.buildSql(sql, params));
		Database.release(conn);
		return {success: true};
	}

	public function deleteMenu(id:Int):Bool {
		var conn = Database.acquire();
		var params = new Map<String, Dynamic>();
		params.set("id", id);
		var sql = "DELETE FROM menus WHERE id = @id";
		conn.request(Database.buildSql(sql, params));
		Database.release(conn);
		return true;
	}

	public function getMenu(id:Int):MenuDTO {
		var conn = Database.acquire();
		var params = new Map<String, Dynamic>();
		params.set("id", id);
		var sql = "SELECT * FROM menus WHERE id = @id";
		var rs = conn.request(Database.buildSql(sql, params));
		if (!rs.hasNext()) {
			Database.release(conn);
			return null;
		}
		var menu = rs.next();
		var items = this.listMenuItems(id);
		Database.release(conn);
		return {
			id: menu.id,
			name: menu.name,
			createdAt: Date.fromString(menu.created_at),
			items: items
		};
	}

	public function listMenus():Array<MenuDTO> {
		var conn = Database.acquire();
		var sql = "SELECT * FROM menus";
		var rs = conn.request(Database.buildSql(sql, new Map()));
		var menus = [];
		while (rs.hasNext()) {
			var menu = rs.next();
			menus.push(getMenu(menu.id));
		}
		Database.release(conn);
		return menus;
	}

	public function createMenuItem(item:MenuItemDTO):Int {
		var conn = Database.acquire();
		var params = new Map<String, Dynamic>();
		params.set("menu_id", item.menuId);
		params.set("parent_id", item.parentId);
		params.set("title", item.title);
		params.set("page_id", item.pageId);
		params.set("external_url", item.externalUrl);
		params.set("sort_order", item.sortOrder);
		var sql = "INSERT INTO menu_items (menu_id, parent_id, title, page_id, external_url, sort_order) VALUES (@menu_id, @parent_id, @title, @page_id, @external_url, @sort_order)";
		conn.request(Database.buildSql(sql, params));
		var id = conn.lastInsertId();
		Database.release(conn);
		return id;
	}

	public function updateMenuItem(menuItemId:Int, item:MenuItemDTO):Bool {
		var conn = Database.acquire();
		var params = new Map<String, Dynamic>();
		params.set("id", menuItemId);
		params.set("menu_id", item.menuId);
		params.set("parent_id", item.parentId);
		params.set("title", item.title);
		params.set("page_id", item.pageId);
		params.set("external_url", item.externalUrl);
		params.set("sort_order", item.sortOrder);
		var sql = "UPDATE menu_items SET menu_id = @menu_id, parent_id = @parent_id, title = @title, page_id = @page_id, external_url = @external_url, sort_order = @sort_order WHERE id = @id";
		conn.request(Database.buildSql(sql, params));
		Database.release(conn);
		return true;
	}

	public function deleteMenuItem(id:Int):Bool {
		var conn = Database.acquire();
		var params = new Map<String, Dynamic>();
		params.set("id", id);
		var sql = "DELETE FROM menu_items WHERE id = @id";
		conn.request(Database.buildSql(sql, params));
		Database.release(conn);
		return true;
	}

	public function getMenuItem(id:Int):MenuItemDTO {
		var conn = Database.acquire();
		var params = new Map<String, Dynamic>();
		params.set("id", id);
		var sql = "SELECT * FROM menu_items WHERE id = @id";
		var rs = conn.request(Database.buildSql(sql, params));
		if (!rs.hasNext()) {
			Database.release(conn);
			return null;
		}
		var item = rs.next();
		Database.release(conn);
		return buildMenuItemDTO(item);
	}

	public function listMenuItems(menuId:Int):Array<MenuItemDTO> {
		var conn = Database.acquire();
		var params = new Map<String, Dynamic>();
		params.set("menu_id", menuId);
		var sql = "SELECT * FROM menu_items WHERE menu_id = @menu_id ORDER BY sort_order ASC";
		var rs = conn.request(Database.buildSql(sql, params));
		var items = [];
		var itemMap = new Map<Int, MenuItemDTO>();
		while (rs.hasNext()) {
			var item = rs.next();
			var dto = buildMenuItemDTO(item);
			itemMap.set(dto.id, dto);
			items.push(dto);
		}
		// Build hierarchy
		for (item in items) {
			if (item.parentId != null && itemMap.exists(item.parentId)) {
				if (itemMap[item.parentId].children == null)
					itemMap[item.parentId].children = [];
				itemMap[item.parentId].children.push(item);
			}
		}
		// Return only root items
		var roots = [for (item in items) if (item.parentId == null) item];
		Database.release(conn);
		return roots;
	}

	private function buildMenuItemDTO(item:Dynamic):MenuItemDTO {
		return {
			id: Std.int(item.id),
			menuId: Std.int(item.menu_id),
			parentId: item.parent_id != null ? Std.int(item.parent_id) : null,
			title: Std.string(item.title),
			pageId: item.page_id != null ? Std.int(item.page_id) : null,
			externalUrl: item.external_url,
			sortOrder: item.sort_order != null ? Std.int(item.sort_order) : 0,
			createdAt: Date.fromString(item.created_at),
			children: []
		};
	}
}
