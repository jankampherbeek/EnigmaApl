//
//  UserConfigurationRepository.swift
//  EnigmaApl
//

import SwiftData
import Foundation

enum UserConfigurationRepositoryError: Error {
    /// Thrown when no active configuration exists.
    case noActiveConfiguration
    /// Thrown when trying to delete the active configuration.
    case cannotDeleteActiveConfiguration
    /// Thrown when trying to delete the only remaining configuration.
    case cannotDeleteOnlyConfiguration
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

    // MARK: - Update

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
    /// Throws when the configuration is the only one or is currently active.
    func delete(_ config: UserConfiguration) throws {
        let all = try fetchAll()
        guard all.count > 1 else {
            throw UserConfigurationRepositoryError.cannotDeleteOnlyConfiguration
        }
        guard !config.isActive else {
            throw UserConfigurationRepositoryError.cannotDeleteActiveConfiguration
        }
        context.delete(config)
        try context.save()
    }
}
