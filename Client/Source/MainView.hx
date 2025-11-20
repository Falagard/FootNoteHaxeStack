package;

import haxe.ui.containers.VBox;
import haxe.ui.components.Button;
import haxe.ui.components.Label;
import state.AppState;
import components.Notifications;
import cms.CmsManager;
import CmsModels;
import cms.PageList;
import cms.PageEditor;

@:build(haxe.ui.ComponentBuilder.build("Assets/main-view.xml"))
class MainView extends VBox {
	var userLabel:Label; // from XML - displays current user
	var logoutBtn:Button; // from XML - logout button
	var cmsBtn:Button; // from XML - CMS button
	var contentPlaceholder:VBox; // from XML - main content area

	var appState = AppState.instance;
	var asyncServices = AppState.instance.asyncServices;

	var cmsManager:CmsManager;
	var currentPageList:PageList;
	var currentEditor:PageEditor;

	// Page navigation
	var pageNavigator:state.PageNavigator;
	var pageRenderer:cms.PageRenderer;

	public function new() {
		super();

		// Initialize CMS manager
		cmsManager = new CmsManager();
		pageRenderer = new cms.PageRenderer();

		// Initialize PageNavigator
		pageNavigator = new state.PageNavigator(appState, cmsManager, pageRenderer);

		wireEvents();

		// Watch authentication state and update user display
		appState.currentUser.watch(function(user) {
			updateUserDisplay();
		});
		updateUserDisplay();

		// Listen for navigation events to update UI
		pageNavigator.onNavigate.push(function() {
			renderActivePage();
		});
	}
	/** Render the active page using PageNavigator */
	private function renderActivePage():Void {
		contentPlaceholder.removeAllComponents();
		var pageIdInt = Std.parseInt(pageNavigator.currentPage);
		cmsManager.getPage(pageIdInt, function(response:GetPageResponse) {
			if (response.success && response.page != null) {
				var rendered = pageRenderer.renderPage(response.page, pageNavigator.currentAnchor);
				contentPlaceholder.addComponent(rendered);
			} else {
				var errorLabel = new haxe.ui.components.Label();
				errorLabel.text = "Failed to load page.";
				contentPlaceholder.addComponent(errorLabel);
			}
		});
	}

	private function updateUserDisplay():Void {
		if (userLabel != null) {
			var user = appState.currentUser.value;
			if (user != null) {
				var displayName = user.username != null ? user.username : user.email;
				userLabel.text = displayName;
			} else {
				userLabel.text = "";
			}
		}
	}

	private function wireEvents():Void {
		if (logoutBtn != null) logoutBtn.onClick = function(_) {
			handleLogout();
		};
		
		if (cmsBtn != null) cmsBtn.onClick = function(_) {
			showCMS();
		};
	}

	private function handleLogout():Void {
		untyped asyncServices.auth.logoutAsync(function(success:Bool) {
			appState.clearAuthentication();
			Notifications.show('Signed out successfully', 'info');
			#if js
			js.Browser.window.location.reload();
			#end
		}, function(err:Dynamic) {
			// Still clear local auth even if server call fails
			appState.clearAuthentication();
			Notifications.show('Signed out', 'info');
			#if js
			js.Browser.window.location.reload();
			#end
		});
	}
	
	/** Show the CMS page list */
	private function showCMS():Void {
		// Clear current content
		contentPlaceholder.removeAllComponents();
		
		// Create and show page list
		currentPageList = new PageList(cmsManager);
		
		// Handle edit page request
		currentPageList.onEditPage = function(pageId:Int) {
			showPageEditor(pageId);
		};
		
		contentPlaceholder.addComponent(currentPageList);
	}
	
    /** Show the page editor */
    private function showPageEditor(pageId:Int):Void {
        currentEditor = new PageEditor(cmsManager);
        currentEditor.showDialog();
        currentEditor.loadPage(pageId);		// Handle save callback to refresh list
		currentEditor.onSaved = function(_) {
			if (currentPageList != null) {
				currentPageList.loadPages();
			}
		};
		
		currentEditor.showDialog();
	}
}