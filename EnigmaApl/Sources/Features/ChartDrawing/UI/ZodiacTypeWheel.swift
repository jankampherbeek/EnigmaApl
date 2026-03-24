// ZodiacTypeWheel.swift
// EnigmaApl
//
// Draws a horoscope wheel using SwiftUI Canvas.
// All coordinates are relative to outerRadius = min(width, height) / 2.
// Angle convention: 0° = top (12 o'clock), increases counter-clockwise.
// Ascendant is placed at 90° (9 o'clock).

import SwiftUI
import SwiftData

struct ZodiacTypeWheel: View {
    let chart: FullChart
    let chartVersion: UUID
    @StateObject private var viewModel = ZodiacTypeWheelModel()
    @Query(filter: #Predicate<UserConfiguration> { $0.isActive == true })
    private var activeConfigs: [UserConfiguration]

    private var activeConfig: UserConfiguration? { activeConfigs.first }

    var body: some View {
        Canvas { ctx, size in
            let outerRadius = Double(min(size.width, size.height)) / 2.0
            let center = CGPoint(x: size.width / 2, y: size.height / 2)
            let data = viewModel.plotData
            let asc = data.ascendantLongitude

            drawCircles(&ctx, center: center, outerRadius: outerRadius)
            drawElementSectors(&ctx, center: center, outerRadius: outerRadius, ascLong: asc)
            drawSignSeparators(&ctx, center: center, outerRadius: outerRadius, ascLong: asc)
            drawSignGlyphs(&ctx, center: center, outerRadius: outerRadius, ascLong: asc)
            drawDegreeLines(&ctx, center: center, outerRadius: outerRadius, ascLong: asc)
            if data.hasTime {
                drawCuspLines(&ctx, center: center, outerRadius: outerRadius, data: data)
                drawCardinalLines(&ctx, center: center, outerRadius: outerRadius, data: data)
                drawCardinalLabels(&ctx, center: center, outerRadius: outerRadius, data: data)
                drawCuspTexts(&ctx, center: center, outerRadius: outerRadius, data: data)
            }
            drawAspectLines(&ctx, center: center, outerRadius: outerRadius, data: data)
            drawPlanetConnectLines(&ctx, center: center, outerRadius: outerRadius, data: data)
            drawPlanetGlyphs(&ctx, center: center, outerRadius: outerRadius, data: data)
            drawPlanetTexts(&ctx, center: center, outerRadius: outerRadius, data: data)
        }
        .aspectRatio(1, contentMode: .fit)
        .onAppear { viewModel.update(from: chart, config: activeConfig) }
        .onChange(of: chartVersion) { viewModel.update(from: chart, config: activeConfig) }
    }
}
