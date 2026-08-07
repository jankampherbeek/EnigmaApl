// LotsOrchestrator.swift
// EnigmaApl is open source. For more information see se_license.html and License, both at the root of the application.
// Created by Jan Kampherbeek 2026

import Foundation

public enum LotType: CaseIterable {
    case fortune, spirit, eros, victory, necessity, courage, nemesis
}

public struct LotResult: Identifiable {
    public let id = UUID()
    public let type: LotType
    public let longitude: Double
}

/// Calculates the seven classic Hellenistic lots.
/// A night chart is defined as a chart where the Sun is below the horizon.
/// When 'useSect' is deselected, or the chart is a day chart, the day formulas are used.
public struct LotsOrchestrator {

    public static func isNightChart(_ chart: FullChart) -> Bool {
        (chart.Coordinates[.sun]?.horizontal.first?.altitude ?? 0.0) < 0.0
    }

    public static func calculate(chart: FullChart, useSect: Bool) -> [LotResult] {
        let useNightFormula = isNightChart(chart) && useSect

        let ascendant = chart.HousePositions.ascendant.longitude
        let sun     = longitude(.sun, in: chart)
        let moon    = longitude(.moon, in: chart)
        let venus   = longitude(.venus, in: chart)
        let jupiter = longitude(.jupiter, in: chart)
        let mercury = longitude(.mercury, in: chart)
        let mars    = longitude(.mars, in: chart)
        let saturn  = longitude(.saturn, in: chart)

        let fortune   = normalize(ascendant + (useNightFormula ? sun - moon : moon - sun))
        let spirit    = normalize(ascendant + (useNightFormula ? moon - sun : sun - moon))
        let eros      = normalize(ascendant + (useNightFormula ? spirit - venus : venus - spirit))
        let victory   = normalize(ascendant + (useNightFormula ? spirit - jupiter : jupiter - spirit))
        let necessity = normalize(ascendant + (useNightFormula ? mercury - fortune : fortune - mercury))
        let courage   = normalize(ascendant + (useNightFormula ? mars - fortune : fortune - mars))
        let nemesis   = normalize(ascendant + (useNightFormula ? saturn - fortune : fortune - saturn))

        return [
            LotResult(type: .fortune,   longitude: fortune),
            LotResult(type: .spirit,    longitude: spirit),
            LotResult(type: .eros,      longitude: eros),
            LotResult(type: .victory,   longitude: victory),
            LotResult(type: .necessity, longitude: necessity),
            LotResult(type: .courage,   longitude: courage),
            LotResult(type: .nemesis,   longitude: nemesis),
        ]
    }

    private static func longitude(_ factor: Factors, in chart: FullChart) -> Double {
        chart.Coordinates[factor]?.ecliptical.first?.mainPos ?? 0.0
    }

    private static func normalize(_ value: Double) -> Double {
        RangeUtil.valueToRange(value, lowerLimit: 0.0, upperLimit: 360.0)
    }
}
