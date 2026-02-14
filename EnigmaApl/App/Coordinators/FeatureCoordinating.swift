//
//  FeatureCoordinating.swift
//  EnigmaApl
//
//  Created by Jan Kampherbeek on 14/02/2026.
//
import Foundation

/// Contract implemented by each feature coordinator.
/// A feature decides its own submenu actions and content behavior.
protocol FeatureCoordinating {
    var descriptor: FeatureDescriptor { get }
    func start() -> FeatureSession
}

