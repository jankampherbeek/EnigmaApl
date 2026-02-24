//
//  TwoColumnDetailPlaceHolder.swift
//  EnigmaApl
//
//  Created by Jan Kampherbeek on 24/02/2026.
//

import SwiftUI
import Combine

struct TwoColumnDetailPlaceholder: View {
    var body: some View {
        ContentUnavailableView(
            "Details in inspector",
            systemImage: "sidebar.right",
            description: Text("Open Details via de knop rechtsboven.")
        )
        .padding()
    }
}
