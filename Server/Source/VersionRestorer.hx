package;

import CmsModels;
import PageLoader;
import PageSerializer;

class VersionRestorer {
	private var loader:PageLoader;
	private var serializer:PageSerializer;

	public function new() {
		this.loader = new PageLoader();
		this.serializer = new PageSerializer();
	}

	/**
	 * Restores a given version as the latest version of a page.
	 * This does NOT overwrite the old version—Instead, it creates
	 * a NEW version cloned from the previous one.
	 */
	public function restoreVersion(versionId:Int, ?userId:String):Int {
		// Load the old version
		var v = loader.loadVersion(versionId);

		// Build DTO for new version
		var p:PageDTO = {
			pageId: v.pageId,
			title: v.title,
			layout: v.layout,
			slug: v.slug,
			components: [],
			visibilityConfig: v.visibilityConfig != null ? v.visibilityConfig : { visibilityMode: "Public", groupIds: [] }
		};
		for (c in v.components) {
			p.components.push({
				id: 0,
				type: c.type,
				sort: c.sort,
				data: c.data,
				visibilityConfig: c.visibilityConfig != null ? c.visibilityConfig : { visibilityMode: "Public", groupIds: [] }
			});
		}

		// Save as new version
		var newVersionId = serializer.savePageVersion(p, userId);
		return newVersionId;
	}
}
