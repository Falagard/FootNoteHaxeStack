-- CMS tables for page management with versioning

CREATE TABLE IF NOT EXISTS Page (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    slug TEXT NOT NULL UNIQUE,
    title TEXT,
    created_at TEXT DEFAULT CURRENT_TIMESTAMP,
    published_version_id INTEGER,
    latest_version_id INTEGER
);

CREATE TABLE IF NOT EXISTS PageVersion (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    page_id INTEGER NOT NULL,
    version_num INTEGER NOT NULL,
    title TEXT,
    layout TEXT,
    created_at TEXT DEFAULT CURRENT_TIMESTAMP,
    created_by TEXT,
    UNIQUE(page_id, version_num),
    FOREIGN KEY (page_id) REFERENCES Page(id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS PageComponent (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    page_version_id INTEGER NOT NULL,
    sort_order INTEGER NOT NULL,
    type TEXT NOT NULL,
    data_json TEXT,
    created_at TEXT DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (page_version_id) REFERENCES PageVersion(id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS page_assets (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    page_id INTEGER,
    filename TEXT NOT NULL,
    mime TEXT NOT NULL,
    data BLOB NOT NULL,
    created_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (page_id) REFERENCES Page(id) ON DELETE CASCADE
);

CREATE INDEX IF NOT EXISTS idx_page_slug ON Page(slug);
CREATE INDEX IF NOT EXISTS idx_page_version_page_id ON PageVersion(page_id);
CREATE INDEX IF NOT EXISTS idx_page_component_version_id ON PageComponent(page_version_id);
CREATE INDEX IF NOT EXISTS idx_page_assets_page_id ON page_assets(page_id);
