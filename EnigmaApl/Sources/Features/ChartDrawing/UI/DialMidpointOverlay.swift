// DialMidpointOverlay.swift
// EnigmaApl is open source. For more information see se_license.html and License, both at the root of the application.
// Created by Jan Kampherbeek 2026

import SwiftUI

// MARK: - Dial type for angle mapping

enum DialOverlayType {
    case dial360   // plotAngle = eclipticLongitude (mod 360)
    case dial90    // plotAngle = (eclipticLongitude mod 90) * 4
    case dial45    // plotAngle = (eclipticLongitude mod 45) * 8
}

// MARK: - Overlay view

/// Transparent overlay that detects hover and tap on planet glyphs and draws
/// a red opposition line + perpendicular midpoint lines for the selected factor.
struct DialMidpointOverlay: View {
    let plotData:  WheelPlotData
    let dialType:  DialOverlayType
    /// Radius fraction where glyphs are drawn (matches fPlanetGlyph in each canvas).
    var glyphFraction: Double = 0.78

    @State private var hoveredFactor: Factors? = nil
    @State private var pinnedFactor:  Factors? = nil

    /// The factor whose lines are currently shown: pinned takes priority over hover.
    private var activeFactor: Factors? { pinnedFactor ?? hoveredFactor }

    var body: some View {
        GeometryReader { geo in
            let size   = geo.size
            let R      = Double(min(size.width, size.height)) / 2.0
            let center = CGPoint(x: size.width / 2, y: size.height / 2)

            Canvas { ctx, _ in
                guard let factor = activeFactor,
                      let item = plotData.planetItems.first(where: { $0.factor == factor })
                else { return }
                drawOverlay(&ctx, center: center, R: R, selected: item)
            }
            .contentShape(Rectangle())
            // ── Hover (macOS) ──────────────────────────────────────────────
            .onContinuousHover { phase in
                switch phase {
                case .active(let location):
                    hoveredFactor = nearestFactor(to: location, center: center, R: R)
                case .ended:
                    hoveredFactor = nil
                }
            }
            // ── Tap ────────────────────────────────────────────────────────
            .onTapGesture { location in
                let tapped = nearestFactor(to: location, center: center, R: R)
                if tapped == pinnedFactor {
                    pinnedFactor = nil   // second tap on same glyph → clear
                } else {
                    pinnedFactor = tapped
                }
            }
        }
        .aspectRatio(1, contentMode: .fit)
    }

    // MARK: - Drawing

    private func drawOverlay(_ ctx: inout GraphicsContext, center: CGPoint,
                              R: Double, selected: WheelPlotItem) {
        let outerR  = R * glyphFraction           // line starts/ends at glyph ring
        let red     = Color.red
        let stroke  = max(1.0, R * 0.006)

        let selAngle = selected.plotAngle
        let oppAngle = WheelGeometry.normalise(selAngle + 180.0)

        // ── Opposition line: from glyph ring through center to opposite side ──
        let p1 = WheelGeometry.point(angleDeg: selAngle, radius: outerR, center: center)
        let p2 = WheelGeometry.point(angleDeg: oppAngle, radius: outerR, center: center)
        var oppPath = Path()
        oppPath.move(to: p1)
        oppPath.addLine(to: p2)
        ctx.stroke(oppPath, with: .color(red), lineWidth: stroke)

        // ── Midpoint lines: for each pair (B, C) whose midpoint coincides with
        //    the selected factor A, draw a line from glyph B to glyph C. ──
        let pairs = midpointPairs(for: selected, in: plotData)
        for (b, c) in pairs {
            let bp = WheelGeometry.point(angleDeg: b.plotAngle, radius: outerR, center: center)
            let cp = WheelGeometry.point(angleDeg: c.plotAngle, radius: outerR, center: center)
            var mPath = Path()
            mPath.move(to: bp)
            mPath.addLine(to: cp)
            ctx.stroke(mPath, with: .color(red.opacity(0.75)), lineWidth: stroke)
        }
    }

    // MARK: - Midpoint calculation

    /// Returns all pairs (B, C) of factors whose midpoint on the dial coincides
    /// with the selected factor A (within a 1.6° orb on the dial).
    private func midpointPairs(for selected: WheelPlotItem,
                                in data: WheelPlotData) -> [(WheelPlotItem, WheelPlotItem)] {
        var pairs: [(WheelPlotItem, WheelPlotItem)] = []
        let selAngle = selected.plotAngle
        let items    = data.planetItems.filter { $0.factor != selected.factor }

        for i in 0 ..< items.count {
            for j in (i + 1) ..< items.count {
                let b = items[i]
                let c = items[j]
                // Two midpoints of the arc between B and C on the dial
                let diff = WheelGeometry.normalise(c.plotAngle - b.plotAngle)
                let mid1 = WheelGeometry.normalise(b.plotAngle + diff / 2.0)
                let mid2 = WheelGeometry.normalise(mid1 + 180.0)
                if angularDistance(selAngle, mid1) < 1.6 || angularDistance(selAngle, mid2) < 1.6 {
                    pairs.append((b, c))
                }
            }
        }
        return pairs
    }

    private func angularDistance(_ a: Double, _ b: Double) -> Double {
        let d = abs(WheelGeometry.normalise(a - b))
        return min(d, 360.0 - d)
    }

    // MARK: - Hit testing

    private let hitRadius: Double = 20.0   // pixels

    private func nearestFactor(to location: CGPoint, center: CGPoint, R: Double) -> Factors? {
        let glyphR = R * glyphFraction
        var best: (factor: Factors, dist: Double)? = nil

        for item in plotData.planetItems {
            let pt   = WheelGeometry.point(angleDeg: item.plotAngle, radius: glyphR, center: center)
            let dx   = Double(location.x - pt.x)
            let dy   = Double(location.y - pt.y)
            let dist = sqrt(dx * dx + dy * dy)
            if dist < hitRadius {
                if best == nil || dist < best!.dist {
                    best = (item.factor, dist)
                }
            }
        }
        return best?.factor
    }
}
