// ResearchProjectDao.swift
// EnigmaApl is open source. For more information see se_license.html and License, both at the root of the application.
// Created by Jan Kampherbeek 2026

import SwiftData
import Foundation

enum ResearchProjectDaoError: Error {
    case notFound
    case duplicateId
}

@MainActor
struct ResearchProjectDao {

    private let context: ModelContext

    init(context: ModelContext) {
        self.context = context
    }

    /// Returns the names of all research projects, sorted alphabetically.
    func fetchAllNames() throws -> [String] {
        let descriptor = FetchDescriptor<ResearchProjectModel>(
            sortBy: [SortDescriptor(\.name)]
        )
        return try context.fetch(descriptor).map(\.name)
    }

    /// Returns all research projects, sorted alphabetically by name.
    func fetchAll() throws -> [ResearchProjectModel] {
        let descriptor = FetchDescriptor<ResearchProjectModel>(
            sortBy: [SortDescriptor(\.name)]
        )
        return try context.fetch(descriptor)
    }

    /// Returns the research project with the given name, or nil if not found.
    func fetch(byName name: String) throws -> ResearchProjectModel? {
        let descriptor = FetchDescriptor<ResearchProjectModel>(
            predicate: #Predicate { $0.name == name }
        )
        return try context.fetch(descriptor).first
    }

    /// Adds a new research project. Throws ResearchProjectDaoError.duplicateId if the id already exists.
    @discardableResult
    func add(
        id: Int,
        name: String,
        projectDescription: String,
        enquiry: Inquiries,
        config: String,
        cgMultiplication: Int,
        path: String,
        creationDate: Date = Date()
    ) throws -> ResearchProjectModel {
        let existing = FetchDescriptor<ResearchProjectModel>(
            predicate: #Predicate { $0.id == id }
        )
        if let _ = try context.fetch(existing).first {
            throw ResearchProjectDaoError.duplicateId
        }
        let project = ResearchProjectModel(
            id: id,
            name: name,
            projectDescription: projectDescription,
            enquiry: enquiry,
            config: config,
            cgMultiplication: cgMultiplication,
            path: path,
            creationDate: creationDate
        )
        context.insert(project)
        try context.save()
        return project
    }

    /// Deletes the given research project.
    func delete(_ project: ResearchProjectModel) throws {
        context.delete(project)
        try context.save()
    }
}
