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
            nv(NavigationKeys.placeholderTitle),
            systemImage: "sidebar.right",
            description: Text(nv(NavigationKeys.placeholderDescription))
        )
        .padding()
    }
}

private func nv(_ key: String) -> String {
    NSLocalizedString(key, tableName: "Navigation", bundle: .main, comment: "")
}

