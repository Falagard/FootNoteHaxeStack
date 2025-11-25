package;

import VisibilityConfig;
import MegaMenuModels;
import IMegaMenuService;
import sidewinder.Database;
import haxe.Json;

class MegaMenuService implements IMegaMenuService {
    public function new() {}

    // Menus
    public function listMenus():Array<MenuDTO> {
        var conn = Database.acquire();
        var sql = "SELECT *, visibilityConfig FROM menus WHERE enabled = 1 ORDER BY sort_order ASC";
        var rs = conn.request(Database.buildSql(sql, new Map()));
        var menus = [];
        while (rs.hasNext()) {
            var menu = rs.next();
            menus.push(buildMenuDTO(menu));
        }
        Database.release(conn);
        return menus;
    }

    public function getMenu(id:Int):MenuDTO {
        var conn = Database.acquire();
        var params = new Map<String, Dynamic>();
        params.set("id", id);
        var sql = "SELECT *, visibilityConfig FROM menus WHERE id = @id";
        var rs = conn.request(Database.buildSql(sql, params));
        if (!rs.hasNext()) {
            Database.release(conn);
            return null;
        }
        var menu = rs.next();
        Database.release(conn);
        return buildMenuDTO(menu);
    }

    public function createMenu(menu:MenuDTO):Int {
        var conn = Database.acquire();
        var params = new Map<String, Dynamic>();
        params.set("name", menu.name);
        params.set("slug", menu.slug);
        params.set("icon", menu.icon);
        params.set("sort_order", menu.sortOrder);
        params.set("enabled", menu.enabled);
        params.set("visibilityConfig", haxe.Json.stringify(menu.visibilityConfig));
        var sql = "INSERT INTO menus (name, slug, icon, sort_order, enabled, visibilityConfig) VALUES (@name, @slug, @icon, @sort_order, @enabled, @visibilityConfig)";
        conn.request(Database.buildSql(sql, params));
        var id = conn.lastInsertId();
        Database.release(conn);
        return id;
    }

    public function updateMenu(id:Int, menu:MenuDTO):Bool {
        var conn = Database.acquire();
        var params = new Map<String, Dynamic>();
        params.set("id", id);
        params.set("name", menu.name);
        params.set("slug", menu.slug);
        params.set("icon", menu.icon);
        params.set("sort_order", menu.sortOrder);
        params.set("enabled", menu.enabled);
        params.set("visibilityConfig", haxe.Json.stringify(menu.visibilityConfig));
        var sql = "UPDATE menus SET name = @name, slug = @slug, icon = @icon, sort_order = @sort_order, enabled = @enabled, visibilityConfig = @visibilityConfig WHERE id = @id";
        conn.request(Database.buildSql(sql, params));
        Database.release(conn);
        return true;
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

    // Sections
    public function listSections(menuId:Int):Array<MenuSectionDTO> {
        var conn = Database.acquire();
        var params = new Map<String, Dynamic>();
        params.set("menu_id", menuId);
        var sql = "SELECT * FROM menu_sections WHERE menu_id = @menu_id AND enabled = 1 ORDER BY sort_order ASC";
        var rs = conn.request(Database.buildSql(sql, params));
        var sections = [];
        while (rs.hasNext()) {
            var section = rs.next();
            sections.push(buildSectionDTO(section));
        }
        Database.release(conn);
        return sections;
    }

    public function createSection(menuId:Int, section:MenuSectionDTO):Int {
        var conn = Database.acquire();
        var params = new Map<String, Dynamic>();
        params.set("menu_id", menuId);
        params.set("title", section.title);
        params.set("layout_type", section.layoutType);
        params.set("sort_order", section.sortOrder);
        params.set("enabled", section.enabled);
        var sql = "INSERT INTO menu_sections (menu_id, title, layout_type, sort_order, enabled) VALUES (@menu_id, @title, @layout_type, @sort_order, @enabled)";
        conn.request(Database.buildSql(sql, params));
        var id = conn.lastInsertId();
        Database.release(conn);
        return id;
    }

    public function updateSection(id:Int, section:MenuSectionDTO):Bool {
        var conn = Database.acquire();
        var params = new Map<String, Dynamic>();
        params.set("id", id);
        params.set("title", section.title);
        params.set("layout_type", section.layoutType);
        params.set("sort_order", section.sortOrder);
        params.set("enabled", section.enabled);
        var sql = "UPDATE menu_sections SET title = @title, layout_type = @layout_type, sort_order = @sort_order, enabled = @enabled WHERE id = @id";
        conn.request(Database.buildSql(sql, params));
        Database.release(conn);
        return true;
    }

    public function deleteSection(id:Int):Bool {
        var conn = Database.acquire();
        var params = new Map<String, Dynamic>();
        params.set("id", id);
        var sql = "DELETE FROM menu_sections WHERE id = @id";
        conn.request(Database.buildSql(sql, params));
        Database.release(conn);
        return true;
    }

    // Items
    public function listItems(sectionId:Int):Array<MenuItemDTO> {
        var conn = Database.acquire();
        var params = new Map<String, Dynamic>();
        params.set("section_id", sectionId);
        var sql = "SELECT *, visibilityConfig FROM menu_items WHERE section_id = @section_id AND enabled = 1 ORDER BY sort_order ASC";
        var rs = conn.request(Database.buildSql(sql, params));
        var items = [];
        while (rs.hasNext()) {
            var item = rs.next();
            items.push(buildItemDTO(item));
        }
        Database.release(conn);
        return items;
    }

    public function createItem(sectionId:Int, item:MenuItemDTO):Int {
        var conn = Database.acquire();
        var params = new Map<String, Dynamic>();
        params.set("section_id", sectionId);
        params.set("label", item.label);
        params.set("description", item.description);
        params.set("url", item.url);
        params.set("icon", item.icon);
        params.set("item_type", item.itemType);
        params.set("custom_component", item.customComponent);
        params.set("sort_order", item.sortOrder);
        params.set("enabled", item.enabled);
        params.set("visibilityConfig", haxe.Json.stringify(item.visibilityConfig));
        var sql = "INSERT INTO menu_items (section_id, label, description, url, icon, item_type, custom_component, sort_order, enabled, visibilityConfig) VALUES (@section_id, @label, @description, @url, @icon, @item_type, @custom_component, @sort_order, @enabled, @visibilityConfig)";
        conn.request(Database.buildSql(sql, params));
        var id = conn.lastInsertId();
        Database.release(conn);
        return id;
    }

    public function updateItem(id:Int, item:MenuItemDTO):Bool {
        var conn = Database.acquire();
        var params = new Map<String, Dynamic>();
        params.set("id", id);
        params.set("label", item.label);
        params.set("description", item.description);
        params.set("url", item.url);
        params.set("icon", item.icon);
        params.set("item_type", item.itemType);
        params.set("custom_component", item.customComponent);
        params.set("sort_order", item.sortOrder);
        params.set("enabled", item.enabled);
        params.set("visibilityConfig", haxe.Json.stringify(item.visibilityConfig));
        var sql = "UPDATE menu_items SET label = @label, description = @description, url = @url, icon = @icon, item_type = @item_type, custom_component = @custom_component, sort_order = @sort_order, enabled = @enabled, visibilityConfig = @visibilityConfig WHERE id = @id";
        conn.request(Database.buildSql(sql, params));
        Database.release(conn);
        return true;
    }

    public function deleteItem(id:Int):Bool {
        var conn = Database.acquire();
        var params = new Map<String, Dynamic>();
        params.set("id", id);
        var sql = "DELETE FROM menu_items WHERE id = @id";
        conn.request(Database.buildSql(sql, params));
        Database.release(conn);
        return true;
    }

    // Metadata
    public function listMetadata(itemId:Int):Array<MenuItemMetadataDTO> {
        var conn = Database.acquire();
        var params = new Map<String, Dynamic>();
        params.set("item_id", itemId);
        var sql = "SELECT * FROM menu_item_metadata WHERE item_id = @item_id";
        var rs = conn.request(Database.buildSql(sql, params));
        var metadata = [];
        while (rs.hasNext()) {
            var meta = rs.next();
            metadata.push({
                id: Std.int(meta.id),
                itemId: Std.int(meta.item_id),
                keyName: Std.string(meta.key_name),
                value: Std.string(meta.value)
            });
        }
        Database.release(conn);
        return metadata;
    }

    public function createMetadata(itemId:Int, metadata:MenuItemMetadataDTO):Int {
        var conn = Database.acquire();
        var params = new Map<String, Dynamic>();
        params.set("item_id", itemId);
        params.set("key_name", metadata.keyName);
        params.set("value", metadata.value);
        var sql = "INSERT INTO menu_item_metadata (item_id, key_name, value) VALUES (@item_id, @key_name, @value)";
        conn.request(Database.buildSql(sql, params));
        var id = conn.lastInsertId();
        Database.release(conn);
        return id;
    }

    public function updateMetadata(id:Int, metadata:MenuItemMetadataDTO):Bool {
        var conn = Database.acquire();
        var params = new Map<String, Dynamic>();
        params.set("id", id);
        params.set("key_name", metadata.keyName);
        params.set("value", metadata.value);
        var sql = "UPDATE menu_item_metadata SET key_name = @key_name, value = @value WHERE id = @id";
        conn.request(Database.buildSql(sql, params));
        Database.release(conn);
        return true;
    }

    public function deleteMetadata(id:Int):Bool {
        var conn = Database.acquire();
        var params = new Map<String, Dynamic>();
        params.set("id", id);
        var sql = "DELETE FROM menu_item_metadata WHERE id = @id";
        conn.request(Database.buildSql(sql, params));
        Database.release(conn);
        return true;
    }

    // Helper builders
    private function buildMenuDTO(menu:Dynamic):MenuDTO {
            return {
                id: Std.int(menu.id),
                name: Std.string(menu.name),
                slug: Std.string(menu.slug),
                icon: menu.icon,
                sortOrder: Std.int(menu.sort_order),
                enabled: menu.enabled == 1,
                sections: listSections(menu.id),
                visibilityConfig: menu.visibilityConfig != null ? haxe.Json.parse(menu.visibilityConfig) : { visibilityMode: "Public", groupIds: [] }
            };
    }

    private function buildSectionDTO(section:Dynamic):MenuSectionDTO {
        return {
            id: Std.int(section.id),
            menuId: Std.int(section.menu_id),
            title: section.title,
            layoutType: section.layout_type,
            sortOrder: Std.int(section.sort_order),
            enabled: section.enabled == 1,
            items: listItems(section.id)
        };
    }

    private function buildItemDTO(item:Dynamic):MenuItemDTO {
            return {
                id: Std.int(item.id),
                sectionId: Std.int(item.section_id),
                label: item.label,
                description: item.description,
                url: item.url,
                icon: item.icon,
                itemType: item.item_type,
                customComponent: item.custom_component,
                sortOrder: Std.int(item.sort_order),
                enabled: item.enabled == 1,
                metadata: listMetadata(item.id),
                visibilityConfig: item.visibilityConfig != null ? haxe.Json.parse(item.visibilityConfig) : { visibilityMode: "Public", groupIds: [] }
            };
    }
}
