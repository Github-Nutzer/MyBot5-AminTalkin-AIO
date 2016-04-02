; #FUNCTION# ====================================================================================================================
; Name ..........: PrepareAttack
; Description ...: Checks the troops when in battle, checks for type, slot, and quantity.  Saved in $atkTroops[SLOT][TYPE/QUANTITY] variable
; Syntax ........: PrepareAttack($pMatchMode[, $Remaining = False])
; Parameters ....: $pMatchMode          - a pointer value.
;                  $Remaining           - [optional] Flag for when checking remaining troops. Default is False.
; Return values .: None
; Author ........:
; Modified ......: LunaEclipse(January, 2016)
; Remarks .......: This file is part of MyBot, previously known as ClashGameBot. Copyright 2015-2016
;                  MyBot is distributed under the terms of the GNU GPL
; Related .......:
; Link ..........: https://github.com/MyBotRun/MyBot/wiki
; Example .......: No
; ===============================================================================================================================

Func IsUnitAlreadyOnBar($aBarArray, $pTroopType, $index)
	If Not IsArray($aBarArray) Then Return False ; Prevent errors
	
	Local $return = False
	Local $i = 0

	; This loops through the bar array but allows us to exit as soon as we find our match.
	For $i = 0 To $index - 1
		; $aBarArray[$i][0] holds the unit ID for that position on the deployment bar.
		If $aBarArray[$i][0] = $pTroopType Then
			$return = True
			ExitLoop
		EndIf
	Next
	
	Return $return
EndFunc   ;==>IsUnitAlreadyOnBar

Func IsTroopToBeUsed($pMatchMode, $pTroopType)
	If $pMatchMode = $DT Or $pMatchMode = $TB Or $pMatchMode = $TS Then Return True

	Local $tempArr = $troopsToBeUsed[$iCmbSelectTroop[$pMatchMode]]

	For $x = 0 To UBound($tempArr) - 1
		If $tempArr[$x] = $pTroopType Then
			Return True
		EndIf
	Next

	Return False
EndFunc   ;==>IsTroopToBeUsed

Func TestScreenCap($x, $y, $x2, $y2)
    Local $hBitmap1, $hBitmap2, $hImage1, $hImage2, $hGraphics

    ; Initialize GDI+ library
    _GDIPlus_Startup()

    ; Capture full screen
    $hBitmap1 = _ScreenCapture_Capture("", $x, $y, $x2, $y2)
    $hImage1 = _GDIPlus_BitmapCreateFromHBITMAP($hBitmap1)

    ; Save resultant image
    _GDIPlus_ImageSaveToFile($hImage1, @ScriptDir & "\GDIPlus_Image.jpg")

    ; Clean up resources
    _GDIPlus_ImageDispose($hImage1)
    _WinAPI_DeleteObject($hBitmap1)

    ; Shut down GDI+ library
    _GDIPlus_Shutdown()
EndFunc   ;==>Example

Func PrepareAttack($pMatchMode, $Remaining = False) ; Assigns troops
	Local Static $barCounter = 0

	Local $result, $troopData, $kind
	Local $aTemp[12][3], $aTroopDataList
	
	If $debugSetlog = 1 Then SetLog("PrepareAttack", $COLOR_PURPLE)

	If $Remaining Then
		SetLog("Checking remaining unused troops for: " & $sModeText[$pMatchMode], $COLOR_BLUE)

		_CaptureRegion2(0, 571 + $bottomOffsetY, GetXPosofArmySlot($barCounter, 68), 671 + $bottomOffsetY)
		If _Sleep($iDelayPrepareAttack1) Then Return
	Else
		; Clear and reset variables from previous search
		Dim $atkTroops[12][2] ; This erases the data in the array

		$barCounter = 0 ; Reset the bar counter for the new search
		$CCSpellType = -1 ; Removes the currently save CC Spell Type

		SetLog("Initiating attack for: " & $sModeText[$pMatchMode], $COLOR_RED)		

		_CaptureRegion2(0, 571 + $bottomOffsetY, 859, 671 + $bottomOffsetY)
		If _Sleep($iDelayPrepareAttack1) Then Return		
	EndIf

	; SuspendAndroid()
	$result = DllCall($hFuncLib, "str", "searchIdentifyTroop", "ptr", $hHBitmap2)

	If $debugSetlog = 1 Then SetLog("First Search of Troopsbar, getting units and spells", $COLOR_PURPLE)
	If $debugSetlog = 1 Then Setlog("DLL Troopsbar list: " & $result[0], $COLOR_PURPLE)

	$aTroopDataList = StringSplit($result[0], "|", $STR_NOCOUNT)
	
	If $result[0] <> "" Then
		For $i = 0 To UBound($aTroopDataList) - 1
			$troopData = StringSplit($aTroopDataList[$i], "#", $STR_NOCOUNT)
			$aTemp[$i][0] = $troopData[0]
			$aTemp[$i][1] = $troopData[2]
		
			If Not $Remaining Then $barCounter += 1
		Next
	EndIf

	; Check to see if a second copy of any of the dark elixir spells exists, as this will be a Clan Castle Spell
	_CaptureRegion2(GetXPosofArmySlot($barCounter, 68), 571 + $bottomOffsetY, 859, 671 + $bottomOffsetY)
	If _Sleep($iDelayPrepareAttack1) Then Return
	TestScreenCap(GetXPosofArmySlot($barCounter, 68), 571 + $bottomOffsetY, 859, 671 + $bottomOffsetY)
	$result = DllCall($hFuncLib, "str", "searchIdentifyTroop", "ptr", $hHBitmap2)
	
	If $debugSetlog = 1 Then Setlog("Second Search of Troopsbar, checking for CC Spells", $COLOR_PURPLE)
	If $debugSetlog = 1 Then Setlog("DLL Troopsbar list: " & $result[0], $COLOR_PURPLE)
	
	$aTroopDataList = StringSplit($result[0], "|", $STR_NOCOUNT)

	If $result[0] <> "" Then
		For $i = 0 To UBound($aTroopDataList) - 1
			$troopData = StringSplit($aTroopDataList[$i], "#", $STR_NOCOUNT)
			If IsUnitAlreadyOnBar($aTemp, $troopData[0], $barCounter + $i) Then
				$aTemp[$barCounter + $i][0] = $eCCSpell
				$CCSpellType = $troopData[0]
			Else
				$aTemp[$barCounter + $i][0] = $troopData[0]
			EndIf
			$aTemp[$barCounter + $i][1] = Number($troopData[2])
		Next
	EndIf
	
	For $i = 0 To UBound($aTemp) - 1
		If $aTemp[$i][0] = "" And $aTemp[$i][1] = "" Then
			$atkTroops[$i][0] = -1
			$atkTroops[$i][1] = 0
		Else
			$kind = $aTemp[$i][0]
			$atkTroops[$i][0] = $kind

			If $kind = -1 Then
				$atkTroops[$i][1] = 0
			ElseIf ($kind = $eKing) Or ($kind = $eQueen) Or ($kind = $eCastle) Or ($kind = $eWarden) Then
				$atkTroops[$i][1] = ""
			Else
				$atkTroops[$i][1] = $aTemp[$i][1]
			EndIf

			If $kind <> -1 Then
				If $kind = $eCCSpell Then
					SetLog("-*-" & "Clan Castle Spell: " & getTranslatedTroopName($CCSpellType), $COLOR_GREEN)
				Else
					If $atkTroops[$i][1] = "" Then
						SetLog("-*-" & getTranslatedTroopName($kind), $COLOR_GREEN)
					Else
						SetLog("-*-" & getTranslatedTroopName($kind) & ": " & $atkTroops[$i][1], $COLOR_GREEN)
					EndIf
				EndIf
			EndIf
		EndIf
	Next

    ; ResumeAndroid()
EndFunc   ;==>PrepareAttack
