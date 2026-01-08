package app.cms;

import app.cms.components.*;
import app.cms.components.PageListComponent;
import app.cms.components.MenuListComponent;
import app.models.CmsModels;

/** Factory for creating page components by type */
class ComponentFactory {
	public static function create(type:String, ?id:String):IPageComponent {
		return switch (type.toLowerCase()) {
			case "text": new TextComponent(id);
			case "image": new ImageComponent(id);
			case "button": new ButtonComponent(id);
			case "pagelist": new PageListComponent(id);
			case "menulist": new MenuListComponent(id);
			default:
				// Default to text component for unknown types
				trace('Unknown component type: $type, using TextComponent');
				new TextComponent(id);
		}
	}

	/** Create a component from a DTO */
	public static function fromDTO(dto:PageComponentDTO):IPageComponent {
		var comp = create(dto.type, Std.string(dto.id));
		comp.props = dto.data;
		return comp;
	}

	/** Get list of available component types */
	public static function getAvailableTypes():Array<String> {
		return ["text", "image", "button", "pagelist", "menulist"];
	}
}
