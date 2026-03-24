// WheelPlotData.swift
// EnigmaApl
//
// The fully prepared, draw-ready data for a chart wheel.
// Built by WheelPlotDataBuilder from a FullChart.

import Foundation
import SwiftUI

/// A single aspect line ready to be drawn inside the aspect circle.
struct WheelAspectItem {
    let angle1: Double     // mundane angle of the first factor
    let angle2: Double     // mundane angle of the second factor
    let color: Color       // from AspectSettings
    let exactness: Double  // 1.0 = exact, 0.0 = at orb edge — drives line width
    let aspect: Aspects    // aspect type, used by ring wheel for major/minor distinction
}

/// A single planet/factor ready to be drawn on the wheel.
struct WheelPlotItem {
    let factor: Factors
    let glyph: String               // from GlyphSelector
    let eclipticLongitude: Double   // exact ecliptic position (for connect line + position text)
    let mundaneAngle: Double        // angle on wheel (longitude - ascLong + 90), used for connect line endpoint
    var plotAngle: Double           // visual angle after anti-overlap adjustment
    let positionText: String        // e.g. "15°23'"
}

/// All data needed to draw a complete chart wheel.
struct WheelPlotData {
    let ascendantLongitude: Double  // for wheel rotation
    let mcLongitude: Double
    let cuspLongitudes: [Double]    // 12 cusps
    let planetItems: [WheelPlotItem]
    let hasTime: Bool               // false = no houses, no ASC/MC shown
    let aspectItems: [WheelAspectItem]

    /// An empty plot (nothing loaded yet).
    static let empty = WheelPlotData(
        ascendantLongitude: 0,
        mcLongitude: 0,
        cuspLongitudes: [],
        planetItems: [],
        hasTime: false,
        aspectItems: []
    )
}
