// GeocentricLatitude.swift
// EnigmaApl is open source. For more information see se_license.html and License, both at the root of the application.
// Created by Jan Kampherbeek 2026

import Foundation

/// Converts geographic (geodetic) latitude to geocentric latitude using the WGS-84 ellipsoid.
struct GeocentricLatitude {

    private static let equatorRadius: Double = 6378.137
    private static let flattening: Double = 1.0 / 298.257
    private static let polarRadius: Double = equatorRadius * (1.0 - flattening)

    /// Converts a geographic (geodetic) latitude to geocentric latitude.
    /// - Parameter geographicLatitude: Geographic latitude in decimal degrees (positive = north, negative = south).
    /// - Returns: Geocentric latitude in decimal degrees.
    static func geographicToGeocentric(_ geographicLatitude: Double) -> Double {
        let gglRad = geographicLatitude * .pi / 180.0
        let ratio = polarRadius / equatorRadius
        let tanGcl = ratio * ratio * tan(gglRad)
        let gclRad = atan(tanGcl)
        return gclRad * 180.0 / .pi
    }
}
