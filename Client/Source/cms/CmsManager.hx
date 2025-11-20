package cms;

import services.AsyncServiceRegistry;
import CmsModels;
import util.SeoHtmlGenerator;
import components.Notifications;

/** Manager for all CMS operations - interfaces with backend services */
class CmsManager {
    var asyncServices = AsyncServiceRegistry.instance;
    
    public function new() {}
    
    // ============ Page Operations ============
    
    /** Create a new page */
    public function createPage(slug:String, title:String, layout:String, ?components:Array<PageComponentDTO>, callback:CreatePageResponse->Void, ?errorCallback:Dynamic->Void):Void {
        var seoHtml:String = components != null ? SeoHtmlGenerator.generate(components) : null;
        var request:CreatePageRequest = {
            slug: slug,
            title: title,
            layout: layout,
            seoHtml: seoHtml
        };
        
        untyped asyncServices.cms.createPageAsync(request, function(response:CreatePageResponse) {
            if (response.success) {
                Notifications.show('Page created successfully', 'success');
            } else {
                Notifications.show('Failed to create page: ' + (response.error != null ? response.error : 'Unknown error'), 'error');
            }
            callback(response);
        }, function(err:Dynamic) {
            Notifications.show('Error creating page: ' + Std.string(err), 'error');
            if (errorCallback != null) errorCallback(err);
        });
    }
    
    /** Update a page (creates new version) */
    public function updatePage(pageId:Int, title:String, layout:String, components:Array<PageComponentDTO>, slug:String, callback:UpdatePageResponse->Void, ?errorCallback:Dynamic->Void):Void {
        var seoHtml:String = SeoHtmlGenerator.generate(components);
        var request:UpdatePageRequest = {
            pageId: pageId,
            title: title,
            layout: layout,
            components: components,
            slug: slug,
            seoHtml: seoHtml
        };
        
        untyped asyncServices.cms.updatePageAsync(pageId, request, function(response:UpdatePageResponse) {
            if (response.success) {
                Notifications.show('Page updated successfully (version ${response.versionNum})', 'success');
            } else {
                Notifications.show('Failed to update page: ' + (response.error != null ? response.error : 'Unknown error'), 'error');
            }
            callback(response);
        }, function(err:Dynamic) {
            Notifications.show('Error updating page: ' + Std.string(err), 'error');
            if (errorCallback != null) errorCallback(err);
        });
    }
    
    /** Get a page by ID */
    public function getPage(pageId:Int, callback:GetPageResponse->Void, ?errorCallback:Dynamic->Void):Void {
        untyped asyncServices.cms.getPageAsync(pageId, function(response:GetPageResponse) {
            if (!response.success) {
                Notifications.show('Failed to load page: ' + (response.error != null ? response.error : 'Unknown error'), 'error');
            }
            callback(response);
        }, function(err:Dynamic) {
            Notifications.show('Error loading page: ' + Std.string(err), 'error');
            if (errorCallback != null) errorCallback(err);
        });
    }
    
    /** Get a page by slug */
    public function getPageBySlug(slug:String, ?published:Bool = true, callback:GetPageResponse->Void, ?errorCallback:Dynamic->Void):Void {
        untyped asyncServices.cms.getPageBySlugAsync(slug, published, function(response:GetPageResponse) {
            if (!response.success) {
                Notifications.show('Failed to load page: ' + (response.error != null ? response.error : 'Unknown error'), 'error');
            }
            callback(response);
        }, function(err:Dynamic) {
            Notifications.show('Error loading page: ' + Std.string(err), 'error');
            if (errorCallback != null) errorCallback(err);
        });
    }
    
    /** List all pages */
    public function listPages(callback:ListPagesResponse->Void, ?errorCallback:Dynamic->Void):Void {
        untyped asyncServices.cms.listPagesAsync(function(response:ListPagesResponse) {
            if (!response.success) {
                Notifications.show('Failed to list pages: ' + (response.error != null ? response.error : 'Unknown error'), 'error');
            }
            callback(response);
        }, function(err:Dynamic) {
            Notifications.show('Error listing pages: ' + Std.string(err), 'error');
            if (errorCallback != null) errorCallback(err);
        });
    }
    
    // ============ Version Operations ============
    
    /** Publish a specific version */
    public function publishVersion(pageId:Int, versionId:Int, callback:CreatePageResponse->Void, ?errorCallback:Dynamic->Void):Void {
        untyped asyncServices.cms.publishVersionAsync(pageId, versionId, function(response:CreatePageResponse) {
            if (response.success) {
                Notifications.show('Version published successfully', 'success');
            } else {
                Notifications.show('Failed to publish version: ' + (response.error != null ? response.error : 'Unknown error'), 'error');
            }
            callback(response);
        }, function(err:Dynamic) {
            Notifications.show('Error publishing version: ' + Std.string(err), 'error');
            if (errorCallback != null) errorCallback(err);
        });
    }
    
    /** Restore a previous version (creates new version as copy) */
    public function restoreVersion(versionId:Int, callback:UpdatePageResponse->Void, ?errorCallback:Dynamic->Void):Void {
        untyped asyncServices.cms.restoreVersionAsync(versionId, function(response:UpdatePageResponse) {
            if (response.success) {
                Notifications.show('Version restored successfully', 'success');
            } else {
                Notifications.show('Failed to restore version: ' + (response.error != null ? response.error : 'Unknown error'), 'error');
            }
            callback(response);
        }, function(err:Dynamic) {
            Notifications.show('Error restoring version: ' + Std.string(err), 'error');
            if (errorCallback != null) errorCallback(err);
        });
    }
    
    /** List all versions for a page */
    public function listVersions(pageId:Int, callback:Dynamic->Void, ?errorCallback:Dynamic->Void):Void {
        untyped asyncServices.cms.listVersionsAsync(pageId, function(response:Dynamic) {
            callback(response);
        }, function(err:Dynamic) {
            Notifications.show('Error listing versions: ' + Std.string(err), 'error');
            if (errorCallback != null) errorCallback(err);
        });
    }
    
    // ============ Asset Operations ============
    
    /** Upload an asset */
    public function uploadAsset(pageId:Int, filename:String, mime:String, data:String, callback:UploadAssetResponse->Void, ?errorCallback:Dynamic->Void):Void {
        var request:UploadAssetRequest = {
            pageId: pageId,
            filename: filename,
            mime: mime,
            data: data
        };
        
        untyped asyncServices.cms.uploadAssetAsync(request, function(response:UploadAssetResponse) {
            if (response.success) {
                Notifications.show('Asset uploaded successfully', 'success');
            } else {
                Notifications.show('Failed to upload asset: ' + (response.error != null ? response.error : 'Unknown error'), 'error');
            }
            callback(response);
        }, function(err:Dynamic) {
            Notifications.show('Error uploading asset: ' + Std.string(err), 'error');
            if (errorCallback != null) errorCallback(err);
        });
    }
    
    /** Get component types */
    public function getComponentTypes(callback:Array<String>->Void, ?errorCallback:Dynamic->Void):Void {
        untyped asyncServices.cms.getComponentTypesAsync(function(types:Array<String>) {
            callback(types);
        }, function(err:Dynamic) {
            Notifications.show('Error fetching component types: ' + Std.string(err), 'error');
            if (errorCallback != null) errorCallback(err);
        });
    }
}
