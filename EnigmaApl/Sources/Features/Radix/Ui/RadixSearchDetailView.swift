//
//  RadixSearchDetailView.swift
//  EnigmaApl
//
//  Created by Jan Kampherbeek on 14/02/2026.
//
import SwiftUI

/// Right pane for results list + selected item details.
struct RadixSearchDetailView: View {
    @ObservedObject var viewModel: RadixSearchViewModel
    let onClose: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Search Details")
                .font(.title2)
                .bold()

            List(selection: $viewModel.selectedItemID) {
                ForEach(viewModel.results) { item in
                    VStack(alignment: .leading, spacing: 2) {
                        Text(item.name)
                        Text("\(item.category) • score \(item.score)")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    .tag(item.id)
                }
            }
            .frame(minHeight: 180)

            GroupBox("Selected") {
                if let item = viewModel.selectedItem {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Name: \(item.name)")
                        Text("Category: \(item.category)")
                        Text("Score: \(item.score)")
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                } else {
                    Text("No selection")
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
            }

            HStack {
                Spacer()
                Button("Close", action: onClose)
                    .buttonStyle(.bordered)
            }
        }
        .padding(20)
        .onAppear {
            viewModel.selectFirstIfNeeded()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }
}

