package shared;

import CmsModels;
import sidewinder.Database;
import haxe.Json;

class PageLoader {
	public function new() {}

	public function loadLatest(pageId:Int):PageVersionDTO {
		var conn = Database.acquire();
		try {
			var params = new Map<String, Dynamic>();
			params.set("pageId", pageId);
			var sql = "SELECT latest_version_id FROM pages WHERE id = @pageId";
			var rs = conn.request(Database.buildSql(sql, params));
			if (!rs.hasNext()) {
				Database.release(conn);
				throw 'Page not found: $pageId';
			}
			var versionId = rs.next().getInt(0);
			var result = loadVersion(versionId);
			Database.release(conn);
			return result;
		} catch (e:Dynamic) {
			Database.release(conn);
			throw e;
		}
	}

	public function loadPublished(pageId:Int):PageVersionDTO {
		var conn = Database.acquire();
		try {
			var params = new Map<String, Dynamic>();
			params.set("pageId", pageId);
			var sql = "SELECT published_version_id FROM pages WHERE id = @pageId";
			var rs = conn.request(Database.buildSql(sql, params));
			if (!rs.hasNext()) {
				Database.release(conn);
				throw 'Page not found: $pageId';
			}
			var versionId = rs.next().getInt(0);
			if (versionId == null || versionId == 0) {
				Database.release(conn);
				throw 'Page has no published version: $pageId';
			}
			var result = loadVersion(versionId);
			Database.release(conn);
			return result;
		} catch (e:Dynamic) {
			Database.release(conn);
			throw e;
		}
	}

	public function loadBySlug(slug:String, published:Bool = true):PageVersionDTO {
		var conn = Database.acquire();
		try {
			var params = new Map<String, Dynamic>();
			params.set("slug", slug);
			var column = published ? "published_version_id" : "latest_version_id";
			var sql = 'SELECT id, $column FROM pages WHERE slug = @slug';
			var rs = conn.request(Database.buildSql(sql, params));
			if (!rs.hasNext()) {
				Database.release(conn);
				throw 'Page not found: $slug';
			}
			var rec = rs.next();
			var versionId = rec.getInt(1);
			if (versionId == null || versionId == 0) {
				Database.release(conn);
				throw 'Page has no ${published ? "published" : "latest"} version: $slug';
			}
			var result = loadVersion(versionId);
			Database.release(conn);
			return result;
		} catch (e:Dynamic) {
			Database.release(conn);
			throw e;
		}
	}

	public function loadVersion(versionId:Int):PageVersionDTO {
		var conn = Database.acquire();
		try {
			var params = new Map<String, Dynamic>();
			params.set("versionId", versionId);
			var sql = "SELECT id, page_id, version_num, title, layout, created_at, created_by FROM page_versions WHERE id = @versionId";
			var rs = conn.request(Database.buildSql(sql, params));
			if (!rs.hasNext()) {
				Database.release(conn);
				throw 'Version not found: $versionId';
			}
			var v = rs.next();
			var dto:PageVersionDTO = {
				id: v.getInt(0),
				pageId: v.getInt(1),
				versionNum: v.getInt(2),
				title: v.getString(3),
				layout: v.getString(4),
				createdAt: v.getString(5),
				createdBy: v.getString(6),
				components: []
			};

			params = new Map<String, Dynamic>();
			params.set("versionId", versionId);
			sql = "SELECT id, sort_order, type, data_json FROM page_components WHERE page_version_id = @versionId ORDER BY sort_order ASC";
			var rs2 = conn.request(Database.buildSql(sql, params));
			while (rs2.hasNext()) {
				var c = rs2.next();
				dto.components.push({
					id: c.getInt(0),
					sort: c.getInt(1),
					type: c.getString(2),
					data: Json.parse(c.getString(3))
				});
			}

			Database.release(conn);
			return dto;
		} catch (e:Dynamic) {
			Database.release(conn);
			throw e;
		}
	}

	public function listVersions(pageId:Int):Array<{id:Int, versionNum:Int, createdAt:String, createdBy:String}> {
		var conn = Database.acquire();
		try {
			var params = new Map<String, Dynamic>();
			params.set("pageId", pageId);
			var sql = "SELECT id, version_num, created_at, created_by FROM page_versions WHERE page_id = @pageId ORDER BY version_num DESC";
			var rs = conn.request(Database.buildSql(sql, params));
			var versions = [];
			while (rs.hasNext()) {
				var rec = rs.next();
				versions.push({
					id: rec.getInt(0),
					versionNum: rec.getInt(1),
					createdAt: rec.getString(2),
					createdBy: rec.getString(3)
				});
			}
			Database.release(conn);
			return versions;
		} catch (e:Dynamic) {
			Database.release(conn);
			throw e;
		}
	}

	public function listPages():Array<PageListItem> {
		var conn = Database.acquire();
		try {
			var sql = "SELECT id, slug, title, created_at FROM pages ORDER BY created_at DESC";
			var rs = conn.request(sql);
			var pages = [];
			while (rs.hasNext()) {
				var rec = rs.next();
				pages.push({
					id: rec.getInt(0),
					slug: rec.getString(1),
					title: rec.getString(2),
					createdAt: rec.getString(3)
				});
			}
			Database.release(conn);
			return pages;
		} catch (e:Dynamic) {
			Database.release(conn);
			throw e;
		}
	}

	public function getAsset(assetId:Int):{filename:String, mime:String, data:String} {
		var conn = Database.acquire();
		try {
			var params = new Map<String, Dynamic>();
			params.set("assetId", assetId);
			var sql = "SELECT filename, mime, data FROM page_assets WHERE id = @assetId";
			var rs = conn.request(Database.buildSql(sql, params));
			if (!rs.hasNext()) {
				Database.release(conn);
				throw 'Asset not found: $assetId';
			}
			var rec = rs.next();
			var result = {
				filename: rec.getString(0),
				mime: rec.getString(1),
				data: rec.getString(2)
			};
			Database.release(conn);
			return result;
		} catch (e:Dynamic) {
			Database.release(conn);
			throw e;
		}
	}

	public function listAssets(pageId:Int):Array<PageAssetDTO> {
		var conn = Database.acquire();
		try {
			var params = new Map<String, Dynamic>();
			params.set("pageId", pageId);
			var sql = "SELECT id, page_id, filename, mime, created_at FROM page_assets WHERE page_id = @pageId ORDER BY created_at DESC";
			var rs = conn.request(Database.buildSql(sql, params));
			var assets = [];
			while (rs.hasNext()) {
				var rec = rs.next();
				assets.push({
					id: rec.getInt(0),
					pageId: rec.getInt(1),
					filename: rec.getString(2),
					mime: rec.getString(3),
					createdAt: rec.getString(4)
				});
			}
			Database.release(conn);
			return assets;
		} catch (e:Dynamic) {
			Database.release(conn);
			throw e;
		}
	}
}
