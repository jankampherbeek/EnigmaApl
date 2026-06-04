// ZodiacDivisionsModel.swift
// EnigmaApl is open source. For more information see se_license.html and License, both at the root of the application.
// Created by Jan Kampherbeek 2026

import Foundation
import Combine

/// Shared state for zodiacal division method selections.
/// Injected as an EnvironmentObject so ZodiacDivisionsInputView and ZodiacDivisionsResultsView stay in sync.
@MainActor
final class ZodiacDivisionsModel: ObservableObject {

    @Published var useDecansPlanet:    Bool = false   // false → signs, true → planets
    @Published var useDodecatsOriginal: Bool = true    // true → original, false → Paulus
    @Published var useBoundsEgyptian:  Bool = true    // true → Egyptian, false → Ptolemy

    var decansMethod:   ZodiacDivisionMethod { useDecansPlanet    ? .decansPlanet    : .decansSign       }
    var dodecatsMethod: ZodiacDivisionMethod { useDodecatsOriginal ? .dodecatsOriginal : .dodecatsPaulus  }
    var boundsMethod:   ZodiacDivisionMethod { useBoundsEgyptian  ? .boundsEgyptian  : .boundsPtolemy    }

    // Planet ruler sequence: Sun=0, Moon=1, Mercury=2, Venus=3, Mars=4, Jupiter=5, Saturn=6
    private static let rulersForIndex: [Factors] = [
        .sun, .moon, .mercury, .venus, .mars, .jupiter, .saturn
    ]

    func signGlyph(for index: Int) -> String {
        guard let sign = Signs(rawValue: index + 1) else { return "?" }
        return GlyphSelector.getGlyphForSign(sign)
    }

    func planetGlyph(for index: Int) -> String {
        guard index >= 0, index < Self.rulersForIndex.count else { return "?" }
        return GlyphSelector.getGlyphForFactor(Self.rulersForIndex[index])
    }

    func decanGlyph(for index: Int) -> String {
        useDecansPlanet ? planetGlyph(for: index) : signGlyph(for: index)
    }

    func dodecatGlyph(for index: Int) -> String { signGlyph(for: index) }
    func boundGlyph(for index: Int) -> String    { planetGlyph(for: index) }
}
