; #FUNCTION# ====================================================================================================================
; Name ..........: MBR GUI Design Tab MOD
; Description ...: This file Includes GUI Design
; Syntax ........:
; Parameters ....: None
; Return values .: None
; Author ........: LunaEclipse(February, 2016)
; Modified ......:
; Remarks .......: This file is part of MyBot, previously known as ClashGameBot. Copyright 2015
;                  MyBot is distributed under the terms of the GNU GPL
; Related .......:
; Link ..........: https://github.com/MyBotRun/MyBot/wiki
; Example .......: No
; ===============================================================================================================================

$tabMOD = GUICtrlCreateTabItem("MOD")
	; SmartZap Settings
	Local $x = 35, $y = 150
    $grpStatsMisc = GUICtrlCreateGroup("SmartZap", $x - 20, $y - 20, 440, 115)
		GUICtrlCreateIcon($pIconLib, $eIcnLightSpell, $x - 10, $y + 20, 24, 24)
		GUICtrlCreateIcon($pIconLib, $eIcnDrill, $x - 10, $y - 7, 24, 24)
		$chkSmartLightSpell = GUICtrlCreateCheckbox("Use Lightning Spells to Zap Drills", $x + 20, $y - 5, -1, -1)
			$txtTip = "Check this to drop Lightning Spells on top of Dark Elixir Drills." & @CRLF & @CRLF & _ 
					  "Remember to go to the tab 'troops' and put the maximum capacity " & @CRLF & _
					  "of your spell factory and the number of spells so that the bot " & @CRLF & _
					  "can function perfectly."
			GUICtrlSetTip(-1, $txtTip)
			GUICtrlSetOnEvent(-1, "chkSmartLightSpell")
			GUICtrlSetState(-1, $GUI_UNCHECKED)
		$chkSmartZapDB = GUICtrlCreateCheckbox("Only Zap Drills in Dead Bases", $x + 20, $y + 21, -1, -1)
			$txtTip = "It is recommended you only zap drills in dead bases as most of the " & @CRLF & _ 
					  "Dark Elixir in a live base will be in the storage."
			GUICtrlSetTip(-1, $txtTip)
			GUICtrlSetOnEvent(-1, "chkSmartZapDB")
			GUICtrlSetState(-1, $GUI_CHECKED)
			GUICtrlSetState(-1, $GUI_DISABLE)
		$lblSmartZap = GUICtrlCreateLabel("Min. amount of Dark Elixir:", $x - 10, $y + 48, 160, -1, $SS_RIGHT)
		$txtMinDark = GUICtrlCreateInput("478", $x + 155, $y + 45, 35, 21, BitOR($GUI_SS_DEFAULT_INPUT, $ES_CENTER, $ES_NUMBER))
		    $txtTip = "The value here depends a lot on what level your Town Hall is, " & @CRLF & _ 
					  "and what level drills you most often see."
			GUICtrlSetTip(-1, $txtTip)
			GUICtrlSetLimit(-1, 4)
			GUICtrlSetOnEvent(-1, "txtMinDark")
			GUICtrlSetState(-1, $GUI_DISABLE)
		$chkSmartZapSaveHeroes = GUICtrlCreateCheckbox("Don't Zap on Town Hall Snipe when Heroes Deployed", $x + 20, $y + 69, -1, -1)
			$txtTip = "This will stop SmartZap from zapping a base on a Town Hall Snipe " & @CRLF & _ 
					  "if your heroes were deployed. " & @CRLF & @CRLF & _
					  "This protects their health so they will be ready for battle sooner!"
			GUICtrlSetTip(-1, $txtTip)
			GUICtrlSetOnEvent(-1, "chkSmartZapSaveHeroes")
			GUICtrlSetState(-1, $GUI_CHECKED)
			GUICtrlSetState(-1, $GUI_DISABLE)
	Local $x = 236, $y = 150
		$picSmartZap = GUICtrlCreateIcon($pIconLib, $eIcnDark, $x + 160, $y + 3, 24, 24)
		$lblSmartZap = GUICtrlCreateLabel("0", $x + 60, $y + 5, 80, 30, $SS_RIGHT)
			GUICtrlSetFont(-1, 16, $FW_BOLD, Default, "arial", $CLEARTYPE_QUALITY)
			GUICtrlSetColor(-1, 0x279B61)
			$txtTip = "Number of dark elixir zapped during the attack with lightning."
			GUICtrlSetTip(-1, $txtTip)
			GUICtrlCreateIcon($pIconLib, $eIcnLightSpell, $x + 160, $y + 40, 24, 24)
		$lblLightningUsed = GUICtrlCreateLabel("0", $x + 60, $y + 40, 80, 30, $SS_RIGHT)
			GUICtrlSetFont(-1, 16, $FW_BOLD, Default, "arial", $CLEARTYPE_QUALITY)
			GUICtrlSetColor(-1, 0x279B61)
			$txtTip = "Amount of used spells."
			GUICtrlSetTip(-1, $txtTip)
	GUICtrlCreateGroup("", -99, -99, 1, 1)

	; Save for Collector Settings
	Local $x = 35, $y = 265
	$grpSaveTroops = GUICtrlCreateGroup("Save Troops for Collectors", $x - 20, $y - 20, 440, 70)
		$chkChangeFF = GUICtrlCreateCheckbox("Use Multi Finger", $x - 10, $y - 5, -1, -1)
			$txtTip = "Change to Multi Finger if less than " & $percentCollectors & "% of collectors near RED LINE." & @CRLF & _
					  "     This will switch to 0 delay for troops for a fast deployment."
			GUICtrlSetTip(-1, $txtTip)
			GUICtrlSetOnEvent(-1, "chkChangeFF")
		$lblChangeFF = GUICtrlCreateLabel("Minimum near Red Line:", $x + 105, $y - 2, 125, -1, $SS_RIGHT)
		$txtPercentCollectors = GUICtrlCreateInput("80", $x + 235, $y - 5, 35, 21, BitOR($GUI_SS_DEFAULT_INPUT, $ES_CENTER, $ES_NUMBER))
			$txtTip = "Suggestions: " & @CRLF & _ 
					  "     Barch lvl. 6 and above use 70%." & @CRLF & _ 
					  "     Barch lvl. 5 use 80%." & @CRLF & _ 
					  "     Barch lvl. 4 and below use 90%."
			GUICtrlSetTip(-1, $txtTip)
			GUICtrlSetLimit(-1, 100)
			GUICtrlSetOnEvent(-1, "txtPercentCollectors")
		$lblChangeFFPercent = GUICtrlCreateLabel("% Collectors.", $x + 275, $y - 2, -1, -1)
		$lblDistance = GUICtrlCreateLabel("Maximum Distance to Redline:", $x - 10, $y + 24, 240, -1, $SS_RIGHT)
		$txtDistance = GUICtrlCreateInput("50", $x + 235, $y + 21, 35, 21, BitOR($GUI_SS_DEFAULT_INPUT, $ES_CENTER, $ES_NUMBER))
			$txtTip = "Maximum number of pixels between the collector and the Redline." & @CRLF & _ 
					  "     Recommended: 50 pixels."
			GUICtrlSetTip(-1, $txtTip)
			GUICtrlSetLimit(-1, 100)
			GUICtrlSetOnEvent(-1, "txtDistance")
		$lblDistancePixels = GUICtrlCreateLabel("pixels.", $x + 275, $y + 24, -1, -1)
	GUICtrlCreateGroup("", -99, -99, 1, 1)
GUICtrlCreateTabItem("")