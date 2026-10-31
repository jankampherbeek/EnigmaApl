// AnalysisGroup.swift
// EnigmaApl is open source. For more information see se_license.html and License, both at the root of the application.
// Created by Jan Kampherbeek 2026

// Single definition of the analysis items and their grouping.
// Used by AnalysisScreen (content column) and by the Analysis menu in the menu bar, so both stay identical.

enum AnalysisGroup: String, CaseIterable, Identifiable {
    case general
    case harmonics
    case zodiac
    case schemas
    case stars

    var id: String { rawValue }

    /// Key in RadixAnalysis.strings.
    var rbKey: String {
        switch self {
        case .general:   return RadixAnalysisKeys.groupGeneral
        case .harmonics: return RadixAnalysisKeys.groupHarmonics
        case .zodiac:    return RadixAnalysisKeys.groupZodiac
        case .schemas:   return RadixAnalysisKeys.groupSchemas
        case .stars:     return RadixAnalysisKeys.groupStars
        }
    }

    var items: [RadixInspector] {
        switch self {
        case .general:   return [.analysisAspects, .analysisMidpoints, .analysisDeclinations, .analysisLots]
        case .harmonics: return [.analysisHarmonics, .analysisHarmonicExactAspects, .analysisHarmonicOrbs]
        case .zodiac:    return [.analysisZodiacDivisions, .analysisAltZodiacStart]
        case .schemas:   return [.analysisEnneagram, .analysisVsp, .analysisBlaSchema, .analysisCountings]
        case .stars:     return [.analysisFixStars, .analysisParans]
        }
    }
}

extension RadixInspector {
    /// True for inspectors that are opened from the analysis overview.
    var isAnalysisItem: Bool {
        AnalysisGroup.allCases.contains { $0.items.contains(self) }
    }

    /// Label for the analysis overview and the Analysis menu, key in RadixAnalysis.strings.
    var analysisRbKey: String {
        switch self {
        case .analysisAspects:              return RadixAnalysisKeys.btnAspects
        case .analysisMidpoints:            return RadixAnalysisKeys.btnMidpoints
        case .analysisDeclinations:         return RadixAnalysisKeys.btnDeclinations
        case .analysisLots:                 return RadixAnalysisKeys.btnLots
        case .analysisHarmonics:            return RadixAnalysisKeys.btnHarmonics
        case .analysisHarmonicExactAspects: return RadixAnalysisKeys.btnHarmonicExactAspects
        case .analysisHarmonicOrbs:         return RadixAnalysisKeys.btnHarmonicOrbs
        case .analysisZodiacDivisions:      return RadixAnalysisKeys.btnZodiacDivisions
        case .analysisAltZodiacStart:       return RadixAnalysisKeys.btnAltZodiacStart
        case .analysisEnneagram:            return RadixAnalysisKeys.btnEnneagram
        case .analysisVsp:                  return RadixAnalysisKeys.btnVsp
        case .analysisBlaSchema:            return RadixAnalysisKeys.btnBlaSchema
        case .analysisCountings:            return RadixAnalysisKeys.btnCountings
        case .analysisFixStars:             return RadixAnalysisKeys.btnFixStars
        case .analysisParans:               return RadixAnalysisKeys.btnParans
        default:                            return rbKey
        }
    }
}
