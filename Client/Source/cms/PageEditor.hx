package cms;

import haxe.ui.containers.dialogs.Dialog;
import haxe.ui.containers.VBox;
import haxe.ui.containers.HBox;
import haxe.ui.components.Button;
import haxe.ui.components.Label;
import haxe.ui.components.TextField;
import haxe.ui.components.DropDown;
import haxe.ui.data.ArrayDataSource;
import cms.CmsManager;
import cms.ComponentFactory;
import cms.components.IPageComponent;
import CmsModels;

/** Page editor dialog for editing pages with live preview */
@:build(haxe.ui.ComponentBuilder.build("Assets/page-editor.xml"))
class PageEditor extends Dialog {
    public var onSaved:PageVersionDTO->Void; // callback when page is saved
    
    // UI components from XML
    var componentList:VBox;
    var canvas:VBox;
    var inspector:VBox;
    var pageTitle:Label;
    var saveDraftBtn:Button;
    var publishBtn:Button;
    
    // Data
    var cmsManager:CmsManager;
    var currentPage:PageVersionDTO;
    var editorComponents:Array<EditorComponent> = [];
    var selectedComponent:EditorComponent;
    
    public function new(cmsManager:CmsManager) {
        super();
        this.cmsManager = cmsManager;
        this.title = "Page Editor";
        this.destroyOnClose = true;
        
        initializeUI();
    }
    
    function initializeUI():Void {
        // Setup component palette
        var types = ComponentFactory.getAvailableTypes();
        
        if (componentList != null) {
            componentList.removeAllComponents();
            for (type in types) {
                var btn = new Button();
                btn.text = "Add " + type;
                btn.percentWidth = 100;
                btn.userData = type;
                btn.onClick = function(_) addNewComponent(Std.string(btn.userData));
                componentList.addComponent(btn);
            }
        }
        
        // Wire up buttons
        if (saveDraftBtn != null) saveDraftBtn.onClick = function(_) saveDraft();
        if (publishBtn != null) publishBtn.onClick = function(_) publish();
    }
    
    /** Load a page for editing */
    public function loadPage(pageId:Int):Void {
        cmsManager.getPage(pageId, function(response:GetPageResponse) {
            if (response.success && response.page != null) {
                currentPage = response.page;
                hydrateEditor();
                pageTitle.text = currentPage.title;
            }
        });
    }
    
    /** Create a new blank page */
    public function createNewPage(slug:String, title:String):Void {
        cmsManager.createPage(slug, title, "default", function(response:CreatePageResponse) {
            if (response.success && response.pageId != null) {
                loadPage(response.pageId);
            }
        });
    }
    
    /** Hydrate editor from current page data */
    function hydrateEditor():Void {
        editorComponents = [];
        canvas.removeAllComponents();
        
        if (currentPage != null && currentPage.components != null) {
            for (compDTO in currentPage.components) {
                var editorComp = new EditorComponent(compDTO, this);
                editorComponents.push(editorComp);
                canvas.addComponent(editorComp.container);
            }
        }
    }
    
    /** Add a new component to the canvas */
    function addNewComponent(type:String):Void {
        var comp = ComponentFactory.create(type);
        
        // Create DTO for this component
        var dto:PageComponentDTO = {
            id: 0, // will be assigned by server
            type: comp.type,
            sort: editorComponents.length,
            data: comp.props
        };
        
        var editorComp = new EditorComponent(dto, this);
        editorComponents.push(editorComp);
        canvas.addComponent(editorComp.container);
        
        // Auto-select new component
        selectComponent(editorComp);
    }
    
    /** Select a component for editing */
    public function selectComponent(editorComp:EditorComponent):Void {
        // Deselect previous
        if (selectedComponent != null) {
            selectedComponent.setSelected(false);
        }
        
        selectedComponent = editorComp;
        editorComp.setSelected(true);
        showInspector(editorComp);
    }
    
    /** Show component properties in inspector */
    function showInspector(editorComp:EditorComponent):Void {
        inspector.removeAllComponents();
        
        var titleLabel = new Label();
        titleLabel.text = "Component: " + editorComp.dto.type;
        inspector.addComponent(titleLabel);
        
        // Type-specific properties
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
                inspector.addComponent(label);
        }
        
        // Delete button
        var deleteBtn = new Button();
        deleteBtn.text = "Delete Component";
        deleteBtn.onClick = function(_) deleteComponent(editorComp);
        inspector.addComponent(deleteBtn);
    }
    
    function addTextInspector(editorComp:EditorComponent):Void {
        // Text content
        var textLabel = new Label();
        textLabel.text = "Text:";
        inspector.addComponent(textLabel);
        
        var textField = new TextField();
        textField.text = Std.string(editorComp.dto.data.text != null ? editorComp.dto.data.text : "");
        textField.percentWidth = 100;
        textField.onChange = function(_) {
            editorComp.dto.data.text = textField.text;
            editorComp.refresh();
        };
        inspector.addComponent(textField);
        
        // Style dropdown
        var styleLabel = new Label();
        styleLabel.text = "Style:";
        inspector.addComponent(styleLabel);
        
        var styleDropdown = new DropDown();
        styleDropdown.dataSource = new ArrayDataSource<String>();
        styleDropdown.dataSource.add("normal");
        styleDropdown.dataSource.add("h1");
        styleDropdown.dataSource.add("h2");
        styleDropdown.dataSource.add("h3");
        styleDropdown.selectedItem = editorComp.dto.data.style != null ? editorComp.dto.data.style : "normal";
        styleDropdown.onChange = function(_) {
            editorComp.dto.data.style = styleDropdown.selectedItem;
            editorComp.refresh();
        };
        inspector.addComponent(styleDropdown);
    }
    
    function addImageInspector(editorComp:EditorComponent):Void {
        // URL
        var urlLabel = new Label();
        urlLabel.text = "Image URL:";
        inspector.addComponent(urlLabel);
        
        var urlField = new TextField();
        urlField.text = Std.string(editorComp.dto.data.url != null ? editorComp.dto.data.url : "");
        urlField.percentWidth = 100;
        urlField.onChange = function(_) {
            editorComp.dto.data.url = urlField.text;
            editorComp.refresh();
        };
        inspector.addComponent(urlField);
        
        // Alt text
        var altLabel = new Label();
        altLabel.text = "Alt Text:";
        inspector.addComponent(altLabel);
        
        var altField = new TextField();
        altField.text = Std.string(editorComp.dto.data.alt != null ? editorComp.dto.data.alt : "");
        altField.percentWidth = 100;
        altField.onChange = function(_) {
            editorComp.dto.data.alt = altField.text;
            editorComp.refresh();
        };
        inspector.addComponent(altField);
    }
    
    function addButtonInspector(editorComp:EditorComponent):Void {
        // Button text
        var textLabel = new Label();
        textLabel.text = "Button Text:";
        inspector.addComponent(textLabel);
        
        var textField = new TextField();
        textField.text = Std.string(editorComp.dto.data.text != null ? editorComp.dto.data.text : "");
        textField.percentWidth = 100;
        textField.onChange = function(_) {
            editorComp.dto.data.text = textField.text;
            editorComp.refresh();
        };
        inspector.addComponent(textField);
        
        // Action URL
        var actionLabel = new Label();
        actionLabel.text = "Action URL:";
        inspector.addComponent(actionLabel);
        
        var actionField = new TextField();
        actionField.text = Std.string(editorComp.dto.data.action != null ? editorComp.dto.data.action : "");
        actionField.percentWidth = 100;
        actionField.onChange = function(_) {
            editorComp.dto.data.action = actionField.text;
            editorComp.refresh();
        };
        inspector.addComponent(actionField);
    }
    
    /** Delete a component */
    function deleteComponent(editorComp:EditorComponent):Void {
        editorComponents.remove(editorComp);
        canvas.removeComponent(editorComp.container);
        inspector.removeAllComponents();
        selectedComponent = null;
    }
    
    /** Save current state as draft */
    function saveDraft():Void {
        if (currentPage == null) return;
        
        // Build components array
        var components:Array<PageComponentDTO> = [];
        for (i in 0...editorComponents.length) {
            var ec = editorComponents[i];
            ec.dto.sort = i; // Update sort order
            components.push(ec.dto);
        }
        
        cmsManager.updatePage(
            currentPage.pageId,
            currentPage.title,
            currentPage.layout,
            components,
            function(response:UpdatePageResponse) {
                if (response.success) {
                    // Reload to get updated version info
                    loadPage(currentPage.pageId);
                    if (onSaved != null && currentPage != null) onSaved(currentPage);
                }
            }
        );
    }
    
    /** Publish the current version */
    function publish():Void {
        if (currentPage == null) return;
        
        cmsManager.publishVersion(
            currentPage.pageId,
            currentPage.id,
            function(response:CreatePageResponse) {
                if (response.success) {
                    // Optionally close or reload
                }
            }
        );
    }
}

/** Wrapper for a component in the editor with selection state */
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
        
        // Make clickable
        container.onClick = function(_) {
            editor.selectComponent(this);
        };
    }
    
    public function refresh():Void {
        container.removeAllComponents();
        
        // Render the actual component
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
