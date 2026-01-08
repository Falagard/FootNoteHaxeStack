package app.cms;

import app.models.CmsModels;
import app.models.VisibilityConfig;
import app.models.MegaMenuModels; // for MenuDTO
import hx.injection.Service;

/**
 * Interface for CmsManager to support dependency injection (haxe_injection)
 */
interface ICmsManager extends Service {
	// Page Operations
	public function createPage(slug:String, title:String, layout:String, ?components:Array<PageComponentDTO>, callback:CreatePageResponse->Void,
		?errorCallback:Dynamic->Void):Void;
	public function updatePage(pageId:Int, title:String, layout:String, components:Array<PageComponentDTO>, slug:String, visibilityConfig:VisibilityConfig,
		callback:UpdatePageResponse->Void, ?errorCallback:Dynamic->Void):Void;
	public function getPage(pageId:Int, callback:GetPageResponse->Void, ?errorCallback:Dynamic->Void):Void;
	public function getPageBySlug(slug:String, ?published:Bool = true, callback:GetPageResponse->Void, ?errorCallback:Dynamic->Void):Void;
	public function listPages(callback:ListPagesResponse->Void, ?errorCallback:Dynamic->Void):Void;

	// Version Operations
	public function publishVersion(pageId:Int, versionId:Int, callback:CreatePageResponse->Void, ?errorCallback:Dynamic->Void):Void;
	public function restoreVersion(versionId:Int, callback:UpdatePageResponse->Void, ?errorCallback:Dynamic->Void):Void;
	public function listVersions(pageId:Int, callback:Dynamic->Void, ?errorCallback:Dynamic->Void):Void;

	// Asset Operations
	public function uploadAsset(pageId:Int, filename:String, mime:String, data:String, callback:UploadAssetResponse->Void, ?errorCallback:Dynamic->Void):Void;

	// Component Types
	public function getComponentTypes(callback:Array<String>->Void, ?errorCallback:Dynamic->Void):Void;

	// MegaMenu
	public function getMenuAsync(id:Int, callback:MenuDTO->Void, ?errorCallback:Dynamic->Void):Void;
	public function listMenusAsync(callback:Array<MenuDTO>->Void, ?errorCallback:Dynamic->Void):Void;
}
