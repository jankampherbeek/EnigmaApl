//
//  RoddenRatingKeys.swift
//  EnigmaApl
//
//  Created by Jan Kampherbeek on 11/03/2026.
//

/// Localization keys for RoddenRating enum values.
struct RoddenRatingKeys {
    private init() {}

    static let keys: [RoddenRating: String] = [
        .none: "enum.roddenrating.none",
        .aa:   "enum.roddenrating.aa",
        .a:    "enum.roddenrating.a",
        .b:    "enum.roddenrating.b",
        .c:    "enum.roddenrating.c",
        .dd:   "enum.roddenrating.dd",
        .x:    "enum.roddenrating.x",
        .xx:   "enum.roddenrating.xx",
    ]

    static func key(for rating: RoddenRating) -> String {
        keys[rating] ?? ""
    }
}
