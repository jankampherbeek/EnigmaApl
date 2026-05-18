// FactorCycleSpecTests.swift
// EnigmaApl is open source. For more information see se_license.html and License, both at the root of the application.
// Created by Jan Kampherbeek 2026

import Testing
@testable import EnigmaApl

struct FactorCycleSpecTests {

    // MARK: - Moon group (interval 0.1, maxPeriod 2_000)

    @Test("FactorCycleSpec: Moon has interval 0.1")
    func testMoon_interval() {
        #expect(Factors.moon.cycleSpec?.interval == 0.1)
    }

    @Test("FactorCycleSpec: Moon has maxPeriod 2_000")
    func testMoon_maxPeriod() {
        #expect(Factors.moon.cycleSpec?.maxPeriod == 2_000)
    }

    // MARK: - Sun group (interval 1, maxPeriod 20_000)
    // Members: sun, earth, mercury, venus, mars, pallas, juno, vesta, apogeeMean

    @Test("FactorCycleSpec: Sun has interval 1")
    func testSun_interval() {
        #expect(Factors.sun.cycleSpec?.interval == 1)
    }

    @Test("FactorCycleSpec: Sun has maxPeriod 20_000")
    func testSun_maxPeriod() {
        #expect(Factors.sun.cycleSpec?.maxPeriod == 20_000)
    }

    @Test("FactorCycleSpec: Mars has interval 1 and maxPeriod 20_000")
    func testMars_spec() {
        #expect(Factors.mars.cycleSpec?.interval == 1)
        #expect(Factors.mars.cycleSpec?.maxPeriod == 20_000)
    }

    @Test("FactorCycleSpec: Pallas has interval 1 and maxPeriod 20_000")
    func testPallas_spec() {
        #expect(Factors.pallas.cycleSpec?.interval == 1)
        #expect(Factors.pallas.cycleSpec?.maxPeriod == 20_000)
    }

    @Test("FactorCycleSpec: ApogeeMean has interval 1 and maxPeriod 20_000")
    func testApogeeMean_spec() {
        #expect(Factors.apogeeMean.cycleSpec?.interval == 1)
        #expect(Factors.apogeeMean.cycleSpec?.maxPeriod == 20_000)
    }

    // MARK: - Jupiter group (interval 5, maxPeriod 200_000)
    // Members: jupiter, saturn, ceres

    @Test("FactorCycleSpec: Jupiter has interval 5")
    func testJupiter_interval() {
        #expect(Factors.jupiter.cycleSpec?.interval == 5)
    }

    @Test("FactorCycleSpec: Jupiter has maxPeriod 200_000")
    func testJupiter_maxPeriod() {
        #expect(Factors.jupiter.cycleSpec?.maxPeriod == 200_000)
    }

    @Test("FactorCycleSpec: Saturn has interval 5 and maxPeriod 200_000")
    func testSaturn_spec() {
        #expect(Factors.saturn.cycleSpec?.interval == 5)
        #expect(Factors.saturn.cycleSpec?.maxPeriod == 200_000)
    }

    @Test("FactorCycleSpec: Ceres has interval 5 and maxPeriod 200_000")
    func testCeres_spec() {
        #expect(Factors.ceres.cycleSpec?.interval == 5)
        #expect(Factors.ceres.cycleSpec?.maxPeriod == 200_000)
    }

    // MARK: - Uranus group (interval 10, maxPeriod 750_000)
    // Members: uranus, neptune, pluto

    @Test("FactorCycleSpec: Uranus has interval 10")
    func testUranus_interval() {
        #expect(Factors.uranus.cycleSpec?.interval == 10)
    }

    @Test("FactorCycleSpec: Uranus has maxPeriod 750_000")
    func testUranus_maxPeriod() {
        #expect(Factors.uranus.cycleSpec?.maxPeriod == 750_000)
    }

    @Test("FactorCycleSpec: Neptune has interval 10 and maxPeriod 750_000")
    func testNeptune_spec() {
        #expect(Factors.neptune.cycleSpec?.interval == 10)
        #expect(Factors.neptune.cycleSpec?.maxPeriod == 750_000)
    }

    @Test("FactorCycleSpec: Pluto has interval 10 and maxPeriod 750_000")
    func testPluto_spec() {
        #expect(Factors.pluto.cycleSpec?.interval == 10)
        #expect(Factors.pluto.cycleSpec?.maxPeriod == 750_000)
    }

    // MARK: - Node / centaur group (interval 10, maxPeriod 200_000)
    // Members: northNode, southNode, chiron, pholus, nessus, huya

    @Test("FactorCycleSpec: NorthNode has interval 10")
    func testNorthNode_interval() {
        #expect(Factors.northNode.cycleSpec?.interval == 10)
    }

    @Test("FactorCycleSpec: NorthNode has maxPeriod 200_000")
    func testNorthNode_maxPeriod() {
        #expect(Factors.northNode.cycleSpec?.maxPeriod == 200_000)
    }

    @Test("FactorCycleSpec: Chiron has interval 10 and maxPeriod 200_000")
    func testChiron_spec() {
        #expect(Factors.chiron.cycleSpec?.interval == 10)
        #expect(Factors.chiron.cycleSpec?.maxPeriod == 200_000)
    }

    @Test("FactorCycleSpec: Huya has interval 10 and maxPeriod 200_000")
    func testHuya_spec() {
        #expect(Factors.huya.cycleSpec?.interval == 10)
        #expect(Factors.huya.cycleSpec?.maxPeriod == 200_000)
    }

    // MARK: - Unsupported factors (must return nil)

    @Test("FactorCycleSpec: Priapus returns nil")
    func testPriapus_isNil() {
        #expect(Factors.priapus.cycleSpec == nil)
    }

    @Test("FactorCycleSpec: PriapusCorrected returns nil")
    func testPriapusCorrected_isNil() {
        #expect(Factors.priapusCorrected.cycleSpec == nil)
    }

    @Test("FactorCycleSpec: Dragon returns nil")
    func testDragon_isNil() {
        #expect(Factors.dragon.cycleSpec == nil)
    }

    @Test("FactorCycleSpec: Beast returns nil")
    func testBeast_isNil() {
        #expect(Factors.beast.cycleSpec == nil)
    }

    @Test("FactorCycleSpec: Diamond returns nil")
    func testDiamond_isNil() {
        #expect(Factors.diamond.cycleSpec == nil)
    }

    @Test("FactorCycleSpec: Ascendant returns nil")
    func testAscendant_isNil() {
        #expect(Factors.ascendant.cycleSpec == nil)
    }

    @Test("FactorCycleSpec: MC returns nil")
    func testMC_isNil() {
        #expect(Factors.mc.cycleSpec == nil)
    }

    @Test("FactorCycleSpec: EastPoint returns nil")
    func testEastPoint_isNil() {
        #expect(Factors.eastPoint.cycleSpec == nil)
    }

    @Test("FactorCycleSpec: Vertex returns nil")
    func testVertex_isNil() {
        #expect(Factors.vertex.cycleSpec == nil)
    }

    @Test("FactorCycleSpec: ZeroAries returns nil")
    func testZeroAries_isNil() {
        #expect(Factors.zeroAries.cycleSpec == nil)
    }

    @Test("FactorCycleSpec: ParsFortuna returns nil")
    func testParsFortuna_isNil() {
        #expect(Factors.parsfortuna.cycleSpec == nil)
    }

    // MARK: - Structural invariants

    @Test("FactorCycleSpec: all non-nil specs have a positive interval")
    func testAllNonNilSpecs_havePositiveInterval() {
        let supported: [Factors] = [
            .moon,
            .sun, .earth, .mercury, .venus, .mars, .pallas, .juno, .vesta, .apogeeMean,
            .jupiter, .saturn, .ceres,
            .uranus, .neptune, .pluto,
            .northNode, .southNode, .chiron, .pholus, .nessus, .huya
        ]
        for factor in supported {
            if let spec = factor.cycleSpec {
                #expect(spec.interval > 0, "\(factor) has non-positive interval \(spec.interval)")
            }
        }
    }

    @Test("FactorCycleSpec: all non-nil specs have a positive maxPeriod")
    func testAllNonNilSpecs_havePositiveMaxPeriod() {
        let supported: [Factors] = [
            .moon,
            .sun, .earth, .mercury, .venus, .mars, .pallas, .juno, .vesta, .apogeeMean,
            .jupiter, .saturn, .ceres,
            .uranus, .neptune, .pluto,
            .northNode, .southNode, .chiron, .pholus, .nessus, .huya
        ]
        for factor in supported {
            if let spec = factor.cycleSpec {
                #expect(spec.maxPeriod > 0, "\(factor) has non-positive maxPeriod \(spec.maxPeriod)")
            }
        }
    }
}
