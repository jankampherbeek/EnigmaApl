// LogTimeScaleKeys.swift
// EnigmaApl is open source. For more information see se_license.html and License, both at the root of the application.
// Created by Jan Kampherbeek 2026

struct LogTimeScaleKeys {
    private init() {}

    // MARK: - Input screen
    static let title                 = "view.logtimescale.title"
    static let modePositionsForEvent = "view.logtimescale.mode.positionsforevent"
    static let modeOverview          = "view.logtimescale.mode.overview"
    static let calculate             = "view.logtimescale.calculate"
    static let help                  = "view.logtimescaleinput.help"
    static let helpResults           = "view.logtimescaleresults.help"

    // MARK: - Results screen – general
    static let resultsTitle   = "view.logtimescale.results.title"
    static let noResults      = "view.logtimescale.noresults"
    static let tabPositions   = "view.logtimescale.tab.positions"
    static let tabMatches     = "view.logtimescale.tab.matches"
    static let tabWheel       = "view.logtimescale.tab.wheel"
    static let positionLabel  = "view.logtimescale.positionlabel"
    static let columnPosition = "view.logtimescale.col.position"

    // MARK: - Results screen – Matches tab: aspects section
    static let aspectsHeader   = "view.logtimescale.matches.aspectsheader"
    static let noAspects       = "view.logtimescale.matches.noaspects"
    static let colAspect       = "view.logtimescale.matches.col.aspect"
    static let colRadix        = "view.logtimescale.matches.col.radix"
    static let colOrb          = "view.logtimescale.matches.col.orb"
    static let colExactness    = "view.logtimescale.matches.col.exactness"

    // MARK: - Results screen – Matches tab: midpoints section
    static let midpointsRadixHeader       = "view.logtimescale.matches.midpoints.radixheader"
    static let midpointsTimescaleHeader   = "view.logtimescale.matches.midpoints.timescaleheader"
    static let midpointsNoMatches         = "view.logtimescale.matches.midpoints.nomatches"

    // MARK: - Results screen – Overview positions table
    static let overviewColLabel  = "view.logtimescale.overview.col.label"
    static let overviewMonthFmt  = "view.logtimescale.overview.month"
    static let overviewAgeFmt    = "view.logtimescale.overview.age"
}
