// SpiritualBirthtimeCandidate.swift
// EnigmaApl is open source. For more information see se_license.html and License, both at the root of the application.
// Created by Jan Kampherbeek 2026

import Foundation

/// One candidate result from the Spiritual Birthtime (Moment of Incarnation) calculation.
public struct SpiritualBirthtimeCandidate {
    /// Local Sidereal Time of the candidate, in decimal hours.
    public let lst: Double
    /// True Local Time (after iterative refinement), in decimal hours.
    public let tlt: Double
    /// Greenwich Mean Time of the candidate, in decimal hours.
    public let gmt: Double
    /// Zone time (civil local time) of the candidate, in decimal hours.
    public let zoneTime: Double
    /// RAMC arc value in radians.
    public let arc: Double
    /// Whether the time is AM (true) or PM (false).
    public let isAm: Bool
    /// Number of additional sidereal hours applied during windowing (0 or 6).
    public let additionalHours: Int
}
