package cms;

import haxe.ui.containers.VBox;
import cms.ComponentFactory;
import cms.PageEditor;
import CmsModels;

class EditorComponent {
    public var dto:PageComponentDTO;
    public var container:VBox;
    var editor:PageEditor;
    var contentContainer:VBox;
    var isSelected:Bool = false;

    public function new(dto:PageComponentDTO, editor:PageEditor) {
        this.dto = dto;
        this.editor = editor;
        container = new VBox();
        container.percentWidth = 100;
        container.styleNames = "editorComponent";
        //container.mouseEnabled = true;

        refresh();
    }

    public function refresh():Void {
        container.removeAllComponents();
        var comp = ComponentFactory.fromDTO(dto);
        var rendered = comp.render();
        container.addComponent(rendered);

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

    public function setSelected(selected:Bool):Void {
        isSelected = selected;
        if (selected) {
            container.addClass("selected");
        } else {
            container.removeClass("selected");
        }
    }
}
