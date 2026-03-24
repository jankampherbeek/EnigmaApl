// WheelPlotDataBuilder.swift
// EnigmaApl
//
// Converts a FullChart into a WheelPlotData ready for drawing.

import SwiftUI

struct WheelPlotDataBuilder {

    /// Builds a WheelPlotData from a FullChart and optional active configuration.
    static func build(from chart: FullChart, config: UserConfiguration? = nil) -> WheelPlotData {
        let ascLong = chart.HousePositions.ascendant.longitude
        let mcLong  = chart.HousePositions.midheaven.longitude
        let cusps   = chart.HousePositions.cusps.map { $0.longitude }
        let hasTime = true  // FullChart always has time; extend later if needed

        var items: [WheelPlotItem] = []
        for (factor, position) in chart.Coordinates {
            guard factor.calculationType != .Mundane,
                  factor.calculationType != .Unknown,
                  FactorDisplaySelector.shouldDraw(factor),
                  let eclPos = position.ecliptical.first?.mainPos else { continue }

            let mundane = WheelGeometry.mundaneAngle(longitude: eclPos, ascendantLongitude: ascLong)
            let text    = positionText(longitude: eclPos)
            let glyph   = GlyphSelector.getGlyphForFactor(factor)

            items.append(WheelPlotItem(
                factor: factor,
                glyph: glyph,
                eclipticLongitude: eclPos,
                mundaneAngle: mundane,
                plotAngle: mundane,
                positionText: text
            ))
        }

        let resolved = GlyphOverlapResolver.resolve(items)
        let aspectItems = buildAspectItems(chart: chart, planetItems: resolved,
                                           ascLong: ascLong, config: config)

        return WheelPlotData(
            ascendantLongitude: ascLong,
            mcLongitude: mcLong,
            cuspLongitudes: cusps,
            planetItems: resolved,
            hasTime: hasTime,
            aspectItems: aspectItems
        )
    }

    // MARK: - Aspect items

    private static func buildAspectItems(
        chart: FullChart,
        planetItems: [WheelPlotItem],
        ascLong: Double,
        config: UserConfiguration?
    ) -> [WheelAspectItem] {
        guard let config else { return [] }

        let foundAspects = AspectsOrchestrator.calculate(
            chart: chart,
            factorConfig: config.factorConfig,
            aspectConfig: config.aspectConfig,
            orbConfig: config.orbConfig
        )
        guard !foundAspects.isEmpty else { return [] }

        // Map factor → mundane angle for drawn planets only
        let angleMap: [Factors: Double] = Dictionary(
            uniqueKeysWithValues: planetItems.map { ($0.factor, $0.mundaneAngle) }
        )

        // Build aspect color lookup from config
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
                                   color: color, exactness: exactness)
        }
    }

    // MARK: - Helpers

    /// Degrees°minutes' within the sign, e.g. "15°23'".
    private static func positionText(longitude: Double) -> String {
        let inSign = longitude.truncatingRemainder(dividingBy: 30.0)
        let totalMin = Int(abs(inSign) * 60)
        let deg = totalMin / 60
        let min = totalMin % 60
        return "\(deg)°\(String(format: "%02d", min))'"
    }
}
