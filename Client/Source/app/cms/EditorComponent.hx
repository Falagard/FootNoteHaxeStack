package app.cms;

import haxe.ui.containers.VBox;
import app.cms.ComponentFactory;
import app.cms.PageEditor;
import app.models.CmsModels;

class EditorComponent {
	public var dto:PageComponentDTO;
	public var container:VBox;

	var editor:PageEditor;
	var contentContainer:VBox;
	var isSelected:Bool = false;
	var showEditorButtons:Bool;

	public function new(dto:PageComponentDTO, editor:PageEditor, showEditorButtons:Bool = true) {
		this.dto = dto;
		this.editor = editor;
		this.showEditorButtons = showEditorButtons;
		container = new VBox();
		container.percentWidth = 100;
		container.styleNames = "editorComponent";
		// container.mouseEnabled = true;

		refresh();
	}

	public function refresh():Void {
		container.removeAllComponents();
		var comp = ComponentFactory.fromDTO(dto);
		var rendered = comp.render();
		container.addComponent(rendered);

		if (showEditorButtons) {
			var btnBox = new haxe.ui.containers.HBox();

			var upBtn = new haxe.ui.components.Button();
			upBtn.text = "Up";
			upBtn.onClick = function(_) {
				editor.moveComponentInEditor(this, -1);
			};
			btnBox.addComponent(upBtn);

			var downBtn = new haxe.ui.components.Button();
			downBtn.text = "Down";
			downBtn.onClick = function(_) {
				editor.moveComponentInEditor(this, 1);
			};
			btnBox.addComponent(downBtn);

			var editBtn = new haxe.ui.components.Button();
			editBtn.text = "Edit";
			editBtn.onClick = function(_) {
				editor.selectComponent(this);
			};
			btnBox.addComponent(editBtn);

			container.addComponent(btnBox);
		}
	}

	public function setSelected(selected:Bool):Void {
		isSelected = selected;
		if (selected) {
			container.addClass("selected");
		} else {
			container.removeClass("selected");
		}
	}
}
