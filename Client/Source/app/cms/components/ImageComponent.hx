package app.cms.components;

import haxe.ui.core.Component;
import haxe.ui.containers.VBox;
import haxe.ui.components.Image;
import haxe.ui.components.Label;

/** Image component for displaying images */
class ImageComponent extends BaseComponent {
	public function new(?id:String) {
		super(id, "image");
		if (_props.url == null)
			_props.url = "";
		if (_props.alt == null)
			_props.alt = "";
		if (_props.width == null)
			_props.width = 100; // percentage
	}

	override public function render():Component {
		var box = new VBox();
		box.percentWidth = 100;

		if (_props.url != null && _props.url != "") {
			var img = new Image();
			// Set width
			var width = Std.parseInt(Std.string(_props.width));
			if (width != null && width > 0 && width <= 100) {
				img.percentWidth = width;
			} else {
				img.percentWidth = 100;
			}
			box.addComponent(img);
			img.registerEvent(haxe.ui.events.UIEvent.READY, function(_) {
				img.resource = Std.string(_props.url);
			});
		} else {
			var placeholder = new Label();
			placeholder.text = "[Image: " + (_props.alt != null ? _props.alt : "No URL set") + "]";
			placeholder.styleNames = "imagePlaceholder";
			box.addComponent(placeholder);
		}

		return box;
	}
}
