package cms;

import haxe.ui.containers.VBox;
import haxe.ui.containers.HBox;
import haxe.ui.containers.dialogs.Dialog;
import haxe.ui.components.Button;
import haxe.ui.components.Label;
import haxe.ui.components.TextField;
import cms.CmsManager;
import cms.PageEditor;
import CmsModels;
using StringTools;

/** View for listing and managing all pages */
@:build(haxe.ui.ComponentBuilder.build("Assets/page-list.xml"))
class PageList extends VBox {
    public var onEditPage:Int->Void; // callback when user wants to edit a page
    
    // UI components from XML
    var createPageBtn:Button;
    var refreshBtn:Button;
    var pageGrid:VBox;
    var createDialog:Dialog;
    var slugField:TextField;
    var titleField:TextField;
    var cancelCreateBtn:Button;
    var confirmCreateBtn:Button;
    
    var cmsManager:CmsManager;
    var pages:Array<PageListItem> = [];
    
    public function new(cmsManager:CmsManager) {
        super();
        this.cmsManager = cmsManager;
        
        // Wire up buttons
        if (createPageBtn != null) createPageBtn.onClick = function(_) showCreateDialog();
        if (refreshBtn != null) refreshBtn.onClick = function(_) loadPages();
        if (cancelCreateBtn != null) cancelCreateBtn.onClick = function(_) hideCreateDialog();
        if (confirmCreateBtn != null) confirmCreateBtn.onClick = function(_) createPage();
        
        // Load pages on init
        haxe.ui.Toolkit.callLater(function() {
            loadPages();
        });
    }
    
    /** Load all pages from server */
    public function loadPages():Void {
        cmsManager.listPages(function(response:ListPagesResponse) {
            if (response.success && response.pages != null) {
                pages = response.pages;
                renderPages();
            }
        });
    }
    
    /** Render the pages in the grid */
    function renderPages():Void {
        if (pageGrid == null) return;
        
        pageGrid.removeAllComponents();
        
        // Add header row
        var headerRow = new HBox();
        headerRow.percentWidth = 100;
        headerRow.addComponent(createLabel("ID", true));
        headerRow.addComponent(createLabel("Slug", true));
        headerRow.addComponent(createLabel("Title", true));
        headerRow.addComponent(createLabel("Created", true));
        headerRow.addComponent(createLabel("Actions", true));
        pageGrid.addComponent(headerRow);
        
        // Add page rows
        for (page in pages) {
            var row = new HBox();
            row.percentWidth = 100;
            
            row.addComponent(createLabel(Std.string(page.id), false));
            row.addComponent(createLabel(page.slug, false));
            row.addComponent(createLabel(page.title, false));
            row.addComponent(createLabel(page.createdAt, false));
            
            var actionsBox = new HBox();
            
            var editBtn = new Button();
            editBtn.text = "Edit";
            editBtn.onClick = function(_) editPage(page.id);
            actionsBox.addComponent(editBtn);
            
            var viewBtn = new Button();
            viewBtn.text = "View";
            viewBtn.onClick = function(_) viewPage(page.id);
            actionsBox.addComponent(viewBtn);
            
            row.addComponent(actionsBox);
            pageGrid.addComponent(row);
        }
    }
    
    function createLabel(text:String, isHeader:Bool):Label {
        var label = new Label();
        label.text = text;
        if (isHeader) {
            label.styleNames = "gridHeader";
        }
        return label;
    }
    
    /** Show create page dialog */
    function showCreateDialog():Void {
        if (createDialog != null) {
            slugField.text = "";
            titleField.text = "";
            createDialog.hidden = false;
        }
    }
    
    /** Hide create page dialog */
    function hideCreateDialog():Void {
        if (createDialog != null) {
            createDialog.hidden = true;
        }
    }
    
    /** Create a new page */
    function createPage():Void {
        var slug = slugField.text;
        var title = titleField.text;
        
        if (slug == null || slug.trim() == "") {
            components.Notifications.show("Slug is required", "error");
            return;
        }
        
        if (title == null || title.trim() == "") {
            components.Notifications.show("Title is required", "error");
            return;
        }
        
        cmsManager.createPage(slug, title, "default", function(response:CreatePageResponse) {
            if (response.success) {
                hideCreateDialog();
                loadPages();
                
                // Open editor for new page
                if (response.pageId != null && onEditPage != null) {
                    onEditPage(response.pageId);
                }
            }
        });
    }
    
    /** Edit a page */
    function editPage(pageId:Int):Void {
        if (onEditPage != null) {
            onEditPage(pageId);
        }
    }
    
    /** View a published page */
    function viewPage(pageId:Int):Void {
        cmsManager.getPage(pageId, function(response:GetPageResponse) {
            if (response.success && response.page != null) {
                // Show in a preview dialog
                var previewDialog = new Dialog();
                previewDialog.title = "Preview: " + response.page.title;
                previewDialog.percentWidth = 80;
                previewDialog.percentHeight = 80;
                
                var renderer = new PageRenderer();
                var rendered = renderer.render(response.page);
                previewDialog.addComponent(rendered);
                
                previewDialog.showDialog();
            }
        });
    }
}
