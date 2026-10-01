// WheelAngleMapper.swift
// EnigmaApl is open source. For more information see se_license.html and License, both at the root of the application.
// Created by Jan Kampherbeek 2026

import Foundation

/// Converts ecliptic longitudes to the visual angle used by each chart drawing type,
/// so positions of a second chart (transits, progressions, synastry) line up with the
/// wheel of the first chart.
enum WheelAngleMapper {

    /// Visual angle for `longitude` on a wheel of the given type, drawn for a chart with
    /// the given ascendant and house cusps.
    static func angle(longitude: Double, drawingType: DrawingType,
                      ascendantLongitude: Double, cuspLongitudes: [Double]) -> Double {
        switch drawingType {
        case .signBased, .french, .ring:
            return WheelGeometry.mundaneAngle(longitude: longitude, ascendantLongitude: ascendantLongitude)
        case .houseBased:
            return HouseWheelPlotDataBuilder.eclipticToHouseAngle(longitude: longitude, cusps: cuspLongitudes)
        case .dial360:
            return WheelGeometry.normalise(longitude)
        case .dial90:
            return Dial90PlotDataBuilder.dial90Angle(WheelGeometry.normalise(longitude))
        case .dial45:
            return Dial45PlotDataBuilder.dial45Angle(WheelGeometry.normalise(longitude))
        }
    }

    /// Inverse of `WheelGeometry.mundaneAngle`: the longitude at a sign-based wheel angle.
    static func longitude(fromMundaneAngle angle: Double, ascendantLongitude: Double) -> Double {
        WheelGeometry.normalise(angle + ascendantLongitude - 90.0)
    }

    /// True for the Ebertin dials, which have no houses.
    static func isDial(_ drawingType: DrawingType) -> Bool {
        drawingType == .dial360 || drawingType == .dial90 || drawingType == .dial45
    }
}

/// Builds the plot data for a chart with the builder that matches the drawing type.
enum ChartWheelPlotDataBuilder {

    static func build(from chart: FullChart, config: UserConfiguration?,
                      drawingType: DrawingType) -> WheelPlotData {
        switch drawingType {
        case .signBased, .french, .ring: return WheelPlotDataBuilder.build(from: chart, config: config)
        case .houseBased:                return HouseWheelPlotDataBuilder.build(from: chart, config: config)
        case .dial360:                   return DialPlotDataBuilder.build(from: chart, config: config)
        case .dial90:                    return Dial90PlotDataBuilder.build(from: chart, config: config)
        case .dial45:                    return Dial45PlotDataBuilder.build(from: chart, config: config)
        }
    }
}
