; #FUNCTION# ====================================================================================================================
; Name ..........: MBR GUI Controls Tab MOD
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

Func chkSmartLightSpell()
	If GUICtrlRead($chkSmartLightSpell) = $GUI_CHECKED Then
		GUICtrlSetState($chkSmartZapDB, $GUI_ENABLE)
		GUICtrlSetState($chkSmartZapSaveHeroes, $GUI_ENABLE)
		GUICtrlSetState($txtMinDark, $GUI_ENABLE)
		$ichkSmartZap = 1
	Else
		GUICtrlSetState($chkSmartZapDB, $GUI_DISABLE)
		GUICtrlSetState($chkSmartZapSaveHeroes, $GUI_DISABLE)
		GUICtrlSetState($txtMinDark, $GUI_DISABLE)
		$ichkSmartZap = 0
	EndIf
 EndFunc   ;==>chkSmartLightSpell

Func chkSmartZapDB()
	If GUICtrlRead($chkSmartZapDB) = $GUI_CHECKED Then
		$ichkSmartZapDB = 1
	Else
		$ichkSmartZapDB = 0
	EndIf
 EndFunc   ;==>chkSmartZapDB

Func chkSmartZapSaveHeroes()
	If GUICtrlRead($chkSmartZapSaveHeroes) = $GUI_CHECKED Then
		$ichkSmartZapSaveHeroes = 1
	Else
		$ichkSmartZapSaveHeroes = 0
	EndIf
 EndFunc   ;==>chkSmartZapSaveHeroes

Func txtMinDark()
	$itxtMinDE = GUICtrlRead($txtMinDark)
EndFunc   ;==>txtMinDark

Func chkChangeFF()
	If GUICtrlRead($chkChangeFF) = $GUI_CHECKED Then
		$useFFBarchST = 1
	Else
		$useFFBarchST = 0
	EndIf
 EndFunc   ;==>chkChangeFF

Func txtPercentCollectors()
	$percentCollectors = GUICtrlRead($txtPercentCollectors)
EndFunc   ;==>txtPercentCollectors

Func txtDistance()
	$redlineDistance = GUICtrlRead($txtDistance)
EndFunc   ;==>txtDistance