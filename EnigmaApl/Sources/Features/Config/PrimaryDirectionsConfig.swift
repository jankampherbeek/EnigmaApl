// PrimaryDirectionsConfig.swift
// EnigmaApl is open source. For more information see se_license.html and License, both at the root of the application.
// Created by Jan Kampherbeek 2026

import Foundation

public enum PrimaryMethod: Int, CaseIterable, Codable {
    case placidus = 0
    case regiomontanus = 1

    var rbKey: String {
        switch self {
        case .placidus:      return "enum.primarymethod.placidus"
        case .regiomontanus: return "enum.primarymethod.regiomontanus"
        }
    }
}

public enum PrimaryApproach: Int, CaseIterable, Codable {
    case mundane = 0
    case ecliptical = 1

    var rbKey: String {
        switch self {
        case .mundane:    return "enum.primaryapproach.mundane"
        case .ecliptical: return "enum.primaryapproach.ecliptical"
        }
    }
}

public enum PrimaryTimeKey: Int, CaseIterable, Codable {
    case placidus = 0
    case naibod = 1
    case brahe = 2
    case ptolemy = 3
    case vanDam = 4

    var rbKey: String {
        switch self {
        case .placidus:  return "enum.primarytimekey.placidus"
        case .naibod:    return "enum.primarytimekey.naibod"
        case .brahe:     return "enum.primarytimekey.brahe"
        case .ptolemy:   return "enum.primarytimekey.ptolemy"
        case .vanDam:    return "enum.primarytimekey.vandam"
        }
    }
}

/// Configuration for primary directions.
public struct PrimaryDirectionsConfig: Codable, Sendable {
    public let promissors: [Factors]
    public let significators: [Factors]
    public let orb: Double
    public let method: PrimaryMethod
    public let approach: PrimaryApproach
    public let timeKey: PrimaryTimeKey

    public init(
        promissors: [Factors] = PrimaryDirectionsConfig.defaultPromissors,
        significators: [Factors] = PrimaryDirectionsConfig.defaultSignificators,
        orb: Double = 1.0,
        method: PrimaryMethod = .placidus,
        approach: PrimaryApproach = .mundane,
        timeKey: PrimaryTimeKey = .naibod
    ) {
        self.promissors = promissors
        self.significators = significators
        self.orb = orb
        self.method = method
        self.approach = approach
        self.timeKey = timeKey
    }

    public static let defaultPromissors: [Factors] = [
        .sun, .moon, .mercury, .venus, .mars, .jupiter, .saturn
    ]

    public static let defaultSignificators: [Factors] = [
        .sun, .moon, .mercury, .venus, .mars, .jupiter, .saturn, .mc, .ascendant
    ]
}
