// ImplicitAspectsTests.swift
// EnigmaApl is open source. For more information see se_license.html and License, both at the root of the application.
// Created by Jan Kampherbeek 2026

import Testing
@testable import EnigmaApl

struct ImplicitAspectsTests {

    @Test("ImplicitAspects: all pairs within nodes, Dragon and Beast are implicit")
    func testNodeGroup() {
        let group: [Factors] = [.northNode, .southNode, .dragon, .beast]
        for f1 in group {
            for f2 in group where f1 != f2 {
                #expect(ImplicitAspects.isImplicit(f1, f2))
            }
        }
    }

    @Test("ImplicitAspects: each Black Moon and its matching Priapus are implicit, in both orders")
    func testBlackMoonPriapus() {
        let pairs: [(Factors, Factors)] = [
            (.apogeeMean, .priapus), (.apogeeKoch, .priapusKoch),
            (.apogeeDuval, .priapusDuval), (.apogeeInterpolated, .priapusInterpolated)
        ]
        for (a, b) in pairs {
            #expect(ImplicitAspects.isImplicit(a, b))
            #expect(ImplicitAspects.isImplicit(b, a))
        }
    }

    @Test("ImplicitAspects: Black Sun and Diamond are implicit")
    func testBlackSunDiamond() {
        #expect(ImplicitAspects.isImplicit(.blackSun, .diamond))
        #expect(ImplicitAspects.isImplicit(.diamond, .blackSun))
    }

    @Test("ImplicitAspects: unrelated or mismatched pairs are not implicit")
    func testNotImplicit() {
        #expect(!ImplicitAspects.isImplicit(.sun, .moon))
        #expect(!ImplicitAspects.isImplicit(.northNode, .moon))
        #expect(!ImplicitAspects.isImplicit(.apogeeMean, .priapusKoch))
        #expect(!ImplicitAspects.isImplicit(.apogeeKoch, .priapus))
        #expect(!ImplicitAspects.isImplicit(.blackSun, .apogeeMean))
        #expect(!ImplicitAspects.isImplicit(.northNode, .northNode))
    }
}
