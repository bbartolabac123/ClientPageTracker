# ClientProjectTracker

A small SwiftUI app for tracking client projects. You can browse all projects, create new ones, and edit or delete existing ones. The app is **offline-first**: it talks to a REST API when there's a connection and falls back to a local SwiftData store when there isn't.

## Overview

- **Home** — lists all projects with status/priority badges and start/due dates, with an empty state and pull-to-refresh.
- **Create** — a validated form (with inline field errors and success/error handling) to add a project.
- **Detail** — an editable form to update a project, plus delete (with confirmation). Surfaces both success and error states.
- **Offline mode** — reads/writes go to the API when online and to SwiftData when offline; remote results are cached locally so they remain available offline.

## Architecture

The app follows a layered, MVVM + Coordinator structure:

- **Domain** — plain models: `ClientProject` (DTO) and `ClientProjectEntity` (SwiftData `@Model`), plus the `Status`/`Priority` enums.
- **Presentation** — SwiftUI `View`s and `@Observable` view models (`HomeViewModel`, `CreateProjectViewModel`, `ProjectDetailViewModel`). Each view model exposes a single `state` enum that drives loading/empty/error/success UI.
- **Repository** — `ClientProjectRepository` protocol with `ClientProjectImplementation`, which decides between the API and SwiftData based on connectivity. `ClientProjectsUseCase` sits between the view models and the repository. `ClientProjectService` defines the Moya API endpoints.
- **Network** — a thin `NetworkService` abstraction over Moya (`NetworkServiceImplementation` for live calls, `NetworkStubServiceImplementation` for stubbed `sampleData`), a `NetworkMonitor` for reachability, and `ErrorMapper` which normalizes all failures into a single `NetworkError` type.
- **Coordinator** — `Coordinator` owns the navigation path, sheets, and full-screen covers; `CoordinatorView` hosts the root `NavigationStack` and builds destinations. Views drive navigation through the coordinator rather than managing it themselves.

Data flow: `View → ViewModel → UseCase → Repository → (NetworkService | SwiftData)`.

## Packages

Dependencies are managed with Swift Package Manager:

- [Moya](https://github.com/Moya/Moya) `15.0.3` — network abstraction layer (pulls in **Alamofire** `5.12.0`, **ReactiveSwift** `6.7.0`, and **RxSwift** `6.10.2`).
- **SwiftData** and **SwiftUI** — Apple frameworks, no installation required.

Packages resolve automatically on first build; no manual setup needed.

## Requirements

- Xcode 26.5+
- iOS 26.5+ (deployment target)

## How to run

1. Clone the repository.
2. Open `ClientProjectTracker.xcodeproj` in Xcode.
3. Wait for Swift Package Manager to resolve dependencies (Moya and friends).
4. Select the `ClientProjectTracker` scheme and an iOS Simulator (e.g. iPhone 17).
5. Press **Run** (⌘R).

> Note: The API base URL in `BaseTargetType` points to a placeholder host. In the simulator with internet, live API calls will fail and surface the error states; the offline (SwiftData) path and the stubbed `NetworkStubServiceImplementation` exercise the success paths.

## Assumptions

- **No real backend.** There is no live API, so `BaseTargetType` uses a placeholder base URL and endpoints rely on Moya's `sampleData`. The contract (paths, methods, JSON shape) is assumed rather than confirmed against a server.
- **Connectivity decides the data source.** "Online" means `NWPathMonitor` reports a satisfied path; the app then prefers the API and treats SwiftData purely as a cache. A reachable path is assumed to mean the API is reachable.
- **Offline changes are not synced back.** Creates/updates/deletes made while offline are written to SwiftData only. There is no pending-changes queue or conflict resolution to replay them to the server once connectivity returns.
- **`id` is the source of truth for identity.** Caching and updates upsert by the project's `UUID`; the server is assumed to preserve the id sent by the client.
- **Delete returns the resource.** The network layer decodes a `ClientProject` from the delete response; an API returning `204 No Content` would need a no-body request variant.
- **Single user, single device.** No authentication, authorization, or multi-device sync is implemented.
- **Validation is client-side only.** Required fields and the start/due date rule are enforced in the view models; the server is assumed to apply its own validation.
- **Wiring is intentionally mixed for demonstration.** `HomeView` uses the stubbed network service (so the list populates) while create/detail use the live service (so error handling is visible). This is a demo choice, not a production setup.
- **Latest-only toolchain.** The project targets the newest Xcode/iOS (26.5) and uses Swift's MainActor-by-default concurrency; older OS versions are not supported.
