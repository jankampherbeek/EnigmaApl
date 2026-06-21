// EphemerisKeys.swift
// EnigmaApl is open source. For more information see se_license.html and License, both at the root of the application.
// Created by Jan Kampherbeek 2026

import Foundation

struct EphemerisKeys {
    private init() {}

    static let title              = "view.ephemeris.title"
    static let month              = "view.ephemeris.month"
    static let year               = "view.ephemeris.year"
    static let observerPosition   = "view.ephemeris.observerposition"
    static let ayanamsha          = "view.ephemeris.ayanamsha"
    static let coordinate         = "view.ephemeris.coordinate"
    static let factors            = "view.ephemeris.factors"
    static let tabTable           = "view.ephemeris.tab.table"
    static let tabGraph           = "view.ephemeris.tab.graph"
    static let noResults          = "view.ephemeris.noresults"
    static let dateHeader         = "view.ephemeris.date.header"
    static let coordLongitude     = "view.ephemeris.coord.longitude"
    static let coordLatitude      = "view.ephemeris.coord.latitude"
    static let coordRA            = "view.ephemeris.coord.ra"
    static let coordDeclination   = "view.ephemeris.coord.declination"
    static let coordDistance      = "view.ephemeris.coord.distance"
    static let coordSpeedLon      = "view.ephemeris.coord.speedlon"
    static let coordSpeedDec      = "view.ephemeris.coord.speeddec"
    static let help               = "view.ephemeris.help"

    static func coordinateKey(for coord: EphemerisCoordinate) -> String {
        switch coord {
        case .longitude:        return coordLongitude
        case .latitude:         return coordLatitude
        case .rightAscension:   return coordRA
        case .declination:      return coordDeclination
        case .distance:         return coordDistance
        case .speedLongitude:   return coordSpeedLon
        case .speedDeclination: return coordSpeedDec
        }
    }
}
