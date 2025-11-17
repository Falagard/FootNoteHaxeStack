package shared;

import CmsModels;
import sidewinder.Database;
import haxe.Json;

class PageSerializer {
	public function new() {}

	public function savePageVersion(page:PageDTO, ?userId:String):Int {
		var conn = Database.acquire();
		try {
			// Get next version number
			var params = new Map<String, Dynamic>();
			params.set("pageId", page.pageId);
			var sql = "SELECT COALESCE(MAX(version_num),0)+1 AS nextVer FROM PageVersion WHERE page_id = @pageId";
			var rs = conn.request(Database.buildSql(sql, params));
			var nextVer = 1;
			if (rs.hasNext()) {
				var rec = rs.next();
				nextVer = rec.getInt(0);
			}

			// Insert new version
			params = new Map<String, Dynamic>();
			params.set("pageId", page.pageId);
			params.set("versionNum", nextVer);
			params.set("title", page.title);
			params.set("layout", page.layout);
			params.set("createdBy", userId);
			sql = "INSERT INTO PageVersion (page_id, version_num, title, layout, created_by) VALUES (@pageId, @versionNum, @title, @layout, @createdBy)";
			conn.request(Database.buildSql(sql, params));
			var versionId = conn.lastInsertId();

			// Insert components
			for (comp in page.components) {
				var jsonData = Json.stringify(comp.data);
				params = new Map<String, Dynamic>();
				params.set("versionId", versionId);
				params.set("sortOrder", comp.sort);
				params.set("type", comp.type);
				params.set("dataJson", jsonData);
				sql = "INSERT INTO PageComponent (page_version_id, sort_order, type, data_json) VALUES (@versionId, @sortOrder, @type, @dataJson)";
				conn.request(Database.buildSql(sql, params));
			}

			// Update Page latest_version_id
			params = new Map<String, Dynamic>();
			params.set("versionId", versionId);
			params.set("pageId", page.pageId);
			sql = "UPDATE Page SET latest_version_id = @versionId WHERE id = @pageId";
			conn.request(Database.buildSql(sql, params));

			Database.release(conn);
			return versionId;
		} catch (e:Dynamic) {
			Database.release(conn);
			throw e;
		}
	}

	public function createPage(slug:String, title:String, layout:String = "default"):Int {
		var conn = Database.acquire();
		try {
			var params = new Map<String, Dynamic>();
			params.set("slug", slug);
			params.set("title", title);
			var sql = "INSERT INTO Page (slug, title) VALUES (@slug, @title)";
			conn.request(Database.buildSql(sql, params));
			var pageId = conn.lastInsertId();

			// Create initial empty version
			var page:PageDTO = {
				pageId: pageId,
				title: title,
				layout: layout,
				components: []
			};
			savePageVersion(page);

			Database.release(conn);
			return pageId;
		} catch (e:Dynamic) {
			Database.release(conn);
			throw e;
		}
	}

	public function publishVersion(pageId:Int, versionId:Int):Void {
		var conn = Database.acquire();
		try {
			var params = new Map<String, Dynamic>();
			params.set("versionId", versionId);
			params.set("pageId", pageId);
			var sql = "UPDATE Page SET published_version_id = @versionId WHERE id = @pageId";
			conn.request(Database.buildSql(sql, params));
			Database.release(conn);
		} catch (e:Dynamic) {
			Database.release(conn);
			throw e;
		}
	}

	public function uploadAsset(pageId:Int, filename:String, mime:String, data:String):Int {
		var conn = Database.acquire();
		try {
			// Decode base64 data
			var bytes = haxe.crypto.Base64.decode(data);
			
			var params = new Map<String, Dynamic>();
			params.set("pageId", pageId);
			params.set("filename", filename);
			params.set("mime", mime);
			params.set("data", bytes.toString());
			var sql = "INSERT INTO page_assets (page_id, filename, mime, data) VALUES (@pageId, @filename, @mime, @data)";
			conn.request(Database.buildSql(sql, params));
			var assetId = conn.lastInsertId();
			
			Database.release(conn);
			return assetId;
		} catch (e:Dynamic) {
			Database.release(conn);
			throw e;
		}
	}
}
