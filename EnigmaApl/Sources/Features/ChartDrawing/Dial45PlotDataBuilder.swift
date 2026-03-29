// Dial45PlotDataBuilder.swift
// EnigmaApl is open source. For more information see se_license.html and License, both at the root of the application.
// Created by Jan Kampherbeek 2026
//
// Converts a FullChart into WheelPlotData for the Ebertin 45° dial.
// Visual angle = (eclipticLongitude mod 45) × 8 — maps 0-45° across the full circle.

import Foundation

struct Dial45PlotDataBuilder {

    static func build(from chart: FullChart, config: UserConfiguration? = nil) -> WheelPlotData {
        let ascLong = chart.HousePositions.ascendant.longitude
        let mcLong  = chart.HousePositions.midheaven.longitude

        var items: [WheelPlotItem] = []
        for (factor, position) in chart.Coordinates {
            guard factor.calculationType != .Mundane,
                  factor.calculationType != .Unknown,
                  FactorDisplaySelector.shouldDraw(factor),
                  let eclPos = position.ecliptical.first?.mainPos else { continue }

            let visualAngle = dial45Angle(eclPos)
            let glyph       = GlyphSelector.getGlyphForFactor(factor)
            let speed       = position.ecliptical.first?.mainPosSpeed ?? 0.0
            let calcConfig  = config?.calculationConfig ?? CalculationConfig()
            let speedType   = SpeedOrchestrator().determine(speed: speed, for: factor, config: calcConfig)
            let text        = dial45PositionText(longitude: eclPos, speedType: speedType)

            items.append(WheelPlotItem(
                factor: factor,
                glyph: glyph,
                eclipticLongitude: eclPos,
                mundaneAngle: visualAngle,
                plotAngle: visualAngle,
                positionText: text,
                speedType: speedType
            ))
        }

        // Add ASC and MC as regular items so the overlap resolver treats them like planets.
        items.append(WheelPlotItem(
            factor: .ascendant,
            glyph: GlyphSelector.getGlyphForFactor(.ascendant),
            eclipticLongitude: ascLong,
            mundaneAngle: dial45Angle(ascLong),
            plotAngle: dial45Angle(ascLong),
            positionText: dial45PositionText(longitude: ascLong),
            speedType: .direct
        ))
        items.append(WheelPlotItem(
            factor: .mc,
            glyph: GlyphSelector.getGlyphForFactor(.mc),
            eclipticLongitude: mcLong,
            mundaneAngle: dial45Angle(mcLong),
            plotAngle: dial45Angle(mcLong),
            positionText: dial45PositionText(longitude: mcLong),
            speedType: .direct
        ))

        let resolved = GlyphOverlapResolver.resolve(items)

        return WheelPlotData(
            ascendantLongitude: ascLong,
            mcLongitude: mcLong,
            cuspLongitudes: [],
            planetItems: resolved,
            hasTime: true,
            aspectItems: []
        )
    }

    // MARK: - Helpers

    /// Maps an ecliptic longitude to a visual angle on the 45° dial (0-45° → 0-360°).
    static func dial45Angle(_ longitude: Double) -> Double {
        longitude.truncatingRemainder(dividingBy: 45.0) * 8.0
    }

    /// Degrees and minutes within the 45° range, with optional speed suffix, e.g. "23°15' R".
    private static func dial45PositionText(longitude: Double, speedType: SpeedType = .direct) -> String {
        let dialPos  = longitude.truncatingRemainder(dividingBy: 45.0)
        let totalMin = Int(abs(dialPos) * 60)
        let deg      = totalMin / 60
        let min      = totalMin % 60
        let base     = "\(deg)°\(String(format: "%02d", min))'"
        return speedType == .direct ? base : "\(base) \(speedType.abbreviation)"
    }
}
