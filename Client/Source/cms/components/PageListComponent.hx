package cms.components;

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
import cms.ICmsManager;
import cms.PageEditor;
import CmsModels;
using StringTools;

/** Embeddable component for listing and managing all pages */
class PageListComponent extends VBox {
    /**
     * Callback when user wants to edit a page. Set by parent.
     * Example: pageList.onEditPage = function(pageId) { ... }
     */
    public var onEditPage:Int->Void = null;
    /**
     * Callback when user wants to view a page. Optional.
     * Example: pageList.onViewPage = function(pageId) { ... }
     */
    public var onViewPage:Int->Void = null;
    // UI components
    var createPageBtn:Button;
    var refreshBtn:Button;
    var pageTable:TableView;
    var createDialog:Dialog;
    var slugField:TextField;
    var titleField:TextField;
    var cancelCreateBtn:Button;
    var confirmCreateBtn:Button;
    var cmsManager:ICmsManager;
    var pages:Array<PageListItem> = [];
    var tableDataSource:ArrayDataSource<Dynamic>;
    /**
     * Create a new PageListComponent.
     * @param cmsManager The ICmsManager instance to use. Can also be set later via property.
     *
     * Sizing is not set by default; parent should control width/height as needed.
     */
    public function new(cmsManager:ICmsManager) {
        super();
        this.cmsManager = cmsManager;
        buildUI();
        loadPages();
    }
    function buildUI():Void {
        var topBar = new HBox();
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
        pageTable = new TableView();
        pageTable.addColumn("ID").width = 80;
        pageTable.addColumn("Slug").width = 100;
        pageTable.addColumn("Title").width = 200;
        pageTable.addColumn("Created").width = 200;
        tableDataSource = new ArrayDataSource<Dynamic>();
        pageTable.dataSource = tableDataSource;
        pageTable.onClick = function(event) {
            var selectedItem = pageTable.selectedItem;
            if (selectedItem != null && selectedItem.pageId != null) {
                editPage(selectedItem.pageId);
            }
        };
        addComponent(pageTable);
    }
    public function loadPages():Void {
        cmsManager.listPages(function(response:ListPagesResponse) {
            if (response.success && response.pages != null) {
                pages = response.pages;
                renderPages();
            }
        });
    }
    function renderPages():Void {
        if (tableDataSource == null) return;
        tableDataSource.clear();
        for (page in pages) {
            var rowData:Dynamic = {
                ID: page.id,
                Slug: page.slug,
                Title: page.title,
                Created: Std.string(page.createdAt),
                pageId: page.id
            };
            tableDataSource.add(rowData);
        }
    }
    function showCreateDialog():Void {
        createDialog = new Dialog();
        createDialog.title = "Create New Page";
        createDialog.width = 400;
        var content = new VBox();
        content.percentWidth = 100;
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
    function hideCreateDialog():Void {
        if (createDialog != null) {
            createDialog.hideDialog(null);
        }
    }
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
        cmsManager.createPage(slug, title, "default", [], function(response:CreatePageResponse) {
            if (response.success) {
                hideCreateDialog();
                loadPages();
                if (response.pageId != null && onEditPage != null) {
                    onEditPage(response.pageId);
                }
            }
        });
    }
    function editPage(pageId:Int):Void {
        if (onEditPage != null) {
            onEditPage(pageId);
        }
    }
    function triggerViewPage(pageId:Int):Void {
        if (onViewPage != null) {
            onViewPage(pageId);
        } else {
            viewPage(pageId);
        }
    }
    function viewPage(pageId:Int):Void {
        cmsManager.getPage(pageId, function(response:GetPageResponse) {
            if (response.success && response.page != null) {
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
    /**
     * Documentation:
     *
     * Embeddable PageListComponent for listing and managing CMS pages.
     *
     * Usage:
     *   var pageList = new PageListComponent(cmsManager);
     *   pageList.onEditPage = function(pageId) { ... };
     *   pageList.onViewPage = function(pageId) { ... };
     *   // Add to parent container as needed
     *
     * Sizing:
     *   By default, PageListComponent does not set percentWidth/percentHeight. Parent should control sizing.
     *
     * Dependencies:
     *   Requires ICmsManager (pass to constructor or set property).
     *
     * Events:
     *   onEditPage(pageId:Int): Called when user wants to edit a page.
     *   onViewPage(pageId:Int): Called when user wants to view a page (optional).
     */
}
