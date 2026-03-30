// ConfigEditKeys.swift
// EnigmaApl is open source. For more information see se_license.html and License, both at the root of the application.
// Created by Jan Kampherbeek 2026

/// Localization keys for all Config UI screens, resolved from ConfigEdit.strings.
struct ConfigEditKeys {
    private init() {}

    // MARK: - List screen
    static let listTitle              = "view.configedit.list.title"
    static let listActiveBadge        = "view.configedit.list.activebadge"
    static let listNew                = "view.configedit.list.new"
    static let listAlertDeleteTitle   = "view.configedit.list.alert.deletetitle"
    static let listAlertDeleteButton  = "view.configedit.list.alert.deletebutton"
    static let listAlertDeleteMessage = "view.configedit.list.alert.deletemessage"

    // MARK: - New configuration sheet
    static let newSheetTitle          = "view.configedit.new.sheettitle"
    static let newNameLabel           = "view.configedit.new.namelabel"
    static let newNamePlaceholder     = "view.configedit.new.nameplaceholder"
    static let newBasedOn             = "view.configedit.new.basedon"
    static let newBasedOnFooter       = "view.configedit.new.basedonfooter"
    static let newDefaults            = "view.configedit.new.defaults"
    static let newCreate              = "view.configedit.new.create"
    static let defaultConfigName      = "view.configedit.default.configname"

    // MARK: - Edit screen
    static let editNameLabel          = "view.configedit.edit.namelabel"
    static let editSettings           = "view.configedit.edit.settings"
    static let editSave               = "view.configedit.edit.save"
    static let editActiveToggle       = "view.configedit.edit.activetoggle"
    static let editActiveFooter       = "view.configedit.edit.activefooter"
    static let editFallbackTitle      = "view.configedit.edit.fallbacktitle"

    // MARK: - Shared
    static let cancel                 = "view.configedit.cancel"
    static let backToOverview         = "view.configedit.backtoverview"

    // MARK: - Help
    static let helpTitle              = "view.configedit.help.title"
    static let helpClose              = "view.configedit.help.close"
    static let helpTooltip            = "view.configedit.help.tooltip"
    static let helpLine1              = "view.configedit.help.line1"
    static let helpLine2              = "view.configedit.help.line2"

    // MARK: - Empty state
    static let emptyTitle             = "view.configedit.empty.title"
    static let emptyDescription       = "view.configedit.empty.description"

    // MARK: - Calculation editor help
    static let calcHelpTooltip        = "view.configedit.calc.help.tooltip"
    static let calcHelpGroupBox       = "view.configedit.calc.help.groupbox"
    static let calcHelpLine1          = "view.configedit.calc.help.line1"
    static let calcHelpLine2          = "view.configedit.calc.help.line2"
    static let calcHelpLine3          = "view.configedit.calc.help.line3"
    static let calcHelpLine4          = "view.configedit.calc.help.line4"
    static let calcHelpLine5          = "view.configedit.calc.help.line5"
    static let calcHelpLine6          = "view.configedit.calc.help.line6"
    static let calcHelpLine7          = "view.configedit.calc.help.line7"
    static let calcHelpLine8          = "view.configedit.calc.help.line8"

    // MARK: - Calculation editor fields
    static let calcSectionSystems     = "view.configedit.calc.section.systems"
    static let calcSectionCalculation = "view.configedit.calc.section.calculation"
    static let calcSectionLunar       = "view.configedit.calc.section.lunar"
    static let calcSectionSpeeds      = "view.configedit.calc.section.speeds"
    static let calcHouseSystem        = "view.configedit.calc.housesystem"
    static let calcAyanamsha          = "view.configedit.calc.ayanamsha"
    static let calcObserverPosition   = "view.configedit.calc.observerposition"
    static let calcProjectionType     = "view.configedit.calc.projectiontype"
    static let calcBlackMoon          = "view.configedit.calc.blackmooncorrection"
    static let calcLunarNode          = "view.configedit.calc.lunarnode"
    static let calcLotsType           = "view.configedit.calc.lotstype"
    static let calcStationary         = "view.configedit.calc.stationarypercentage"
    static let calcSlow               = "view.configedit.calc.slowpercentage"
    static let calcStationaryFooter   = "view.configedit.calc.stationaryfooter"
    static let calcSlowFooter         = "view.configedit.calc.slowfooter"

    // MARK: - Factor editor columns
    static let factorColUsed           = "view.configedit.factor.col.used"
    static let factorColDrawn          = "view.configedit.factor.col.drawn"
    static let factorColOrb            = "view.configedit.factor.col.orb"
    static let factorRestoreDefaults   = "view.configedit.factor.restoredefaults"

    // MARK: - Factor editor help
    static let factorHelpTooltip       = "view.configedit.factor.help.tooltip"
    static let factorHelpGroupBox      = "view.configedit.factor.help.groupbox"
    static let factorHelpLine1         = "view.configedit.factor.help.line1"
    static let factorHelpLine2         = "view.configedit.factor.help.line2"
    static let factorHelpLine3         = "view.configedit.factor.help.line3"

    // MARK: - Glyphs editor sections
    static let glyphsSectionSigns      = "view.configedit.glyphs.section.signs"
    static let glyphsSectionFactors    = "view.configedit.glyphs.section.factors"
    static let glyphsSectionAspects    = "view.configedit.glyphs.section.aspects"
    static let glyphsRestoreDefaults   = "view.configedit.glyphs.restoredefaults"

    // MARK: - Glyphs editor help
    static let glyphsHelpTooltip       = "view.configedit.glyphs.help.tooltip"
    static let glyphsHelpGroupBox      = "view.configedit.glyphs.help.groupbox"
    static let glyphsHelpLine1         = "view.configedit.glyphs.help.line1"
    static let glyphsHelpLine2         = "view.configedit.glyphs.help.line2"
    static let glyphsHelpLine3         = "view.configedit.glyphs.help.line3"

    // MARK: - Display editor fields
    static let displaySectionDrawing      = "view.configedit.display.section.drawing"
    static let displayDrawingType         = "view.configedit.display.drawingtype"
    static let displaySectionSignColors   = "view.configedit.display.section.signcolors"

    // MARK: - Display editor help
    static let displayHelpTooltip         = "view.configedit.display.help.tooltip"
    static let displayHelpGroupBox        = "view.configedit.display.help.groupbox"
    static let displayHelpLine1           = "view.configedit.display.help.line1"
    static let displayHelpLine2           = "view.configedit.display.help.line2"
    static let displayHelpLine3           = "view.configedit.display.help.line3"
    static let displayHelpLine4           = "view.configedit.display.help.line4"

    // MARK: - Progressions navigation
    static let progNavPrimary          = "view.configedit.prog.nav.primary"
    static let progNavTransits         = "view.configedit.prog.nav.transits"
    static let progNavSecondary        = "view.configedit.prog.nav.secondary"
    static let progNavSymbolic         = "view.configedit.prog.nav.symbolic"
    static let progNavSolar            = "view.configedit.prog.nav.solar"

    // MARK: - Progressions shared section headers
    static let progSectionFactors      = "view.configedit.prog.section.factors"
    static let progSectionOrb          = "view.configedit.prog.section.orb"
    static let progSectionSettings     = "view.configedit.prog.section.settings"
    static let progOrbLabel            = "view.configedit.prog.orb"

    // MARK: - Primary directions fields
    static let progPrimaryPromissors   = "view.configedit.prog.primary.promissors"
    static let progPrimarySignificators = "view.configedit.prog.primary.significators"
    static let progPrimaryMethod       = "view.configedit.prog.primary.method"
    static let progPrimaryApproach     = "view.configedit.prog.primary.approach"
    static let progPrimaryTimeKey      = "view.configedit.prog.primary.timekey"
    static let progPrimaryHelpTooltip  = "view.configedit.prog.primary.help.tooltip"
    static let progPrimaryHelpGroupBox = "view.configedit.prog.primary.help.groupbox"
    static let progPrimaryHelpLine1    = "view.configedit.prog.primary.help.line1"
    static let progPrimaryHelpLine2    = "view.configedit.prog.primary.help.line2"
    static let progPrimaryHelpLine3    = "view.configedit.prog.primary.help.line3"

    // MARK: - Transits help
    static let progTransitsHelpTooltip  = "view.configedit.prog.transits.help.tooltip"
    static let progTransitsHelpGroupBox = "view.configedit.prog.transits.help.groupbox"
    static let progTransitsHelpLine1    = "view.configedit.prog.transits.help.line1"
    static let progTransitsHelpLine2    = "view.configedit.prog.transits.help.line2"

    // MARK: - Secondary directions help
    static let progSecondaryHelpTooltip  = "view.configedit.prog.secondary.help.tooltip"
    static let progSecondaryHelpGroupBox = "view.configedit.prog.secondary.help.groupbox"
    static let progSecondaryHelpLine1    = "view.configedit.prog.secondary.help.line1"
    static let progSecondaryHelpLine2    = "view.configedit.prog.secondary.help.line2"

    // MARK: - Symbolic directions fields
    static let progSymbolicTimeKey      = "view.configedit.prog.symbolic.timekey"
    static let progSymbolicHelpTooltip  = "view.configedit.prog.symbolic.help.tooltip"
    static let progSymbolicHelpGroupBox = "view.configedit.prog.symbolic.help.groupbox"
    static let progSymbolicHelpLine1    = "view.configedit.prog.symbolic.help.line1"
    static let progSymbolicHelpLine2    = "view.configedit.prog.symbolic.help.line2"

    // MARK: - Solar return fields
    static let progSolarMethod          = "view.configedit.prog.solar.method"
    static let progSolarLocation        = "view.configedit.prog.solar.location"
    static let progSolarHelpTooltip     = "view.configedit.prog.solar.help.tooltip"
    static let progSolarHelpGroupBox    = "view.configedit.prog.solar.help.groupbox"
    static let progSolarHelpLine1       = "view.configedit.prog.solar.help.line1"
    static let progSolarHelpLine2       = "view.configedit.prog.solar.help.line2"

    // MARK: - Orb editor fields
    static let orbSectionSystem        = "view.configedit.orb.section.system"
    static let orbSectionValues        = "view.configedit.orb.section.values"
    static let orbSystem               = "view.configedit.orb.system"
    static let orbAspectBase           = "view.configedit.orb.aspectbase"
    static let orbMidpoint360          = "view.configedit.orb.midpoint360"
    static let orbMidpoint90           = "view.configedit.orb.midpoint90"
    static let orbMidpoint45           = "view.configedit.orb.midpoint45"
    static let orbHarmonic             = "view.configedit.orb.harmonic"
    static let orbParallel             = "view.configedit.orb.parallel"

    // MARK: - Orb editor help
    static let orbHelpTooltip          = "view.configedit.orb.help.tooltip"
    static let orbHelpGroupBox         = "view.configedit.orb.help.groupbox"
    static let orbHelpLine1            = "view.configedit.orb.help.line1"
    static let orbHelpLine2            = "view.configedit.orb.help.line2"
    static let orbHelpLine3            = "view.configedit.orb.help.line3"

    // MARK: - Aspect editor columns
    static let aspectColUsed           = "view.configedit.aspect.col.used"
    static let aspectColDrawn          = "view.configedit.aspect.col.drawn"
    static let aspectColOrb            = "view.configedit.aspect.col.orb"
    static let aspectColColor          = "view.configedit.aspect.col.color"
    static let aspectRestoreDefaults   = "view.configedit.aspect.restoredefaults"

    // MARK: - Aspect editor help
    static let aspectHelpTooltip       = "view.configedit.aspect.help.tooltip"
    static let aspectHelpGroupBox      = "view.configedit.aspect.help.groupbox"
    static let aspectHelpLine1         = "view.configedit.aspect.help.line1"
    static let aspectHelpLine2         = "view.configedit.aspect.help.line2"
    static let aspectHelpLine3         = "view.configedit.aspect.help.line3"
    static let aspectHelpLine4         = "view.configedit.aspect.help.line4"

    // MARK: - Config sections
    static let sectionCalculation     = "view.configedit.section.calculation"
    static let sectionDisplay         = "view.configedit.section.display"
    static let sectionGlyphs          = "view.configedit.section.glyphs"
    static let sectionFactors         = "view.configedit.section.factors"
    static let sectionAspects         = "view.configedit.section.aspects"
    static let sectionOrbs            = "view.configedit.section.orbs"
    static let sectionProgressions    = "view.configedit.section.progressions"
}
