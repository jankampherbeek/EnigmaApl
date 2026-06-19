// MidpointTreeCanvas.swift
// EnigmaApl is open source. For more information see se_license.html and License, both at the root of the application.
// Created by Jan Kampherbeek 2026

import SwiftUI

// MARK: - Layout constants

private let glyphSize: CGFloat = 18
/// Space reserved for one glyph on either side of the stem.
private let glyphW:    CGFloat = 22
/// Fixed width of one tree cell.
private let treeW:     CGFloat = 72
/// Vertical distance between consecutive crossbars.
private let barStep:   CGFloat = 26
/// Vertical space above the stem for the planet glyph.
private let topPad:    CGFloat = 28
/// Half-width of the horizontal crossbar on each side of the stem.
private let barHalf:   CGFloat = 18

// MARK: - Wrapping container

/// Lays out one `SingleMidpointTree` per matching factor, wrapping onto new rows
/// when the available width is exhausted.
struct MidpointTreeCanvas: View {
    let matches: [MidpointMatch]

    var body: some View {
        let grouped = groupedByFactor(matches)
        LazyVGrid(
            columns: [GridItem(.adaptive(minimum: treeW, maximum: treeW), spacing: 12, alignment: .top)],
            alignment: .leading,
            spacing: 12
        ) {
            ForEach(grouped, id: \.0) { factor, pairs in
                SingleMidpointTree(factor: factor, pairs: pairs)
                    .frame(width: treeW, alignment: .top)
            }
        }
    }
}

// MARK: - Single tree

/// Draws one "midpoint tree" using a Canvas:
/// planet glyph at top → vertical stem → crossbars with factor glyphs left/right.
private struct SingleMidpointTree: View {
    let factor: Factors
    let pairs:  [(Factors, Factors)]

    private var treeHeight: CGFloat {
        topPad + CGFloat(pairs.count) * barStep + barStep / 2 + 8
    }

    var body: some View {
        Canvas { ctx, size in
            let stemX    = size.width / 2
            let glyphTop = topPad / 2

            // Planet glyph centred on stem
            drawGlyph(&ctx, text: GlyphSelector.getGlyphForFactor(factor),
                      cx: stemX, cy: glyphTop)

            // Vertical stem
            let stemTop    = topPad
            let stemBottom = topPad + CGFloat(pairs.count) * barStep
            ctx.stroke(
                Path { p in
                    p.move(to: CGPoint(x: stemX, y: stemTop))
                    p.addLine(to: CGPoint(x: stemX, y: stemBottom))
                },
                with: .foreground, lineWidth: 1
            )

            // Crossbars with factor glyphs
            for (i, (f1, f2)) in pairs.enumerated() {
                let barY = topPad + CGFloat(i) * barStep + barStep / 2

                ctx.stroke(
                    Path { p in
                        p.move(to: CGPoint(x: stemX - barHalf, y: barY))
                        p.addLine(to: CGPoint(x: stemX + barHalf, y: barY))
                    },
                    with: .foreground, lineWidth: 1
                )
                drawGlyph(&ctx, text: GlyphSelector.getGlyphForFactor(f1),
                          cx: stemX - barHalf - glyphW / 2, cy: barY)
                drawGlyph(&ctx, text: GlyphSelector.getGlyphForFactor(f2),
                          cx: stemX + barHalf + glyphW / 2, cy: barY)
            }
        }
        .frame(width: treeW, height: treeHeight)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(factor.localizedName)
    }

    private func drawGlyph(_ ctx: inout GraphicsContext, text: String, cx: CGFloat, cy: CGFloat) {
        let resolved = ctx.resolve(
            Text(text).font(.custom("EnigmaAstrology3", size: glyphSize))
        )
        let sz = resolved.measure(in: CGSize(width: 100, height: 100))
        ctx.draw(resolved,
                 at: CGPoint(x: cx - sz.width / 2, y: cy - sz.height / 2),
                 anchor: .topLeading)
    }
}

// MARK: - Grouping helper

/// Groups matches by matchingFactor, preserving order of first appearance
/// and deduplicating factor pairs within each group.
private func groupedByFactor(_ matches: [MidpointMatch]) -> [(Factors, [(Factors, Factors)])] {
    var seen:   [Factors: Set<String>]           = [:]
    var order:  [Factors]                         = []
    var result: [Factors: [(Factors, Factors)]]  = [:]

    for m in matches {
        let pairKey = "\(m.factor1.rawValue)-\(m.factor2.rawValue)"
        if result[m.matchingFactor] == nil {
            order.append(m.matchingFactor)
            result[m.matchingFactor] = []
            seen[m.matchingFactor]   = []
        }
        if seen[m.matchingFactor]!.insert(pairKey).inserted {
            result[m.matchingFactor]!.append((m.factor1, m.factor2))
        }
    }
    return order.map { ($0, result[$0]!) }
}
