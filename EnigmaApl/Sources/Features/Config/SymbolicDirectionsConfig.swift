// SymbolicDirectionsConfig.swift
// EnigmaApl is open source. For more information see se_license.html and License, both at the root of the application.
// Created by Jan Kampherbeek 2026

import Foundation

public enum SymbolicTimeKey: Int, CaseIterable, Codable {
    case oneDegree = 0
    case trueSun = 1
    case meanSun = 2

    var rbKey: String {
        switch self {
        case .oneDegree: return "enum.symbolictimekey.onedegree"
        case .trueSun:   return "enum.symbolictimekey.truesun"
        case .meanSun:   return "enum.symbolictimekey.meansun"
        }
    }
}

/// Configuration for symbolic directions.
public struct SymbolicDirectionsConfig: Codable, Sendable {
    public let factors: [Factors]
    public let orb: Double
    public let timeKey: SymbolicTimeKey

    public init(
        factors: [Factors] = SymbolicDirectionsConfig.defaultFactors,
        orb: Double = 1.0,
        timeKey: SymbolicTimeKey = .oneDegree
    ) {
        self.factors = factors
        self.orb = orb
        self.timeKey = timeKey
    }

    public static let defaultFactors: [Factors] = [
        .sun, .moon, .mercury, .venus, .mars, .jupiter, .saturn,
        .uranus, .neptune, .pluto, .chiron, .northNode, .mc, .ascendant
    ]
}
