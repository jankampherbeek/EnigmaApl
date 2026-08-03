// HarmonicOrbSetting.swift
// EnigmaApl is open source. For more information see se_license.html and License, both at the root of the application.
// Created by Jan Kampherbeek 2026

import Foundation

/// A single aspect entry for the Harmonic Orbs feature: its harmonic divisor and whether it is
/// currently selected for inclusion in the chart drawing.
struct HarmonicOrbSetting: Identifiable {
    let aspect: Aspects
    let harmonicNumber: Int
    var isSelected: Bool

    var id: Aspects { aspect }

    /// The 20 aspects supported by Harmonic Orbs, in display order, each with its harmonic divisor.
    static let defaults: [HarmonicOrbSetting] = [
        HarmonicOrbSetting(aspect: .conjunction,    harmonicNumber: 1,  isSelected: true),
        HarmonicOrbSetting(aspect: .opposition,     harmonicNumber: 2,  isSelected: true),
        HarmonicOrbSetting(aspect: .trine,          harmonicNumber: 3,  isSelected: true),
        HarmonicOrbSetting(aspect: .square,         harmonicNumber: 4,  isSelected: true),
        HarmonicOrbSetting(aspect: .quintile,       harmonicNumber: 5,  isSelected: true),
        HarmonicOrbSetting(aspect: .biquintile,     harmonicNumber: 5,  isSelected: true),
        HarmonicOrbSetting(aspect: .sextile,        harmonicNumber: 6,  isSelected: true),
        HarmonicOrbSetting(aspect: .septile,        harmonicNumber: 7,  isSelected: true),
        HarmonicOrbSetting(aspect: .biseptile,      harmonicNumber: 7,  isSelected: true),
        HarmonicOrbSetting(aspect: .triseptile,     harmonicNumber: 7,  isSelected: true),
        HarmonicOrbSetting(aspect: .semisquare,     harmonicNumber: 8,  isSelected: true),
        HarmonicOrbSetting(aspect: .sesquiquadrate, harmonicNumber: 8,  isSelected: true),
        HarmonicOrbSetting(aspect: .novile,         harmonicNumber: 9,  isSelected: true),
        HarmonicOrbSetting(aspect: .binovile,       harmonicNumber: 9,  isSelected: true),
        HarmonicOrbSetting(aspect: .quadranovile,   harmonicNumber: 9,  isSelected: true),
        HarmonicOrbSetting(aspect: .semiquintile,   harmonicNumber: 10, isSelected: true),
        HarmonicOrbSetting(aspect: .tridecile,      harmonicNumber: 10, isSelected: true),
        HarmonicOrbSetting(aspect: .undecile,       harmonicNumber: 11, isSelected: true),
        HarmonicOrbSetting(aspect: .semisextile,    harmonicNumber: 12, isSelected: true),
        HarmonicOrbSetting(aspect: .inconjunct,     harmonicNumber: 12, isSelected: true),
    ]
}
