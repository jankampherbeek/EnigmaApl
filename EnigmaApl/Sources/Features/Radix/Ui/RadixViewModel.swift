//
//  RadixViewModel.swift
//  EnigmaApl
//
//  Created by Jan Kampherbeek on 14/02/2026.
//
import Foundation
import SwiftUI

/// MVVM ViewModel for Radix feature state.
final class RadixViewModel {
    private(set) var selectedActionID: String?
    private var searchViewModel: RadixSearchViewModel?

    let actions: [FeatureAction] = [
        FeatureAction(id: "new", title: "New"),
        FeatureAction(id: "search", title: "Search")
    ]

    func openAction(_ id: String, onClose: @escaping () -> Void) -> SplitPaneContent {
        selectedActionID = id

        if id == "search" {
            let vm = RadixSearchViewModel()
            searchViewModel = vm
            return .custom(
                left: AnyView(RadixSearchFormView(viewModel: vm, onClose: onClose)),
                right: AnyView(RadixSearchDetailView(viewModel: vm, onClose: onClose))
            )
        }

        let title = actions.first(where: { $0.id == id })?.title ?? "Unknown"
        return .dummy(title)
    }

    func close() {
        selectedActionID = nil
        searchViewModel = nil
    }
}

