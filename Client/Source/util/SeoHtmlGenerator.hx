package util;

import CmsModels;
import StringTools;

class SeoHtmlGenerator {
    public static function generate(components:Array<PageComponentDTO>):String {
        var html = new StringBuf();
        for (component in components) {
            switch (component.type) {
                case "text":
                    html.add('<div>' + escapeHtml(component.data.text) + '</div>');
                case "image":
                    html.add('<img src="' + escapeHtml(component.data.url) + '" alt="' + escapeHtml(component.data.alt) + '" />');
                case "button":
                    html.add('<a href="#" class="button">' + escapeHtml(component.data.label) + '</a>');
                default:
                    // Ignore non-SEO components
            }
        }
        return html.toString();
    }

    static function escapeHtml(text:String):String {
        if (text == null) return "";
        text = StringTools.replace(text, "&", "&amp;");
        text = StringTools.replace(text, "<", "&lt;");
        text = StringTools.replace(text, ">", "&gt;");
        text = StringTools.replace(text, '"', "&quot;");
        text = StringTools.replace(text, "'", "&#39;");
        return text;
    }
}
