// TransitKeys.swift
// EnigmaApl is open source. For more information see se_license.html and License, both at the root of the application.
// Created by Jan Kampherbeek 2026

struct TransitKeys {
    private init() {}

    // TransitScreen
    static let help             = "view.transitscreen.help"
    static let title           = "view.transitscreen.title"
    static let noChart         = "view.transitscreen.nochart"
    static let chartLabel      = "view.transitscreen.chart"
    static let createEvent     = "view.transitscreen.createevent"
    static let eventsHeader    = "view.transitscreen.eventsheader"
    static let noEvents        = "view.transitscreen.noevents"
    static let columnTitle     = "view.transitscreen.col.title"
    static let columnDateTime  = "view.transitscreen.col.datetime"
    static let columnLocation  = "view.transitscreen.col.location"
    static let select          = "view.transitscreen.select"
    static let calculate       = "view.transitscreen.calculate"
    static let errorCalcFailed = "view.transitscreen.error.calcfailed"

    // TransitResults - tabs
    static let helpResults       = "view.transitresults.help"
    static let resultsTitle      = "view.transitresults.title"
    static let noResults         = "view.transitresults.noresults"
    static let tabPositions      = "view.transitresults.tab.positions"
    static let tabMatches        = "view.transitresults.tab.matches"
    static let tabDualWheel      = "view.transitresults.tab.dualwheel"

    // Positions tab
    static let columnFactor      = "view.transitresults.col.factor"
    static let columnLongitude   = "view.transitresults.col.longitude"
    static let columnDeclination = "view.transitresults.col.declination"

    // Matches tab
    static let matchesNoMatches   = "view.transitresults.matches.nomatches"
    static let matchesColTransit  = "view.transitresults.matches.col.transit"
    static let matchesColAspect   = "view.transitresults.matches.col.aspect"
    static let matchesColRadix    = "view.transitresults.matches.col.radix"
    static let matchesColOrb      = "view.transitresults.matches.col.orb"
    static let matchesColExactness = "view.transitresults.matches.col.exactness"
    static let parallelName       = "view.transitresults.parallel"
    static let contraparallelName = "view.transitresults.contraparallel"

    // Midpoints tab
    static let tabMidpoints           = "view.transitresults.tab.midpoints"
    static let midpointsRadixHeader   = "view.transitresults.midpoints.radixheader"
    static let midpointsTransitHeader = "view.transitresults.midpoints.transitheader"
    static let midpointsNoMatches     = "view.transitresults.midpoints.nomatches"
}
