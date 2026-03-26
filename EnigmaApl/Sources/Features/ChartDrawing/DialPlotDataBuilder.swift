// DialPlotDataBuilder.swift
// EnigmaApl is open source. For more information see se_license.html and License, both at the root of the application.
// Created by Jan Kampherbeek 2026
//
// Converts a FullChart into WheelPlotData for Ebertin-style dial wheels.
// Unlike WheelPlotDataBuilder, angles equal the ecliptic longitude directly —
// no rotation by ascendant. Cusp lines and aspects are not used.

import Foundation

struct DialPlotDataBuilder {

    static func build(from chart: FullChart) -> WheelPlotData {
        let ascLong = chart.HousePositions.ascendant.longitude
        let mcLong  = chart.HousePositions.midheaven.longitude

        var items: [WheelPlotItem] = []
        for (factor, position) in chart.Coordinates {
            guard factor.calculationType != .Mundane,
                  factor.calculationType != .Unknown,
                  FactorDisplaySelector.shouldDraw(factor),
                  let eclPos = position.ecliptical.first?.mainPos else { continue }

            let glyph     = GlyphSelector.getGlyphForFactor(factor)
            let speed     = position.ecliptical.first?.mainPosSpeed ?? 0.0
            let speedType = SpeedOrchestrator().determine(speed: speed, for: factor, config: CalculationConfig())
            let text      = dialPositionText(longitude: eclPos, speedType: speedType)

            // For the dial: mundaneAngle == eclipticLongitude (no ascendant rotation)
            items.append(WheelPlotItem(
                factor: factor,
                glyph: glyph,
                eclipticLongitude: eclPos,
                mundaneAngle: eclPos,
                plotAngle: eclPos,
                positionText: text,
                speedType: speedType
            ))
        }

        // Add ASC and MC as regular items so the overlap resolver treats them like planets.
        items.append(WheelPlotItem(
            factor: .ascendant,
            glyph: GlyphSelector.getGlyphForFactor(.ascendant),
            eclipticLongitude: ascLong,
            mundaneAngle: ascLong,
            plotAngle: ascLong,
            positionText: dialPositionText(longitude: ascLong),
            speedType: .direct
        ))
        items.append(WheelPlotItem(
            factor: .mc,
            glyph: GlyphSelector.getGlyphForFactor(.mc),
            eclipticLongitude: mcLong,
            mundaneAngle: mcLong,
            plotAngle: mcLong,
            positionText: dialPositionText(longitude: mcLong),
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

    /// Degrees and minutes within sign, with optional speed suffix, e.g. "15°23' R".
    private static func dialPositionText(longitude: Double, speedType: SpeedType = .direct) -> String {
        let inSign   = longitude.truncatingRemainder(dividingBy: 30.0)
        let totalMin = Int(abs(inSign) * 60)
        let deg      = totalMin / 60
        let min      = totalMin % 60
        let base     = "\(deg)°\(String(format: "%02d", min))'"
        return speedType == .direct ? base : "\(base) \(speedType.abbreviation)"
    }
}
