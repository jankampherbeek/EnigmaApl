// DefaultLocationTests.swift
// EnigmaApl is open source. For more information see se_license.html and License, both at the root of the application.
// Created by Jan Kampherbeek 2026

import Testing
import Foundation
@testable import EnigmaApl

struct DefaultLocationTests {

    @Test func storeAndReadRoundTrip() {
        let defaults = TestUserDefaults.make()
        let location = DefaultLocation(name: "Enschede", latitude: 52.218055, longitude: 6.895555)

        DefaultLocation.store(location, in: defaults)

        #expect(DefaultLocation.stored(in: defaults) == location)
    }

    @Test func storingNilRemovesTheLocation() {
        let defaults = TestUserDefaults.make()
        DefaultLocation.store(DefaultLocation(name: "Paris", latitude: 48.86, longitude: 2.35), in: defaults)

        DefaultLocation.store(nil, in: defaults)

        #expect(DefaultLocation.stored(in: defaults) == nil)
    }

    @Test func nothingStoredGivesNil() {
        #expect(DefaultLocation.stored(in: TestUserDefaults.make()) == nil)
    }

    @Test func southAndWestAreNegative() {
        let defaults = TestUserDefaults.make()
        let location = DefaultLocation(name: "Buenos Aires", latitude: -34.6, longitude: -58.38)

        DefaultLocation.store(location, in: defaults)

        let stored = DefaultLocation.stored(in: defaults)
        #expect(stored?.latitude == -34.6)
        #expect(stored?.longitude == -58.38)
    }
}
