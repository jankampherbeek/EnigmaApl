// RadixAnalysisKeys.swift
// EnigmaApl is open source. For more information see se_license.html and License, both at the root of the application.
// Created by Jan Kampherbeek 2026

/// Localization keys for AnalysisScreen, HarmonicsScreen and related views, resolved from RadixAnalysis.strings.
struct RadixAnalysisKeys {
    private init() {}

    // AnalysisScreen
    static let title              = "view.analysisscreen.title"
    static let btnAspects         = "view.analysisscreen.btn.aspects"
    static let btnMidpoints       = "view.analysisscreen.btn.midpoints"
    static let btnHarmonics       = "view.analysisscreen.btn.harmonics"
    static let btnDeclinations       = "view.analysisscreen.btn.declinations"
    static let btnZodiacDivisions    = "view.analysisscreen.btn.zodiacdivisions"
    static let btnEnneagram          = "view.analysisscreen.btn.enneagram"
    static let btnVsp                = "view.analysisscreen.btn.vsp"
    static let help                  = "view.analysisscreen.help"

    // HarmonicsScreen — shared
    static let noChart            = "view.harmonicsscreen.nochart"
    static let inputLabel         = "view.harmonicsscreen.inputlabel"
    static let btnAllHarmonics    = "view.harmonicsscreen.btn.allharmonics"
    static let btnMatches         = "view.harmonicsscreen.btn.matches"
    static let btnDrawing         = "view.harmonicsscreen.btn.drawing"

    // AllHarmonicsView
    static let allHarmonicsTitle  = "view.allharmonicsview.title"
    static let allHarmonicsNoData = "view.allharmonicsview.nodata"
    static let colFactor          = "view.allharmonicsview.col.factor"
    static let colPosition        = "view.allharmonicsview.col.position"

    // HarmonicMatchesView
    static let matchesTitle       = "view.harmonicmatchesview.title"
    static let matchesNoData      = "view.harmonicmatchesview.nodata"
    static let colHarmonicFactor  = "view.harmonicmatchesview.col.harmonicfactor"
    static let colRadixFactor     = "view.harmonicmatchesview.col.radixfactor"
    static let colOrb             = "view.harmonicmatchesview.col.orb"
    static let colExactness       = "view.harmonicmatchesview.col.exactness"

    // HarmonicDrawingView
    static let drawingTitle       = "view.harmonicdrawingview.title"
    static let drawingPlaceholder = "view.harmonicdrawingview.placeholder"

    // Help texts
    static let allHarmonicsHelp   = "view.allharmonicsview.help"
    static let matchesHelp        = "view.harmonicmatchesview.help"
    static let drawingHelp        = "view.harmonicdrawingview.help"
}
