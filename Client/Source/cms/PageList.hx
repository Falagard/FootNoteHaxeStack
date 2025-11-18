package cms;

import haxe.ui.containers.VBox;
import haxe.ui.containers.HBox;
import haxe.ui.containers.ScrollView;
import haxe.ui.containers.dialogs.Dialog;
import haxe.ui.containers.TableView;
import haxe.ui.components.Button;
import haxe.ui.components.Label;
import haxe.ui.components.TextField;
import haxe.ui.components.Spacer;
import haxe.ui.data.ArrayDataSource;
import cms.CmsManager;
import cms.PageEditor;
import CmsModels;
using StringTools;

/** View for listing and managing all pages */
class PageList extends VBox {
    public var onEditPage:Int->Void; // callback when user wants to edit a page
    
    // UI components
    var createPageBtn:Button;
    var refreshBtn:Button;
    var pageTable:TableView;
    var createDialog:Dialog;
    var slugField:TextField;
    var titleField:TextField;
    var cancelCreateBtn:Button;
    var confirmCreateBtn:Button;
    
    var cmsManager:CmsManager;
    var pages:Array<PageListItem> = [];
    var tableDataSource:ArrayDataSource<Dynamic>;
    
    public function new(cmsManager:CmsManager) {
        super();
        this.cmsManager = cmsManager;
        this.percentWidth = 100;
        this.percentHeight = 100;
        
        buildUI();
        loadPages();
    }
    
    function buildUI():Void {
        // Top bar
        var topBar = new HBox();
        topBar.percentWidth = 100;
        
        var titleLabel = new Label();
        titleLabel.text = "CMS Pages";
        topBar.addComponent(titleLabel);
        
        var spacer = new Spacer();
        spacer.percentWidth = 100;
        topBar.addComponent(spacer);
        
        createPageBtn = new Button();
        createPageBtn.text = "Create New Page";
        createPageBtn.onClick = function(_) showCreateDialog();
        topBar.addComponent(createPageBtn);
        
        refreshBtn = new Button();
        refreshBtn.text = "Refresh";
        refreshBtn.onClick = function(_) loadPages();
        topBar.addComponent(refreshBtn);
        
        addComponent(topBar);
        
        // Create table view
        pageTable = new TableView();
        pageTable.percentWidth = 100;
        pageTable.percentHeight = 100;
        
        // Add columns
        pageTable.addColumn("ID");
        pageTable.addColumn("Slug");
        pageTable.addColumn("Title");
        pageTable.addColumn("Created");
        
        // Initialize data source
        tableDataSource = new ArrayDataSource<Dynamic>();
        pageTable.dataSource = tableDataSource;
        
        // Handle row click for editing
        pageTable.onClick = function(event) {
            var selectedItem = pageTable.selectedItem;
            if (selectedItem != null && selectedItem.pageId != null) {
                editPage(selectedItem.pageId);
            }
        };
        
        addComponent(pageTable);
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
    
    /** Render the pages in the table */
    function renderPages():Void {
        if (tableDataSource == null) return;
        
        tableDataSource.clear();
        
        // Add page data to table
        for (page in pages) {
            var rowData:Dynamic = {
                ID: page.id,
                Slug: page.slug,
                Title: page.title,
                Created: Std.string(page.createdAt),
                pageId: page.id // Store pageId for actions
            };
            tableDataSource.add(rowData);
        }
    }
    
    /** Show create page dialog */
    function showCreateDialog():Void {
        createDialog = new Dialog();
        createDialog.title = "Create New Page";
        createDialog.width = 400;
        
        var content = new VBox();
        content.percentWidth = 100;
        
        // Slug field
        var slugRow = new HBox();
        slugRow.percentWidth = 100;
        var slugLabel = new Label();
        slugLabel.text = "Slug:";
        slugLabel.width = 100;
        slugRow.addComponent(slugLabel);
        slugField = new TextField();
        slugField.percentWidth = 100;
        slugField.placeholder = "page-slug";
        slugRow.addComponent(slugField);
        content.addComponent(slugRow);
        
        // Title field
        var titleRow = new HBox();
        titleRow.percentWidth = 100;
        var titleLabel = new Label();
        titleLabel.text = "Title:";
        titleLabel.width = 100;
        titleRow.addComponent(titleLabel);
        titleField = new TextField();
        titleField.percentWidth = 100;
        titleField.placeholder = "Page Title";
        titleRow.addComponent(titleField);
        content.addComponent(titleRow);
        
        // Buttons
        var buttonRow = new HBox();
        buttonRow.percentWidth = 100;
        var spacer = new Spacer();
        spacer.percentWidth = 100;
        buttonRow.addComponent(spacer);
        
        cancelCreateBtn = new Button();
        cancelCreateBtn.text = "Cancel";
        cancelCreateBtn.onClick = function(_) createDialog.hideDialog(null);
        buttonRow.addComponent(cancelCreateBtn);
        
        confirmCreateBtn = new Button();
        confirmCreateBtn.text = "Create";
        confirmCreateBtn.onClick = function(_) createPage();
        buttonRow.addComponent(confirmCreateBtn);
        
        content.addComponent(buttonRow);
        
        createDialog.addComponent(content);
        createDialog.showDialog();
    }
    
    /** Hide create page dialog */
    function hideCreateDialog():Void {
        if (createDialog != null) {
            createDialog.hideDialog(null);
        }
    }
    
    /** Create a new page */
    function createPage():Void {
        var slug = slugField != null ? slugField.text : "";
        var title = titleField != null ? titleField.text : "";
        
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
