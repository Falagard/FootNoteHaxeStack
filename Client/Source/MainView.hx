package;

import haxe.ui.containers.VBox;
import cms.megamenu.MegaMenuView;
import cms.megamenu.MegaMenuAdminDialog;
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
	var megaMenuView:MegaMenuView;
	var megaMenuAdminDialog:MegaMenuAdminDialog;
	var userLabel:Label; // from XML - displays current user
	var logoutBtn:Button; // from XML - logout button
	var cmsBtn:Button; // from XML - CMS button
	var contentPlaceholder:VBox; // from XML - main content area

	var appState = AppState.instance;
	var asyncServices = AppState.instance.asyncServices;

	var cmsManager:CmsManager;
	var currentPageList:PageList;
	var currentEditor:PageEditor;

	var authManager:views.auth.AuthManager;

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

		authManager = new views.auth.AuthManager(this);

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

		// Handle deep link from URL on app load, or navigate to default page 3
		if (!pageNavigator.handleInitialDeepLink()) {
			pageNavigator.navigate("3", null);
		}

		// --- MegaMenu Integration ---
		// TODO: Replace null with actual IMegaMenuService instance
		megaMenuView = new MegaMenuView();
		this.addComponent(megaMenuView);
		// To show admin dialog, call megaMenuAdminDialog.showDialog() as needed
		// megaMenuAdminDialog = new MegaMenuAdminDialog(menuService);
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

		// Show/hide CMS button based on authentication
		if (cmsBtn != null) {
            var isAuthenticated = appState.isAuthenticated;
			cmsBtn.hidden = !isAuthenticated;
		}

		// Change logout button to login button if not authenticated
		if (logoutBtn != null) {
			if (!appState.isAuthenticated) {
				logoutBtn.text = "Login";
				logoutBtn.onClick = function(_) {
					authManager.showLogin(function() {
						updateUserDisplay(); // Show CMS button after login
					});
				};
			} else {
				logoutBtn.text = "Logout";
				logoutBtn.onClick = function(_) {
					handleLogout();
				};
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
	
	/** Show the CMS page list with Back button */
	private var lastPage:String = null;
	private var lastAnchor:String = null;
	private function showCMS():Void {
		// Store current page and anchor before showing CMS
		lastPage = pageNavigator.currentPage;
		lastAnchor = pageNavigator.currentAnchor;

		// Clear current content
		contentPlaceholder.removeAllComponents();

		// Create Back button
		var backBtn = new Button();
		backBtn.text = "Back";
		backBtn.onClick = function(_) {
			if (lastPage != null) {
				pageNavigator.navigate(lastPage, lastAnchor);
			}
		};
		contentPlaceholder.addComponent(backBtn);

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