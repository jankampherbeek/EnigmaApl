// HouseSystemKeys.swift
// EnigmaApl is open source. For more information see se_license.html and License, both at the root of the application.
// Created by Jan Kampherbeek 2026

/// Localization keys for HouseSystems enum values.
struct HouseSystemKeys {
    private init() {}

    static let keys: [HouseSystems: String] = [
        .noHouses:        "enum.housesystem.nohouses",
        .placidus:        "enum.housesystem.placidus",
        .koch:            "enum.housesystem.koch",
        .porphyri:        "enum.housesystem.porphyri",
        .regiomontanus:   "enum.housesystem.regiomontanus",
        .campanus:        "enum.housesystem.campanus",
        .alcabitius:      "enum.housesystem.alcabitius",
        .topoCentric:     "enum.housesystem.topocentric",
        .krusinski:       "enum.housesystem.krusinski",
        .apc:             "enum.housesystem.apc",
        .morin:           "enum.housesystem.morin",
        .wholeSign:       "enum.housesystem.whole_sign",
        .equalAsc:        "enum.housesystem.equal_from_ascendant",
        .equalMc:         "enum.housesystem.equal_from_mc",
        .equalAries:      "enum.housesystem.equal_from_0_aries",
        .vehlow:          "enum.housesystem.vehlow",
        .axial:           "enum.housesystem.axial_rotation",
        .horizon:         "enum.housesystem.horizon",
        .carter:          "enum.housesystem.carter",
        .gauquelin:       "enum.housesystem.gauquelin",
        .sunShine:        "enum.housesystem.sunshine",
        .sunShineTreindl: "enum.housesystem.sunshine_treindl",
        .pullenSd:        "enum.housesystem.pullen_sin_diff",
        .pullenSr:        "enum.housesys.pullen_sin_ratio",
        .sripati:         "enum.housesys.sripati",
    ]

    static func key(for system: HouseSystems) -> String {
        keys[system] ?? ""
    }
}
