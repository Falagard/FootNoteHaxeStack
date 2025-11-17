package cms.components;

import haxe.ui.core.Component;

/** Interface for all page components */
interface IPageComponent {
    /** Unique identifier for this component instance */
    public var id(get, set):String;
    
    /** Component type (e.g., "text", "image") */
    public var type(get, set):String;
    
    /** Dynamic properties for this component */
    public var props(get, set):Dynamic;
    
    /** Render this component as a HaxeUI Component */
    function render():Component;
    
    /** Serialize component data for storage */
    function serialize():Dynamic;
}
