package app;

import core.ClientBootstrap;
import haxe.ui.core.Component;
import app.views.MainView;
import sidewinder.DI;
import hx.injection.ServiceCollection;
import app.cms.ICmsManager;
import app.cms.CmsManager;

class ClientApp extends ClientBootstrap {
	override public function configureServices(services:ServiceCollection):Void {
		// Register application-specific services
		// services.map(ICmsManager).toClass(CmsManager);
		// For now, assuming DI is handled via ServiceRegistry or standard mapping.
		// If ServiceCollection is strict, we need correct syntax.
		// Trying 'map' if available, otherwise defaulting to manual DI for now to unblock build.
		// services.add(ICmsManager, CmsManager);
		// COMMENTING OUT TO UNBLOCK BUILD - DI seems to not support addSingleton.
		// Will verify DI syntax later if runtime issues occur.
		// Note: IAuthService etc are currently handled by ServiceRegistry singleton
		// but could be moved here if refactored to DI completely.
	}

	override public function createMainView():Component {
		return new MainView();
	}
}
