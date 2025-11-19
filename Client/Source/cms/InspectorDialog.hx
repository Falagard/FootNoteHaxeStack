package cms;

import haxe.ui.containers.dialogs.Dialog;
import haxe.ui.components.Label;
import haxe.ui.components.Button;
import haxe.ui.containers.VBox;
import haxe.ui.containers.dialogs.Dialog;
import cms.EditorComponent;

@:build(haxe.ui.ComponentBuilder.build("Assets/inspector-dialog.xml"))
class InspectorDialog extends Dialog {
	public var onClose:Void->Void;
	public var onDelete:Void->Void;

	var inspectorContent:VBox;
	var closeBtn:Button;

	public function new() {
		super();
		this.title = "Inspector";
		this.modal = true;
		this.destroyOnClose = true;
	}

	public override function onReady():Void {
		super.onReady();
		var self = this;
		if (closeBtn != null)
			closeBtn.onClick = function(_) self.hide();
	}

	public function showInspector(editorComp:EditorComponent):Void {
		inspectorContent.removeAllComponents();
		// Add inspector UI for the selected component
		var titleLabel = new Label();
		titleLabel.text = "Component: " + editorComp.dto.type;
		inspectorContent.addComponent(titleLabel);
		// Type-specific properties (copy logic from PageEditor)
		switch (editorComp.dto.type) {
			case "text":
				addTextInspector(editorComp);
			case "image":
				addImageInspector(editorComp);
			case "button":
				addButtonInspector(editorComp);
			default:
				var label = new Label();
				label.text = "No properties available";
				inspectorContent.addComponent(label);
		}
		// Delete button
		var deleteBtn = new Button();
		deleteBtn.text = "Delete Component";
		var self = this;
		deleteBtn.onClick = function(_) {
			if (onDelete != null) onDelete();
			if (onClose != null) onClose();
			self.hide();
		};
		inspectorContent.addComponent(deleteBtn);
	}

	function addTextInspector(editorComp:EditorComponent):Void {
		var dto = editorComp.dto;
		var textArea = new haxe.ui.components.TextArea();
		textArea.text = dto.data.text != null ? dto.data.text : "";
		textArea.percentWidth = 100;
		textArea.height = 100;
		textArea.onChange = function(_) {
			dto.data.text = textArea.text;
			editorComp.refresh();
		};
		inspectorContent.addComponent(textArea);

		var styleDrop = new haxe.ui.components.DropDown();
		styleDrop.dataSource = haxe.ui.data.ArrayDataSource.fromArray(["normal", "h1", "h2", "h3"]);
		styleDrop.selectedItem = dto.data.style != null ? dto.data.style : "normal";
		styleDrop.percentWidth = 100;
		styleDrop.onChange = function(_) {
			dto.data.style = styleDrop.selectedItem;
			editorComp.refresh();
		};
		inspectorContent.addComponent(styleDrop);
	}

	function addImageInspector(editorComp:EditorComponent):Void {
		var dto = editorComp.dto;
		var urlField = new haxe.ui.components.TextField();
		urlField.text = dto.data.url != null ? dto.data.url : "";
		urlField.percentWidth = 100;
		// urlField.prompt = "Image URL"; // Not supported in Haxe UI
		urlField.onChange = function(_) {
			dto.data.url = urlField.text;
			editorComp.refresh();
		};
		inspectorContent.addComponent(urlField);
	}

	function addButtonInspector(editorComp:EditorComponent):Void {
		var dto = editorComp.dto;
		var labelField = new haxe.ui.components.TextField();
		labelField.text = dto.data.label != null ? dto.data.label : "Button";
		labelField.percentWidth = 100;
		// labelField.prompt = "Button Label"; // Not supported in Haxe UI
		labelField.onChange = function(_) {
			dto.data.label = labelField.text;
			editorComp.refresh();
		};
		inspectorContent.addComponent(labelField);
	}
}
