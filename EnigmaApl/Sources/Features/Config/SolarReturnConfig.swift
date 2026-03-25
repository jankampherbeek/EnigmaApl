// SolarReturnConfig.swift
// EnigmaApl is open source. For more information see se_license.html and License, both at the root of the application.
// Created by Jan Kampherbeek 2026

import Foundation

public enum SolarMethod: Int, CaseIterable, Codable {
    case tropicalParallax = 0
    case tropicalNoParallax = 1
    case siderealParallax = 2
    case siderealNoParallax = 3

    var rbKey: String {
        switch self {
        case .tropicalParallax:    return "enum.solarmethod.tropicalparallax"
        case .tropicalNoParallax:  return "enum.solarmethod.tropicalnoparallax"
        case .siderealParallax:    return "enum.solarmethod.siderealparallax"
        case .siderealNoParallax:  return "enum.solarmethod.siderealnoparallax"
        }
    }
}

public enum SolarLocation: Int, CaseIterable, Codable {
    case birth = 0
    case relocateBirthDay = 1
    case relocateResidence = 2

    var rbKey: String {
        switch self {
        case .birth:              return "enum.solarlocation.birth"
        case .relocateBirthDay:   return "enum.solarlocation.relocatebirthday"
        case .relocateResidence:  return "enum.solarlocation.relocateresidence"
        }
    }
}

/// Configuration for solar returns.
public struct SolarReturnConfig: Codable, Sendable {
    public let orb: Double
    public let method: SolarMethod
    public let location: SolarLocation

    public init(
        orb: Double = 1.0,
        method: SolarMethod = .tropicalParallax,
        location: SolarLocation = .birth
    ) {
        self.orb = orb
        self.method = method
        self.location = location
    }
}
