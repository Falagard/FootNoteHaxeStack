package cms.components;

import haxe.ui.core.Component;

/** Base implementation for page components */
class BaseComponent implements IPageComponent {
        /**
         * Register navigation prevention hook for this component.
         * Override shouldPreventNavigation in subclasses as needed.
         */
        public function registerNavigationPrevention():Void {
            state.PageNavigator.instance.addBeforeNavigateHook(function() {
                return !shouldPreventNavigation();
            });
        }

        /**
         * Override in subclasses to block navigation (e.g. unsaved changes).
         */
        public function shouldPreventNavigation():Bool {
            return false;
        }
    var _id:String;
    var _type:String;
    var _props:Dynamic;
    
    public function new(?id:String, type:String) {
        this._id = id != null ? id : generateId();
        this._type = type;
        this._props = {};
    }
    
    public var id(get, set):String;
    function get_id():String return _id;
    function set_id(v:String):String return _id = v;
    
    public var type(get, set):String;
    function get_type():String return _type;
    function set_type(v:String):String return _type = v;
    
    public var props(get, set):Dynamic;
    function get_props():Dynamic return _props;
    function set_props(v:Dynamic):Dynamic return _props = v;
    
    public function render():Component {
        throw "Override render() in subclass";
    }
    
    public function serialize():Dynamic {
        return {
            id: _id,
            type: _type,
            props: _props
        };
    }
    
    static function generateId():String {
        return "comp_" + Std.int(Math.random() * 1000000);
    }
}
