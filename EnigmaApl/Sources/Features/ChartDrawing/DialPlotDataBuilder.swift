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

            let text  = dialPositionText(longitude: eclPos)
            let glyph = GlyphSelector.getGlyphForFactor(factor)

            // For the dial: mundaneAngle == eclipticLongitude (no ascendant rotation)
            items.append(WheelPlotItem(
                factor: factor,
                glyph: glyph,
                eclipticLongitude: eclPos,
                mundaneAngle: eclPos,
                plotAngle: eclPos,
                positionText: text
            ))
        }

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

    /// Degrees and minutes within sign, e.g. "15°23'".
    private static func dialPositionText(longitude: Double) -> String {
        let inSign   = longitude.truncatingRemainder(dividingBy: 30.0)
        let totalMin = Int(abs(inSign) * 60)
        let deg      = totalMin / 60
        let min      = totalMin % 60
        return "\(deg)°\(String(format: "%02d", min))'"
    }
}
