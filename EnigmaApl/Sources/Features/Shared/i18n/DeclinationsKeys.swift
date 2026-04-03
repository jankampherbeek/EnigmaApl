// DeclinationsKeys.swift
// EnigmaApl is open source. For more information see se_license.html and License, both at the root of the application.
// Created by Jan Kampherbeek 2026

/// Localization keys for DeclinationsScreen and sub-views, resolved from Declinations.strings.
struct DeclinationsKeys {
    private init() {}

    // DeclinationsScreen — shared
    static let title              = "view.declinationsscreen.title"
    static let noChart            = "view.declinationsscreen.nochart"
    static let btnAllDeclinations = "view.declinationsscreen.btn.alldeclinations"
    static let btnParallels       = "view.declinationsscreen.btn.parallels"
    static let btnEquivalents     = "view.declinationsscreen.btn.equivalents"
    static let btnDiagram         = "view.declinationsscreen.btn.diagram"
    static let btnMidpoints       = "view.declinationsscreen.btn.midpoints"

    // AllDeclinationsView
    static let allDeclinationsTitle   = "view.alldeclinationsview.title"
    static let allDeclinationsNoData  = "view.alldeclinationsview.nodata"
    static let allDeclinationsHelp    = "view.alldeclinationsview.help"
    static let colFactor              = "view.alldeclinationsview.col.factor"
    static let colLongitude           = "view.alldeclinationsview.col.longitude"
    static let colDeclination         = "view.alldeclinationsview.col.declination"

    // DeclinationParallelsView
    static let parallelsTitle         = "view.declinationparallelsview.title"
    static let parallelsNoData        = "view.declinationparallelsview.nodata"
    static let parallelsHelp          = "view.declinationparallelsview.help"
    static let parallelsColFactor1    = "view.declinationparallelsview.col.factor1"
    static let parallelsColDecl1      = "view.declinationparallelsview.col.decl1"
    static let parallelsColAspect     = "view.declinationparallelsview.col.aspect"
    static let parallelsColFactor2    = "view.declinationparallelsview.col.factor2"
    static let parallelsColDecl2      = "view.declinationparallelsview.col.decl2"
    static let parallelsColOrb        = "view.declinationparallelsview.col.orb"
    static let parallelsColExactness  = "view.declinationparallelsview.col.exactness"

    // DeclinationLongEquivalentsView
    static let equivalentsTitle       = "view.declinationlongequivalentsview.title"
    static let equivalentsNoData      = "view.declinationlongequivalentsview.nodata"
    static let equivalentsHelp        = "view.declinationlongequivalentsview.help"

    // DeclinationDiagramView
    static let diagramTitle           = "view.declinationdiagramview.title"
    static let diagramPlaceholder     = "view.declinationdiagramview.placeholder"
    static let diagramHelp            = "view.declinationdiagramview.help"

    // DeclinationMidpointsView
    static let decMidpointsTitle      = "view.declinationmidpointsview.title"
    static let decMidpointsNoData     = "view.declinationmidpointsview.nodata"
    static let decMidpointsHelp       = "view.declinationmidpointsview.help"
}
