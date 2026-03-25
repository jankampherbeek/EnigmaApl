// AyanamshaKeys.swift
// EnigmaApl is open source. For more information see se_license.html and License, both at the root of the application.
// Created by Jan Kampherbeek 2026

/// Localization keys for Ayanamshas enum values.
struct AyanamshaKeys {
    private init() {}

    static let keys: [Ayanamshas: String] = [
        .tropical:              "enum.ayanamsha.tropical",
        .fagan:                 "enum.ayanamsha.fagan",
        .lahiri:                "enum.ayanamsha.lahiri",
        .deLuce:                "enum.ayanamsha.deluce",
        .raman:                 "enum.ayanamsha.raman",
        .ushaShashi:            "enum.ayanamsha.ushashashi",
        .krishnamurti:          "enum.ayanamsha.krishnamurti",
        .djwhalKhul:            "enum.ayanamsha.djwhalkhul",
        .yukteshwar:            "enum.ayanamsha.yukteshwar",
        .bhasin:                "enum.ayanamsha.bhasin",
        .kugler1:               "enum.ayanamsha.kugler1",
        .kugler2:               "enum.ayanamsha.kugler2",
        .kugler3:               "enum.ayanamsha.kugler3",
        .huber:                 "enum.ayanamsha.huber",
        .etaPiscium:            "enum.ayanamsha.etapiscium",
        .aldebaran15Tau:        "enum.ayanamsha.aldebaran15tau",
        .hipparchus:            "enum.ayanamsha.hipparchus",
        .sassanian:             "enum.ayanamsha.sassanian",
        .galactCtr0Sag:         "enum.ayanamsha.galcent0sag",
        .j2000:                 "enum.ayanamsha.j2000",
        .j1900:                 "enum.ayanamsha.j1900",
        .b1950:                 "enum.ayanamsha.b1950",
        .suryaSiddhanta:        "enum.ayanamsha.suryasiddhanta",
        .suryaSiddhantaMeanSun: "enum.ayanamsha.suryasiddhantameansun",
        .aryabhata:             "enum.ayanamsha.aryabhata",
        .aryabhataMeanSun:      "enum.ayanamsha.aryabhatameansun",
        .ssRevati:              "enum.ayanamsha.ssrevati",
        .ssCitra:               "enum.ayanamsha.sscitra",
        .trueCitra:             "enum.ayanamsha.truecitrapaksha",
        .trueRevati:            "enum.ayanamsha.truerevati",
        .truePushya:            "enum.ayanamsha.truepushya",
        .galacticCtrBrand:      "enum.ayanamsha.galcentbrand",
        .galacticEqIau1958:     "enum.ayanamsha.galcentiau1958",
        .galacticEq:            "enum.ayanamsha.galequator",
        .galacticEqMidMula:     "enum.ayanamsha.galequatormidmula",
        .skydram:               "enum.ayanamsha.skydram",
        .trueMula:              "enum.ayanamsha.truemula",
        .dhruva:                "enum.ayanamsha.dhruva",
        .aryabhata522:          "enum.ayanamsha.aryabhata522",
        .britton:               "enum.ayanamsha.britton",
        .galacticCtrOCap:       "enum.ayanamsha.galcent0cap",
    ]

    static func key(for ayanamsha: Ayanamshas) -> String {
        keys[ayanamsha] ?? ""
    }
}
