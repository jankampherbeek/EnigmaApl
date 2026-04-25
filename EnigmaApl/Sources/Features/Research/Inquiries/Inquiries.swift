// Inquiries.swift
// EnigmaApl is open source. For more information see se_license.html and License, both at the root of the application.
// Created by Jan Kampherbeek 2026

/// Types of research inquiries that can be performed on a dataset.
public enum Inquiries: Int, CaseIterable {
    case factorsInSigns = 0
    case factorsInHouses = 1
    case aspects = 2
    case unaspect = 3
    case midpoints = 4
    case harmonics = 5
    case parallels = 6
    case declMidpoints = 7
    case oob = 8

    /// Resource bundle key for the localized name
    var rbKey: String { InquiriesKeys.nameKey(for: self) }

    /// Resource bundle key for the localized description
    var rbDescriptionKey: String { InquiriesKeys.descriptionKey(for: self) }

    /// Whether this inquiry uses ecliptical longitude.
    /// OOB, parallels, and declination midpoints use equatorial declination instead.
    var usesEcliptical: Bool {
        switch self {
        case .oob, .parallels, .declMidpoints: return false
        default: return true
        }
    }

    /// Whether this inquiry uses equatorial declination (the complement of `usesEcliptical`).
    var usesEquatorial: Bool { !usesEcliptical }

    /// Whether this inquiry requires house cusps (only `.factorsInHouses`).
    var requiresHouses: Bool { self == .factorsInHouses }
}
