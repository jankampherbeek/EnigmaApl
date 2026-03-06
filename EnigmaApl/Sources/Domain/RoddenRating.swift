//
//  RoddenRating.swift
//  EnigmaApl
//
//  Created by Jan Kampherbeek on 06/03/2026.
//

enum RoddenRating: String, CaseIterable, Identifiable {
    case none = "None"
    case aa = "AA"
    case a = "A"
    case b = "B"
    case c = "C"
    case dd = "DD"
    case x = "X"
    case xx = "XX"

    var id: String { rawValue }

    var description: String {
        switch self {
        case .none : return "Unknown"
        case .aa: return "AA - Accurate"
        case .a: return "A - Quoted"
        case .b: return "B - (Auto)biography"
        case .c: return "C - Caution, no source"
        case .dd: return "DD - Dirty Data"
        case .x: return "X - No time of birth"
        case .xx: return "XX - No date of birth"
        }
    }

    var displayText: String { "\(rawValue) - \(description)" }
}


