// FactorKeys.swift
// EnigmaApl is open source. For more information see se_license.html and License, both at the root of the application.
// Created by Jan Kampherbeek 2026

/// Localization keys for Factors enum values.
struct FactorKeys {
    private init() {}

    static let keys: [Factors: String] = [
        .sun:                "enum.factor.sun",
        .moon:               "enum.factor.moon",
        .mercury:            "enum.factor.mercury",
        .venus:              "enum.factor.venus",
        .earth:              "enum.factor.earth",
        .mars:               "enum.factor.mars",
        .jupiter:            "enum.factor.jupiter",
        .saturn:             "enum.factor.saturn",
        .uranus:             "enum.factor.uranus",
        .neptune:            "enum.factor.neptune",
        .pluto:              "enum.factor.pluto",
        .northNode:          "enum.factor.northnode",
        .chiron:             "enum.factor.chiron",
        .persephoneRam:      "enum.factor.persephoneram",
        .hermesRam:          "enum.factor.hermesram",
        .demeterRam:         "enum.factor.demeterram",
        .cupidoUra:          "enum.factor.cupidoura",
        .hadesUra:           "enum.factor.hadesura",
        .zeusUra:            "enum.factor.zeusura",
        .kronosUra:          "enum.factor.kronosura",
        .apollonUra:         "enum.factor.apollonura",
        .admetosUra:         "enum.factor.admetosura",
        .vulcanusUra:        "enum.factor.vulcanusura",
        .poseidonUra:        "enum.factor.poseidonura",
        .eris:               "enum.factor.eris",
        .pholus:             "enum.factor.pholus",
        .ceres:              "enum.factor.ceres",
        .pallas:             "enum.factor.pallas",
        .juno:               "enum.factor.juno",
        .vesta:              "enum.factor.vesta",
        .isis:               "enum.factor.isis",
        .nessus:             "enum.factor.nessus",
        .huya:               "enum.factor.huya",
        .varuna:             "enum.factor.varuna",
        .ixion:              "enum.factor.ixion",
        .quaoar:             "enum.factor.quaoar",
        .haumea:             "enum.factor.haumea",
        .orcus:              "enum.factor.orcus",
        .makemake:           "enum.factor.makemake",
        .sedna:              "enum.factor.sedna",
        .hygieia:            "enum.factor.hygieia",
        .astraea:            "enum.factor.astraea",
        .apogeeMean:         "enum.factor.apogeemean",
        .apogeeCorrected:    "enum.factor.apogeecorrected",
        .apogeeInterpolated: "enum.factor.apogeeinterpolated",
        .persephoneCarteret: "enum.factor.persephonecarteret",
        .vulcanusCarteret:   "enum.factor.vulcanuscarteret",
        .perigeeInterpolated:"enum.factor.perigeeinterpolated",
        .priapus:            "enum.factor.priapus",
        .priapusCorrected:   "enum.factor.priapuscorrected",
        .dragon:             "enum.factor.dragon",
        .beast:              "enum.factor.beast",
        .southNode:          "enum.factor.southnode",
        .blackSun:           "enum.factor.blacksun",
        .diamond:            "enum.factor.diamond",
        .ascendant:          "enum.factor.ascendant",
        .mc:                 "enum.factor.mc",
        .eastPoint:          "enum.factor.eastpoint",
        .vertex:             "enum.factor.vertex",
        .zeroAries:          "enum.factor.zeroaries",
        .parsfortuna:        "enum.factor.parsfortuna",
    ]

    static func key(for factor: Factors) -> String {
        keys[factor] ?? ""
    }
}
