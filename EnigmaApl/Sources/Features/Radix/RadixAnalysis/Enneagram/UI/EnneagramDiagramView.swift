// EnneagramDiagramView.swift
// EnigmaApl is open source. For more information see se_license.html and License, both at the root of the application.
// Created by Jan Kampherbeek 2026

import SwiftUI

/// Draws the traditional enneagram figure: 9 numbered circles arranged on a ring,
/// connected by the 3-6-9 triangle and the 1-4-2-8-5-7 hexagon path.
struct EnneagramDiagramView: View {
    let results: [EnneagramTypeResult]

    private func t(_ key: String) -> String {
        NSLocalizedString(key, tableName: "Enneagram", bundle: .main, comment: "")
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text(t(EnneagramKeys.diagramTitle))
                    .font(.title2.weight(.semibold))

                GeometryReader { geo in
                    let size = min(geo.size.width, geo.size.height)
                    EnneagramCanvas(results: results, size: size)
                        .frame(width: size, height: size)
                }
                .frame(maxWidth: 500)
                .aspectRatio(1, contentMode: .fit)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding()
        }
    }
}

// MARK: - Canvas

private struct EnneagramCanvas: View {
    let results: [EnneagramTypeResult]
    let size: CGFloat

    private var center: CGPoint { CGPoint(x: size / 2, y: size / 2) }
    private var ringRadius: CGFloat { size * 0.38 }
    private var circleRadius: CGFloat { size * 0.07 }

    /// Clock-face position (0° = top, clockwise) for each type 1..9.
    private func angle(for type: Int) -> CGFloat {
        CGFloat(type % 9) * (2 * .pi / 9)
    }

    private func point(for type: Int) -> CGPoint {
        let a = angle(for: type)
        return CGPoint(
            x: center.x + ringRadius * sin(a),
            y: center.y - ringRadius * cos(a)
        )
    }

    private func circleColor(for type: Int) -> Color {
        let sorted = results.sorted { $0.strength > $1.strength }
        guard let rank = sorted.firstIndex(where: { $0.type == type }) else { return .accentColor }
        if rank == 0 { return .red }
        if rank <= 2 { return .orange }
        return .accentColor
    }

    var body: some View {
        Canvas { ctx, _ in
            // Outer reference ring (subtle)
            var ring = Path()
            ring.addEllipse(in: CGRect(x: center.x - ringRadius, y: center.y - ringRadius,
                                       width: ringRadius * 2, height: ringRadius * 2))
            ctx.stroke(ring, with: .color(.secondary.opacity(0.15)), lineWidth: 1)

            // Triangle: 3 – 6 – 9
            let triangle = [3, 6, 9]
            drawPath(ctx: ctx, types: triangle + [3])

            // Hexagon path: 1 – 4 – 2 – 8 – 5 – 7 – 1
            let hexPath = [1, 4, 2, 8, 5, 7, 1]
            drawPath(ctx: ctx, types: hexPath)
        }
        .overlay(
            ZStack {
                ForEach(1...9, id: \.self) { t in
                    circleOverlay(for: t)
                }
            }
        )
    }

    private func drawPath(ctx: GraphicsContext, types: [Int]) {
        guard types.count >= 2 else { return }
        var path = Path()
        path.move(to: point(for: types[0]))
        for t in types.dropFirst() { path.addLine(to: point(for: t)) }
        ctx.stroke(path, with: .color(.secondary.opacity(0.5)), lineWidth: 1.5)
    }

    @ViewBuilder
    private func circleOverlay(for type: Int) -> some View {
        let pt = point(for: type)
        let color = circleColor(for: type)
        ZStack {
            Circle()
                .fill(color.opacity(0.15))
                .overlay(Circle().stroke(color, lineWidth: 2))
                .frame(width: circleRadius * 2, height: circleRadius * 2)
            Text("\(type)")
                .font(.system(size: circleRadius * 0.9, weight: .bold))
                .foregroundStyle(color)
        }
        .position(pt)
    }
}
