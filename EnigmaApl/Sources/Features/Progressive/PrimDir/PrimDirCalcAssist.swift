// PrimDirCalcAssist.swift
// EnigmaApl is open source. For more information see se_license.html and License, both at the root of the application.
// Created by Jan Kampherbeek 2026

import Foundation

/// Pure mathematical helpers for primary-direction calculations.
/// All functions are static; the struct cannot be instantiated.
struct PrimDirCalcAssist {
    private init() {}

    // MARK: - Basic math

    static func deg2rad(_ deg: Double) -> Double { deg * .pi / 180.0 }
    static func rad2deg(_ rad: Double) -> Double { rad * 180.0 / .pi }

    static func valueToRange(_ value: Double, _ min: Double, _ max: Double) -> Double {
        let range = max - min
        var result = value
        while result < min  { result += range }
        while result >= max { result -= range }
        return result
    }

    // MARK: - Chart hemisphere helpers

    /// Returns true when the point falls on the left (eastern, rising) side of the chart.
    static func isChartLeft(_ pos: Double, mc: Double) -> Bool {
        valueToRange(pos - mc, 0, 360) < 180
    }

    /// Returns true when the point falls above the horizon (diurnal hemisphere).
    static func isChartTop(_ pos: Double, asc: Double) -> Bool {
        valueToRange(pos - asc, 0, 360) > 180
    }

    // MARK: - Astronomical functions

    /// Ascensional difference: asin(tan(decl) * tan(geoLat)).
    static func ascensionalDifference(_ decl: Double, geoLat: Double) -> Double {
        let x = tan(deg2rad(decl)) * tan(deg2rad(geoLat))
        guard abs(x) <= 1.0 else { return 0.0 }
        return rad2deg(asin(x))
    }

    /// Oblique ascension (or descent) of a point.
    /// - Parameters:
    ///   - ra: Right ascension of the point.
    ///   - ascDiff: Ascensional difference.
    ///   - chartLeft: True if the point is on the eastern (left, rising) side.
    ///   - north: True for northern geographic latitudes.
    static func obliqueAscDesc(_ ra: Double, ascDiff ad: Double, chartLeft: Bool, north: Bool) -> Double {
        let oa: Double
        if north {
            oa = chartLeft ? ra - ad : ra + ad
        } else {
            oa = chartLeft ? ra + ad : ra - ad
        }
        return valueToRange(oa, 0, 360)
    }

    /// Arc from the point to the relevant meridian (MC or IC).
    static func meridianDistance(_ ra: Double, raMc: Double, raIc: Double, isTop: Bool) -> Double {
        let raMcIc = isTop ? raMc : raIc
        var shortArc = valueToRange(abs(ra - raMcIc), 0, 360)
        if shortArc >= 180 { shortArc = abs(360 - shortArc) }
        return shortArc
    }

    /// Arc from the oblique ascension of the point to that of the ascendant.
    /// - Parameters:
    ///   - oa: Oblique ascension of the point.
    ///   - oaAsc: Oblique ascension of the ascendant.
    ///   - chartLeft: True if the point is on the eastern (left, rising) side.
    ///   - north: True for northern geographic latitudes.
    static func horizontalDistance(_ oa: Double, oaAsc: Double, chartLeft: Bool, north: Bool) -> Double {
        var hd: Double
        if north {
            if chartLeft { hd = abs(oa - oaAsc) }
            else { hd = abs(valueToRange(oa + 180, 0, 180) - valueToRange(oaAsc + 180, 0, 180)) }
        } else {
            if !chartLeft { hd = abs(oa - oaAsc) }
            else { hd = abs(valueToRange(oa + 180, 0, 180) - valueToRange(oaAsc + 180, 0, 180)) }
        }
        if hd >= 180 { hd = 360 - hd }
        if hd >= 90  { hd = 180 - hd }
        return hd
    }

    /// Declination from ecliptic longitude, ignoring ecliptic latitude.
    static func declFromLongNoLat(_ longitude: Double, obliquity: Double) -> Double {
        rad2deg(asin(sin(deg2rad(obliquity)) * sin(deg2rad(longitude))))
    }

    /// Right ascension from ecliptic longitude, ignoring ecliptic latitude.
    static func rightAscFromLongNoLat(_ longitude: Double, obliquity: Double) -> Double {
        let lon = deg2rad(longitude)
        let obl = deg2rad(obliquity)
        return valueToRange(rad2deg(atan2(sin(lon) * cos(obl), cos(lon))), 0, 360)
    }

    // MARK: - Regiomontanus

    /// Zenith distance of a point under its Regiomontanus house pole.
    static func zenithDistReg(_ decl: Double, merDist: Double, geoLat: Double, isTop: Bool) -> Double {
        let declRad = deg2rad(decl)
        let mdRad   = deg2rad(merDist)
        let glRad   = deg2rad(geoLat)

        if abs(merDist - 90) < 0.000001 {
            return 90 - rad2deg(atan(sin(abs(glRad)) * tan(declRad)))
        }

        let a = rad2deg(atan(cos(glRad) * tan(mdRad)))
        let b = rad2deg(atan(tan(abs(glRad)) * cos(mdRad)))
        let c: Double
        if (decl >= 0 && geoLat >= 0) || (decl < 0 && geoLat < 0) {
            c = isTop ? b - abs(decl) : b + abs(decl)
        } else {
            c = isTop ? b + abs(decl) : b - abs(decl)
        }
        var f = 0.0
        if abs(b - decl) >= 0.0000001 {
            f = rad2deg(atan(sin(abs(glRad)) * sin(mdRad) * tan(deg2rad(c))))
        }
        var zd = a + f
        if zd < 0 { zd += 180 }
        return zd
    }

    /// Regiomontanus pole for a point from its upper meridian distance.
    static func poleRegiomontanus(_ decl: Double, mdUpper: Double, geoLat: Double) -> Double {
        let zd = zenithDistReg(decl, merDist: mdUpper, geoLat: geoLat, isTop: true)
        return rad2deg(asin(sin(deg2rad(geoLat)) * sin(deg2rad(zd))))
    }

    /// Ascensional difference of a point under the Regiomontanus pole.
    static func adUnderRegPole(_ regPole: Double, decl: Double) -> Double {
        ascensionalDifference(decl, geoLat: regPole)
    }

    // MARK: - Placidus

    /// Elevation of the pole under a Placidus house (from Gansten's formula).
    static func elevationOfThePolePlac(_ adPole: Double, decl: Double) -> Double {
        rad2deg(atan(sin(deg2rad(adPole)) / tan(deg2rad(decl))))
    }

    /// Ascensional difference of a promissor under the elevation of the pole of its sign.
    static func adPromUnderElevPoleSign(_ elevPoleSign: Double, declProm: Double) -> Double {
        ascensionalDifference(declProm, geoLat: elevPoleSign)
    }
}
