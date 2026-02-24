//
//  AppComposition.swift
//  EnigmaApl
//
//  Created by Jan Kampherbeek on 24/02/2026.
//

import SwiftUI
import Combine


@MainActor
final class AppComposition: ObservableObject {
    let app: AppState
    let radixNav: RadixNavigator
    let researchNav: ResearchNavigator
    let cyclesNav: CyclesNavigator

    init(app: AppState) {
        self.app = app

        self.radixNav = RadixNavigator(nav: Binding(
            get: { app.nav.radix },
            set: { app.nav.radix = $0 }
        ))

        self.researchNav = ResearchNavigator(nav: Binding(
            get: { app.nav.research },
            set: { app.nav.research = $0 }
        ))

        self.cyclesNav = CyclesNavigator(nav: Binding(
            get: { app.nav.cycles },
            set: { app.nav.cycles = $0 }
        ))
    }
}
