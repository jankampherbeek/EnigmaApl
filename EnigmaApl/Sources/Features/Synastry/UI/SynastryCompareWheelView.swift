// SynastryCompareWheelView.swift
// EnigmaApl is open source. For more information see se_license.html and License, both at the root of the application.
// Created by Jan Kampherbeek 2026

import SwiftUI
import SwiftData

private func t(_ key: String) -> String {
    NSLocalizedString(key, tableName: "Synastry", bundle: .main, comment: "")
}

/// Dual wheel for a synastry chart comparison: the inner wheel is one person's
/// radix chart, the outer ring shows the other person's positions (same drawing
/// logic as the transit/progression dual wheel). The two can be swapped.
struct SynastryCompareWheelView: View {
    let first: NamedChart
    let second: NamedChart

    @Query(filter: #Predicate<UserConfiguration> { $0.isActive == true })
    private var activeConfigs: [UserConfiguration]

    @State private var swapped = false
    @State private var blackWhite = false
    @State private var hideAspects = false
    @State private var showExport = false

    private var inner: NamedChart { swapped ? second : first }
    private var outer: NamedChart { swapped ? first : second }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            namesRow
            wheelControls
            dualWheelCanvas
        }
        .sheet(isPresented: $showExport) {
            WheelExportSheet(wheelView: dualWheelCanvas)
        }
    }

    // MARK: - Controls

    private var wheelControls: some View {
        HStack(spacing: 8) {
            Button { blackWhite.toggle() } label: {
                Image(systemName: blackWhite ? "circle.lefthalf.filled" : "paintpalette")
            }
            .buttonStyle(.bordered)
            .accessibilityLabel(blackWhite ? "Switch to color" : "Switch to black and white")

            Button { hideAspects.toggle() } label: {
                Image(systemName: "angle")
                    .foregroundStyle(hideAspects ? .secondary : .primary)
            }
            .buttonStyle(.bordered)
            .accessibilityLabel(hideAspects ? "Show aspects" : "Hide aspects")

            Button { showExport = true } label: {
                Image(systemName: "square.and.arrow.up")
            }
            .buttonStyle(.bordered)
            .accessibilityLabel("Export")
        }
    }

    private var dualWheelCanvas: DualWheelCanvas {
        DualWheelCanvas(
            radixData: WheelPlotDataBuilder.build(from: inner.chart, config: activeConfigs.first),
            transitItems: outerItems,
            theme: blackWhite ? .blackWhite : .color,
            showAspects: !hideAspects,
            transitCuspAngles: outerCuspAngles,
            transitAscAngle: outerAscAngle,
            transitMcAngle: outerMcAngle
        )
    }

    private var namesRow: some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 2) {
                Text(t(SynastryKeys.compareInnerLabel))
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Text(inner.name)
                    .font(.headline)
            }

            Button { swapped.toggle() } label: {
                Image(systemName: "arrow.left.arrow.right.circle")
            }
            .buttonStyle(.bordered)
            .accessibilityLabel(t(SynastryKeys.compareSwap))

            VStack(alignment: .leading, spacing: 2) {
                Text(t(SynastryKeys.compareOuterLabel))
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Text(outer.name)
                    .font(.headline)
            }
        }
    }

    private var outerCuspAngles: [Double] {
        let ascLong = inner.chart.HousePositions.ascendant.longitude
        return outer.chart.HousePositions.cusps.map {
            WheelGeometry.mundaneAngle(longitude: $0.longitude, ascendantLongitude: ascLong)
        }
    }

    private var outerAscAngle: Double {
        let ascLong = inner.chart.HousePositions.ascendant.longitude
        return WheelGeometry.mundaneAngle(longitude: outer.chart.HousePositions.ascendant.longitude, ascendantLongitude: ascLong)
    }

    private var outerMcAngle: Double {
        let ascLong = inner.chart.HousePositions.ascendant.longitude
        return WheelGeometry.mundaneAngle(longitude: outer.chart.HousePositions.midheaven.longitude, ascendantLongitude: ascLong)
    }

    private var outerItems: [WheelPlotItem] {
        let ascLong = inner.chart.HousePositions.ascendant.longitude
        var items: [WheelPlotItem] = []
        for (factor, position) in outer.chart.Coordinates {
            guard factor.calculationType != .Mundane,
                  factor.calculationType != .Unknown,
                  !outer.chart.omittedFactors.contains(factor),
                  FactorDisplaySelector.shouldDraw(factor),
                  let eclPos = position.ecliptical.first?.mainPos else { continue }

            let mundane = WheelGeometry.mundaneAngle(longitude: eclPos, ascendantLongitude: ascLong)
            items.append(WheelPlotItem(
                factor: factor,
                glyph: GlyphSelector.getGlyphForFactor(factor),
                eclipticLongitude: eclPos,
                mundaneAngle: mundane,
                plotAngle: mundane,
                positionText: cuspPositionText(longitude: eclPos),
                speedType: .direct
            ))
        }
        return GlyphOverlapResolver.resolve(items)
    }
}
