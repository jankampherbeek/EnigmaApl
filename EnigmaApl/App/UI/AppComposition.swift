//
//  AppComposition.swift
//  EnigmaApl
//
//  Created by Jan Kampherbeek on 24/02/2026.
//

import SwiftUI
import SwiftData
import Combine

// Creates and injects app-level objects (including navigators) as EnvironmentObjects
@MainActor
final class AppComposition: ObservableObject {
    let app: AppState
    let chartSession: ChartSession
    let radixNav: RadixNavigator
    let progressiveNav: ProgressiveNavigator
    let researchNav: ResearchNavigator
    let cyclesNav: CyclesNavigator
    let cyclesModel: AstronomicalCyclesModel
    let wavesModel: WavesModel
    let progressiveSession: ProgressiveSession
    let transitModel: TransitModel
    let secondaryModel: SecondaryModel
    let symbolicModel: SymbolicModel
    let configNav: ConfigNavigator
    let horoscopeRepository: HoroscopeRepository
    let eventRepository: EventRepository

    init(app: AppState) {
        self.app = app
        self.chartSession = ChartSession()
        self.configNav = ConfigNavigator()
        let context = PersistenceController.shared.container.mainContext
        self.horoscopeRepository = HoroscopeRepository(context: context)
        self.eventRepository = EventRepository(context: context)

        self.radixNav = RadixNavigator(nav: Binding(
            get: { app.nav.radix },
            set: { app.nav.radix = $0 }
        ))

        self.progressiveNav = ProgressiveNavigator(nav: Binding(
            get: { app.nav.progressive },
            set: { app.nav.progressive = $0 }
        ))

        self.researchNav = ResearchNavigator(nav: Binding(
            get: { app.nav.research },
            set: { app.nav.research = $0 }
        ))

        self.cyclesNav = CyclesNavigator(nav: Binding(
            get: { app.nav.cycles },
            set: { app.nav.cycles = $0 }
        ))
        self.cyclesModel = AstronomicalCyclesModel()
        self.wavesModel = WavesModel()
        self.progressiveSession = ProgressiveSession()
        self.transitModel = TransitModel()
        self.secondaryModel = SecondaryModel()
        self.symbolicModel = SymbolicModel()
    }
}
