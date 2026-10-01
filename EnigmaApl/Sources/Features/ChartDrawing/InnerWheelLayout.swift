// InnerWheelLayout.swift
// EnigmaApl is open source. For more information see se_license.html and License, both at the root of the application.
// Created by Jan Kampherbeek 2026

import SwiftUI

/// Layout of a radix wheel that is drawn inside an outer ring: dual wheels (transits, progressions,
/// synastry) and wheels with an outer overlay (arrows, tick marks, zodiac divisions).
/// Each drawing type has its own outermost elements, so the radix wheel is scaled per type and the
/// overlay starts at a type-specific radius.
enum InnerWheelLayout {

    /// Factor applied to a screen's sign-based radix scale, so the outermost elements of the given
    /// type end at about the same radius as those of the sign-based wheel.
    static func scaleFactor(_ drawingType: DrawingType) -> Double {
        switch drawingType {
        case .signBased, .houseBased:    return 1.0           // sign ring 0.89, cardinal labels 0.93
        case .french:                    return 0.66 / 0.78   // position texts reach past the outer edge
        case .ring:                      return 0.70 / 0.78   // position texts (with sign glyph) outside the ring
        case .dial360, .dial90, .dial45: return 0.72 / 0.78   // label ring up to 0.99
        }
    }

    /// Fraction of the radix wheel radius where the radix content ends. Connect lines, arrows and
    /// tick marks of the outer ring end here.
    static func contentFraction(_ drawingType: DrawingType) -> Double {
        switch drawingType {
        case .signBased, .houseBased:    return WheelMetrics.outerSign
        case .french:                    return 1.08   // just outside the position texts
        case .ring:                      return 1.02   // just outside the position texts
        case .dial360, .dial90, .dial45: return 0.99
        }
    }

    /// Fraction of the radix wheel radius where the outer ring starts.
    static func ringStartFraction(_ drawingType: DrawingType) -> Double {
        switch drawingType {
        case .signBased, .houseBased: return 1.0
        default:                      return contentFraction(drawingType)
        }
    }

    /// French and ring wheels place their planets outside their main circles, so a boundary
    /// circle keeps the radix planets visually apart from the outer ring.
    static func drawsBoundary(_ drawingType: DrawingType) -> Bool {
        drawingType == .french || drawingType == .ring
    }

    /// Background of the outer ring. The ring type keeps a white background.
    static func ringBackground(_ drawingType: DrawingType, theme: WheelTheme) -> Color {
        drawingType == .ring ? .white : theme.outerCircleBackground
    }

    /// Angle on a wheel of the given type for a sign-based (mundane) angle, measured from the
    /// ascendant in `data`.
    static func angle(fromMundane angle: Double, data: WheelPlotData, drawingType: DrawingType) -> Double {
        let longitude = WheelAngleMapper.longitude(fromMundaneAngle: angle,
                                                   ascendantLongitude: data.ascendantLongitude)
        return WheelAngleMapper.angle(longitude: longitude, drawingType: drawingType,
                                      ascendantLongitude: data.ascendantLongitude,
                                      cuspLongitudes: data.cuspLongitudes)
    }

    /// Draws the radix wheel of the given type within `outerRadius`.
    static func drawRadixWheel(_ ctx: inout GraphicsContext, drawingType: DrawingType, center: CGPoint,
                               outerRadius: Double, data: WheelPlotData, theme: WheelTheme,
                               showAspects: Bool) {
        switch drawingType {
        case .signBased:
            drawZodiacTypeWheel(&ctx, center: center, outerRadius: outerRadius,
                                plotData: data, theme: theme, showAspects: showAspects)
        case .houseBased:
            drawHouseTypeWheel(&ctx, center: center, outerRadius: outerRadius,
                               plotData: data, theme: theme, showAspects: showAspects)
        case .french:
            drawFrenchTypeWheel(&ctx, center: center, outerRadius: outerRadius,
                                plotData: data, theme: theme, showAspects: showAspects)
        case .ring:
            drawRingTypeWheel(&ctx, center: center, outerRadius: outerRadius,
                              plotData: data, theme: theme, showAspects: showAspects)
        case .dial360:
            drawDial360TypeWheel(&ctx, center: center, outerRadius: outerRadius,
                                 plotData: data, theme: theme, showAspects: showAspects)
        case .dial90:
            drawDial90TypeWheel(&ctx, center: center, outerRadius: outerRadius,
                                plotData: data, theme: theme)
        case .dial45:
            drawDial45TypeWheel(&ctx, center: center, outerRadius: outerRadius,
                                plotData: data, theme: theme)
        }
    }

    /// Fills the outer ring background up to `radius`.
    static func drawRingBackground(_ ctx: inout GraphicsContext, drawingType: DrawingType, center: CGPoint,
                                   radius: Double, theme: WheelTheme) {
        let r    = CGFloat(radius)
        let rect = CGRect(x: center.x - r, y: center.y - r, width: r * 2, height: r * 2)
        ctx.fill(Path(ellipseIn: rect), with: .color(ringBackground(drawingType, theme: theme)))
    }

    /// Thin circle separating the radix wheel from the outer ring, for types that need one.
    static func drawBoundaryIfNeeded(_ ctx: inout GraphicsContext, drawingType: DrawingType, center: CGPoint,
                                     radius: Double, fullRadius: Double, theme: WheelTheme) {
        guard drawsBoundary(drawingType) else { return }
        let r    = CGFloat(radius)
        let rect = CGRect(x: center.x - r, y: center.y - r, width: r * 2, height: r * 2)
        ctx.stroke(Path(ellipseIn: rect), with: .color(theme.circleStroke),
                   lineWidth: WheelMetrics.strokeWidth(WheelMetrics.strokeFraction, outerRadius: fullRadius))
    }
}

extension WheelAngleMapper {
    /// Drawing type used by the specialised radix wheels (Log Time Scale, Age Point,
    /// Alternative Zodiac Start, VSP): sign-based, French, ring and the 360° dial.
    /// House-based falls back to sign-based, the 90° and 45° dials to the 360° dial.
    static func specialisedType(_ configured: DrawingType) -> DrawingType {
        switch configured {
        case .signBased, .french, .ring, .dial360: return configured
        case .houseBased:                          return .signBased
        case .dial90, .dial45:                     return .dial360
        }
    }

    /// Drawing type used by Zodiac Divisions and Harmonic Orbs: as `specialisedType`,
    /// but the house-based wheel is supported as well.
    static func specialisedTypeWithHouses(_ configured: DrawingType) -> DrawingType {
        configured == .houseBased ? .houseBased : specialisedType(configured)
    }
}
