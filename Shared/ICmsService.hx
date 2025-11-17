package;

import CmsModels;
import hx.injection.Service;

interface ICmsService extends Service {
@post("/api/cms/createPage")
function createPage(request:CreatePageRequest):CreatePageResponse;

@post("/api/cms/updatePage")
function updatePage(request:UpdatePageRequest, ?userId:String):UpdatePageResponse;

@post("/api/cms/getPage")
function getPage(pageId:Int):GetPageResponse;

@get("/api/cms/pages/slug/:slug")
function getPageBySlug(slug:String, ?published:Bool = true):GetPageResponse;

@post("/api/cms/listPages")
function listPages():ListPagesResponse;

@post("/api/cms/publishVersion")
function publishVersion(pageId:Int, versionId:Int):CreatePageResponse;

@post("/api/cms/restoreVersion")
function restoreVersion(versionId:Int, ?userId:String):UpdatePageResponse;

@post("/api/cms/listVersions")
function listVersions(pageId:Int):Dynamic;

@post("/api/cms/uploadAsset")
function uploadAsset(request:UploadAssetRequest):UploadAssetResponse;

@post("/api/cms/getAsset")
function getAsset(assetId:Int):Dynamic;

@post("/api/cms/listAssets")
function listAssets(pageId:Int):Dynamic;

@post("/api/cms/validate")
function validateComponents(json:String):ValidationResult;

@post("/api/cms/ai-prompt")
function generateAiPrompt(prompt:String):Dynamic;

@get("/api/cms/component-types")
function getComponentTypes():Array<String>;
}
