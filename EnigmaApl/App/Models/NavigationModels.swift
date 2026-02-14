//
//  NavigationModels.swift
//  EnigmaApl
//
//  Created by Jan Kampherbeek on 14/02/2026.
//

import SwiftUI

/// Metadata for a top-level feature shown in the master sidebar.
struct FeatureDescriptor: Identifiable, Hashable {
    let id: String
    let title: String
}

/// Represents one selectable action in a feature-specific submenu.
struct FeatureAction: Identifiable, Hashable {
    let id: String
    let title: String
}

/// Render model for the split pane.
/// A feature can either return simple dummy titles or fully custom views.
struct SplitPaneContent {
    let leftTitle: String
    let rightTitle: String
    let customLeft: AnyView?
    let customRight: AnyView?

    static let welcome = SplitPaneContent(leftTitle: "Welkom", rightTitle: "Maak een keuze", customLeft: nil, customRight: nil)

    static func dummy(_ title: String) -> SplitPaneContent {
        SplitPaneContent(leftTitle: title, rightTitle: "\(title) Details", customLeft: nil, customRight: nil)
    }

    static func custom(left: AnyView, right: AnyView) -> SplitPaneContent {
        SplitPaneContent(leftTitle: "", rightTitle: "", customLeft: left, customRight: right)
    }
}

/// Runtime object returned when a feature is started by the AppCoordinator.
/// The app shell only uses this generic contract and stays independent from feature internals.
struct FeatureSession {
    let actions: [FeatureAction]
    let openAction: (String, @escaping () -> Void) -> SplitPaneContent
    let close: () -> Void
}
