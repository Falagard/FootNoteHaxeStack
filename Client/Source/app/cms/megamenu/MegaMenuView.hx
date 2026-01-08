package app.cms.megamenu;

import haxe.ui.containers.VBox;
import haxe.ui.containers.HBox;
import haxe.ui.components.Button;
import haxe.ui.components.Label;
import haxe.ui.components.Image;
import haxe.ui.components.TextField;
import haxe.ui.components.DropDown;
import haxe.ui.components.Switch;
import haxe.ui.containers.dialogs.Dialog;
import haxe.ui.core.Component;
import app.cms.megamenu.MegaMenuManager;
import app.models.MegaMenuModels;
import app.models.CmsModels;

/**
 * MegaMenuView renders the runtime mega menu UI using data from IMegaMenuService.
 */
class MegaMenuView extends VBox {
	var menuManager:MegaMenuManager;
	var menus:Array<MenuDTO> = [];

	public function new() {
		super();
		this.menuManager = new MegaMenuManager();
		loadMenus();
	}

	function loadMenus():Void {
		menuManager.listMenus(function(menuList:Array<MenuDTO>) {
			menus = menuList;
			renderMenus();
		});
	}

	function renderMenus():Void {
		this.removeAllComponents();
		var menuBar = new HBox();
		for (menu in menus) {
			if (!menu.enabled)
				continue;
			var btn = new Button();
			btn.text = menu.name;
			btn.userData = menu.id;
			btn.onClick = function(_) showMegaMenu(menu);
			menuBar.addComponent(btn);
		}
		this.addComponent(menuBar);
	}

	function showMegaMenu(menu:MenuDTO):Void {
		// Remove previous mega menu if any
		if (this.numComponents > 1) {
			this.removeComponentAt(1);
		}
		var megaMenu = new VBox();
		menuManager.listSections(menu.id, function(sections:Array<MenuSectionDTO>) {
			for (section in sections) {
				if (!section.enabled)
					continue;
				var sectionBox = renderSection(section);
				megaMenu.addComponent(sectionBox);
			}
			this.addComponent(megaMenu);
		});
	}

	function renderSection(section:MenuSectionDTO):Component {
		var sectionBox = new VBox();
		if (section.title != null && section.title != "") {
			var titleLabel = new Label();
			titleLabel.text = section.title;
			sectionBox.addComponent(titleLabel);
		}
		// Layout type can be handled here (column, grid, custom_html)
		menuManager.listItems(section.id, function(items:Array<MenuItemDTO>) {
			for (item in items) {
				if (!item.enabled)
					continue;
				var itemComp = renderItem(item);
				sectionBox.addComponent(itemComp);
			}
		});
		return sectionBox;
	}

	function renderItem(item:MenuItemDTO):Component {
		switch (item.itemType) {
			case "link":
				var btn = new Button();
				btn.text = item.label;
				btn.userData = item.url;
				btn.onClick = function(_) {
					// Open link logic
				};
				if (item.description != null && item.description != "") {
					var desc = new Label();
					desc.text = item.description;
					btn.addComponent(desc);
				}
				return btn;
			case "header":
				var header = new Label();
				header.text = item.label;
				// header.bold = true; // Remove if not supported
				return header;
			case "separator":
				var sep = new Label();
				sep.text = "----------------------";
				return sep;
			case "custom_component":
				// Custom component registry logic
				var custom = new Label();
				custom.text = "[Custom: " + item.customComponent + "]";
				return custom;
			default:
				var unknown = new Label();
				unknown.text = item.label;
				return unknown;
		}
	}
}
