// PrimDirKeys.swift
// EnigmaApl is open source. For more information see se_license.html and License, both at the root of the application.
// Created by Jan Kampherbeek 2026

struct PrimDirKeys {
    private init() {}

    // MARK: - Input screen
    static let title              = "view.primdir.title"
    static let noChart            = "view.primdir.nochart"
    static let startDateLabel     = "view.primdir.startdate.label"
    static let endDateLabel       = "view.primdir.enddate.label"
    static let datePlaceholder    = "view.primdir.date.placeholder"
    static let settingsHeader       = "view.primdir.settings.header"
    static let settingsOverrideNote = "view.primdir.settings.overridenote"
    static let settingsReset        = "view.primdir.settings.reset"
    static let methodLabel          = "view.primdir.settings.method"
    static let approachLabel        = "view.primdir.settings.approach"
    static let timeKeyLabel         = "view.primdir.settings.timekey"
    static let calculate          = "view.primdir.calculate"
    static let help               = "view.primdir.help"

    // MARK: - Results screen
    static let resultsTitle       = "view.primdir.results.title"
    static let noResults          = "view.primdir.results.noresults"
    static let noHits             = "view.primdir.results.nohits"
    static let colDate            = "view.primdir.results.col.date"
    static let helpResults        = "view.primdir.results.help"

    // MARK: - Validation errors
    static let errorInvalidStartDate = "view.primdir.error.invalidstartdate"
    static let errorInvalidEndDate   = "view.primdir.error.invalidenddate"
    static let errorStartBeforeBirth = "view.primdir.error.startbeforebirth"
    static let errorEndBeforeStart   = "view.primdir.error.endbeforestart"
}
