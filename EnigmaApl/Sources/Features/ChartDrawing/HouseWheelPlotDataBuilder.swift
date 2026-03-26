// HouseWheelPlotDataBuilder.swift
// EnigmaApl is open source. For more information see se_license.html and License, both at the root of the application.
// Created by Jan Kampherbeek 2026

import SwiftUI

struct HouseWheelPlotDataBuilder {

    static func build(from chart: FullChart, config: UserConfiguration? = nil) -> WheelPlotData {
        let ascLong = chart.HousePositions.ascendant.longitude
        let mcLong  = chart.HousePositions.midheaven.longitude
        let cusps   = chart.HousePositions.cusps.map { $0.longitude }
        let hasTime = true

        var items: [WheelPlotItem] = []
        for (factor, position) in chart.Coordinates {
            guard factor.calculationType != .Mundane,
                  factor.calculationType != .Unknown,
                  FactorDisplaySelector.shouldDraw(factor),
                  let eclPos = position.ecliptical.first?.mainPos else { continue }

            let houseAngle = eclipticToHouseAngle(longitude: eclPos, cusps: cusps)
            let glyph      = GlyphSelector.getGlyphForFactor(factor)
            let speed      = position.ecliptical.first?.mainPosSpeed ?? 0.0
            let calcConfig = config?.calculationConfig ?? CalculationConfig()
            let speedType  = SpeedOrchestrator().determine(speed: speed, for: factor, config: calcConfig)
            let text       = positionText(longitude: eclPos, speedType: speedType)

            items.append(WheelPlotItem(
                factor: factor,
                glyph: glyph,
                eclipticLongitude: eclPos,
                mundaneAngle: houseAngle,
                plotAngle: houseAngle,
                positionText: text,
                speedType: speedType
            ))
        }

        let resolved = GlyphOverlapResolver.resolve(items)

        return WheelPlotData(
            ascendantLongitude: ascLong,
            mcLongitude: mcLong,
            cuspLongitudes: cusps,
            planetItems: resolved,
            hasTime: hasTime,
            aspectItems: []
        )
    }

    // MARK: - Angle mapping

    /// Maps an ecliptic longitude to a visual angle in the house wheel.
    /// The result is in [0°, 360°) with cusp 1 at 90°.
    static func eclipticToHouseAngle(longitude: Double, cusps: [Double]) -> Double {
        guard cusps.count >= 12 else { return 90.0 }
        let lon = WheelGeometry.normalise(longitude)
        for i in 0..<12 {
            let c1 = cusps[i]
            let c2 = cusps[(i + 1) % 12]
            let span: Double
            let offset: Double
            if c2 > c1 {
                guard lon >= c1 && lon < c2 else { continue }
                span   = c2 - c1
                offset = lon - c1
            } else {
                // House crosses the 0°/360° boundary
                guard lon >= c1 || lon < c2 else { continue }
                span   = c2 + 360.0 - c1
                offset = lon >= c1 ? lon - c1 : lon + 360.0 - c1
            }
            let fraction = span > 0 ? offset / span : 0
            return WheelGeometry.normalise(90.0 + Double(i) * 30.0 + fraction * 30.0)
        }
        return 90.0
    }

    // MARK: - Helpers

    private static func positionText(longitude: Double, speedType: SpeedType) -> String {
        let inSign   = longitude.truncatingRemainder(dividingBy: 30.0)
        let totalMin = Int(abs(inSign) * 60)
        let base = "\(totalMin / 60)°\(String(format: "%02d", totalMin % 60))'"
        return speedType == .direct ? base : "\(base) \(speedType.abbreviation)"
    }
}
