// BlaSchemaKeys.swift
// EnigmaApl is open source. For more information see se_license.html and License, both at the root of the application.
// Created by Jan Kampherbeek 2026

/// Localization keys for the BLA schema ("Invisible Luminaries Astrology") screens, resolved from BlaSchema.strings.
struct BlaSchemaKeys {
    private init() {}

    // Screen / navigation
    static let title = "view.blaschemascreen.title"
    static let noChart = "view.blaschemascreen.nochart"
    static let help = "view.blaschemascreen.help"
    static let explanation = "view.blaschemascreen.explanation"
    static let headerTitleFormat = "view.blaschemascreen.headertitle.format"

    // Sections
    static let sectionConfigPositions = "view.blaschemascreen.section.configpositions"
    static let sectionCounts = "view.blaschemascreen.section.counts"
    static let sectionDispositors = "view.blaschemascreen.section.dispositors"
    static let sectionDetailsCycles = "view.blaschemascreen.section.detailscycles"
    static let sectionReinforcements = "view.blaschemascreen.section.reinforcements"
    static let sectionReceptions = "view.blaschemascreen.section.receptions"

    // Config controls
    static let configHouseSystem = "view.blaschemascreen.config.housesystem"
    static let configUseChiron = "view.blaschemascreen.config.usechiron"
    static let configUseCeres = "view.blaschemascreen.config.useceres"
    static let configUseDecanates = "view.blaschemascreen.config.usedecanates"
    static let configBlackMoonCorrectionType = "view.blaschemascreen.config.blackmooncorrectiontype"

    // Positions
    static let positionsTitle = "view.blaschemascreen.positions.title"
    static let housePositionsTitle = "view.blaschemascreen.positions.houses.title"

    // Shared column headers
    static let colPosition = "view.blaschemascreen.col.position"
    static let colHouse = "view.blaschemascreen.col.house"
    static let colCusp = "view.blaschemascreen.col.cusp"
    static let colName = "view.blaschemascreen.col.name"
    static let colSign = "view.blaschemascreen.col.sign"
    static let colSum = "view.blaschemascreen.col.sum"
    static let colHCusp = "view.blaschemascreen.col.hcusp"
    static let colTotal = "view.blaschemascreen.col.total"
    static let colRulers = "view.blaschemascreen.col.rulers"
    static let colSplit = "view.blaschemascreen.col.split"
    static let colIndirect = "view.blaschemascreen.col.indirect"
    static let colDecanate = "view.blaschemascreen.col.decanate"

    // Counts
    static let elementsTitle = "view.blaschemascreen.counts.elements.title"
    static let crossesTitle = "view.blaschemascreen.counts.crosses.title"
    static let quadrantsTitle = "view.blaschemascreen.counts.quadrants.title"
    static let elementsChartTitle = "view.blaschemascreen.counts.elements.chart.title"
    static let crossesChartTitle = "view.blaschemascreen.counts.crosses.chart.title"
    static let quadrantLabelFormat = "view.blaschemascreen.quadrant.label.format"
    static let decanatesTitle = "view.blaschemascreen.counts.decanates.title"
    static let quadrantsChartTitle = "view.blaschemascreen.counts.quadrants.chart.title"
    static let decanatesChartTitle = "view.blaschemascreen.counts.decanates.chart.title"

    // Cross/element group names
    static let groupCardinal = "view.blaschemascreen.group.cardinal"
    static let groupFixed = "view.blaschemascreen.group.fixed"
    static let groupMutable = "view.blaschemascreen.group.mutable"
    static let groupFire = "view.blaschemascreen.group.fire"
    static let groupEarth = "view.blaschemascreen.group.earth"
    static let groupAir = "view.blaschemascreen.group.air"
    static let groupWater = "view.blaschemascreen.group.water"

    // Dispositors
    static let dispositorsTitle = "view.blaschemascreen.dispositors.title"

    // Details
    static let detailsTitle = "view.blaschemascreen.details.title"
    static let detailSisterSignAsc = "view.blaschemascreen.detail.sistersignasc"
    static let detailClampedHouses = "view.blaschemascreen.detail.clampedhouses"
    static let detailInterceptedSigns = "view.blaschemascreen.detail.interceptedsigns"
    static let detailGroundNote = "view.blaschemascreen.detail.groundnote"
    static let detailLordAscInHouses = "view.blaschemascreen.detail.lordascinhouses"
    static let detailMoonInHouse = "view.blaschemascreen.detail.mooninhouse"

    // Cycles
    static let cyclesTitle = "view.blaschemascreen.cycles.title"
    static let shortenedCyclesTitle = "view.blaschemascreen.cycles.shortened.title"

    // Reinforcements
    static let ownSignTitle = "view.blaschemascreen.reinforcements.ownsign.title"
    static let ownHouseTitle = "view.blaschemascreen.reinforcements.ownhouse.title"
    static let ownMundaneHouseTitle = "view.blaschemascreen.reinforcements.ownmundanehouse.title"
    static let lordAnalogSignTitle = "view.blaschemascreen.reinforcements.lordanalogsign.title"
    static let pairsTitle = "view.blaschemascreen.reinforcements.pairs.title"
    static let connectorIn = "view.blaschemascreen.reinforcements.connector.in"

    // Receptions
    static let receptionsInSignsTitle = "view.blaschemascreen.receptions.insigns.title"
    static let receptionsInHousesTitle = "view.blaschemascreen.receptions.inhouses.title"
    static let receptionsInMundaneHousesTitle = "view.blaschemascreen.receptions.inmundanehouses.title"
}
