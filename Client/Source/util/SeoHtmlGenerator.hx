package util;

import CmsModels;
import StringTools;
import TextFieldMarkdown;

class SeoHtmlGenerator {
    public static function generate(components:Array<PageComponentDTO>):String {
        var html = new StringBuf();
        for (component in components) {
            switch (component.type) {
                case "text":
                    var md = component.data.text;
                    var htmlText = TextFieldMarkdown.markdownToHtml(md);
                    html.add('<div>' + htmlText + '</div>');
                case "image":
                    html.add('<img src="' + escapeHtml(component.data.url) + '" alt="' + escapeHtml(component.data.alt) + '" />');
                case "button":
                    var slug = component.data.pageSlug;
                    var link = slug != null && slug != "" ? '/seo/' + escapeHtml(slug) : '#';
                    html.add('<a href="' + link + '" class="button">' + escapeHtml(component.data.label) + '</a>');
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
