// AgePointKeys.swift
// EnigmaApl is open source. For more information see se_license.html and License, both at the root of the application.
// Created by Jan Kampherbeek 2026

struct AgePointKeys {
    private init() {}

    // MARK: - Input screen
    static let title                 = "view.agepoint.title"
    static let modePositionsForEvent = "view.agepoint.mode.positionsforevent"
    static let modeOverview          = "view.agepoint.mode.overview"
    static let houseSystemLabel      = "view.agepoint.housesystem.label"
    static let calculate             = "view.agepoint.calculate"
    static let help                  = "view.agepointinput.help"
    static let helpResults           = "view.agepointresults.help"

    // MARK: - Results screen – general
    static let resultsTitle   = "view.agepoint.results.title"
    static let noResults      = "view.agepoint.noresults"
    static let tabPositions   = "view.agepoint.tab.positions"
    static let tabMatches     = "view.agepoint.tab.matches"
    static let tabWheel       = "view.agepoint.tab.wheel"
    static let positionLabel  = "view.agepoint.positionlabel"
    static let columnPosition = "view.agepoint.col.position"

    // MARK: - Results screen – Matches tab: aspects section
    static let aspectsHeader   = "view.agepoint.matches.aspectsheader"
    static let noAspects       = "view.agepoint.matches.noaspects"
    static let colOrb          = "view.agepoint.matches.col.orb"
    static let colExactness    = "view.agepoint.matches.col.exactness"

    // MARK: - Results screen – Matches tab: midpoints section
    static let midpointsRadixHeader       = "view.agepoint.matches.midpoints.radixheader"
    static let midpointsAgePointHeader    = "view.agepoint.matches.midpoints.agepointheader"
    static let midpointsNoMatches         = "view.agepoint.matches.midpoints.nomatches"

    // MARK: - Results screen – Overview positions table
    static let overviewColLabel = "view.agepoint.overview.col.label"
    static let overviewAgeFmt   = "view.agepoint.overview.age"
}
