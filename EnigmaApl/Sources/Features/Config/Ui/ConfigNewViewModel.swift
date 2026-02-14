//
//  ConfigNewViewModel.swift
//  EnigmaApl
//
//  Created by Jan Kampherbeek on 14/02/2026.
//

import Foundation
import Combine

/// Shared ViewModel for the complex "Configuratie > Nieuw" split screen.
/// Both panes bind to the same instance so the right pane previews left-pane input live.
@MainActor
final class ConfigNewViewModel: ObservableObject {
    enum ConfigType: String, CaseIterable, Identifiable {
        case basic = "Basic"
        case advanced = "Advanced"
        case experimental = "Experimental"

        var id: String { rawValue }
    }

    @Published private(set) var name: String = ""
    @Published private(set) var type: ConfigType = .basic
    @Published private(set) var isActive: Bool = true
    @Published private(set) var remarks: String = ""

    var combination: String {
        let state = isActive ? "Active" : "Inactive"
        return "Name: \(name.isEmpty ? "(empty)" : name)\nType: \(type.rawValue)\nState: \(state)"
    }

    /// Summary string for the detail pane "Conclusion" box (same as combination).
    var conclusion: String { combination }

    /// Update methods are used by SwiftUI bindings.
    /// This keeps mutation flow explicit and avoids nested publish timing issues.
    func updateName(_ value: String) {
        DispatchQueue.main.async { [weak self] in
            self?.name = value
        }
    }

    func updateType(_ value: ConfigType) {
        DispatchQueue.main.async { [weak self] in
            self?.type = value
        }
    }

    func updateIsActive(_ value: Bool) {
        DispatchQueue.main.async { [weak self] in
            self?.isActive = value
        }
    }

    func updateRemarks(_ value: String) {
        DispatchQueue.main.async { [weak self] in
            self?.remarks = value
        }
    }
}
