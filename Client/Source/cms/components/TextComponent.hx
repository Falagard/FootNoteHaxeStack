package cms.components;

import haxe.ui.core.Component;
import haxe.ui.containers.VBox;
import haxe.ui.components.Label;
import TextFieldMarkdown;

/** Text component for displaying paragraphs and headings */
class TextComponent extends BaseComponent {
    
    public function new(?id:String) {
        super(id, "text");
        if (_props.text == null) _props.text = "New text";
        if (_props.style == null) _props.style = "normal"; // normal, h1, h2, h3
    }
    
    override public function render():Component {
        var box = new VBox();
        box.percentWidth = 100;

        var label = new Label();
        var rawText = Std.string(_props.text != null ? _props.text : "");
        var htmlText = TextFieldMarkdown.markdownToHtml(rawText);
        label.htmlText = htmlText;
        label.percentWidth = 100;

        // Apply style based on props.style
        switch(Std.string(_props.style)) {
            case "h1":
                label.styleNames = "h1";
            case "h2":
                label.styleNames = "h2";
            case "h3":
                label.styleNames = "h3";
            default:
                label.styleNames = "normalText";
        }

        box.addComponent(label);
        return box;
    }
}
