// ProgressiveCalendarRangeLimiter.swift
// EnigmaApl is open source. For more information see se_license.html and License, both at the root of the application.
// Created by Jan Kampherbeek 2026

import Foundation

/// Computes the maximum allowed date-range span for a Progressive Calendar scan, based on
/// which techniques and factors are currently selected. Scanning is far more expensive for
/// fast-moving factors (a transiting Moon) over a long range than for slow ones, so the limit
/// tightens as fast factors are added to the selection.
///
/// When more than one rule matches the current selection, the shortest limit always wins.
/// This does not enforce the limit — callers (the input screen / model) are responsible for
/// clamping the requested end date against `maxRangeInDays(selections:)`.
struct ProgressiveCalendarRangeLimiter {

    private init() {}

    private static let TROPICAL_YEAR_IN_DAYS = 365.242199074

    /// Applies when no rule below matches the current selection.
    static let defaultLimitInDays = 125.0 * TROPICAL_YEAR_IN_DAYS

    private static let mercuryVenusMars: Set<Factors> = [.mercury, .venus, .mars]
    private static let jupiterSaturn: Set<Factors> = [.jupiter, .saturn]

    /// - Parameter selections: the techniques and factors currently selected for the scan.
    /// - Returns: the maximum allowed span, in days, between the scan's start and end date.
    static func maxRangeInDays(selections: [ProgressiveCalendarOrchestrator.Selection]) -> Double {
        var limits: [Double] = []

        for selection in selections {
            switch selection.technique {
            case .transit:
                if selection.factors.contains(.moon) {
                    limits.append(60.0)
                }
                if selection.factors.contains(where: mercuryVenusMars.contains) {
                    limits.append(2.0 * TROPICAL_YEAR_IN_DAYS)
                }
                if selection.factors.contains(where: jupiterSaturn.contains) {
                    limits.append(40.0 * TROPICAL_YEAR_IN_DAYS)
                }
            case .secondaryDirection:
                if selection.factors.contains(.moon) {
                    limits.append(60.0 * TROPICAL_YEAR_IN_DAYS)
                }
            case .symbolicDirection:
                break
            }
        }

        return limits.min() ?? defaultLimitInDays
    }
}
