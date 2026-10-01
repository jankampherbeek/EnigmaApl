// RadixInspectorKeys.swift
// EnigmaApl is open source. For more information see se_license.html and License, both at the root of the application.
// Created by Jan Kampherbeek 2026

/// Localization keys for RadixInspector enum values.
struct RadixInspectorKeys {
    private init() {}

    static let keys: [RadixInspector: String] = [
        .overview:                 "enum.radixinspector.overview",
        .horoscope:                "enum.radixinspector.horoscope",
        .positions:                "enum.radixinspector.positions",
        .analysis:                 "enum.radixinspector.analysis",
        .analysisAspects:          "enum.radixinspector.analysisaspects",
        .analysisMidpoints:        "enum.radixinspector.analysismidpoints",
        .analysisHarmonics:        "enum.radixinspector.analysisharmonics",
        .analysisDeclinations:     "enum.radixinspector.analysisdeclinations",
        .analysisZodiacDivisions:  "enum.radixinspector.analysiszodiacdivisions",
        .analysisAltZodiacStart:   "enum.radixinspector.analysisaltzodiacstart",
        .analysisEnneagram:        "enum.radixinspector.analysisenneagram",
        .analysisVsp:              "enum.radixinspector.analysisvsp",
        .analysisParans:           "enum.radixinspector.analysisparans",
        .analysisHarmonicOrbs:     "enum.radixinspector.analysisharmonicorbs",
        .analysisLots:             "enum.radixinspector.analysislots",
        .analysisBlaSchema:        "enum.radixinspector.analysisblaschema",
        .analysisCountings:        "enum.radixinspector.analysiscountings",
        .newChart:                 "enum.radixinspector.newchart",
        .search:                   "enum.radixinspector.search",
        .editChart:                "enum.radixinspector.editchart",
    ]

    static func key(for value: RadixInspector) -> String {
        keys[value] ?? ""
    }
}
