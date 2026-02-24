//
//  DetailColumn.swift
//  EnigmaApl
//
//  Created by Jan Kampherbeek on 24/02/2026.
//

import SwiftUI
import Combine


// MARK: - Minimal placeholder views (keep your existing implementations)


struct DetailColumn: View {
    @EnvironmentObject private var app: AppState
    var body: some View {
        Text("Detail (\(app.nav.mode.rawValue))")
            .navigationTitle("Detail")
    }
}

