// ProgressiveCalendarConfig.swift
// EnigmaApl is open source. For more information see se_license.html and License, both at the root of the application.
// Created by Jan Kampherbeek 2026

import Foundation

/// Configuration for the Progressive Calendar feature: which techniques and factors to
/// include, the radix factors to compare against, which event kinds to include, and orbs.
///
/// Like `PrimaryDirectionsConfig`'s method/approach/timeKey, these settings are meant to be
/// edited directly in the Progressive Calendar feature's own input screen, not only through
/// the generic Config editor — this struct only supplies the persisted defaults that screen
/// seeds its local editable state from.
public struct ProgressiveCalendarConfig: Codable, Sendable {
    public let useTransits: Bool
    public let useSecondaryDirections: Bool
    public let useSymbolicDirections: Bool

    public let transitFactors: [Factors]
    public let secondaryDirectionFactors: [Factors]
    public let symbolicDirectionFactors: [Factors]
    public let symbolicKey: SymbolicKeys

    public let radixFactors: [Factors]
    public let aspects: [Aspects]

    public let aspectOrb: Double
    public let parallelOrb: Double
    public let cuspOrb: Double

    public let useAspectsToRadix: Bool
    public let useParallelsToRadix: Bool
    public let useAspectsProgToProg: Bool
    public let useParallelsProgToProg: Bool
    public let useCuspConjunctions: Bool
    public let useRetrogradeDirectStations: Bool
    public let useOobEnterExit: Bool
    public let useDeclinationExtremes: Bool

    public init(
        useTransits: Bool = true,
        useSecondaryDirections: Bool = true,
        useSymbolicDirections: Bool = false,
        transitFactors: [Factors] = ProgressiveCalendarConfig.defaultTransitFactors,
        secondaryDirectionFactors: [Factors] = ProgressiveCalendarConfig.defaultSecondaryDirectionFactors,
        symbolicDirectionFactors: [Factors] = ProgressiveCalendarConfig.defaultSymbolicDirectionFactors,
        symbolicKey: SymbolicKeys = .oneDegree,
        radixFactors: [Factors] = ProgressiveCalendarConfig.defaultRadixFactors,
        aspects: [Aspects] = ProgressiveCalendarConfig.defaultAspects,
        aspectOrb: Double = 1.0,
        parallelOrb: Double = 1.0,
        cuspOrb: Double = 1.0,
        useAspectsToRadix: Bool = true,
        useParallelsToRadix: Bool = true,
        useAspectsProgToProg: Bool = false,
        useParallelsProgToProg: Bool = false,
        useCuspConjunctions: Bool = true,
        useRetrogradeDirectStations: Bool = true,
        useOobEnterExit: Bool = false,
        useDeclinationExtremes: Bool = false
    ) {
        self.useTransits = useTransits
        self.useSecondaryDirections = useSecondaryDirections
        self.useSymbolicDirections = useSymbolicDirections
        self.transitFactors = transitFactors
        self.secondaryDirectionFactors = secondaryDirectionFactors
        self.symbolicDirectionFactors = symbolicDirectionFactors
        self.symbolicKey = symbolicKey
        self.radixFactors = radixFactors
        self.aspects = aspects
        self.aspectOrb = aspectOrb
        self.parallelOrb = parallelOrb
        self.cuspOrb = cuspOrb
        self.useAspectsToRadix = useAspectsToRadix
        self.useParallelsToRadix = useParallelsToRadix
        self.useAspectsProgToProg = useAspectsProgToProg
        self.useParallelsProgToProg = useParallelsProgToProg
        self.useCuspConjunctions = useCuspConjunctions
        self.useRetrogradeDirectStations = useRetrogradeDirectStations
        self.useOobEnterExit = useOobEnterExit
        self.useDeclinationExtremes = useDeclinationExtremes
    }

    public static let defaultTransitFactors: [Factors] = TransitsConfig.defaultFactors
    public static let defaultSecondaryDirectionFactors: [Factors] = SecondaryDirectionsConfig.defaultFactors
    public static let defaultSymbolicDirectionFactors: [Factors] = SymbolicDirectionsConfig.defaultFactors
    public static let defaultRadixFactors: [Factors] = TransitsConfig.defaultFactors
    public static let defaultAspects: [Aspects] = [.conjunction, .opposition, .trine, .square, .sextile]
}
