// ResearchProjectDaoTests.swift
// EnigmaApl is open source. For more information see se_license.html and License, both at the root of the application.
// Created by Jan Kampherbeek 2026

import Testing
import SwiftData
import Foundation
@testable import EnigmaApl

@MainActor
struct ResearchProjectDaoTests {

    // MARK: - Helpers

    private func makeDao() throws -> ResearchProjectDao {
        let schema = Schema([ResearchProjectModel.self])
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: schema, configurations: config)
        return ResearchProjectDao(context: ModelContext(container))
    }

    private func addSample(
        to dao: ResearchProjectDao,
        id: Int = 1,
        name: String = "Project Alpha",
        description: String = "A test project",
        enquiry: Inquiries = .factorsInSigns,
        config: String = "{}",
        cgMultiplication: Int = 1,
        path: String = "/tmp/alpha"
    ) throws -> ResearchProjectModel {
        try dao.add(
            id: id,
            name: name,
            projectDescription: description,
            enquiry: enquiry,
            config: config,
            cgMultiplication: cgMultiplication,
            path: path
        )
    }

    // MARK: - add

    @Test("add: stores a project with the correct name")
    func testAddStoresName() throws {
        let dao = try makeDao()
        let project = try addSample(to: dao, name: "Project Alpha")
        #expect(project.name == "Project Alpha")
    }

    @Test("add: stores the correct enquiry raw value")
    func testAddStoresEnquiry() throws {
        let dao = try makeDao()
        let project = try addSample(to: dao, enquiry: .aspects)
        #expect(project.enquiry == Inquiries.aspects.rawValue)
    }

    @Test("add: stores all fields correctly")
    func testAddStoresAllFields() throws {
        let dao = try makeDao()
        let date = Date()
        let project = try dao.add(
            id: 42,
            name: "Full Project",
            projectDescription: "Full description",
            enquiry: .midpoints,
            config: "{\"key\":\"value\"}",
            cgMultiplication: 3,
            path: "/data/full",
            creationDate: date
        )
        #expect(project.id == 42)
        #expect(project.projectDescription == "Full description")
        #expect(project.cgMultiplication == 3)
        #expect(project.path == "/data/full")
        #expect(project.config == "{\"key\":\"value\"}")
        #expect(project.creationDate == date)
    }

    @Test("add: throws duplicateId when the same id is added twice")
    func testAddDuplicateIdThrows() throws {
        let dao = try makeDao()
        try addSample(to: dao, id: 1)
        #expect(throws: ResearchProjectDaoError.duplicateId) {
            try addSample(to: dao, id: 1, name: "Other")
        }
    }

    @Test("add: allows two projects with different ids")
    func testAddDifferentIds() throws {
        let dao = try makeDao()
        try addSample(to: dao, id: 1, name: "Alpha")
        try addSample(to: dao, id: 2, name: "Beta")
        let all = try dao.fetchAll()
        #expect(all.count == 2)
    }

    // MARK: - fetchAllNames

    @Test("fetchAllNames: returns all names sorted alphabetically")
    func testFetchAllNamesSorted() throws {
        let dao = try makeDao()
        try addSample(to: dao, id: 1, name: "Zeta")
        try addSample(to: dao, id: 2, name: "Alpha")
        try addSample(to: dao, id: 3, name: "Mu")
        let names = try dao.fetchAllNames()
        #expect(names == ["Alpha", "Mu", "Zeta"])
    }

    @Test("fetchAllNames: returns empty array when no projects exist")
    func testFetchAllNamesEmpty() throws {
        let dao = try makeDao()
        let names = try dao.fetchAllNames()
        #expect(names.isEmpty)
    }

    // MARK: - fetchAll

    @Test("fetchAll: returns all projects sorted by name")
    func testFetchAllSortedByName() throws {
        let dao = try makeDao()
        try addSample(to: dao, id: 1, name: "Zeta")
        try addSample(to: dao, id: 2, name: "Alpha")
        let all = try dao.fetchAll()
        #expect(all.map(\.name) == ["Alpha", "Zeta"])
    }

    @Test("fetchAll: returns empty array when no projects exist")
    func testFetchAllEmpty() throws {
        let dao = try makeDao()
        #expect(try dao.fetchAll().isEmpty)
    }

    // MARK: - fetch(byName:)

    @Test("fetch(byName:): returns the matching project")
    func testFetchByNameFound() throws {
        let dao = try makeDao()
        try addSample(to: dao, id: 1, name: "Alpha")
        let result = try dao.fetch(byName: "Alpha")
        #expect(result?.name == "Alpha")
    }

    @Test("fetch(byName:): returns nil when name does not exist")
    func testFetchByNameNotFound() throws {
        let dao = try makeDao()
        try addSample(to: dao, id: 1, name: "Alpha")
        let result = try dao.fetch(byName: "Nonexistent")
        #expect(result == nil)
    }

    @Test("fetch(byName:): returns correct project when multiple exist")
    func testFetchByNameCorrectProject() throws {
        let dao = try makeDao()
        try addSample(to: dao, id: 1, name: "Alpha", enquiry: .factorsInSigns)
        try addSample(to: dao, id: 2, name: "Beta", enquiry: .aspects)
        let result = try dao.fetch(byName: "Beta")
        #expect(result?.inquiryType == .aspects)
    }

    // MARK: - delete

    @Test("delete: removes the project from the store")
    func testDeleteRemovesProject() throws {
        let dao = try makeDao()
        let project = try addSample(to: dao, id: 1, name: "Alpha")
        try dao.delete(project)
        #expect(try dao.fetchAll().isEmpty)
    }

    @Test("delete: removes only the specified project")
    func testDeleteRemovesOnlyTarget() throws {
        let dao = try makeDao()
        let alpha = try addSample(to: dao, id: 1, name: "Alpha")
        try addSample(to: dao, id: 2, name: "Beta")
        try dao.delete(alpha)
        let remaining = try dao.fetchAll()
        #expect(remaining.count == 1)
        #expect(remaining.first?.name == "Beta")
    }

    // MARK: - inquiryType

    @Test("inquiryType: returns correct enum value for stored raw value")
    func testInquiryType() throws {
        let dao = try makeDao()
        let project = try addSample(to: dao, enquiry: .harmonics)
        #expect(project.inquiryType == .harmonics)
    }
}
