// ParansResults.swift
// EnigmaApl is open source. For more information see se_license.html and License, both at the root of the application.
// Created by Jan Kampherbeek 2026

import Foundation

// MARK: - Paran event type

public enum ParanType: CaseIterable {
    case rising
    case setting
    case culmination
    case antiCulmination

    /// SE rsmi flag value, including disc-centre and no-refraction bits for rise/set.
    var rsmi: Int {
        switch self {
        case .rising:          return 1 | 256 | 512   // SE_CALC_RISE | SE_BIT_DISC_CENTER | SE_BIT_NO_REFRACTION
        case .setting:         return 2 | 256 | 512   // SE_CALC_SET  | SE_BIT_DISC_CENTER | SE_BIT_NO_REFRACTION
        case .culmination:     return 4               // SE_CALC_MTRANSIT
        case .antiCulmination: return 8               // SE_CALC_ITRANSIT
        }
    }
}

// MARK: - Body wrapper (factor or fixed star)

public enum ParanBody: Equatable {
    case factor(Factors)
    case star(StarDefinitions)

    var displayName: String {
        switch self {
        case .factor(let f): return f.localizedName
        case .star(let s):   return s.name
        }
    }
}

// MARK: - Times for one body

/// All four paran transit times (JD UT) for a single body on the birth day.
/// A nil value means the body is circumpolar or the SE calculation failed.
public struct ParanTimesForBody {
    public let body: ParanBody
    public let rising: Double?
    public let setting: Double?
    public let culmination: Double?
    public let antiCulmination: Double?

    public func time(for type: ParanType) -> Double? {
        switch type {
        case .rising:          return rising
        case .setting:         return setting
        case .culmination:     return culmination
        case .antiCulmination: return antiCulmination
        }
    }
}

// MARK: - A single paran match

/// Two bodies whose transit times (of potentially different event types) fall within the configured time orb.
public struct ParanMatch {
    /// The first body (a fixed star, or a factor). Never a star when body2 is also a star.
    public let body1: ParanBody
    /// Event type for body1.
    public let type1: ParanType
    /// Actual transit time of body1 (JD UT).
    public let time1: Double
    /// The second body (always a factor).
    public let body2: ParanBody
    /// Event type for body2.
    public let type2: ParanType
    /// Actual transit time of body2 (JD UT).
    public let time2: Double
    /// Absolute difference between the two transit times, in minutes.
    public let orbMinutes: Double
}

// MARK: - Full paran result

public struct ParansResult {
    public let allTimes: [ParanTimesForBody]
    public let matches: [ParanMatch]
}
