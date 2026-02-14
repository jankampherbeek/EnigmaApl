//
//  AppShellViewModel.swift
//  EnigmaApl
//
//  Created by Jan Kampherbeek on 14/02/2026.
//
import Foundation
import Combine

/// ViewModel for the app shell (MVVM). It translates sidebar selection into content state.
@MainActor
final class AppShellViewModel: ObservableObject {
    @Published var selectedFeatureID: String?
    @Published var selectedActionID: String?
    @Published private(set) var submenuActions: [FeatureAction] = []
    @Published private(set) var splitContent: SplitPaneContent = .welcome

    let features: [FeatureDescriptor]

    private let appCoordinator: AppCoordinator
    private var activeSession: FeatureSession?

    init(appCoordinator: AppCoordinator) {
        self.appCoordinator = appCoordinator
        self.features = appCoordinator.descriptors
    }

    func selectFeature(_ featureID: String?) {
        selectedFeatureID = featureID
        selectedActionID = nil

        guard let featureID, let session = appCoordinator.startFeature(with: featureID) else {
            activeSession?.close()
            activeSession = nil
            submenuActions = []
            splitContent = .welcome
            return
        }

        activeSession = session
        submenuActions = session.actions
        splitContent = .welcome
    }

    func selectAction(_ actionID: String?) {
        selectedActionID = actionID

        guard let actionID, let session = activeSession else {
            splitContent = .welcome
            return
        }

        splitContent = session.openAction(actionID, closeCurrentDetail)
    }

    func closeCurrentDetail() {
        selectedActionID = nil
        activeSession?.close()
        splitContent = .welcome
    }
}

