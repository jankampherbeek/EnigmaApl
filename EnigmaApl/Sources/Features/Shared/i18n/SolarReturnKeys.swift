// SolarReturnKeys.swift
// EnigmaApl is open source. For more information see se_license.html and License, both at the root of the application.
// Created by Jan Kampherbeek 2026

/// Localization keys for SolarInputScreen and SolarResultsScreen, resolved from SolarReturn.strings.
struct SolarReturnKeys {
    private init() {}

    // Input screen
    static let title            = "view.solarreturn.title"
    static let noChart          = "view.solarreturn.nochart"
    static let ageLabel         = "view.solarreturn.age.label"
    static let agePlaceholder   = "view.solarreturn.age.placeholder"
    static let siderealLabel    = "view.solarreturn.sidereal.label"
    static let relocationHeader = "view.solarreturn.relocation.header"
    static let longitudeLabel   = "view.solarreturn.longitude.label"
    static let latitudeLabel    = "view.solarreturn.latitude.label"
    static let east             = "view.solarreturn.direction.east"
    static let west             = "view.solarreturn.direction.west"
    static let north            = "view.solarreturn.direction.north"
    static let south            = "view.solarreturn.direction.south"
    static let calculate        = "view.solarreturn.calculate"
    static let help             = "view.solarreturn.help"

    // Results screen
    static let resultsTitle     = "view.solarreturn.results.title"
    static let noResults        = "view.solarreturn.results.noresults"
    static let tabSolarChart    = "view.solarreturn.tab.solarchart"
    static let tabCombinedChart = "view.solarreturn.tab.combinedchart"
    static let tabPositions     = "view.solarreturn.tab.positions"
    static let tabAspects       = "view.solarreturn.tab.aspects"
    static let tabDetails       = "view.solarreturn.tab.details"

    // Positions table
    static let colLongitude     = "view.solarreturn.col.longitude"
    static let colDeclination   = "view.solarreturn.col.declination"

    // Aspects tab
    static let aspectsNoAspects = "view.solarreturn.aspects.noaspects"
    static let aspectsColSolar  = "view.solarreturn.aspects.col.solar"
    static let aspectsColAspect = "view.solarreturn.aspects.col.aspect"
    static let aspectsColRadix  = "view.solarreturn.aspects.col.radix"
    static let aspectsColOrb    = "view.solarreturn.aspects.col.orb"

    // Details tab
    static let detailsRadixHeader    = "view.solarreturn.details.radix.header"
    static let detailsRadixDate      = "view.solarreturn.details.radix.date"
    static let detailsRadixSun       = "view.solarreturn.details.radix.sun"
    static let detailsSolarHeader    = "view.solarreturn.details.solar.header"
    static let detailsSolarDate      = "view.solarreturn.details.solar.date"
    static let detailsSolarJd        = "view.solarreturn.details.solar.jd"
    static let detailsSolarSun       = "view.solarreturn.details.solar.sun"
    static let detailsSolarLocation  = "view.solarreturn.details.solar.location"
    static let detailsSidereal       = "view.solarreturn.details.sidereal"

    // Help
    static let helpResults      = "view.solarreturn.results.help"
}
