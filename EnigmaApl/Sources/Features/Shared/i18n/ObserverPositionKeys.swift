//
//  ObserverPositionKeys.swift
//  EnigmaApl
//
//  Created by Jan Kampherbeek on 11/03/2026.
//

/// Localization keys for ObserverPositions enum values.
struct ObserverPositionKeys {
    private init() {}

    static let keys: [ObserverPositions: String] = [
        .geoCentric:  "enum.observerpos.geocentric",
        .topoCentric: "enum.observerpos.topocentric",
        .helioCentric:"enum.observerpos.heliocentric",
    ]

    static func key(for position: ObserverPositions) -> String {
        keys[position] ?? ""
    }
}
