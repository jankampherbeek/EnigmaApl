// WheelGeometry.swift
// EnigmaApl is open source. For more information see se_license.html and License, both at the root of the application.
// Created by Jan Kampherbeek 2026

import CoreGraphics
import Foundation

struct WheelGeometry {

    // MARK: - Point on circle

    /// Returns the CGPoint on a circle at the given angle and radius, relative to center.
    static func point(angleDeg: Double, radius: Double, center: CGPoint) -> CGPoint {
        let rad = angleDeg * Double.pi / 180.0
        let x = center.x - CGFloat(sin(rad) * radius)
        let y = center.y - CGFloat(cos(rad) * radius)
        return CGPoint(x: x, y: y)
    }

    // MARK: - Mundane angle

    /// Converts an ecliptic longitude to a wheel angle, placing the ascendant at 9 o'clock (270°→90°).
    static func mundaneAngle(longitude: Double, ascendantLongitude: Double) -> Double {
        var angle = longitude - ascendantLongitude + 90.0
        angle = angle.truncatingRemainder(dividingBy: 360.0)
        if angle < 0 { angle += 360.0 }
        return angle
    }

    // MARK: - Sign offset

    /// Offset in degrees for the first sign boundary after the ascendant.
    static func signOffset(ascendantLongitude: Double) -> Double {
        let offset = 30.0 - ascendantLongitude.truncatingRemainder(dividingBy: 30.0)
        return offset
    }

    // MARK: - Normalise angle to 0..<360

    static func normalise(_ angle: Double) -> Double {
        var a = angle.truncatingRemainder(dividingBy: 360.0)
        if a < 0 { a += 360.0 }
        return a
    }
}
