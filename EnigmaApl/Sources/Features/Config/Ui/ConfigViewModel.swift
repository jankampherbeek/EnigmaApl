//
//  ConfigViewModel.swift
//  EnigmaApl
//
//  Created by Jan Kampherbeek on 14/02/2026.
//
import Foundation
import SwiftUI

/// MVVM ViewModel for Configu feature state.
final class ConfigViewModel {
    private(set) var selectedActionID: String?
    private var nieuwViewModel: ConfigNewViewModel?

    let actions: [FeatureAction] = [
        FeatureAction(id: "new", title: "New"),
        FeatureAction(id: "change", title: "Change")
    ]

    func openAction(_ id: String, onClose: @escaping () -> Void) -> SplitPaneContent {
        selectedActionID = id
        
        if id == "nieuw" {
            let vm = ConfigNewViewModel()
            nieuwViewModel = vm

            return .custom(
                left: AnyView(ConfigNewFormView(viewModel: vm, onClose: onClose)),
                right: AnyView(ConfigNewDetailView(viewModel: vm, onClose: onClose))
            )
        }

        let title = actions.first(where: { $0.id == id })?.title ?? "Unknown"
        return .dummy(title)
    }

    func close() {
        selectedActionID = nil
        nieuwViewModel = nil
    }
}

