//
//  ConfigModel.swift
//  EnigmaApl
//
//  Created by Jan Kampherbeek on 16/02/2026.
//
import Foundation
import SwiftUI

/// MV for Config feature state.
final class ConfigModel {
    private(set) var selectedActionID: String?
    private var newModel: ConfigNewModel?

    let actions: [FeatureAction] = [
        FeatureAction(id: "new", title: "New"),
        FeatureAction(id: "change", title: "Change")
    ]

    func openAction(_ id: String, onClose: @escaping () -> Void) -> SplitPaneContent {
        selectedActionID = id
        
        if id == "nieuw" {
            let vw = ConfigNewModel()
            newModel = vw

            return .custom(
                left: AnyView(ConfigNewFormView(view: vw, onClose: onClose)),
                right: AnyView(ConfigNewDetailView(view: vw, onClose: onClose))
            )
        }

        let title = actions.first(where: { $0.id == id })?.title ?? "Unknown"
        return .dummy(title)
    }

    func close() {
        selectedActionID = nil
        newModel = nil
    }
}

