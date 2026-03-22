//
//  ConfigEditKeys.swift
//  EnigmaApl
//
//  Created by Jan Kampherbeek on 22/03/2026.
//

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

    // MARK: - Config sections
    static let sectionCalculation     = "view.configedit.section.calculation"
    static let sectionDisplay         = "view.configedit.section.display"
    static let sectionGlyphs          = "view.configedit.section.glyphs"
    static let sectionFactors         = "view.configedit.section.factors"
    static let sectionAspects         = "view.configedit.section.aspects"
    static let sectionOrbs            = "view.configedit.section.orbs"
    static let sectionProgressions    = "view.configedit.section.progressions"
}
