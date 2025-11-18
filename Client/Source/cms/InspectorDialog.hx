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
        if (closeBtn != null) closeBtn.onClick = function(_) self.hide();
    }

    public function showInspector(editorComp:EditorComponent):Void {
        inspectorContent.removeAllComponents();
        // Add inspector UI for the selected component
        var titleLabel = new Label();
        titleLabel.text = "Component: " + editorComp.dto.type;
        inspectorContent.addComponent(titleLabel);
        // Type-specific properties (copy logic from PageEditor)
        switch(editorComp.dto.type) {
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
            if (onClose != null) onClose();
            self.hide();
        };
        inspectorContent.addComponent(deleteBtn);
    }

    function addTextInspector(editorComp:EditorComponent):Void {
        // ...copy from PageEditor...
    }
    function addImageInspector(editorComp:EditorComponent):Void {
        // ...copy from PageEditor...
    }
    function addButtonInspector(editorComp:EditorComponent):Void {
        // ...copy from PageEditor...
    }
}
