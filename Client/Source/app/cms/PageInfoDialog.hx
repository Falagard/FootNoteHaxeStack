package app.cms;

import haxe.ui.containers.dialogs.Dialog;
import haxe.ui.components.TextField;
import haxe.ui.components.Button;
import haxe.ui.components.Label;
import app.models.CmsModels;

@:build(haxe.ui.ComponentBuilder.build("Assets/page-info-dialog.xml"))
class PageInfoDialog extends Dialog {
	public var onSave:(title:String, slug:String) -> Void;
	public var onCancel:Void->Void;

	var titleField:TextField;
	var slugField:TextField;
	var saveBtn:Button;
	var cancelBtn:Button;
	var errorLabel:Label;

	public function new(currentTitle:String, currentSlug:String) {
		super();
		this.title = "Edit Page Info";
		this.destroyOnClose = true;
		titleField.text = currentTitle;
		slugField.text = currentSlug;
	}

	public override function onReady():Void {
		super.onReady();
		if (saveBtn != null) {
			saveBtn.onClick = function(_) {
				var title = titleField.text;
				var slug = slugField.text;
				if (title == "" || slug == "") {
					if (errorLabel != null)
						errorLabel.text = "Title and slug are required.";
					return;
				}
				if (onSave != null)
					onSave(title, slug);
				this.hideDialog(DialogButton.OK);
			};
		}
		if (cancelBtn != null) {
			cancelBtn.onClick = function(_) {
				if (onCancel != null)
					onCancel();
				this.hideDialog(DialogButton.CANCEL);
			};
		}
	}

	// Removed custom showDialog; use base Dialog.show()
}
