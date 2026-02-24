//
//  AppShellView.swift
//  EnigmaApl
//
//  Created by Jan Kampherbeek on 14/02/2026.
//

import SwiftUI

struct AppShellView: View {
    @ObservedObject var model: AppShellModel

    var body: some View {
        NavigationSplitView {
            MasterDetailSidebarView(
                features: model.features,
                submenuActions: model.submenuActions,
                selectedFeatureID: model.selectedFeatureID,
                selectedActionID: model.selectedActionID,
                onFeatureTap: model.selectFeature,
                onActionTap: model.selectAction
            )
#if os(macOS)
            .navigationSplitViewColumnWidth(min: 260, ideal: 280)
#endif
        } detail: {
            ResizableDetailSplitView {
                if let customLeft = model.splitContent.customLeft {
                    customLeft
                } else {
                    DummyPaneView(title: model.splitContent.leftTitle, onClose: model.closeCurrentDetail)
                }
            } right: {
                if let customRight = model.splitContent.customRight {
                    customRight
                } else {
                    DummyPaneView(title: model.splitContent.rightTitle, onClose: model.closeCurrentDetail)
                }
            }
        }
    }
}

private struct MasterDetailSidebarView: View {
    let features: [FeatureDescriptor]
    let submenuActions: [FeatureAction]
    let selectedFeatureID: String?
    let selectedActionID: String?
    let onFeatureTap: (String?) -> Void
    let onActionTap: (String?) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Main menu")
                .font(.headline)
                .padding(.horizontal)

            VStack(spacing: 8) {
                ForEach(features) { feature in
                    SidebarButton(
                        title: feature.title,
                        isSelected: selectedFeatureID == feature.id,
                        action: { onFeatureTap(feature.id) }
                    )
                }
            }
            .padding(.horizontal)

            Divider()

            Text("Submenu")
                .font(.headline)
                .padding(.horizontal)

            VStack(spacing: 8) {
                ForEach(submenuActions) { action in
                    SidebarButton(
                        title: action.title,
                        isSelected: selectedActionID == action.id,
                        action: { onActionTap(action.id) }
                    )
                }
            }
            .padding(.horizontal)

            Spacer()
        }
        .padding(.vertical)
        .background(.thinMaterial)
    }
}

private struct SidebarButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack {
                Text(title)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
            .background(isSelected ? Color.accentColor.opacity(0.20) : Color.clear)
            .clipShape(RoundedRectangle(cornerRadius: 8))
        }
        .buttonStyle(.plain)
    }
}

private struct DummyPaneView: View {
    let title: String
    let onClose: () -> Void

    var body: some View {
        VStack(spacing: 20) {
            Text(title)
                .font(.title2)
                .bold()

            Button("Close", action: onClose)
                .buttonStyle(.borderedProminent)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

/// Cross-platform split detail view with a draggable separator.
/// This gives an adjustable split pane for both iOS and macOS.
private struct ResizableDetailSplitView<Left: View, Right: View>: View {
    @ViewBuilder let left: () -> Left
    @ViewBuilder let right: () -> Right

    @State private var leftWidthRatio: CGFloat = 0.50

    private let separatorWidth: CGFloat = 8
    private let minimumPaneWidth: CGFloat = 180

    var body: some View {
        GeometryReader { geometry in
            let availableWidth = max(geometry.size.width - separatorWidth, minimumPaneWidth * 2)
            let proposedLeftWidth = availableWidth * leftWidthRatio
            let clampedLeftWidth = min(max(proposedLeftWidth, minimumPaneWidth), availableWidth - minimumPaneWidth)

            HStack(spacing: 0) {
                left()
                    .frame(width: clampedLeftWidth)

                Rectangle()
                    .fill(Color.secondary.opacity(0.25))
                    .frame(width: separatorWidth)
                    .overlay(
                        Capsule()
                            .fill(Color.secondary.opacity(0.55))
                            .frame(width: 3, height: 56)
                    )
                    .gesture(
                        DragGesture(minimumDistance: 0)
                            .onChanged { gesture in
                                let newWidth = clampedLeftWidth + gesture.translation.width
                                leftWidthRatio = min(max(newWidth / availableWidth, 0.2), 0.8)
                            }
                    )

                right()
                    .frame(maxWidth: .infinity)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
}
