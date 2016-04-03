; #FUNCTION# ====================================================================================================================
; Name ..........: troopDeployment
; Description ...: Contains functions for various troop deployments
; Syntax ........:
; Parameters ....:
; Return values .: None
; Author ........: LunaEclipse(March, 2016)
; Modified ......:
; Remarks .......: This file is part of MyBot, previously known as ClashGameBot. Copyright 2015-2016
;                  MyBot is distributed under the terms of the GNU GPL
; Related .......:
; Link ..........: https://github.com/MyBotRun/MyBot/wiki
; Example .......: No
; ===============================================================================================================================

; Randomize a drop point based on which side its on
Func calculateRandomDropPoint($dropPoint, $randomX = 0, $randomY = 0)
	Local $aResult[2] = [$dropPoint[0], $dropPoint[1]]

	Switch calculateSideFromXY($dropPoint[0], $dropPoint[1])
		Case $sideBottomRight
			$aResult[0] = $dropPoint[0] + Random(0, Abs($randomX), 1)
			$aResult[1] = $dropPoint[1] + Random(0, Abs($randomY), 1)
		Case $sideTopLeft
			$aResult[0] = $dropPoint[0] - Random(0, Abs($randomX), 1)
			$aResult[1] = $dropPoint[1] - Random(0, Abs($randomY), 1)
		Case $sideBottomLeft
			$aResult[0] = $dropPoint[0] - Random(0, Abs($randomX), 1)
			$aResult[1] = $dropPoint[1] + Random(0, Abs($randomY), 1)
		Case $sideTopRight
			$aResult[0] = $dropPoint[0] + Random(0, Abs($randomX), 1)
			$aResult[1] = $dropPoint[1] - Random(0, Abs($randomY), 1)
		Case Else
	EndSwitch

	If $debugSetLog = 1 Then SetLog("Coordinate (x,y): " & $aResult[0] & "," & $aResult[1])
	Return $aResult
EndFunc

; Returns the largest X and Y coord as an array
Func getMaxCoords($sideCoords)
	Local $aResult[2] = [_Max($sideCoords[0][0], $sideCoords[Ubound($sideCoords) - 1][0]), _ 
						 _Max($sideCoords[0][1], $sideCoords[Ubound($sideCoords) - 1][1])]
	
	Return $aResult
EndFunc   ;==>getMaxCoords

; Returns the smallest X and Y coord as an array
Func getMinCoords($sideCoords)
	Local $aResult[2] = [_Min($sideCoords[0][0], $sideCoords[Ubound($sideCoords) - 1][0]), _ 
						 _Min($sideCoords[0][1], $sideCoords[Ubound($sideCoords) - 1][1])]
	
	Return $aResult
EndFunc   ;==>getMinCoords

; Returns how much the X and Y change for each index
Func getIndexChange($min, $max, $numParts)
	Local $angle = calculateAngleBetweenPoints($max, $min)
	Local $length = calculateDistanceBetweenPoints($max, $min)

	; Angle value returned is in Radians, so we need to convert to degrees for the log message
	If $debugSetLog = 1 Then SetLog("Angle: " & _Degree($angle) & " degrees - Length: " & $length)
	
	Local $partSize = $length / $numParts
	; Basic Trigonometry, COS gets the change in X based on the angle obtained, SIN gets the change in Y
	Local $partChange[2] = [Cos($angle) * $partSize, Sin($angle) * $partSize]

	If $debugSetLog = 1 Then SetLog("Part Size: " & $partSize & " - ChangeX: " & $partChange[0] & " - ChangeY: " & $partChange[1])
	
	Return $partChange
EndFunc   ;==>getIndexChange

; This calculates the drop point for the side that has been split into multiple parts
Func getSideIndexCoord($side, $direction, $index, $min, $max, $partChange)
	Local $aResult[2] = [0, 0]
	Switch $direction
        Case $directionLeft
			$aResult[0] = Round($max[0] - ($partChange[0] * $index))
			Switch $side
				Case $sideTopLeft, $sideBottomRight
					$aResult[1] = Round($min[1] + ($partChange[1] * $index))
				Case $sideTopRight, $sideBottomLeft
					$aResult[1] = Round($max[1] - ($partChange[1] * $index))
				Case Else
					; This should never happen unless there is a problem with the code.
			EndSwitch
       Case $directionRight
			$aResult[0] = Round($min[0] + ($partChange[0] * $index))
			Switch $side
				Case $sideTopLeft, $sideBottomRight
					$aResult[1] = Round($max[1] - ($partChange[1] * $index))
				Case $sideTopRight, $sideBottomLeft
					$aResult[1] = Round($min[1] + ($partChange[1] * $index))
				Case Else
					; This should never happen unless there is a problem with the code.
			EndSwitch
        Case Else
            ; This should never happen unless there is a problem with the code.
    EndSwitch

	If $debugSetLog = 1 Then SetLog("Coord (x,y): " & $aResult[0] & "," & $aResult[1])
	
	Return $aResult
EndFunc   ;==>getSideIndexCoord

; This splits a side into multiple parts, returning an array containing each drop point for part.
Func splitSide($sideCoords, $side, $direction, $numParts)
	Local $aResult[$numParts + 1][2]

	Local $min = getMinCoords($sideCoords)
	Local $max = getMaxCoords($sideCoords)
	Local $partChange = getIndexChange($min, $max, $numParts)		

	Local $indexCoord

	For $i = 0 to $numParts - 1
		$indexCoord = getSideIndexCoord($side, $direction, $i, $min, $max, $partChange)
		$aResult[$i][0] = $indexCoord[0]
		$aResult[$i][1] = $indexCoord[1]
	Next
    
	Switch $direction
        Case $directionLeft
			$aResult[$numParts][0] = $min[0]
			Switch $side
				Case $sideTopLeft, $sideBottomRight
					$aResult[$numParts][1] = $max[1]
				Case $sideTopRight, $sideBottomLeft
					$aResult[$numParts][1] = $min[1]
				Case Else
					; This should never happen unless there is a problem with the code.
			EndSwitch

       Case $directionRight
			$aResult[$numParts][0] = $max[0]
			Switch $side
				Case $sideTopLeft, $sideBottomRight
					$aResult[$numParts][1] = $min[1]
				Case $sideTopRight, $sideBottomLeft
					$aResult[$numParts][1] = $max[1]
				Case Else
					; This should never happen unless there is a problem with the code.
			EndSwitch
        Case Else
            ; This should never happen unless there is a problem with the code.
    EndSwitch
	
	Return $aResult
EndFunc   ;==>splitSide

; Return the point to drop troops on based on number of drop points and current index
Func calculateDropPoint($sideCoords, $side, $direction, $dropPoint, $numDropPoints)
	Local $min = getMinCoords($sideCoords)
	Local $max = getMaxCoords($sideCoords)
	Local $partChange = getIndexChange($min, $max, $numDropPoints)		

	Local $aResult = getSideIndexCoord($side, $direction, $dropPoint, $min, $max, $partChange)
    
    Return $aResult
EndFunc   ;==>calculateDropPoint

; Drop the number of spells specified on the specified location, will use clan castle spells if you have it.
Func dropSpell($x, $y, $spell = -1, $number = 1) ; Drop Spell
	If $spell = -1 Then Return False

	Local $result = False
	Local $aDeployButtonPositions = getUnitLocationArray()
	Local $barPosition = $aDeployButtonPositions[$spell]
	Local $barCCSpell = $aDeployButtonPositions[$eCCSpell]
	Local $spellCount = unitCount($spell)	
	Local $ccSpellCount = unitCount($eCCSpell)
	Local $totalSpells = $spellCount + $ccSpellCount
	
	If $totalSpells < $number Then
		SetLog("Only " & $totalSpells & " " & getTranslatedTroopName($spell) & " available.  Waiting for " & $number & ".")
		Return $result	
	EndIf
	
	; Check to see if we have a spell in the CC and it hasn't be used
	If $barCCSpell <> -1 And getCCSpellType() = $spell And $totalSpells >= $number Then
		If _Sleep(100) Then Return

		SelectDropTroop($barCCSpell) ; Select Clan Castle Spell
		SetLog("Dropping " & getTranslatedTroopName($spell) & " in the Clan Castle" & " on button " & ($barCCSpell + 1) & " at " & $x & "," & $y, $COLOR_BLUE)
		AttackClick($x, $y, $ccSpellCount, 100, 0)
		$number -= $ccSpellCount
	
		If $barPosition <> -1 And $number > 0 And $spellCount >= $number Then ; Need to use standard spells as well as clan castle spell.
			If _Sleep(100) Then Return
			If $debugSetlog = 1 Then SetLog("Dropping " & getTranslatedTroopName($spell) & " in slot " & $barPosition, $COLOR_BLUE)

			SelectDropTroop($barPosition) ; Select Spell
			SetLog("Dropping " & $number & " " & getTranslatedTroopName($spell) & " on button " & ($barPosition + 1) & " at " & $x & "," & $y, $COLOR_BLUE)			
			AttackClick($x, $y, $number, 100, 0)
		EndIf
		
		$result = True
	ElseIf $barPosition <> -1 And $spellCount >= $number Then ; Check to see if we have a spell trained
		If _Sleep(100) Then Return

		SelectDropTroop($barPosition) ; Select Spell
		SetLog("Dropping " & $number & " " & getTranslatedTroopName($spell) & " on button " & ($barPosition + 1) & " at " & $x & "," & $y, $COLOR_BLUE)
		AttackClick($x, $y, $number, 100, 0)

		$result = True
	EndIf
	
	Return $result
EndFunc   ;==>dropSpell

; Drop the number of units specified on the specified location, even allows for random variation if specified.
Func dropUnit($x, $y, $unit = -1, $number = 1, $randomX = 0, $randomY = 0) ; Drop Unit
	If $unit = -1 Then Return False

	Local $result = False
	Local $barPosition = unitLocation($unit)
	Local $unitCount = unitCount($unit)
	Local $currentDropPoint[2] = [$x, $y]
	Local $dropPoint
	
	If $barPosition <> -1 And $unitCount >= $number Then ; Check to see if we have any units to drop
		If _Sleep(100) Then Return
		If $unitCount < $number Then $number = $unitCount

		SelectDropTroop($barPosition) ; Select Troop
		SetLog("Dropping " & $number & " " & getTranslatedTroopName($unit) & " at " & $x & "," & $y, $COLOR_BLUE)
		
		For $i = 1 to $number
			$dropPoint = calculateRandomDropPoint($currentDropPoint, $randomX, $randomY)
			AttackClick($dropPoint[0], $dropPoint[1], 1, SetSleep(0), 0)
		Next
		
		$result = True
	EndIf
	
	Return $result
EndFunc   ;==>dropUnit

; Drop the troops from a single point on a single side
Func sideSingle($dropSide, $dropAmount)
	AttackClick($dropSide[2][0], $dropSide[2][1], $dropAmount, SetSleep(0), 0)
EndFunc   ;==>sideSingle

; Drop the troops from two points on a single side
Func sideDouble($dropSide, $dropAmount)
	Local $half = Ceiling($dropAmount / 2)

	AttackClick($dropSide[1][0], $dropSide[1][1], $half, 0, 0)
	AttackClick($dropSide[3][0], $dropSide[3][1], $dropAmount - $half, SetSleep(0), 0)
EndFunc   ;==>sideDouble

; Drop the troops from a single point on all sides at once
Func multiSingle($dropAmount)
	AttackClick($TopLeft[2][0], $TopLeft[2][1], $dropAmount, 0, 0)
	AttackClick($TopRight[2][0], $TopRight[2][1], $dropAmount, 0, 0)
	AttackClick($BottomRight[2][0], $BottomRight[2][1], $dropAmount, 0, 0)
	AttackClick($BottomLeft[2][0], $BottomLeft[2][1], $dropAmount, SetSleep(0), 0)
EndFunc   ;==>multiSingle

; Drop the troops from two points on all sides at once
Func multiDouble($dropAmount)
	Local $half = Ceiling($dropAmount / 2)

	AttackClick($TopLeft[1][0], $TopLeft[1][1], $half, 0, 0)
	AttackClick($TopRight[1][0], $TopRight[1][1], $half, 0, 0)
	AttackClick($BottomRight[1][0], $BottomRight[1][1], $half, 0, 0)
	AttackClick($BottomLeft[1][0], $BottomLeft[1][1], $half, 0, 0)

	AttackClick($TopLeft[3][0], $TopLeft[3][1], $dropAmount - $half, 0, 0)
	AttackClick($TopRight[3][0], $TopRight[3][1], $dropAmount - $half, 0, 0)
	AttackClick($BottomRight[3][0], $BottomRight[3][1], $dropAmount - $half, 0, 0)
	AttackClick($BottomLeft[3][0], $BottomLeft[3][1], $dropAmount - $half, SetSleep(0), 0)
EndFunc   ;==>multiDouble

; Drop the troops in a Blossom drop, starting in the center of the side and moving to the both corners
Func blossomSideDrop($dropSide, $side, $currentSlot, $numSlots, $troopsPerSlot, $useDelay = False)
	Local $delay = ($useDelay = True) ? SetSleep(0): 0
	Local $splitSide = splitSide($dropSide, $side, $directionRight, 2)
	Local $dropSideLeft[2][2] = [[$splitSide[0][0], $splitSide[0][1]], _ 
								 [$splitSide[1][0], $splitSide[1][1]]]
	Local $dropSideRight[2][2] = [[$splitSide[1][0], $splitSide[1][1]], _ 
								  [$splitSide[2][0], $splitSide[2][1]]]
	Local $dropPoint[2] = [0, 0]
	
	; Every second one must be offest by -1 to ensure there is not a large gap where the two half sides meet
	$dropPoint = calculateDropPoint($dropSideLeft, $side, $directionLeft, $currentSlot - 1, $numSlots - 1)
	AttackClick($dropPoint[0], $dropPoint[1], $troopsPerSlot, 0, 0)
	$dropPoint = calculateDropPoint($dropSideRight, $side, $directionRight, $currentSlot, $numSlots)
	AttackClick($dropPoint[0], $dropPoint[1], $troopsPerSlot, $delay, 0)
EndFunc   ;==>blossomSideDrop

; Drop the troops in an Implosion drop, starting in the corners and meeting in the center
Func implosionSideDrop($dropSide, $side, $currentSlot, $numSlots, $troopsPerSlot, $useDelay = False)
	Local $delay = ($useDelay = True) ? SetSleep(0): 0
	Local $splitSide = splitSide($dropSide, $side, $directionRight, 2)
	Local $dropSideLeft[2][2] = [[$splitSide[0][0], $splitSide[0][1]], _ 
								 [$splitSide[1][0], $splitSide[1][1]]]
	Local $dropSideRight[2][2] = [[$splitSide[1][0], $splitSide[1][1]], _ 
								  [$splitSide[2][0], $splitSide[2][1]]]
	Local $dropPoint[2] = [0, 0]
	
	; Every second one must be offest by -1 to ensure there is not a large gap where the two half sides meet
	$dropPoint = calculateDropPoint($dropSideLeft, $side, $directionRight, $currentSlot - 1, $numSlots - 1)
	AttackClick($dropPoint[0], $dropPoint[1], $troopsPerSlot, 0, 0)
	$dropPoint = calculateDropPoint($dropSideRight, $side, $directionLeft, $currentSlot, $numSlots)
	AttackClick($dropPoint[0], $dropPoint[1], $troopsPerSlot, $delay, 0)
EndFunc   ;==>implosionSideDrop

; Drop the troops in a Standard drop from two points at once
Func twoFingerStandardSideDrop($dropSide, $side, $direction, $currentSlot, $numSlots, $troopsPerSlot, $useDelay = False)
	Local $delay = ($useDelay = True) ? SetSleep(0): 0
	Local $splitSide = splitSide($dropSide, $side, $directionRight, 2)
	Local $dropSideLeft[2][2] = [[$splitSide[0][0], $splitSide[0][1]], _ 
								 [$splitSide[1][0], $splitSide[1][1]]]
	Local $dropSideRight[2][2] = [[$splitSide[1][0], $splitSide[1][1]], _ 
								  [$splitSide[2][0], $splitSide[2][1]]]
	Local $dropPoint[2] = [0, 0]
	
	; Every second one must be offest by -1 to ensure there is not a large gap where the two half sides meet
	$dropPoint = calculateDropPoint($dropSideLeft, $side, $direction, $currentSlot - 1, $numSlots - 1)
	AttackClick($dropPoint[0], $dropPoint[1], $troopsPerSlot, 0, 0)
	$dropPoint = calculateDropPoint($dropSideRight, $side, $direction, $currentSlot, $numSlots)
	AttackClick($dropPoint[0], $dropPoint[1], $troopsPerSlot, $delay, 0)
EndFunc   ;==>twoFingerStandardSideDrop

; Drop the troops in a Standard drop
Func standardSideDrop($dropSide, $side, $direction, $currentSlot, $numSlots, $troopsPerSlot, $useDelay = False)
	Local $delay = ($useDelay = True) ? SetSleep(0): 0
	Local $dropPoint[2] = [0, 0]

	$dropPoint = calculateDropPoint($dropSide, $side, $direction, $currentSlot, $numSlots)
	AttackClick($dropPoint[0], $dropPoint[1], $troopsPerSlot, $delay, 0)
EndFunc   ;==>standardSideDrop