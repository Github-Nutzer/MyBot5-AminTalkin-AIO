; #FUNCTION# ====================================================================================================================
; Name ..........: multiFinger
; Description ...: Contains functions for all the multi-finger deployment
; Syntax ........:
; Parameters ....:
; Return values .: None
; Author ........: LunaEclipse(January, 2016)
; Modified ......:
; Remarks .......: This file is part of MyBot, previously known as ClashGameBot. Copyright 2015-2016
;                  MyBot is distributed under the terms of the GNU GPL
; Related .......:
; Link ..........: https://github.com/MyBotRun/MyBot/wiki
; Example .......: No
; ===============================================================================================================================

Local $aAttackTypeString[$mf8FPinWheelRight + 1] = ["Random", _ 
													"Four Finger Standard", _ 
													"Four Finger Spiral Left", _ 
													"Four Finger Spiral Right", _ 
													"Eight Finger Blossom", _ 
													"Eight Finger Implosion", _ 
													"Eight Finger Pin Wheel Spiral Left", _ 
													"Eight Finger Pin Wheel Spiral Right"]

Func multiFingerDropOnEdge($multiStyle, $kind, $dropAmount, $position = 0)
	If $dropAmount = 0 Or isProblemAffect(True) Then Return
	If $position = 0 Or $dropAmount < $position Then $position = $dropAmount
		
	KeepClicks()	
	If _SleepAttack($iDelayDropOnEdge1) Then Return
	SelectDropTroop($kind) ; Select Troop
	If _SleepAttack($iDelayDropOnEdge2) Then Return

	Switch $multiStyle
		Case $mfFFStandard
			fourFingerStandardDropOnEdge($kind, $dropAmount, $position)
		Case $mfFFSpiralLeft
			fourFingerSpiralLeftDropOnEdge($kind, $dropAmount, $position)
		Case $mfFFSpiralRight
			fourFingerSpiralRightDropOnEdge($kind, $dropAmount, $position)
		Case $mf8FBlossom
			eightFingerBlossomDropOnEdge($kind, $dropAmount, $position)
		Case $mf8FImplosion
			eightFingerImplosionDropOnEdge($kind, $dropAmount, $position)
		Case $mf8FPinWheelLeft
			eightFingerPinWheelLeftDropOnEdge($kind, $dropAmount, $position)
		Case $mf8FPinWheelRight
			eightFingerPinWheelRightDropOnEdge($kind, $dropAmount, $position)
	EndSwitch
	ReleaseClicks()
EndFunc   ;==>multiFingerDropOnEdge

Func launchMultiFinger($listInfoDeploy, $CC, $King, $Queen, $Warden, $overrideSmartDeploy = -1)
	Local $kind, $nbSides, $waveNumber, $waveCount, $position, $remainingWaves
	Local $RandomEdge, $RandomXY

	Local $multiStyle = ($iMultiFingerStyle[$iMatchMode] = $mfRandom) ? Random($mfFFStandard, $mf8FPinWheelRight, 1) : $iMultiFingerStyle[$iMatchMode]

	SetLog("Attacking " & $aAttackTypeString[$multiStyle] & " fight style.", $COLOR_BLUE)
	If $debugSetLog = 1 Then SetLog("Launch " & $aAttackTypeString[$multiStyle] & " with CC " & $CC & ", K " & $King & ", Q " & $Queen & ", W " & $Warden , $COLOR_PURPLE)
			
	Local $aDeployButtonPositions = getUnitLocationArray()
	Local $unitCount = unitCountArray()

	For $i = 0 To UBound($listInfoDeploy) - 1
		$kind = $listInfoDeploy[$i][0]
		$nbSides = $listInfoDeploy[$i][1]
		$waveNumber = $listInfoDeploy[$i][2]
		$waveCount = $listInfoDeploy[$i][3]
		$position = $listInfoDeploy[$i][4]
		$remainingWaves = ($waveCount - $waveNumber) + 1
		$barPosition = $aDeployButtonPositions[$kind]

		If IsString($kind) And ($kind = "CC" Or $kind = "HEROES") Then
			$RandomEdge = $Edges[Round(Random(0, 3))]
			$RandomXY = Round(Random(0, 4))

			If $kind = "CC" Then
				dropCC($RandomEdge[$RandomXY][0], $RandomEdge[$RandomXY][1], $CC)
			ElseIf $kind = "HEROES" Then
				dropHeroes($RandomEdge[$RandomXY][0], $RandomEdge[$RandomXY][1], $King, $Queen, $Warden)
			EndIf
		ElseIf IsNumber($kind) And $barPosition <> -1 Then
			$dropAmount = calculateDropAmount($unitCount[$kind], $remainingWaves, $position)
			$unitCount[$kind] -= $dropAmount
			
			If $dropAmount > 0 Then 
				SetLog("Dropping " & getWaveName($waveNumber, $waveCount) & " wave of " & $dropAmount & " " & getTranslatedTroopName($kind), $COLOR_GREEN)

				multiFingerDropOnEdge($multiStyle, $barPosition, $dropAmount, $position)
				If _Sleep(SetSleep(1)) Then Return
			EndIf
		EndIf
	Next

	If _Sleep($iDelayalgorithm_AllTroops4) Then Return

	dropRemainingTroops($nbSides) ; Use remaining troops
	useHeroesAbility() ; Use heroes abilities

	SetLog("Finished Attacking, waiting for the battle to end")
	$usingMultiFinger = False
	Return True
EndFunc   ;==>launchMultiFinger