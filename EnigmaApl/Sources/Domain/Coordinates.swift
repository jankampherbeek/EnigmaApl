// Coordinates.swift
// EnigmaApl is open source. For more information see se_license.html and License, both at the root of the application.
// Created by Jan Kampherbeek 2026

import Foundation

/// Coordinate types used for positional data
public enum Coordinates: Int, CaseIterable {
    case longitude = 0
    case latitude = 1
    case rightAscension = 2
    case declination = 3
    case distance = 4

    /// Resource bundle key for localized name
    var rbKey: String { CoordinatesKeys.key(for: self) }
}
