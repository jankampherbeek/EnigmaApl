// HarmonicWheelPlotDataBuilder.swift
// EnigmaApl is open source. For more information see se_license.html and License, both at the root of the application.
// Created by Jan Kampherbeek 2026

import SwiftUI

/// Builds a WheelPlotData from a list of harmonic positions.
/// - If the harmonic ASC is present in harmonicPositions, it is placed at the left (as in the
///   other charts) and 12 equal cusps are added, each a multiple of 30° from the harmonic ASC.
///   The harmonic MC, if present, can fall anywhere.
/// - Without a harmonic ASC, 0° Aries is placed at the left and no cusps are included.
/// - ASC and MC, if present in harmonicPositions, are included as regular planet items so the
///   canvas can draw their indicator lines at the correct harmonic longitudes.
/// - Aspect items are calculated between the harmonic positions, using the aspects and orbs
///   from the configuration. Without a configuration no aspect items are included.
struct HarmonicWheelPlotDataBuilder {

    private init() {}

    /// Returns a WheelPlotData suitable for the harmonic wheel canvas.
    /// - Parameter harmonicPositions: Calculated harmonic positions from HarmonicsOrchestrator,
    ///   which already includes ASC and MC if they are enabled in the factor config.
    /// - Parameter config: Active configuration, provides the aspects and orbs for the aspect lines.
    static func build(harmonicPositions: [HarmonicPosition],
                      config: UserConfiguration? = nil) -> WheelPlotData {
        let ascLong = harmonicPositions.first(where: { $0.factor == .ascendant })?.longitude
        let mcLong  = harmonicPositions.first(where: { $0.factor == .mc })?.longitude
        let wheelAscLong = ascLong ?? 0   // 0° Aries at the left when there is no harmonic ASC
        let cusps   = ascLong.map { equalCusps(ascLong: $0) } ?? []

        var items: [WheelPlotItem] = []
        for hp in harmonicPositions {
            let mundane = WheelGeometry.mundaneAngle(longitude: hp.longitude, ascendantLongitude: wheelAscLong)
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
        let resolved    = GlyphOverlapResolver.resolve(items)
        let aspectItems = buildAspectItems(harmonicPositions: harmonicPositions,
                                           planetItems: resolved, config: config)
        return WheelPlotData(
            ascendantLongitude: wheelAscLong,
            mcLongitude:        mcLong ?? 0,   // not used; canvas extracts MC from planetItems
            cuspLongitudes:     cusps,
            planetItems:        resolved,
            hasTime:            ascLong != nil,
            aspectItems:        aspectItems
        )
    }

    // MARK: - Aspect items

    private static func buildAspectItems(
        harmonicPositions: [HarmonicPosition],
        planetItems: [WheelPlotItem],
        config: UserConfiguration?
    ) -> [WheelAspectItem] {
        guard let config else { return [] }

        let foundAspects = AspectsOrchestrator.calculate(
            positions: harmonicPositions.map { ($0.factor, $0.longitude) },
            factorConfig: config.factorConfig,
            aspectConfig: config.aspectConfig,
            orbConfig: config.orbConfig
        )
        guard !foundAspects.isEmpty else { return [] }

        let angleMap: [Factors: Double] = Dictionary(
            uniqueKeysWithValues: planetItems.map { ($0.factor, $0.mundaneAngle) }
        )
        let colorMap: [Aspects: Color] = Dictionary(
            uniqueKeysWithValues: config.aspectConfig.aspectSettings.map {
                ($0.aspect, Color($0.color))
            }
        )

        return foundAspects.compactMap { found in
            guard let angle1 = angleMap[found.factor1],
                  let angle2 = angleMap[found.factor2] else { return nil }
            let color     = colorMap[found.aspect] ?? .gray
            let exactness = found.maxOrb > 0 ? max(0, 1.0 - found.orb / found.maxOrb) : 1.0
            return WheelAspectItem(angle1: angle1, angle2: angle2,
                                   color: color, exactness: exactness, aspect: found.aspect)
        }
    }

    // MARK: - Private helpers

    /// Equal house cusps: cusp n (0-based) is at ascLong + n * 30°.
    private static func equalCusps(ascLong: Double) -> [Double] {
        (0..<12).map { WheelGeometry.normalise(ascLong + Double($0) * 30.0) }
    }

    private static func positionText(longitude: Double) -> String {
        let inSign   = longitude.truncatingRemainder(dividingBy: 30.0)
        let totalMin = Int(abs(inSign) * 60)
        let deg      = totalMin / 60
        let min      = totalMin % 60
        return "\(deg)°\(String(format: "%02d", min))'"
    }
}
