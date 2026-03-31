// HarmonicWheelPlotDataBuilder.swift
// EnigmaApl is open source. For more information see se_license.html and License, both at the root of the application.
// Created by Jan Kampherbeek 2026

import Foundation

/// Builds a WheelPlotData from a list of harmonic positions.
/// - 0° Aries is always placed at the left (ascendantLongitude = 0 for zodiac ring rotation).
/// - ASC and MC, if present in harmonicPositions, are included as regular planet items so the
///   canvas can draw their indicator lines at the correct harmonic longitudes.
/// - No aspect items and no cusp longitudes are included.
struct HarmonicWheelPlotDataBuilder {

    private init() {}

    /// Returns a WheelPlotData suitable for the harmonic wheel canvas.
    /// - Parameter harmonicPositions: Calculated harmonic positions from HarmonicsOrchestrator,
    ///   which already includes ASC and MC if they are enabled in the factor config.
    static func build(harmonicPositions: [HarmonicPosition]) -> WheelPlotData {
        var items: [WheelPlotItem] = []
        for hp in harmonicPositions {
            let mundane = WheelGeometry.mundaneAngle(longitude: hp.longitude, ascendantLongitude: 0)
            let glyph   = GlyphSelector.getGlyphForFactor(hp.factor)
            let text    = positionText(longitude: hp.longitude)
            items.append(WheelPlotItem(
                factor:            hp.factor,
                glyph:             glyph,
                eclipticLongitude: hp.longitude,
                mundaneAngle:      mundane,
                plotAngle:         mundane,
                positionText:      text,
                speedType:         .direct   // speed is not meaningful for harmonic positions
            ))
        }
        let resolved = GlyphOverlapResolver.resolve(items)
        return WheelPlotData(
            ascendantLongitude: 0,   // 0° Aries fixed at the left
            mcLongitude:        0,   // not used; canvas extracts MC from planetItems
            cuspLongitudes:     [],  // no house cusp lines
            planetItems:        resolved,
            hasTime:            false,
            aspectItems:        []
        )
    }

    // MARK: - Private helpers

    private static func positionText(longitude: Double) -> String {
        let inSign   = longitude.truncatingRemainder(dividingBy: 30.0)
        let totalMin = Int(abs(inSign) * 60)
        let deg      = totalMin / 60
        let min      = totalMin % 60
        return "\(deg)°\(String(format: "%02d", min))'"
    }
}
