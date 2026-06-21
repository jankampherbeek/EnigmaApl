// EphemerisCoordinate.swift
// EnigmaApl is open source. For more information see se_license.html and License, both at the root of the application.
// Created by Jan Kampherbeek 2026

import Foundation

public enum EphemerisCoordinate: Int, CaseIterable, Identifiable {
    case longitude       = 0
    case latitude        = 1
    case rightAscension  = 2
    case declination     = 3
    case distance        = 4
    case speedLongitude  = 5
    case speedDeclination = 6

    public var id: Int { rawValue }

    var labelKey: String { EphemerisKeys.coordinateKey(for: self) }
}
