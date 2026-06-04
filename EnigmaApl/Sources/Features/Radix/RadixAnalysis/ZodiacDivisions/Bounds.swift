// Bounds.swift
// EnigmaApl is open source. For more information see se_license.html and License, both at the root of the application.
// Created by Jan Kampherbeek 2026

/// Returns the planetary ruler index for a term (bound).
/// Planet indices: Sun 0, Moon 1, Mercury 2, Venus 3, Mars 4, Jupiter 5, Saturn 6.
/// Sun and Moon are not used as bound rulers.
struct Bounds {
    private init() {}

    private struct TermPosition {
        let degrees: Int
        let planet: Int
    }

    /// - Parameters:
    ///   - longitude: Ecliptic longitude, must be >= 0 and < 360.
    ///   - egyptian: `true` for Egyptian bounds, `false` for Ptolemy bounds.
    /// - Returns: Planet index (2–6), or -1 if longitude is out of bounds.
    static func indexBound(_ longitude: Double, egyptian: Bool) -> Int {
        guard longitude >= 0.0, longitude < 360.0 else { return -1 }
        let terms = egyptian ? egyptianTerms : ptolemyTerms
        for term in terms where Double(term.degrees) > longitude {
            return term.planet
        }
        return terms.last!.planet
    }

    // MARK: - Term tables

    private static let egyptianTerms: [TermPosition] = [
        // Aries
        .init(degrees: 6, planet: 5), .init(degrees: 12, planet: 3), .init(degrees: 20, planet: 2),
        .init(degrees: 25, planet: 4), .init(degrees: 30, planet: 6),
        // Taurus
        .init(degrees: 38, planet: 3), .init(degrees: 44, planet: 2), .init(degrees: 52, planet: 5),
        .init(degrees: 57, planet: 6), .init(degrees: 60, planet: 4),
        // Gemini
        .init(degrees: 66, planet: 2), .init(degrees: 72, planet: 5), .init(degrees: 77, planet: 3),
        .init(degrees: 84, planet: 4), .init(degrees: 90, planet: 6),
        // Cancer
        .init(degrees: 97, planet: 4), .init(degrees: 103, planet: 3), .init(degrees: 109, planet: 2),
        .init(degrees: 116, planet: 5), .init(degrees: 120, planet: 6),
        // Leo
        .init(degrees: 126, planet: 5), .init(degrees: 131, planet: 3), .init(degrees: 138, planet: 6),
        .init(degrees: 144, planet: 2), .init(degrees: 150, planet: 4),
        // Virgo
        .init(degrees: 157, planet: 2), .init(degrees: 167, planet: 3), .init(degrees: 171, planet: 5),
        .init(degrees: 178, planet: 4), .init(degrees: 180, planet: 6),
        // Libra
        .init(degrees: 186, planet: 6), .init(degrees: 194, planet: 2), .init(degrees: 201, planet: 5),
        .init(degrees: 208, planet: 3), .init(degrees: 210, planet: 4),
        // Scorpio
        .init(degrees: 217, planet: 4), .init(degrees: 221, planet: 3), .init(degrees: 229, planet: 2),
        .init(degrees: 234, planet: 5), .init(degrees: 240, planet: 6),
        // Sagittarius
        .init(degrees: 252, planet: 5), .init(degrees: 257, planet: 3), .init(degrees: 261, planet: 2),
        .init(degrees: 266, planet: 6), .init(degrees: 270, planet: 4),
        // Capricorn
        .init(degrees: 277, planet: 2), .init(degrees: 284, planet: 5), .init(degrees: 292, planet: 3),
        .init(degrees: 296, planet: 6), .init(degrees: 300, planet: 4),
        // Aquarius
        .init(degrees: 307, planet: 2), .init(degrees: 313, planet: 3), .init(degrees: 320, planet: 5),
        .init(degrees: 325, planet: 4), .init(degrees: 330, planet: 6),
        // Pisces
        .init(degrees: 342, planet: 3), .init(degrees: 346, planet: 5), .init(degrees: 349, planet: 2),
        .init(degrees: 358, planet: 4), .init(degrees: 360, planet: 6),
    ]

    private static let ptolemyTerms: [TermPosition] = [
        // Aries
        .init(degrees: 6, planet: 5), .init(degrees: 14, planet: 3), .init(degrees: 21, planet: 2),
        .init(degrees: 26, planet: 4), .init(degrees: 30, planet: 6),
        // Taurus
        .init(degrees: 38, planet: 3), .init(degrees: 45, planet: 2), .init(degrees: 52, planet: 5),
        .init(degrees: 54, planet: 6), .init(degrees: 60, planet: 4),
        // Gemini
        .init(degrees: 67, planet: 2), .init(degrees: 73, planet: 5), .init(degrees: 80, planet: 3),
        .init(degrees: 86, planet: 4), .init(degrees: 90, planet: 6),
        // Cancer
        .init(degrees: 96, planet: 4), .init(degrees: 103, planet: 5), .init(degrees: 110, planet: 2),
        .init(degrees: 117, planet: 3), .init(degrees: 120, planet: 6),
        // Leo
        .init(degrees: 126, planet: 5), .init(degrees: 133, planet: 2), .init(degrees: 139, planet: 6),
        .init(degrees: 145, planet: 3), .init(degrees: 150, planet: 4),
        // Virgo
        .init(degrees: 157, planet: 2), .init(degrees: 163, planet: 3), .init(degrees: 168, planet: 5),
        .init(degrees: 174, planet: 6), .init(degrees: 180, planet: 4),
        // Libra
        .init(degrees: 186, planet: 6), .init(degrees: 191, planet: 3), .init(degrees: 196, planet: 2),
        .init(degrees: 204, planet: 5), .init(degrees: 210, planet: 4),
        // Scorpio
        .init(degrees: 216, planet: 4), .init(degrees: 223, planet: 3), .init(degrees: 231, planet: 5),
        .init(degrees: 237, planet: 2), .init(degrees: 240, planet: 6),
        // Sagittarius
        .init(degrees: 248, planet: 5), .init(degrees: 254, planet: 3), .init(degrees: 259, planet: 2),
        .init(degrees: 265, planet: 6), .init(degrees: 270, planet: 4),
        // Capricorn
        .init(degrees: 276, planet: 3), .init(degrees: 282, planet: 2), .init(degrees: 289, planet: 5),
        .init(degrees: 295, planet: 6), .init(degrees: 300, planet: 4),
        // Aquarius
        .init(degrees: 306, planet: 6), .init(degrees: 312, planet: 2), .init(degrees: 320, planet: 3),
        .init(degrees: 325, planet: 5), .init(degrees: 330, planet: 4),
        // Pisces
        .init(degrees: 338, planet: 3), .init(degrees: 344, planet: 5), .init(degrees: 350, planet: 2),
        .init(degrees: 355, planet: 4), .init(degrees: 360, planet: 6),
    ]
}
