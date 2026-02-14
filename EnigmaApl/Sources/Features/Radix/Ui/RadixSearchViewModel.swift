//
//  RadixSearchViewModel.swift
//  EnigmaApl
//
//  Created by Jan Kampherbeek on 14/02/2026.
//
import Foundation
import Combine

/// Shared ViewModel for "Radix > Search".
/// Left pane edits filters, right pane shows filtered results + selected detail.
@MainActor
final class RadixSearchViewModel: ObservableObject {
    struct ResultItem: Identifiable, Hashable {
        let id = UUID()
        let name: String
        let category: String
        let score: Int
    }

    @Published var searchterm: String = ""
    @Published var onlyHighScore: Bool = false
    @Published var selectedItemID: UUID?

    private let allItems: [ResultItem] = [
        ResultItem(name: "Radix Alpha", category: "Root", score: 82),
        ResultItem(name: "Radix Beta", category: "Root", score: 61),
        ResultItem(name: "Radix Delta", category: "Derived", score: 74),
        ResultItem(name: "Radix Epsilon", category: "Derived", score: 49),
        ResultItem(name: "Radix Gamma", category: "Root", score: 91)
    ]

    var results: [ResultItem] {
        allItems.filter { item in
            let matchTerm = searchterm.isEmpty || item.name.localizedCaseInsensitiveContains(searchterm)
            let matchScore = !onlyHighScore || item.score >= 75
            return matchTerm && matchScore
        }
        .sorted(by: { $0.name < $1.name })
    }

    var selectedItem: ResultItem? {
        guard let selectedItemID else { return nil }
        return results.first(where: { $0.id == selectedItemID })
    }

    func selectFirstIfNeeded() {
        guard selectedItem == nil else { return }
        selectedItemID = results.first?.id
    }

    func reset() {
        searchterm = ""
        onlyHighScore = false
        selectedItemID = nil
    }
}

