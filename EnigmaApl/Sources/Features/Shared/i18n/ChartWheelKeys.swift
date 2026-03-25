// ChartWheelKeys.swift
// EnigmaApl is open source. For more information see se_license.html and License, both at the root of the application.
// Created by Jan Kampherbeek 2026
/// Localization keys for ZodiacTypeWheel and HouseTypeWheel, resolved from ChartWheel.strings.
struct ChartWheelKeys {
    private init() {}

    // MARK: - Wheel toggle buttons
    static let blackWhiteButton  = "view.chartwheel.button.blackwhite"
    static let colorButton       = "view.chartwheel.button.color"
    static let noAspectsButton   = "view.chartwheel.button.noaspects"
    static let showAspectsButton = "view.chartwheel.button.showaspects"
    static let noTimeButton      = "view.chartwheel.button.notime"
    static let withTimeButton    = "view.chartwheel.button.withtime"
    static let exportButton      = "view.chartwheel.button.export"

    // MARK: - Dial type picker
    static let dialType360       = "view.chartwheel.dial.type.360"
    static let dialType90        = "view.chartwheel.dial.type.90"
    static let dialType45        = "view.chartwheel.dial.type.45"

    // MARK: - Help button
    static let helpButton        = "view.chartwheel.button.help"

    // MARK: - Help texts (one per wheel type)
    static let dial360Help       = "view.chartwheel.help.dial360"
    static let dial90Help        = "view.chartwheel.help.dial90"
    static let dial45Help        = "view.chartwheel.help.dial45"
    static let zodiacHelp        = "view.chartwheel.help.zodiac"
    static let houseHelp         = "view.chartwheel.help.house"
    static let frenchHelp        = "view.chartwheel.help.french"
    static let ringHelp          = "view.chartwheel.help.ring"

    // MARK: - Export sheet
    static let exportTitle       = "view.chartwheel.export.title"
    static let exportFormat      = "view.chartwheel.export.format"
    static let exportSave        = "view.chartwheel.export.save"
    static let exportCancel      = "view.chartwheel.export.cancel"
}
