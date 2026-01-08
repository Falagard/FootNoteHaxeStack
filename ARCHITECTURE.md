# HaxeStackStarter Architecture

## Overview

The HaxeStackStarter project follows a **Core/App** architectural pattern to ensure separation of concerns between reusable framework-level code and project-specific application logic. This structure is applied across the `Client`, `Server`, and `Shared` layers.

## Structure

### Server (`Server/Source`)
- **`core/`**: Framework infrastructure.
    - `ServerBootstrap.hx`: Handles lifecycle, database init, configuration, and DI setup.
    - `middleware/`: Reusable middleware (Logging, Auth, etc.).
    - `ServerConfig.hx`: Configuration dataclass.
- **`app/`**: Application-specific logic.
    - `ServerApp.hx`: Extends `ServerBootstrap`, registers app services, and defines custom routes.
    - `services/`: Business logic implementations (`AuthService`, `CmsService`).
    - `models/`: App-specific data models (via shared or local).

### Client (`Client/Source`)
- **`core/`**: Framework infrastructure.
    - `ClientBootstrap.hx`: Handles toolkit initialization and DI setup.
    - `util/`, `state/`: Generic utilities (`Observable`, `AsyncExec`).
- **`app/`**: Application-specific logic.
    - `ClientApp.hx`: Extends `ClientBootstrap`, creates the main view.
    - `views/`: UI components (`MainView`, `auth/`).
    - `services/`: Service proxies (`ServiceRegistry`).
    - `state/`: App state management (`AppState`, `PageNavigator`).

### Shared (`Shared`)
- **`core/`**: Shared utilities and base classes.
- **`app/`**: Application-specific shared types.
    - `models/`: DTOs shared between client and server.
    - `services/`: Interfaces defining service contracts.

## Extension Points

1.  **Server**: Override `ServerBootstrap.configureServices` in `ServerApp` to register new services. Override `configureRoutes` to add endpoints.
2.  **Client**: Override `ClientBootstrap.configureServices` in `ClientApp` to register UI services.
3.  **Services**: Define interfaces in `Shared/app/services`, implement in `Server/Source/app/services`.

## Upstream Workflow

This architecture is designed to allow you to use `HaxeStackStarter` as an upstream remote for your own projects. This allows you to pull in framework updates (bug fixes, performance improvements) while maintaining your own application logic.

### Setup Guide for New Projects

1.  **Clone the Starter**:
    ```bash
    git clone https://github.com/Falagard/HaxeStackStarter.git MyNewProject
    cd MyNewProject
    ```
2.  **Create Remote Repository**:
    Create a new, empty repository on your Git host (GitHub, GitLab, etc.). Do not initialize it with a README or license.

3.  **Configure Remotes**:
    Rename the origin to `upstream` (so you can pull updates later) and add your own repository as `origin`.
    ```bash
    git remote rename origin upstream
    git remote add origin https://github.com/your-username/MyNewProject.git
    git push -u origin main
    ```

### Setting up an Existing Project (Collaborators & New Machines)

If the project repository already exists and you are cloning it (e.g., as a team member or on a new computer):

1.  **Clone Your Project**:
    ```bash
    git clone https://github.com/your-username/MyNewProject.git
    cd MyNewProject
    ```
2.  **Configure Upstream (Maintainers Only)**:
    If you are the project maintainer and want to pull future framework updates, you must manually add the upstream remote again:
    ```bash
    git remote add upstream https://github.com/Falagard/HaxeStackStarter.git
    ```
    *Note: Standard collaborators do not need to do this step.*

### Development Strategy

*   **Modify `app/` directories**: safely.
    All code under `**/app/` (e.g., `Server/Source/app`, `Client/Source/app`) is intended for *your* project logic. You can rename classes, delete example code, and build your application here.

*   **Treat `core/` as Read-Only**:
    Avoid modifying code under `**/core/`. This code represents the "framework". If you modify it, you may encounter merge conflicts when pulling updates from `upstream`.

### Receiving Updates

To get the latest framework features or fixes from the starter kit:

```bash
git fetch upstream
git merge upstream/main
```

Because your work is isolated in `app/` and framework code is in `core/`, these merges should generally be conflict-free.

## Best Practices

- **Dependency Rule**: Core code must NEVER depend on App code.
- **DI**: Use Dependency Injection (`sidewinder.DI`) to access services.
- **State**: Use `core.state.Observable` for reactive state in the client.
