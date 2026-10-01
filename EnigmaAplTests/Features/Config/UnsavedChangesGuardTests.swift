// UnsavedChangesGuardTests.swift
// EnigmaApl is open source. For more information see se_license.html and License, both at the root of the application.
// Created by Jan Kampherbeek 2026

import Testing
import Foundation
@testable import EnigmaApl

@MainActor
struct UnsavedChangesGuardTests {

    @Test("perform: runs the action immediately without unsaved changes")
    func testPerformWithoutChanges() {
        let sut = UnsavedChangesGuard()
        var ran = false
        sut.perform { ran = true }
        #expect(ran)
        #expect(sut.pendingAction == nil)
    }

    @Test("perform: holds the action back while there are unsaved changes")
    func testPerformWithChanges() {
        let sut = UnsavedChangesGuard()
        sut.update(UUID(), isDirty: true, save: {}, discard: {})
        var ran = false
        sut.perform { ran = true }
        #expect(!ran)
        #expect(sut.pendingAction != nil)
    }

    @Test("saveAndContinue: saves, then runs the action")
    func testSaveAndContinue() {
        let sut = UnsavedChangesGuard()
        var events: [String] = []
        sut.update(UUID(), isDirty: true, save: { events.append("save") }, discard: { events.append("discard") })
        sut.perform { events.append("action") }
        sut.saveAndContinue()
        #expect(events == ["save", "action"])
        #expect(!sut.hasUnsavedChanges)
        #expect(sut.pendingAction == nil)
    }

    @Test("discardAndContinue: discards, then runs the action")
    func testDiscardAndContinue() {
        let sut = UnsavedChangesGuard()
        var events: [String] = []
        sut.update(UUID(), isDirty: true, save: { events.append("save") }, discard: { events.append("discard") })
        sut.perform { events.append("action") }
        sut.discardAndContinue()
        #expect(events == ["discard", "action"])
    }

    @Test("cancel: neither saves, discards nor runs the action, and keeps the changes")
    func testCancel() {
        let sut = UnsavedChangesGuard()
        var events: [String] = []
        sut.update(UUID(), isDirty: true, save: { events.append("save") }, discard: { events.append("discard") })
        sut.perform { events.append("action") }
        sut.cancel()
        #expect(events.isEmpty)
        #expect(sut.pendingAction == nil)
    }

    @Test("perform(screen:): only considers the given screen")
    func testPerformForScreen() {
        let sut = UnsavedChangesGuard()
        let clean = UUID()
        sut.update(UUID(), isDirty: true, save: {}, discard: {})
        sut.update(clean, isDirty: false, save: {}, discard: {})
        var ran = false
        sut.perform(screen: clean) { ran = true }
        #expect(ran)
    }

    @Test("update: a screen that is no longer dirty no longer blocks navigation")
    func testUpdateClears() {
        let sut = UnsavedChangesGuard()
        let id = UUID()
        sut.update(id, isDirty: true, save: {}, discard: {})
        sut.update(id, isDirty: false, save: {}, discard: {})
        #expect(!sut.hasUnsavedChanges)
    }
}
