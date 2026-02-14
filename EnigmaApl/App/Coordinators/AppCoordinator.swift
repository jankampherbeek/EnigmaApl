//
//  AppCoordinator.swift
//  EnigmaApl
//
//  Created by Jan Kampherbeek on 14/02/2026.
//
import Foundation

/// Global coordinator that knows how to start a feature, but not how a feature works internally.
final class AppCoordinator {
    private let features: [String: any FeatureCoordinating]
    let descriptors: [FeatureDescriptor]

    init(featureCoordinators: [any FeatureCoordinating]) {
        self.features = Dictionary(uniqueKeysWithValues: featureCoordinators.map { ($0.descriptor.id, $0) })
        self.descriptors = featureCoordinators.map(\.descriptor)
    }

    func startFeature(with id: String) -> FeatureSession? {
        features[id]?.start()
    }
}
