// CalculatorsKeys.swift
// EnigmaApl is open source. For more information see se_license.html and License, both at the root of the application.
// Created by Jan Kampherbeek 2026

struct CalculatorsKeys {
    private init() {}

    // MARK: - CalculatorsScreen
    static let title  = "view.calculators.title"
    static let select = "view.calculators.select"

    // MARK: - Shared date/time fields
    static let date             = "view.calculators.date"
    static let year             = "view.calculators.year"
    static let month            = "view.calculators.month"
    static let day              = "view.calculators.day"
    static let calendarYearCount = "view.calculators.calendaryearcount"
    static let time             = "view.calculators.time"
    static let offsetUT         = "view.calculators.offsetut"
    static let invalidYear      = "view.calculators.validation.invalidyear"

    // MARK: - JulianDayView
    static let jdHelp               = "view.julianday.help"
    static let jdTitle              = "view.julianday.title"
    static let jdDateTimeToJd       = "view.julianday.datetimetojd"
    static let jdCalcButton         = "view.julianday.calcbutton"
    static let jdResultJd           = "view.julianday.result.jd"
    static let jdResultDeltaT       = "view.julianday.result.deltat"
    static let jdToDateTime         = "view.julianday.todatetime"
    static let jdInput              = "view.julianday.input"
    static let jdCalcDateTimeButton = "view.julianday.calcdatetimebutton"
    static let jdResultDate         = "view.julianday.result.date"
    static let jdResultTime         = "view.julianday.result.time"

    // MARK: - ObliquityView
    static let oblHelp           = "view.obliquity.help"
    static let oblTitle          = "view.obliquity.title"
    static let oblDateTimeSection = "view.obliquity.datetimesection"
    static let oblCalcButton     = "view.obliquity.calcbutton"
    static let oblResultMean     = "view.obliquity.result.mean"
    static let oblResultTrue     = "view.obliquity.result.true"
}
