// PreNatalModel.swift
// EnigmaApl is open source. For more information see se_license.html and License, both at the root of the application.
// Created by Jan Kampherbeek 2026

import Foundation
import Combine

@MainActor
final class PreNatalModel: ObservableObject {
    @Published private(set) var moments: [PreNatalMoment] = []
    @Published private(set) var standardConceptionTxt: String = ""
    @Published private(set) var actualConceptionTxt: String = ""
    @Published var isCalculating = false
    @Published var errorMessage: String?
    @Published private(set) var isCombineEnabled: Bool = true
    @Published private(set) var isResetEnabled: Bool = false
    @Published var selectedMomentJD: Double? = nil

    // Type selection
    @Published var useAspects: Bool = true
    @Published var useEclipses: Bool = true
    @Published var useIngresses: Bool = false
    @Published var useRetroDirect: Bool = false

    // Factor and aspect selections
    @Published var selectedFactors: [Factors] = PreNatalOrchestrator.defaultFactors
    @Published var selectedAspects: [Aspects] = PreNatalOrchestrator.defaultAspects

    private(set) var baseConceptionJD: Double = 0
    private var actualConceptionJD: Double = 0

    var hasResults: Bool { !moments.isEmpty }

    func calculate(natalJD: Double) {
        guard !isCalculating else { return }

        let se = SEWrapper()
        baseConceptionJD = natalJD - 273.217
        actualConceptionJD = baseConceptionJD
        standardConceptionTxt = Self.formatDate(baseConceptionJD, se: se)
        actualConceptionTxt = standardConceptionTxt
        isCombineEnabled = true
        isResetEnabled = false

        startCalculation(natalJD: natalJD)
    }

    func combine(natalJD: Double, momentJD: Double, eventJD: Double) {
        guard !isCalculating else { return }
        let corrected = baseConceptionJD + (momentJD - eventJD) / Self.conversionFactor
        actualConceptionJD = corrected
        actualConceptionTxt = Self.formatDate(corrected, se: SEWrapper())
        isCombineEnabled = false
        isResetEnabled = true
        startCalculation(natalJD: natalJD)
    }

    func resetConception(natalJD: Double) {
        guard !isCalculating else { return }
        actualConceptionJD = baseConceptionJD
        actualConceptionTxt = standardConceptionTxt
        isCombineEnabled = true
        isResetEnabled = false
        startCalculation(natalJD: natalJD)
    }

    func updateConceptionDate(natalJD: Double) {
        let se = SEWrapper()
        let base = natalJD - 273.217
        baseConceptionJD = base
        actualConceptionJD = base
        standardConceptionTxt = Self.formatDate(base, se: se)
        actualConceptionTxt = standardConceptionTxt
        isCombineEnabled = true
        isResetEnabled = false
    }

    func clear() {
        moments = []
        errorMessage = nil
        standardConceptionTxt = ""
        actualConceptionTxt = ""
        isCalculating = false
        isCombineEnabled = true
        isResetEnabled = false
    }

    private func startCalculation(natalJD: Double) {
        isCalculating = true
        errorMessage = nil
        moments = []
        selectedMomentJD = nil

        let factors = self.selectedFactors
        let aspects = self.selectedAspects
        let useAsp = self.useAspects
        let useEcl = self.useEclipses
        let useIng = self.useIngresses
        let useRD  = self.useRetroDirect
        let conJD  = self.actualConceptionJD

        Task.detached(priority: .userInitiated) { [natalJD, conJD, factors, aspects, useAsp, useEcl, useIng, useRD] in
            let (resultMoments, _) = PreNatalOrchestrator().calculate(
                natalJD: natalJD,
                conceptionJD: conJD,
                selectedFactors: factors,
                selectedAspects: aspects,
                useAspects: useAsp,
                useEclipses: useEcl,
                useIngresses: useIng,
                useRetroDirect: useRD
            )
            await MainActor.run {
                self.moments = resultMoments
                self.isCalculating = false
                if resultMoments.isEmpty {
                    self.errorMessage = NSLocalizedString(PreNatalKeys.noHits, tableName: "PreNatal", bundle: .main, comment: "")
                }
            }
        }
    }

    private static let conversionFactor = 365.242199074 * (70.0 / 273.217)

    private static func formatDate(_ jd: Double, se: SEWrapper) -> String {
        let dt = se.dateFromJulianDay(jd)
        let sec = min(dt.Time.Second, 59)
        return String(format: "%04d/%02d/%02d %02d:%02d:%02d",
                      dt.Date.Year, dt.Date.Month, dt.Date.Day,
                      dt.Time.Hour, dt.Time.Minute, sec)
    }
}
