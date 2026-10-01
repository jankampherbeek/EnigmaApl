// UserConfigurationRepository.swift
// EnigmaApl is open source. For more information see se_license.html and License, both at the root of the application.
// Created by Jan Kampherbeek 2026

import SwiftData
import Foundation

enum UserConfigurationRepositoryError: Error {
    /// Thrown when no active configuration exists.
    case noActiveConfiguration
    /// Thrown when trying to delete the active configuration.
    case cannotDeleteActiveConfiguration
    /// Thrown when trying to delete the only remaining configuration.
    case cannotDeleteOnlyConfiguration
    /// Thrown when trying to delete the standard configuration.
    case cannotDeleteStandardConfiguration
}

@MainActor
final class UserConfigurationRepository {

    private let context: ModelContext

    init(context: ModelContext) {
        self.context = context
    }

    // MARK: - Create

    /// Creates a new configuration with default sub-configs.
    /// If it is the first configuration, it is automatically set as active.
    @discardableResult
    func add(name: String) throws -> UserConfiguration {
        let config = UserConfiguration(name: name)
        context.insert(config)
        if try fetchAll().count == 1 {
            config.isActive = true
        }
        try context.save()
        return config
    }

    /// Creates the standard configuration. It is active and cannot be deleted.
    @discardableResult
    func addStandard(name: String) throws -> UserConfiguration {
        let config = UserConfiguration(name: name, isActive: true, isStandard: true)
        context.insert(config)
        try context.save()
        return config
    }

    // MARK: - Read

    func fetchAll() throws -> [UserConfiguration] {
        let descriptor = FetchDescriptor<UserConfiguration>(
            sortBy: [SortDescriptor(\.name)]
        )
        return try context.fetch(descriptor)
    }

    func fetchActive() throws -> UserConfiguration? {
        let descriptor = FetchDescriptor<UserConfiguration>(
            predicate: #Predicate { $0.isActive == true }
        )
        return try context.fetch(descriptor).first
    }

    func fetchStandard() throws -> UserConfiguration? {
        let descriptor = FetchDescriptor<UserConfiguration>(
            predicate: #Predicate { $0.isStandard == true }
        )
        return try context.fetch(descriptor).first
    }

    // MARK: - Update

    /// Marks the standard configuration in stores created before the standard flag existed:
    /// the configuration with one of the given names (the localized names of the standard configuration).
    func markStandardIfNeeded(standardNames: Set<String>) throws {
        guard try fetchStandard() == nil else { return }
        guard let standard = try fetchAll().first(where: { standardNames.contains($0.name) }) else { return }
        standard.isStandard = true
        try context.save()
    }

    /// Resets all settings of a configuration to their default values.
    func restoreDefaults(_ config: UserConfiguration) throws {
        config.restoreDefaults()
        try context.save()
    }

    /// Saves any pending changes made to a configuration object.
    func update(_ config: UserConfiguration) throws {
        try context.save()
    }

    /// Sets the given configuration as the active one.
    /// All other configurations are deactivated.
    func setActive(_ config: UserConfiguration) throws {
        let all = try fetchAll()
        all.forEach { $0.isActive = false }
        config.isActive = true
        try context.save()
    }

    // MARK: - Delete

    /// Deletes a configuration.
    /// When the active configuration is deleted, the standard configuration becomes active.
    /// Throws when the configuration is the standard one or the only one, or when it is active
    /// and there is no standard configuration to take over.
    func delete(_ config: UserConfiguration) throws {
        guard config.isStandard != true else {
            throw UserConfigurationRepositoryError.cannotDeleteStandardConfiguration
        }
        let all = try fetchAll()
        guard all.count > 1 else {
            throw UserConfigurationRepositoryError.cannotDeleteOnlyConfiguration
        }
        if config.isActive {
            guard let standard = all.first(where: { $0.isStandard == true }) else {
                throw UserConfigurationRepositoryError.cannotDeleteActiveConfiguration
            }
            config.isActive = false
            standard.isActive = true
        }
        context.delete(config)
        try context.save()
    }
}
