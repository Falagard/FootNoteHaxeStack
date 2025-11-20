package shared;

import CmsModels;
import sidewinder.Database;
import haxe.Json;

class PageSerializer {
	public function new() {}

	public function updatePageSlug(pageId:Int, slug:String):Bool {
		// Validate slug format (only allow a-z, 0-9, dash, underscore, min 3 chars)
		var slugRegex = ~/^[a-z0-9_-]{3,}$/i;
		if (!slugRegex.match(slug)) {
			return false;
		}
		var conn = Database.acquire();
		try {
			// Check for duplicate slug (exclude current page)
			var params = new Map<String, Dynamic>();
			params.set("slug", slug);
			params.set("pageId", pageId);
			var sql = "SELECT id FROM pages WHERE slug = @slug AND id != @pageId";
			var rs = conn.request(Database.buildSql(sql, params));
			if (rs.hasNext()) {
				Database.release(conn);
				return false; // Duplicate found
			}
			// Update slug
			params = new Map<String, Dynamic>();
			params.set("pageId", pageId);
			params.set("slug", slug);
			sql = "UPDATE pages SET slug = @slug WHERE id = @pageId";
			conn.request(Database.buildSql(sql, params));
			Database.release(conn);
			return true;
		} catch (e:Dynamic) {
			Database.release(conn);
			return false;
		}
	}

	public function savePageVersion(page:PageDTO, ?userId:String, ?seoHtml:String):Int {
		var conn = Database.acquire();
		try {
			// Get next version number
			var params = new Map<String, Dynamic>();
			params.set("pageId", page.pageId);
			var sql = "SELECT COALESCE(MAX(version_num),0)+1 AS nextVer FROM page_versions WHERE page_id = @pageId";
			var rs = conn.request(Database.buildSql(sql, params));
			var nextVer = 1;
			if (rs.hasNext()) {
				var rec = rs.next();
				nextVer = rec.nextVer;
			}

			// Insert new version
			params = new Map<String, Dynamic>();
			params.set("pageId", page.pageId);
			params.set("versionNum", nextVer);
			params.set("title", page.title);
			params.set("layout", page.layout);
			params.set("createdBy", userId);
			params.set("seoHtml", seoHtml);
			sql = "INSERT INTO page_versions (page_id, version_num, title, layout, created_by, seo_html) VALUES (@pageId, @versionNum, @title, @layout, @createdBy, @seoHtml)";
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
				sql = "INSERT INTO page_components (page_version_id, sort_order, type, data_json) VALUES (@versionId, @sortOrder, @type, @dataJson)";
				conn.request(Database.buildSql(sql, params));
			}


			// Update Page latest_version_id and title
			params = new Map<String, Dynamic>();
			params.set("versionId", versionId);
			params.set("pageId", page.pageId);
			params.set("title", page.title);
			sql = "UPDATE pages SET latest_version_id = @versionId, title = @title WHERE id = @pageId";
			conn.request(Database.buildSql(sql, params));

			Database.release(conn);
			return versionId;
		} catch (e:Dynamic) {
			Database.release(conn);
			throw e;
		}
	}

	public function createPage(slug:String, title:String, layout:String = "default", ?seoHtml:String):Int {
		var conn = Database.acquire();
		try {
			var params = new Map<String, Dynamic>();
			params.set("slug", slug);
			params.set("title", title);
			var sql = "INSERT INTO pages (slug, title) VALUES (@slug, @title)";
			conn.request(Database.buildSql(sql, params));
			var pageId = conn.lastInsertId();

			// Create initial empty version
			var page:PageDTO = {
				pageId: pageId,
				title: title,
				layout: layout,
				components: []
			};
			savePageVersion(page, null, seoHtml);

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
			var sql = "UPDATE pages SET published_version_id = @versionId WHERE id = @pageId";
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
