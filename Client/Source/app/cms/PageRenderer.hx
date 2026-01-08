package app.cms;

import haxe.ui.core.Component;
import haxe.ui.containers.VBox;
import haxe.ui.components.Label;
import app.cms.ComponentFactory;
import app.models.CmsModels;

/** Renders a page version with all its components */
class PageRenderer {
	public function new() {}

	/** Render a complete page version */
	public function render(page:PageVersionDTO):Component {
		return renderPage(page, null);
	}

	/** Render page and optionally scroll to anchor */
	public function renderPage(page:PageVersionDTO, ?anchor:String):Component {
		var root = new VBox();
		root.percentWidth = 100;
		root.percentHeight = 100;

		// Add title if present
		if (page.title != null && page.title != "") {
			var titleLabel = new Label();
			titleLabel.text = page.title;
			titleLabel.styleNames = "pageTitle";
			root.addComponent(titleLabel);
		}

		var anchorComponent:Component = null;
		// Render all components
		if (page.components != null) {
			for (compDTO in page.components) {
				try {
					var comp = ComponentFactory.fromDTO(compDTO);
					var node = comp.render();
					node.id = Std.string(compDTO.id);
					root.addComponent(node);
					if (anchor != null && Std.string(compDTO.id) == anchor) {
						anchorComponent = node;
					}
				} catch (e:Dynamic) {
					trace('Error rendering component ${compDTO.id}: $e');
					var errorLabel = new Label();
					errorLabel.text = '[Error rendering component: ${compDTO.type}]';
					errorLabel.styleNames = "errorLabel";
					root.addComponent(errorLabel);
				}
			}
		}

		// Scroll to anchor if specified
		#if html5
		if (anchorComponent != null) {
			haxe.ui.Toolkit.callLater(function() {
				var el = js.Browser.document.getElementById(anchorComponent.id);
				if (el != null && Reflect.hasField(el, "scrollIntoView")) {
					untyped el.scrollIntoView();
				}
			});
		}
		#end

		return root;
	}

	/** Render just the components without page wrapper */
	public function renderComponents(components:Array<PageComponentDTO>):VBox {
		var root = new VBox();
		root.percentWidth = 100;

		if (components != null) {
			for (compDTO in components) {
				try {
					var comp = ComponentFactory.fromDTO(compDTO);
					var node = comp.render();
					root.addComponent(node);
				} catch (e:Dynamic) {
					trace('Error rendering component ${compDTO.id}: $e');
				}
			}
		}

		return root;
	}
}
