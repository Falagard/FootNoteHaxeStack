package cms;

import haxe.ui.core.Component;
import haxe.ui.containers.VBox;
import haxe.ui.components.Label;
import cms.ComponentFactory;
import CmsModels;

/** Renders a page version with all its components */
class PageRenderer {
    
    public function new() {}
    
    /** Render a complete page version */
    public function render(page:PageVersionDTO):Component {
        var root = new VBox();
        root.percentWidth = 100;
        root.percentHeight = 100;
        
        // Add title if present
        if (page.title != null && page.title != "") {
            var titleLabel = new Label();
            titleLabel.text = page.title;
            titleLabel.styleNames = "pageTitle";
            root.addComponent(titleLabel);
        }
        
        // Render all components
        if (page.components != null) {
            for (compDTO in page.components) {
                try {
                    var comp = ComponentFactory.fromDTO(compDTO);
                    var node = comp.render();
                    root.addComponent(node);
                } catch (e:Dynamic) {
                    trace('Error rendering component ${compDTO.id}: $e');
                    var errorLabel = new Label();
                    errorLabel.text = '[Error rendering component: ${compDTO.type}]';
                    errorLabel.styleNames = "errorLabel";
                    root.addComponent(errorLabel);
                }
            }
        }
        
        return root;
    }
    
    /** Render just the components without page wrapper */
    public function renderComponents(components:Array<PageComponentDTO>):VBox {
        var root = new VBox();
        root.percentWidth = 100;
        
        if (components != null) {
            for (compDTO in components) {
                try {
                    var comp = ComponentFactory.fromDTO(compDTO);
                    var node = comp.render();
                    root.addComponent(node);
                } catch (e:Dynamic) {
                    trace('Error rendering component ${compDTO.id}: $e');
                }
            }
        }
        
        return root;
    }
}
