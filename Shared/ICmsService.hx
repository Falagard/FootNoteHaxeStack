package;

import CmsModels;
import hx.injection.Service;

interface ICmsService extends Service {
@post("/api/cms/page")
@requiresAuth
function createPage(request:CreatePageRequest):CreatePageResponse;

@put("/api/cms/page/:id")
@requiresAuth
function updatePage(id:Int, request:UpdatePageRequest, ?userId:String):UpdatePageResponse;

@get("/api/cms/page/:id")
function getPage(id:Int):GetPageResponse;

@get("/api/cms/page/slug/:slug")
function getPageBySlug(slug:String, ?published:Bool = true):GetPageResponse;

@get("/api/cms/pages")
function listPages():ListPagesResponse;

@post("/api/cms/page/:pageId/version/:versionId/publish")
@requiresAuth
function publishVersion(pageId:Int, versionId:Int):CreatePageResponse;

@post("/api/cms/version/:versionId/restore")
@requiresAuth
function restoreVersion(versionId:Int, ?userId:String):UpdatePageResponse;

@get("/api/cms/page/:pageId/versions")
function listVersions(pageId:Int):Dynamic;

@post("/api/cms/asset")
@requiresAuth
function uploadAsset(request:UploadAssetRequest):UploadAssetResponse;

@get("/api/cms/asset/:assetId")
function getAsset(assetId:Int):Dynamic;

@get("/api/cms/page/:pageId/assets")
function listAssets(pageId:Int):Dynamic;

@post("/api/cms/validate")
function validateComponents(json:String):ValidationResult;

@post("/api/cms/ai-prompt")
function generateAiPrompt(prompt:String):Dynamic;

@get("/api/cms/component-types")
function getComponentTypes():Array<String>;
}
