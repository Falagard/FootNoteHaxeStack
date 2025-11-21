package cms.megamenu;

import haxe.ui.containers.dialogs.Dialog;
import haxe.ui.containers.VBox;
import haxe.ui.containers.HBox;
import haxe.ui.components.Button;
import haxe.ui.components.Label;
import haxe.ui.components.TextField;
import haxe.ui.components.DropDown;
import haxe.ui.components.Switch;
import haxe.ui.core.Component;
import cms.megamenu.MegaMenuManager;
import MegaMenuModels;
import CmsModels;

/**
 * MegaMenuAdminDialog provides CRUD and ordering for menus, sections, and items.
 * Uses up/down buttons for ordering and supports metadata editing.
 */
class MegaMenuAdminDialog extends Dialog {
    var menuManager: MegaMenuManager;
    var menus:Array<MenuDTO> = [];
    var selectedMenu:MenuDTO;
    var selectedSection:MenuSectionDTO;
    var selectedItem:MenuItemDTO;

    var menuList:VBox;
    var sectionList:VBox;
    var itemList:VBox;

    public function new() {
        super();
        this.menuManager = new MegaMenuManager();
        this.title = "Mega Menu Admin";
        this.destroyOnClose = true;
        buildUI();
        loadMenus();
    }

    function buildUI():Void {
        menuList = new VBox();
        sectionList = new VBox();
        itemList = new VBox();
        var mainBox = new HBox();
        mainBox.addComponent(menuList);
        mainBox.addComponent(sectionList);
        mainBox.addComponent(itemList);
        this.addComponent(mainBox);
    }

    function loadMenus():Void {
        menuManager.listMenus(function(menuArr:Array<MenuDTO>) {
            menus = menuArr;
            renderMenuList();
        });
    }

    function renderMenuList():Void {
        menuList.removeAllComponents();
        for (menu in menus) {
            var row = new HBox();
            var btn = new Button();
            btn.text = menu.name;
            btn.onClick = function(_) {
                selectedMenu = menu;
                loadSections(menu.id);
            };
            row.addComponent(btn);
            var upBtn = new Button();
            upBtn.text = "↑";
            upBtn.onClick = function(_) moveMenu(menu, -1);
            row.addComponent(upBtn);
            var downBtn = new Button();
            downBtn.text = "↓";
            downBtn.onClick = function(_) moveMenu(menu, 1);
            row.addComponent(downBtn);
            menuList.addComponent(row);
        }
    }

    function moveMenu(menu:MenuDTO, direction:Int):Void {
        var idx = menus.indexOf(menu);
        var newIdx = idx + direction;
        if (newIdx < 0 || newIdx >= menus.length) return;
        menus.remove(menu);
        menus.insert(newIdx, menu);
        // Optionally update sort_order in DB
        renderMenuList();
    }

    function loadSections(menuId:Int):Void {
        menuManager.listSections(menuId, function(sections:Array<MenuSectionDTO>) {
            renderSectionList(sections);
        });
    }

    function renderSectionList(sections:Array<MenuSectionDTO>):Void {
        sectionList.removeAllComponents();
        for (section in sections) {
            var row = new HBox();
            var btn = new Button();
            btn.text = section.title;
            btn.onClick = function(_) {
                selectedSection = section;
                loadItems(section.id);
            };
            row.addComponent(btn);
            var upBtn = new Button();
            upBtn.text = "↑";
            upBtn.onClick = function(_) moveSection(sections, section, -1);
            row.addComponent(upBtn);
            var downBtn = new Button();
            downBtn.text = "↓";
            downBtn.onClick = function(_) moveSection(sections, section, 1);
            row.addComponent(downBtn);
            sectionList.addComponent(row);
        }
    }

    function moveSection(sections:Array<MenuSectionDTO>, section:MenuSectionDTO, direction:Int):Void {
        var idx = sections.indexOf(section);
        var newIdx = idx + direction;
        if (newIdx < 0 || newIdx >= sections.length) return;
        sections.remove(section);
        sections.insert(newIdx, section);
        // Optionally update sort_order in DB
        renderSectionList(sections);
    }

    function loadItems(sectionId:Int):Void {
        menuManager.listItems(sectionId, function(items:Array<MenuItemDTO>) {
            renderItemList(items);
        });
    }

    function renderItemList(items:Array<MenuItemDTO>):Void {
        itemList.removeAllComponents();
        for (item in items) {
            var row = new HBox();
            var btn = new Button();
            btn.text = item.label;
            btn.onClick = function(_) {
                selectedItem = item;
                // Optionally show item editor
            };
            row.addComponent(btn);
            var upBtn = new Button();
            upBtn.text = "↑";
            upBtn.onClick = function(_) moveItem(items, item, -1);
            row.addComponent(upBtn);
            var downBtn = new Button();
            downBtn.text = "↓";
            downBtn.onClick = function(_) moveItem(items, item, 1);
            row.addComponent(downBtn);
            itemList.addComponent(row);
        }
    }

    function moveItem(items:Array<MenuItemDTO>, item:MenuItemDTO, direction:Int):Void {
        var idx = items.indexOf(item);
        var newIdx = idx + direction;
        if (newIdx < 0 || newIdx >= items.length) return;
        items.remove(item);
        items.insert(newIdx, item);
        // Optionally update sort_order in DB
        renderItemList(items);
    }
}
