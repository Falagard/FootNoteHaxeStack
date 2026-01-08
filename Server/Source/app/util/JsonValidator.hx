package app.util;

import app.models.CmsModels;
import ComponentSchema;
import haxe.Json;

class JsonValidator {
	public function new() {}

	public function validateJson(input:String):ValidationResult {
		var errors:Array<ValidationError> = [];

		// Try to parse JSON
		var parsed:Dynamic = null;
		try {
			parsed = Json.parse(input);
		} catch (e:Dynamic) {
			return {
				ok: false,
				errors: [{message: 'Invalid JSON syntax', details: Std.string(e)}]
			};
		}

		// Check for components array
		if (!Reflect.hasField(parsed, 'components')) {
			errors.push({message: 'Missing "components" array'});
			return {ok: false, errors: errors};
		}

		var components:Dynamic = Reflect.field(parsed, 'components');
		if (!Std.isOfType(components, Array)) {
			errors.push({message: '"components" must be an array'});
			return {ok: false, errors: errors};
		}

		// Validate each component
		var comps:Array<Dynamic> = cast components;
		for (i in 0...comps.length) {
			var c = comps[i];
			validateComponent(c, i, errors);
		}

		return {
			ok: errors.length == 0,
			errors: errors
		};
	}

	public function validatePageDTO(page:PageDTO):ValidationResult {
		var errors:Array<ValidationError> = [];

		if (page.pageId <= 0) {
			errors.push({message: 'Invalid pageId'});
		}

		if (page.title == null || page.title.length == 0) {
			errors.push({message: 'Title is required'});
		}

		if (page.layout == null || page.layout.length == 0) {
			errors.push({message: 'Layout is required'});
		}

		if (page.components == null) {
			errors.push({message: 'Components array is required'});
		} else {
			for (i in 0...page.components.length) {
				var c = page.components[i];
				validateComponentDTO(c, i, errors);
			}
		}

		return {
			ok: errors.length == 0,
			errors: errors
		};
	}

	private function validateComponent(c:Dynamic, index:Int, errors:Array<ValidationError>):Void {
		// Check required fields
		if (!Reflect.hasField(c, 'type')) {
			errors.push({
				message: 'Component at index $index missing type field',
				component: c
			});
			return;
		}

		if (!Reflect.hasField(c, 'id')) {
			errors.push({
				message: 'Component at index $index missing id field',
				component: c
			});
		}

		if (!Reflect.hasField(c, 'props')) {
			errors.push({
				message: 'Component at index $index missing props field',
				component: c
			});
			return;
		}

		// Validate against schema
		var type:String = Reflect.field(c, 'type');
		var def = ComponentSchema.getDefinition(type);
		if (def == null) {
			errors.push({
				message: 'Unknown component type: $type at index $index',
				component: c
			});
			return;
		}

		var props:Dynamic = Reflect.field(c, 'props');
		validateComponentAgainstSchema(c, def, index, errors);
	}

	private function validateComponentDTO(c:PageComponentDTO, index:Int, errors:Array<ValidationError>):Void {
		if (c.type == null || c.type.length == 0) {
			errors.push({
				message: 'Component at index $index has invalid type'
			});
			return;
		}

		var def = ComponentSchema.getDefinition(c.type);
		if (def == null) {
			errors.push({
				message: 'Unknown component type: ${c.type} at index $index'
			});
			return;
		}

		if (c.data == null) {
			errors.push({
				message: 'Component at index $index missing data/props'
			});
			return;
		}

		// Check required props
		for (requiredProp in def.requiredProps) {
			if (!Reflect.hasField(c.data, requiredProp)) {
				errors.push({
					message: 'Component "${c.type}" at index $index missing required prop: $requiredProp'
				});
			}
		}
	}

	private function validateComponentAgainstSchema(c:Dynamic, def:ComponentDefinition, index:Int, errors:Array<ValidationError>):Void {
		var props:Dynamic = Reflect.field(c, 'props');
		var id:String = Reflect.field(c, 'id');

		// Check required props
		for (requiredProp in def.requiredProps) {
			if (!Reflect.hasField(props, requiredProp)) {
				errors.push({
					message: 'Component "$id" (${def.type}) at index $index missing required prop: $requiredProp',
					component: c
				});
			}
		}

		// Check prop types (basic validation)
		var schemaFields = Reflect.fields(def.propsSchema);
		for (field in schemaFields) {
			if (Reflect.hasField(props, field)) {
				var expectedType:String = Reflect.field(def.propsSchema, field);
				var actualValue:Dynamic = Reflect.field(props, field);

				// Remove optional marker
				var isOptional = expectedType.charAt(0) == '?';
				if (isOptional) {
					expectedType = expectedType.substring(1);
				}

				// Basic type checking
				var valid = true;
				switch (expectedType) {
					case "String":
						valid = Std.isOfType(actualValue, String);
					case "Int":
						valid = Std.isOfType(actualValue, Int);
					case "Float":
						valid = Std.isOfType(actualValue, Float) || Std.isOfType(actualValue, Int);
					case "Bool":
						valid = Std.isOfType(actualValue, Bool);
					case "Array<Dynamic>":
						valid = Std.isOfType(actualValue, Array);
					case _:
						// Skip complex type validation
						valid = true;
				}

				if (!valid) {
					errors.push({
						message: 'Component "$id" prop "$field" expected type $expectedType at index $index',
						component: c
					});
				}
			}
		}
	}

	public function buildAiPrompt(userPrompt:String, componentTypes:Array<String>):String {
		var prompt = "You are a page builder AI. Generate JSON for a page layout.\n\n";
		prompt += "Available component types:\n";

		for (type in componentTypes) {
			var def = ComponentSchema.getDefinition(type);
			if (def != null) {
				prompt += '- $type: ${Json.stringify(def.propsSchema)}\n';
			}
		}

		prompt += "\nOutput JSON structure:\n";
		prompt += '{\n  "components": [\n    {\n      "id": "unique_string_id",\n      "type": "component_type",\n      "props": { /* component props */ }\n    }\n  ]\n}\n\n';
		prompt += 'User request: $userPrompt\n\n';
		prompt += 'Output ONLY valid JSON. No explanations, no markdown formatting.';

		return prompt;
	}
}
