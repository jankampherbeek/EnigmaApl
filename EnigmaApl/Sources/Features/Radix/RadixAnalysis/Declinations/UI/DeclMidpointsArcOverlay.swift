// DeclMidpointsArcOverlay.swift
// EnigmaApl is open source. For more information see se_license.html and License, both at the root of the application.
// Created by Jan Kampherbeek 2026
//
// Transparent overlay for the declination midpoints arc canvas.
// Detects hover / tap on factor glyphs and draws:
//   - A red line from the selected glyph through the circle center to the opposite point.
//   - For each pair (B, C) whose declination midpoint coincides with the selected factor,
//     a semi-transparent red perpendicular line connecting glyph B to glyph C.
//
// Mirrors DialMidpointOverlay but uses linear declination arithmetic instead of circular.

import SwiftUI

struct DeclMidpointsArcOverlay: View {
    let items:   [DeclMidpointsArcItem]
    let orbConfig: OrbConfig

    @State private var hoveredFactor: Factors? = nil
    @State private var pinnedFactor:  Factors? = nil

    private var activeFactor: Factors? { pinnedFactor ?? hoveredFactor }

    var body: some View {
        GeometryReader { geo in
            let size   = geo.size
            let geoArc = ArcCanvasGeometry(size: size)
            let R      = geoArc.R
            let center = geoArc.center

            Canvas { ctx, _ in
                guard let factor = activeFactor,
                      let selected = items.first(where: { $0.factor == factor })
                else { return }
                drawOverlay(&ctx, center: center, R: R, selected: selected)
            }
            .contentShape(Rectangle())
            .onContinuousHover { phase in
                switch phase {
                case .active(let loc):
                    hoveredFactor = nearestFactor(to: loc, center: center, R: R)
                case .ended:
                    hoveredFactor = nil
                }
            }
            .onTapGesture { loc in
                let tapped = nearestFactor(to: loc, center: center, R: R)
                if tapped == pinnedFactor { pinnedFactor = nil }
                else { pinnedFactor = tapped }
            }
        }
        .aspectRatio(ArcLayout.arcAspectRatio, contentMode: .fit)
    }

    // MARK: - Drawing

    private func drawOverlay(_ ctx: inout GraphicsContext, center: CGPoint,
                              R: Double, selected: DeclMidpointsArcItem) {
        let glyphR = R * ArcLayout.fPlanetGlyph
        let red    = Color.red
        let stroke = max(1.0, R * 0.006)

        // Opposition line: from glyph point through center to opposite point
        let selAngle = selected.visualAngle
        let oppAngle = WheelGeometry.normalise(selAngle + 180.0)
        let p1 = WheelGeometry.point(angleDeg: selAngle, radius: glyphR, center: center)
        let p2 = WheelGeometry.point(angleDeg: oppAngle, radius: glyphR, center: center)
        var oppPath = Path()
        oppPath.move(to: p1)
        oppPath.addLine(to: p2)
        ctx.stroke(oppPath, with: .color(red), lineWidth: stroke)

        // Midpoint pair lines: for each (B, C) whose midpoint coincides with A,
        // draw a line from glyph B to glyph C.
        let orb   = orbConfig.declinationMidpointOrb
        let pairs = midpointPairs(for: selected, orb: orb)
        for (b, c) in pairs {
            let bp = WheelGeometry.point(angleDeg: b.visualAngle, radius: glyphR, center: center)
            let cp = WheelGeometry.point(angleDeg: c.visualAngle, radius: glyphR, center: center)
            var mPath = Path()
            mPath.move(to: bp)
            mPath.addLine(to: cp)
            ctx.stroke(mPath, with: .color(red.opacity(0.75)), lineWidth: stroke)
        }
    }

    // MARK: - Midpoint pair detection

    /// Returns all pairs (B, C) from items (excluding A) whose declination midpoint
    /// coincides with the selected factor A within the configured orb.
    /// Declination midpoints use linear arithmetic — no circular reduction needed.
    private func midpointPairs(for selected: DeclMidpointsArcItem,
                                orb: Double) -> [(DeclMidpointsArcItem, DeclMidpointsArcItem)] {
        let others = items.filter { $0.factor != selected.factor }
        var pairs: [(DeclMidpointsArcItem, DeclMidpointsArcItem)] = []
        for i in 0 ..< others.count {
            for j in (i + 1) ..< others.count {
                let b = others[i]
                let c = others[j]
                let midDecl = (b.declination + c.declination) / 2.0
                if abs(selected.declination - midDecl) <= orb {
                    pairs.append((b, c))
                }
            }
        }
        return pairs
    }

    // MARK: - Hit testing

    private let hitRadius: Double = 20.0

    private func nearestFactor(to location: CGPoint, center: CGPoint, R: Double) -> Factors? {
        let glyphR = R * ArcLayout.fPlanetGlyph
        var best: (factor: Factors, dist: Double)? = nil
        for item in items {
            let pt   = WheelGeometry.point(angleDeg: item.visualAngle, radius: glyphR, center: center)
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
