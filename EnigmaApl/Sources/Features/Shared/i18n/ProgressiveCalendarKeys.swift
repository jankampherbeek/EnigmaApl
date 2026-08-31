// ProgressiveCalendarKeys.swift
// EnigmaApl is open source. For more information see se_license.html and License, both at the root of the application.
// Created by Jan Kampherbeek 2026

struct ProgressiveCalendarKeys {
    private init() {}

    // MARK: - Input screen
    static let title                  = "view.progressivecalendar.title"
    static let noChart                = "view.progressivecalendar.nochart"
    static let techniquesHeader       = "view.progressivecalendar.techniques.header"
    static let useTransits            = "view.progressivecalendar.techniques.transits"
    static let useSecondaryDirections = "view.progressivecalendar.techniques.secondarydirections"
    static let useSymbolicDirections  = "view.progressivecalendar.techniques.symbolicdirections"
    static let symbolicKeyLabel       = "view.progressivecalendar.symbolickey"
    static let transitFactorsButton   = "view.progressivecalendar.button.transitfactors"
    static let secondaryFactorsButton = "view.progressivecalendar.button.secondaryfactors"
    static let symbolicFactorsButton  = "view.progressivecalendar.button.symbolicfactors"
    static let radixFactorsButton     = "view.progressivecalendar.button.radixfactors"
    static let aspectsButton          = "view.progressivecalendar.button.aspects"

    static let eventKindsHeader       = "view.progressivecalendar.eventkinds.header"
    static let useAspectsToRadix      = "view.progressivecalendar.eventkinds.aspectstoradix"
    static let useParallelsToRadix    = "view.progressivecalendar.eventkinds.parallelstoradix"
    static let useAspectsProgToProg   = "view.progressivecalendar.eventkinds.aspectsprogtoprog"
    static let useParallelsProgToProg = "view.progressivecalendar.eventkinds.parallelsprogtoprog"
    static let useCuspConjunctions    = "view.progressivecalendar.eventkinds.cuspconjunctions"
    static let useStations            = "view.progressivecalendar.eventkinds.stations"
    static let useOobEnterExit        = "view.progressivecalendar.eventkinds.oob"
    static let useDeclinationExtremes = "view.progressivecalendar.eventkinds.declinationextremes"

    static let orbsHeader             = "view.progressivecalendar.orbs.header"
    static let aspectOrbLabel         = "view.progressivecalendar.orbs.aspect"
    static let parallelOrbLabel       = "view.progressivecalendar.orbs.parallel"
    static let cuspOrbLabel           = "view.progressivecalendar.orbs.cusp"

    static let dateRangeHeader        = "view.progressivecalendar.daterange.header"
    static let startDateLabel         = "view.progressivecalendar.daterange.start"
    static let endDateLabel           = "view.progressivecalendar.daterange.end"
    static let datePlaceholder        = "view.progressivecalendar.daterange.placeholder"
    static let maxRangeNote           = "view.progressivecalendar.daterange.maxnote"

    static let settingsReset          = "view.progressivecalendar.settings.reset"
    static let calculate              = "view.progressivecalendar.calculate"
    static let help                   = "view.progressivecalendar.help"

    // MARK: - Errors
    static let errorInvalidStartDate  = "view.progressivecalendar.error.invalidstart"
    static let errorInvalidEndDate    = "view.progressivecalendar.error.invalidend"
    static let errorEndBeforeStart    = "view.progressivecalendar.error.endbeforestart"
    static let errorNoTechnique       = "view.progressivecalendar.error.notechnique"
    static let errorRangeTooLong      = "view.progressivecalendar.error.rangetoolong"

    // MARK: - Results status (shown inline on the input screen)
    static let noHits                 = "view.progressivecalendar.nohits"
    static let calculating            = "view.progressivecalendar.calculating"
    static let resultsSummary         = "view.progressivecalendar.results.summary"

    // MARK: - Selection sheets
    // Factor-selection sheet titles reuse the button labels above (transitFactorsButton etc.)
    // since the same sheet is reused for all four factor lists.
    static let aspectSelTitle         = "view.progressivecalendar.aspectsel.title"
    static let selectionDone          = "view.progressivecalendar.selection.done"
    static let selectionCancel        = "view.progressivecalendar.selection.cancel"

    // MARK: - Results screen
    // Technique section headers reuse useTransits/useSecondaryDirections/useSymbolicDirections
    // above (same label text as the input screen's toggles).
    static let resultsTitle           = "view.progressivecalendar.results.title"
    static let noResults              = "view.progressivecalendar.results.noresults"
    static let helpResults            = "view.progressivecalendar.results.help"
    static let sectionDiagram         = "view.progressivecalendar.results.section.diagram"
    static let sectionAspectsParallels = "view.progressivecalendar.results.section.aspectsparallels"
    static let sectionOtherEvents     = "view.progressivecalendar.results.section.otherevents"
    static let colEnter               = "view.progressivecalendar.results.col.enter"
    static let colExact               = "view.progressivecalendar.results.col.exact"
    static let colExit                = "view.progressivecalendar.results.col.exit"
    static let colOrb                 = "view.progressivecalendar.results.col.orb"
    static let colDate                = "view.progressivecalendar.results.col.date"
    static let colPosition            = "view.progressivecalendar.results.col.position"
    static let targetRadix            = "view.progressivecalendar.results.target.radix"
    static let targetProg             = "view.progressivecalendar.results.target.prog"
    static let typeDeclinationNorth   = "view.progressivecalendar.results.type.declnorth"
    static let typeDeclinationSouth   = "view.progressivecalendar.results.type.declsouth"
    static let typeOob                = "view.progressivecalendar.results.type.oob"

    // MARK: - Timeline diagram
    static let diagramSelectedDate    = "view.progressivecalendar.diagram.selecteddate"
}
