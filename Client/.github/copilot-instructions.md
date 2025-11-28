# Copilot Instructions for HaxeStackStarter Client

## Project Overview
- **Client** is a Haxe/OpenFL/HaxeUI application for managing CMS content, assets, and deployment workflows. It uses a modular architecture with clear separation between UI, service, and state management layers.
- **Shared** folder contains DTOs, interfaces, and models used by both client and server.
- **Major dependencies:** HaxeUI (UI), OpenFL (rendering), SideWinder (custom logic), haxe-injection (DI), actuate (animation).

## Architecture & Patterns
- **UI Components:** Located in `Source/` (e.g., `MainView.hx`, `cms/`, `components/`). Use HaxeUI for dialogs, forms, and layout. Dialogs should use `haxe.ui.containers.dialogs.Dialog` (see README for usage).
- **Service Layer:** Async service calls are managed via `services/AsyncServiceRegistry.hx` and `ServiceRegistry.hx`. All backend communication is funneled through these registries, using async methods (e.g., `cms.createPageAsync`).
- **Notifications:** Use `components/Notifications.hx` for user feedback. Always show success/error messages for async operations.
- **State Management:** App state is managed in `state/` (e.g., `AppState.hx`, `Observable.hx`). Use observables for reactive UI updates.
- **Utilities:** Place helpers in `util/` (e.g., `SeoHtmlGenerator.hx`, `AsyncExec.hx`).

## Developer Workflows
- **Build (HL target):**
  - Use VS Code task: `Build and run client` (runs `lime build hl -debug --connect 6001`).
- **Build (HTML5 target):**
  - Run: `lime build html5 -debug --connect 6001`
  - Post-build, `copy-html5-build.bat` is executed automatically for asset copying.
- **Run:**
  - Use `run-client.bat` for launching the client (HL target).
- **Dependencies:**
  - Managed via `hmm.json` and `project.xml`. Use `haxelib` and git dependencies as specified.

## Project-Specific Conventions
- **Dialogs:** Always use HaxeUI `Dialog` for modals. Style overlays via CSS classes (e.g., `releaseFormOverlay`).
- **Async Service Calls:** Always provide both success and error callbacks. Show user notifications for all outcomes.
- **Cross-Component Communication:** Use service registries and observables; avoid direct component coupling.
- **Shared Models:** Import from `../Shared` for DTOs and interfaces.
- **Styling:** Inject custom styles in `Main.hx` using HaxeUI's `StyleSheet`.

## Key Files & Directories
- `Source/Main.hx`: App entry, style injection, main view setup.
- `Source/cms/CmsManager.hx`: CMS operations, async service usage, notification patterns.
- `Source/services/AsyncServiceRegistry.hx`: Service registry pattern for backend calls.
- `Source/components/Notifications.hx`: User feedback utilities.
- `README.md`: Up-to-date UI and dialog usage patterns.
- `project.xml`, `hmm.json`: Build config and dependencies.

## Examples
- **Dialog Creation:** See `README.md` for HaxeUI dialog usage and overlay styling.
- **Async Service Call:**
  ```haxe
  asyncServices.cms.createPageAsync(request, function(response) {
    if (response.success) Notifications.show('Success', 'success');
    else Notifications.show('Failed: ' + response.error, 'error');
  }, function(err) {
    Notifications.show('Error: ' + Std.string(err), 'error');
  });
  ```

---

**If you are unsure about a pattern or workflow, check the referenced files or ask for clarification.**
