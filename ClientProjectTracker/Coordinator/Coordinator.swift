//
//  Coordinator.swift
//  ClientProjectTracker
//
//  Created by Benjamin Bartolabac on 6/24/26.
//

import SwiftUI

/// Destinations that are pushed onto the navigation stack.
enum AppRoute: Hashable {
    case projectDetail(ClientProject)
}

/// Destinations that are presented modally, either as a sheet or a
/// full screen cover. The coordinator decides the presentation style.
enum AppModal: Identifiable {
    case createProject

    var id: String { String(describing: self) }
}

@MainActor
@Observable
final class Coordinator {

    /// Backing path for the root `NavigationStack`.
    var path = NavigationPath()

    /// Currently presented sheet, if any.
    var sheet: AppModal?

    /// Currently presented full screen cover, if any.
    var fullScreenCover: AppModal?

    // MARK: - Navigation Stack

    /// Pushes a route onto the navigation stack.
    func push(_ route: AppRoute) {
        path.append(route)
    }

    /// Pops the top route off the navigation stack.
    func pop() {
        guard !path.isEmpty else { return }
        path.removeLast()
    }

    /// Clears the navigation stack back to the root.
    func popToRoot() {
        path = NavigationPath()
    }

    // MARK: - Modal Presentation

    /// Presents a destination as a sheet.
    func presentSheet(_ modal: AppModal) {
        sheet = modal
    }

    /// Presents a destination as a full screen cover.
    func presentFullScreenCover(_ modal: AppModal) {
        fullScreenCover = modal
    }

    /// Dismisses the current sheet.
    func dismissSheet() {
        sheet = nil
    }

    /// Dismisses the current full screen cover.
    func dismissFullScreenCover() {
        fullScreenCover = nil
    }
}
