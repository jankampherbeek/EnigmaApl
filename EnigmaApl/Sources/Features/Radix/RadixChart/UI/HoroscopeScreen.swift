import SwiftUI

struct HoroscopeScreen: View {
    @EnvironmentObject private var chartSession: ChartSession

    var body: some View {
        if let named = chartSession.selected {
            ZodiacTypeWheel(chart: named.chart, chartVersion: named.version)
                .padding()
        } else {
            ContentUnavailableView(
                "Geen horoscoop",
                systemImage: "circle.dashed",
                description: Text("Bereken of selecteer een horoscoop om de tekening te zien.")
            )
        }
    }
}
