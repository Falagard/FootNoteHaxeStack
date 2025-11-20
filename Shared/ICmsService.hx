package;

import CmsModels;
import hx.injection.Service;

interface ICmsService extends Service {

    //Public - don't require auth 
	@get("/pub/cms/page/:id")
	function getPage(id:Int):GetPageResponse;

	@get("/pub/cms/page/slug/:slug")
	function getPageBySlug(slug:String, ?published:Bool = true):GetPageResponse;

    //Api - require auth
	@post("/api/cms/page")
	@requiresAuth
	function createPage(request:CreatePageRequest, userId:String):CreatePageResponse;

	@put("/api/cms/page/:id")
	@requiresAuth
	function updatePage(id:Int, request:UpdatePageRequest, userId:String):UpdatePageResponse;

	@get("/api/cms/pages")
    @requiresAuth
	function listPages():ListPagesResponse;

	@post("/api/cms/page/:pageId/version/:versionId/publish")
	@requiresAuth
	function publishVersion(pageId:Int, versionId:Int, userId:String):CreatePageResponse;

	@post("/api/cms/version/:versionId/restore")
	@requiresAuth
	function restoreVersion(versionId:Int, userId:String):UpdatePageResponse;

	@get("/api/cms/page/:pageId/versions")
    @requiresAuth
	function listVersions(pageId:Int):Dynamic;

	@post("/api/cms/asset")
	@requiresAuth
	function uploadAsset(request:UploadAssetRequest, userId:String):UploadAssetResponse;

	@get("/api/cms/asset/:assetId")
    @requiresAuth
	function getAsset(assetId:Int):Dynamic;

	@get("/api/cms/page/:pageId/assets")
    @requiresAuth
	function listAssets(pageId:Int):Dynamic;

	@post("/api/cms/validate")
    @requiresAuth
	function validateComponents(json:String):ValidationResult;

	@post("/api/cms/ai-prompt")
    @requiresAuth
	function generateAiPrompt(prompt:String):Dynamic;

	@get("/api/cms/component-types")
    @requiresAuth
	function getComponentTypes():Array<String>;
}
