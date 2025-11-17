package shared;

typedef ComponentDefinition = {
	type:String,
	requiredProps:Array<String>,
	propsSchema:Dynamic
};

class ComponentSchema {
	public static var definitions:Array<ComponentDefinition> = [
		{
			type: "text",
			requiredProps: ["text"],
			propsSchema: {
				text: "String",
				style: "?String"
			}
		},
		{
			type: "image",
			requiredProps: ["src"],
			propsSchema: {
				src: "String",
				fit: "?String",
				width: "?Int",
				height: "?Int",
				alt: "?String"
			}
		},
		{
			type: "button",
			requiredProps: ["label"],
			propsSchema: {
				label: "String",
				action: "?String",
				style: "?String"
			}
		},
		{
			type: "buttonRow",
			requiredProps: ["buttons"],
			propsSchema: {
				buttons: "Array<Dynamic>"
			}
		},
		{
			type: "container",
			requiredProps: [],
			propsSchema: {
				layout: "?String",
				style: "?String"
			}
		},
		{
			type: "heading",
			requiredProps: ["text"],
			propsSchema: {
				text: "String",
				level: "?Int",
				style: "?String"
			}
		},
		{
			type: "ai_generator",
			requiredProps: [],
			propsSchema: {
				prompt: "?String",
				assets: "?Array<Dynamic>",
				status: "?String",
				lastOutput: "?Dynamic"
			}
		}
	];

	public static function getDefinition(type:String):Null<ComponentDefinition> {
		for (def in definitions) {
			if (def.type == type) {
				return def;
			}
		}
		return null;
	}

	public static function isValidType(type:String):Bool {
		return getDefinition(type) != null;
	}

	public static function getTypeList():Array<String> {
		return definitions.map(d -> d.type);
	}
}
