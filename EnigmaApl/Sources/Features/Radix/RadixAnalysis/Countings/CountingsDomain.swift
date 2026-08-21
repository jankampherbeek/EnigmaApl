// CountingsDomain.swift
// EnigmaApl is open source. For more information see se_license.html and License, both at the root of the application.
// Created by Jan Kampherbeek 2026

import Foundation

/// The 3 crosses and 4 elements shown in the Countings screen.
enum CountingsGroup: CaseIterable, Hashable {
    case cardinal, fixed, mutable, fire, earth, air, water

    static func crossFor(sign: Int) -> CountingsGroup? {
        switch sign {
        case 1, 4, 7, 10: return .cardinal
        case 2, 5, 8, 11: return .fixed
        case 3, 6, 9, 12: return .mutable
        default: return nil
        }
    }

    static func elementFor(sign: Int) -> CountingsGroup? {
        switch sign {
        case 1, 5, 9: return .fire
        case 2, 6, 10: return .earth
        case 3, 7, 11: return .air
        case 4, 8, 12: return .water
        default: return nil
        }
    }
}

/// One row of the Elements or Crosses count table: how many active factors fall in a sign
/// belonging to this group.
struct CountingsLine: Identifiable {
    var id: String { "\(group)" }
    let group: CountingsGroup
    let count: Int
}
