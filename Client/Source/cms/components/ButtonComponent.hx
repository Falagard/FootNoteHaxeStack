package cms.components;

import haxe.ui.core.Component;
import haxe.ui.containers.HBox;
import haxe.ui.components.Button;

/** Button component for clickable actions */
class ButtonComponent extends BaseComponent {
    
    public function new(?id:String) {
        super(id, "button");
        if (_props.text == null) _props.text = "Click Me";
        if (_props.action == null) _props.action = "#";
        if (_props.pageId == null) _props.pageId = null; // navigation target
    }
    
    override public function render():Component {
        var box = new HBox();
        box.percentWidth = 100;

        var btn = new Button();
        btn.text = Std.string(_props.text != null ? _props.text : "Button");

        btn.onClick = function(_) {
            if (_props.pageId != null) {
                state.PageNavigator.instance.navigate(Std.string(_props.pageId), null);
            } else {
                trace("Button clicked: " + _props.action);
            }
        };

        box.addComponent(btn);
        return box;
    }
}
