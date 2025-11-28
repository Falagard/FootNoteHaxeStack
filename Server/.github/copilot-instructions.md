# Copilot Instructions for HaxeStackStarter CMS Server

## Project Overview
- **Monorepo**: `Server/` (backend), `Shared/` (shared models/interfaces)
- **Language**: Haxe (targeting HashLink, Neko, HTML5)
- **Purpose**: Versioned CMS with AI/manual JSON workflows, asset management, and extensible component system

## Architecture
- **API Layer**: All endpoints under `/api/cms/` (see `CMS_API_README.md`)
- **Core Services** (see `Source/`):
  - `CmsService.hx`: Main business logic, implements `ICmsService`
  - `PageLoader.hx`, `PageSerializer.hx`: Read/write page/version/component data
  - `VersionRestorer.hx`: Non-destructive version restore
  - `JsonValidator.hx`, `ComponentSchema.hx`: Schema-driven validation, component registry
- **Database**: SQLite, migrations in `migrations/` (run via `Database.runMigrations()`)
- **Authentication**: Most endpoints require session token (cookie or `Authorization` header)
- **Manual LLM Workflow**: Generate prompt → LLM → validate JSON → update page (see `CMS_API_README.md`)

## Developer Workflows
- **Build & Run**: Use `build-and-run.bat` (HashLink target by default)
- **Dev Server**: Use `dev-server.bat` for hot-reload
- **Testing**: Use `test-cms-api.ps1` for API tests
- **Migrations**: Place new SQL files in `migrations/` and ensure `Database.runMigrations()` is called on startup
- **API Docs**: See `CMS_API_README.md` for endpoint details and JSON examples

## Project Conventions
- **Component Types**: Defined in `ComponentSchema.hx` (add new types here)
- **DTOs**: Shared request/response types in `Shared/`
- **Versioning**: Every edit creates a new version; pages track both latest and published versions
- **Assets**: Page-scoped, stored as BLOBs, uploaded via base64
- **Validation**: All component JSON must pass schema validation before saving
- **Error Format**: All endpoints return `{ success: false, error: "..." }` on failure

## Integration Points
- **Client**: Not implemented here; see API docs for expected flows
- **AI**: Manual prompt generation and validation endpoints provided; direct LLM integration is optional

## Key Files & Directories
- `Source/` — Main backend logic
- `Shared/` — DTOs and interfaces
- `migrations/` — SQL schema
- `CMS_API_README.md` — API reference
- `CMS_IMPLEMENTATION.md` — Implementation summary

## Examples
- See `CMS_API_README.md` and `CMS_IMPLEMENTATION.md` for sample API calls and workflows.

---

**For AI agents:**
- Always validate component JSON before saving
- Use the provided API endpoints and follow versioning conventions
- Reference `ComponentSchema.hx` for allowed component types and props
- When in doubt, check the API docs for request/response formats
