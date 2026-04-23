// InquiriesKeys.swift
// EnigmaApl is open source. For more information see se_license.html and License, both at the root of the application.
// Created by Jan Kampherbeek 2026

/// Localization keys for Inquiries enum values.
struct InquiriesKeys {
    private init() {}

    static let nameKeys: [Inquiries: String] = [
        .factorsInSigns:  "enum.inquiries.factorsinsigns.name",
        .factorsInHouses: "enum.inquiries.factorsinhouses.name",
        .aspects:         "enum.inquiries.aspects.name",
        .unaspect:        "enum.inquiries.unaspect.name",
        .midpoints:       "enum.inquiries.midpoints.name",
        .harmonics:       "enum.inquiries.harmonics.name",
        .parallels:       "enum.inquiries.parallels.name",
        .declMidpoints:   "enum.inquiries.declmidpoints.name",
        .oob:             "enum.inquiries.oob.name",
    ]

    static let descriptionKeys: [Inquiries: String] = [
        .factorsInSigns:  "enum.inquiries.factorsinsigns.description",
        .factorsInHouses: "enum.inquiries.factorsinhouses.description",
        .aspects:         "enum.inquiries.aspects.description",
        .unaspect:        "enum.inquiries.unaspect.description",
        .midpoints:       "enum.inquiries.midpoints.description",
        .harmonics:       "enum.inquiries.harmonics.description",
        .parallels:       "enum.inquiries.parallels.description",
        .declMidpoints:   "enum.inquiries.declmidpoints.description",
        .oob:             "enum.inquiries.oob.description",
    ]

    static func nameKey(for inquiry: Inquiries) -> String {
        nameKeys[inquiry] ?? ""
    }

    static func descriptionKey(for inquiry: Inquiries) -> String {
        descriptionKeys[inquiry] ?? ""
    }
}
