//
//  YearCountKeys.swift
//  EnigmaApl
//
//  Created by Jan Kampherbeek on 11/03/2026.
//

/// Localization keys for YearCount enum values.
struct YearCountKeys {
    private init() {}

    static let keys: [YearCount: String] = [
        .ce:          "enum.yearcount.ce",
        .bc:          "enum.yearcount.bce",
        .astronomical:"enum.yearcount.astronomical",
    ]

    static func key(for count: YearCount) -> String {
        keys[count] ?? ""
    }
}
