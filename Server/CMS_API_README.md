# CMS Server API Documentation

This document describes the CMS (Content Management System) server implementation based on the Haxe Live Editor prototype from `goal.txt`.

## Overview

The CMS server provides a versioned page management system with support for:
- **Page Management**: Create, read, update pages with slug-based routing
- **Version Control**: Track all page changes, restore previous versions
- **Component System**: Extensible component types with schema validation
- **Asset Management**: Upload and manage page assets (images, files)
- **AI Integration**: Generate AI prompts for manual LLM workflows
- **JSON Validation**: Validate AI-generated component structures

## Database Schema

The system uses SQLite with the following tables:

### Page
- `id`: Primary key
- `slug`: Unique URL-friendly identifier
- `title`: Page title
- `created_at`: Creation timestamp
- `published_version_id`: ID of the published version
- `latest_version_id`: ID of the latest draft version

### PageVersion
- `id`: Primary key
- `page_id`: Foreign key to Page
- `version_num`: Sequential version number per page
- `title`: Version title
- `layout`: Layout type (e.g., "default", "wide")
- `created_at`: Creation timestamp
- `created_by`: User ID who created the version

### PageComponent
- `id`: Primary key
- `page_version_id`: Foreign key to PageVersion
- `sort_order`: Display order of component
- `type`: Component type (text, image, button, etc.)
- `data_json`: JSON blob containing component props

### page_assets
- `id`: Primary key
- `page_id`: Foreign key to Page
- `filename`: Original filename
- `mime`: MIME type
- `data`: Binary data (BLOB)
- `created_at`: Upload timestamp

## API Endpoints

All CMS endpoints are prefixed with `/api/cms/` and require authentication except where noted as **public**.

### Page Management

#### Create Page
- **POST** `/api/cms/createPage`
- **Auth Required**: Yes
- **Body**:
  ```json
  {
    "slug": "my-page",
    "title": "My Page Title",
    "layout": "default"
  }
  ```
- **Response**:
  ```json
  {
    "success": true,
    "pageId": 1
  }
  ```

#### Update Page
- **POST** `/api/cms/updatePage`
- **Auth Required**: Yes
- **Body**:
  ```json
  {
    "pageId": 1,
    "title": "Updated Title",
    "layout": "default",
    "components": [
      {
        "id": 0,
        "type": "text",
        "sort": 0,
        "data": {
          "text": "Hello World",
          "style": "body"
        }
      }
    ]
  }
  ```
- **Response**:
  ```json
  {
    "success": true,
    "versionId": 5,
    "versionNum": 2
  }
  ```

#### Get Page
- **POST** `/api/cms/getPage`
- **Auth Required**: Yes
- **Body**:
  ```json
  {
    "pageId": 1
  }
  ```
- **Response**:
  ```json
  {
    "success": true,
    "page": {
      "id": 5,
      "pageId": 1,
      "versionNum": 2,
      "title": "My Page",
      "layout": "default",
      "createdAt": "2025-11-18 10:00:00",
      "createdBy": "user123",
      "components": [...]
    }
  }
  ```

#### Get Page by Slug (Public)
- **GET** `/api/cms/pages/slug/:slug?published=true`
- **Auth Required**: No
- **Parameters**:
  - `slug`: URL slug
  - `published`: (optional) `true` for published version, `false` for latest draft
- **Response**: Same as Get Page

#### List Pages
- **POST** `/api/cms/listPages`
- **Auth Required**: Yes
- **Body**: `{}`
- **Response**:
  ```json
  {
    "success": true,
    "pages": [
      {
        "id": 1,
        "slug": "my-page",
        "title": "My Page",
        "createdAt": "2025-11-18 10:00:00"
      }
    ]
  }
  ```

### Version Management

#### List Versions
- **POST** `/api/cms/listVersions`
- **Auth Required**: Yes
- **Body**:
  ```json
  {
    "pageId": 1
  }
  ```
- **Response**:
  ```json
  {
    "success": true,
    "versions": [
      {
        "id": 5,
        "versionNum": 2,
        "createdAt": "2025-11-18 10:30:00",
        "createdBy": "user123"
      },
      {
        "id": 3,
        "versionNum": 1,
        "createdAt": "2025-11-18 10:00:00",
        "createdBy": "user123"
      }
    ]
  }
  ```

#### Publish Version
- **POST** `/api/cms/publishVersion`
- **Auth Required**: Yes
- **Body**:
  ```json
  {
    "pageId": 1,
    "versionId": 5
  }
  ```
- **Response**:
  ```json
  {
    "success": true
  }
  ```

#### Restore Version
- **POST** `/api/cms/restoreVersion`
- **Auth Required**: Yes
- **Body**:
  ```json
  {
    "versionId": 3
  }
  ```
- **Response**:
  ```json
  {
    "success": true,
    "versionId": 6,
    "versionNum": 3
  }
  ```
- **Note**: Creates a new version that duplicates the specified version

### Asset Management

#### Upload Asset
- **POST** `/api/cms/uploadAsset`
- **Auth Required**: Yes
- **Body**:
  ```json
  {
    "pageId": 1,
    "filename": "hero.jpg",
    "mime": "image/jpeg",
    "data": "base64encodeddata..."
  }
  ```
- **Response**:
  ```json
  {
    "success": true,
    "assetId": 42
  }
  ```

#### Get Asset
- **POST** `/api/cms/getAsset`
- **Auth Required**: Yes
- **Body**:
  ```json
  {
    "assetId": 42
  }
  ```
- **Response**:
  ```json
  {
    "success": true,
    "asset": {
      "filename": "hero.jpg",
      "mime": "image/jpeg",
      "data": "binarydata..."
    }
  }
  ```

#### List Assets
- **POST** `/api/cms/listAssets`
- **Auth Required**: Yes
- **Body**:
  ```json
  {
    "pageId": 1
  }
  ```
- **Response**:
  ```json
  {
    "success": true,
    "assets": [
      {
        "id": 42,
        "pageId": 1,
        "filename": "hero.jpg",
        "mime": "image/jpeg",
        "createdAt": "2025-11-18 10:00:00"
      }
    ]
  }
  ```

### AI & Validation

#### Validate Component JSON
- **POST** `/api/cms/validate`
- **Auth Required**: Yes
- **Body**:
  ```json
  {
    "json": "{\"components\": [{\"id\":\"comp1\",\"type\":\"text\",\"props\":{\"text\":\"Hello\"}}]}"
  }
  ```
- **Response**:
  ```json
  {
    "ok": true,
    "errors": []
  }
  ```
  or
  ```json
  {
    "ok": false,
    "errors": [
      {
        "message": "Component at index 0 missing required prop: text",
        "component": {...}
      }
    ]
  }
  ```

#### Generate AI Prompt
- **POST** `/api/cms/ai-prompt`
- **Auth Required**: Yes
- **Body**:
  ```json
  {
    "prompt": "Create a landing page with a hero image and call-to-action button"
  }
  ```
- **Response**:
  ```json
  {
    "success": true,
    "prompt": "You are a page builder AI. Generate JSON for a page layout...",
    "componentTypes": ["text", "image", "button", "buttonRow", "container", "heading", "ai_generator"]
  }
  ```
- **Usage**: Copy the `prompt` field and paste into your preferred LLM, then validate and apply the response

#### Get Component Types (Public)
- **GET** `/api/cms/component-types`
- **Auth Required**: No
- **Response**:
  ```json
  {
    "success": true,
    "types": ["text", "image", "button", "buttonRow", "container", "heading", "ai_generator"]
  }
  ```

## Component Schema

The system includes predefined component types with validation:

### text
- **Required Props**: `text` (String)
- **Optional Props**: `style` (String)

### image
- **Required Props**: `src` (String)
- **Optional Props**: `fit` (String), `width` (Int), `height` (Int), `alt` (String)

### button
- **Required Props**: `label` (String)
- **Optional Props**: `action` (String), `style` (String)

### buttonRow
- **Required Props**: `buttons` (Array)
- **Optional Props**: None

### container
- **Required Props**: None
- **Optional Props**: `layout` (String), `style` (String)

### heading
- **Required Props**: `text` (String)
- **Optional Props**: `level` (Int), `style` (String)

### ai_generator
- **Required Props**: None
- **Optional Props**: `prompt` (String), `assets` (Array), `status` (String), `lastOutput` (Dynamic)

## Architecture

### Services

- **PageLoader**: Reads pages, versions, and assets from database
- **PageSerializer**: Writes pages, versions, and assets to database
- **VersionRestorer**: Duplicates previous versions as new versions
- **JsonValidator**: Validates component JSON against schema
- **ComponentSchema**: Registry of component type definitions
- **CmsService**: Orchestrates all CMS operations, exposed via API

### Workflow: Manual LLM Mode

1. User enters natural language prompt
2. Call `/api/cms/ai-prompt` to generate LLM-ready prompt
3. Copy prompt and paste into any LLM (ChatGPT, Claude, local model)
4. LLM returns component JSON
5. Call `/api/cms/validate` to validate the JSON
6. If valid, call `/api/cms/updatePage` to save components
7. New version is automatically created and saved

### Authentication

Most CMS endpoints require authentication via:
- **Cookie**: `session_token` (HttpOnly)
- **Header**: `Authorization: Bearer <token>`

Public endpoints:
- `/api/cms/pages/slug/:slug` - View published pages
- `/api/cms/component-types` - Get available component types

## Database Migration

The migration `2025111801-cms-tables.sql` creates all required tables. Run migrations on server startup via `Database.runMigrations()`.

## Error Handling

All endpoints return consistent error format:
```json
{
  "success": false,
  "error": "Error message description"
}
```

Validation errors use:
```json
{
  "ok": false,
  "errors": [
    {
      "message": "Detailed error message",
      "details": "Additional context",
      "component": {...}
    }
  ]
}
```

## Future Enhancements

From `goal.txt`:
- Automatic schema generation from Haxe typedefs using macros
- Drag-and-drop component ordering in editor
- Real-time preview rendering
- Component inheritance and nesting
- Undo/redo functionality
- Multi-user collaboration with conflict resolution
- Advanced component prop editors (color pickers, image selectors)
- Template system for reusable page layouts
- Export/import page definitions
- Direct AI integration (optional, in addition to manual mode)
