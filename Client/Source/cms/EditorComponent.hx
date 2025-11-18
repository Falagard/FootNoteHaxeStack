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
        refresh();
        container.onClick = function(_) {
            editor.selectComponent(this);
        };
    }

    public function refresh():Void {
        container.removeAllComponents();
        var comp = ComponentFactory.fromDTO(dto);
        var rendered = comp.render();
        container.addComponent(rendered);
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
