package app.cms.megamenu;

import app.services.AsyncServiceRegistry;
import app.models.MegaMenuModels;
import app.components.Notifications;

class MegaMenuManager {
	var service:Dynamic;

	public function new() {
		service = AsyncServiceRegistry.instance.megaMenu;
	}

	// Menus
	public function listMenus(cb:Array<MenuDTO>->Void, ?err:Dynamic->Void):Void {
		untyped service.listMenusAsync(function(result:Array<MenuDTO>) {
			Notifications.show('Menus loaded', 'success');
			cb(result);
		}, function(error:Dynamic) {
			Notifications.show('Error loading menus: ' + Std.string(error), 'error');
			if (err != null)
				err(error);
		});
	}

	public function getMenu(id:Int, cb:MenuDTO->Void, ?err:Dynamic->Void):Void {
		untyped service.getMenuAsync(id, function(result:MenuDTO) {
			Notifications.show('Menu loaded', 'success');
			cb(result);
		}, function(error:Dynamic) {
			Notifications.show('Error loading menu: ' + Std.string(error), 'error');
			if (err != null)
				err(error);
		});
	}

	public function createMenu(menu:MenuDTO, cb:Int->Void, ?err:Dynamic->Void):Void {
		untyped service.createMenuAsync(menu, function(id:Int) {
			Notifications.show('Menu created', 'success');
			cb(id);
		}, function(error:Dynamic) {
			Notifications.show('Error creating menu: ' + Std.string(error), 'error');
			if (err != null)
				err(error);
		});
	}

	public function updateMenu(id:Int, menu:MenuDTO, cb:Bool->Void, ?err:Dynamic->Void):Void {
		untyped service.updateMenuAsync(id, menu, function(success:Bool) {
			Notifications.show(success ? 'Menu updated' : 'Failed to update menu', success ? 'success' : 'error');
			cb(success);
		}, function(error:Dynamic) {
			Notifications.show('Error updating menu: ' + Std.string(error), 'error');
			if (err != null)
				err(error);
		});
	}

	public function deleteMenu(id:Int, cb:Bool->Void, ?err:Dynamic->Void):Void {
		untyped service.deleteMenuAsync(id, function(success:Bool) {
			Notifications.show(success ? 'Menu deleted' : 'Failed to delete menu', success ? 'success' : 'error');
			cb(success);
		}, function(error:Dynamic) {
			Notifications.show('Error deleting menu: ' + Std.string(error), 'error');
			if (err != null)
				err(error);
		});
	}

	// Sections
	public function listSections(menuId:Int, cb:Array<MenuSectionDTO>->Void, ?err:Dynamic->Void):Void {
		untyped service.listSectionsAsync(menuId, function(result:Array<MenuSectionDTO>) {
			Notifications.show('Sections loaded', 'success');
			cb(result);
		}, function(error:Dynamic) {
			Notifications.show('Error loading sections: ' + Std.string(error), 'error');
			if (err != null)
				err(error);
		});
	}

	public function createSection(menuId:Int, section:MenuSectionDTO, cb:Int->Void, ?err:Dynamic->Void):Void {
		untyped service.createSectionAsync(menuId, section, function(id:Int) {
			Notifications.show('Section created', 'success');
			cb(id);
		}, function(error:Dynamic) {
			Notifications.show('Error creating section: ' + Std.string(error), 'error');
			if (err != null)
				err(error);
		});
	}

	public function updateSection(id:Int, section:MenuSectionDTO, cb:Bool->Void, ?err:Dynamic->Void):Void {
		untyped service.updateSectionAsync(id, section, function(success:Bool) {
			Notifications.show(success ? 'Section updated' : 'Failed to update section', success ? 'success' : 'error');
			cb(success);
		}, function(error:Dynamic) {
			Notifications.show('Error updating section: ' + Std.string(error), 'error');
			if (err != null)
				err(error);
		});
	}

	public function deleteSection(id:Int, cb:Bool->Void, ?err:Dynamic->Void):Void {
		untyped service.deleteSectionAsync(id, function(success:Bool) {
			Notifications.show(success ? 'Section deleted' : 'Failed to delete section', success ? 'success' : 'error');
			cb(success);
		}, function(error:Dynamic) {
			Notifications.show('Error deleting section: ' + Std.string(error), 'error');
			if (err != null)
				err(error);
		});
	}

	// Items
	public function listItems(sectionId:Int, cb:Array<MenuItemDTO>->Void, ?err:Dynamic->Void):Void {
		untyped service.listItemsAsync(sectionId, function(result:Array<MenuItemDTO>) {
			Notifications.show('Items loaded', 'success');
			cb(result);
		}, function(error:Dynamic) {
			Notifications.show('Error loading items: ' + Std.string(error), 'error');
			if (err != null)
				err(error);
		});
	}

	public function createItem(sectionId:Int, item:MenuItemDTO, cb:Int->Void, ?err:Dynamic->Void):Void {
		untyped service.createItemAsync(sectionId, item, function(id:Int) {
			Notifications.show('Item created', 'success');
			cb(id);
		}, function(error:Dynamic) {
			Notifications.show('Error creating item: ' + Std.string(error), 'error');
			if (err != null)
				err(error);
		});
	}

	public function updateItem(id:Int, item:MenuItemDTO, cb:Bool->Void, ?err:Dynamic->Void):Void {
		untyped service.updateItemAsync(id, item, function(success:Bool) {
			Notifications.show(success ? 'Item updated' : 'Failed to update item', success ? 'success' : 'error');
			cb(success);
		}, function(error:Dynamic) {
			Notifications.show('Error updating item: ' + Std.string(error), 'error');
			if (err != null)
				err(error);
		});
	}

	public function deleteItem(id:Int, cb:Bool->Void, ?err:Dynamic->Void):Void {
		untyped service.deleteItemAsync(id, function(success:Bool) {
			Notifications.show(success ? 'Item deleted' : 'Failed to delete item', success ? 'success' : 'error');
			cb(success);
		}, function(error:Dynamic) {
			Notifications.show('Error deleting item: ' + Std.string(error), 'error');
			if (err != null)
				err(error);
		});
	}

	// Metadata
	public function listMetadata(itemId:Int, cb:Array<MenuItemMetadataDTO>->Void, ?err:Dynamic->Void):Void {
		untyped service.listMetadataAsync(itemId, function(result:Array<MenuItemMetadataDTO>) {
			Notifications.show('Metadata loaded', 'success');
			cb(result);
		}, function(error:Dynamic) {
			Notifications.show('Error loading metadata: ' + Std.string(error), 'error');
			if (err != null)
				err(error);
		});
	}

	public function createMetadata(itemId:Int, metadata:MenuItemMetadataDTO, cb:Int->Void, ?err:Dynamic->Void):Void {
		untyped service.createMetadataAsync(itemId, metadata, function(id:Int) {
			Notifications.show('Metadata created', 'success');
			cb(id);
		}, function(error:Dynamic) {
			Notifications.show('Error creating metadata: ' + Std.string(error), 'error');
			if (err != null)
				err(error);
		});
	}

	public function updateMetadata(id:Int, metadata:MenuItemMetadataDTO, cb:Bool->Void, ?err:Dynamic->Void):Void {
		untyped service.updateMetadataAsync(id, metadata, function(success:Bool) {
			Notifications.show(success ? 'Metadata updated' : 'Failed to update metadata', success ? 'success' : 'error');
			cb(success);
		}, function(error:Dynamic) {
			Notifications.show('Error updating metadata: ' + Std.string(error), 'error');
			if (err != null)
				err(error);
		});
	}

	public function deleteMetadata(id:Int, cb:Bool->Void, ?err:Dynamic->Void):Void {
		untyped service.deleteMetadataAsync(id, function(success:Bool) {
			Notifications.show(success ? 'Metadata deleted' : 'Failed to delete metadata', success ? 'success' : 'error');
			cb(success);
		}, function(error:Dynamic) {
			Notifications.show('Error deleting metadata: ' + Std.string(error), 'error');
			if (err != null)
				err(error);
		});
	}
}
