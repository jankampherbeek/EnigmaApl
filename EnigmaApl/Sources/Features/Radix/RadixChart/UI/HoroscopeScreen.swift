import SwiftUI
import SwiftData

struct HoroscopeScreen: View {
    @EnvironmentObject private var chartSession: ChartSession
    @Query(filter: #Predicate<UserConfiguration> { $0.isActive == true })
    private var activeConfigs: [UserConfiguration]

    private var drawingType: DrawingType {
        activeConfigs.first?.displayConfig.drawingType ?? .signBased
    }

    var body: some View {
        if let named = chartSession.selected {
            wheelView(for: named)
                .padding()
        } else {
            ContentUnavailableView(
                t(RadixChartKeys.noChartTitle),
                systemImage: "circle.dashed",
                description: Text(t(RadixChartKeys.noChartDescription))
            )
        }
    }

    private func t(_ key: String) -> String {
        NSLocalizedString(key, tableName: "RadixChart", bundle: .main, comment: "")
    }

    @ViewBuilder
    private func wheelView(for named: NamedChart) -> some View {
        switch drawingType {
        case .signBased:
            ZodiacTypeWheel(chart: named.chart, chartVersion: named.version)
        case .houseBased:
            HouseTypeWheel(chart: named.chart, chartVersion: named.version)
        case .french:
            FrenchTypeWheel()
        case .ring:
            RingTypeWheel()
        case .dial360:
            Dial360TypeWheel()
        case .dial90:
            Dial90TypeWheel()
        case .dial45:
            Dial45TypeWheel()
        }
    }
}
