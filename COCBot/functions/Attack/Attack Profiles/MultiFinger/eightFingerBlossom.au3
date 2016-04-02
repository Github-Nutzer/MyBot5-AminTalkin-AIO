; #FUNCTION# ====================================================================================================================
; Name ..........: eightFingerBlossom
; Description ...: Contains functions for eight finger blossom deployment
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

Func eightFingerBlossomMulti($dropAmount, $slotsPerEdge = 0)
	Local $troopsLeft = Ceiling($dropAmount / 2)
	Local $troopsPerSlot = 0

	If $slotsPerEdge = 0 Or $troopsLeft < $slotsPerEdge Then $slotsPerEdge = $troopsLeft

	For $i = 0 To $slotsPerEdge - 1
		$troopsPerSlot = Ceiling($troopsLeft / ($slotsPerEdge - $i)) ; progressively adapt the number of drops to fill at the best

		blossomSideDrop($TopLeft, $sideTopLeft, $i + 1, $slotsPerEdge, $troopsPerSlot)
		blossomSideDrop($TopRight, $sideTopRight, $i + 1, $slotsPerEdge, $troopsPerSlot)
		blossomSideDrop($BottomRight, $sideBottomRight, $i + 1, $slotsPerEdge, $troopsPerSlot)
		blossomSideDrop($BottomLeft, $sideBottomLeft, $i + 1, $slotsPerEdge, $troopsPerSlot, True)

		$troopsLeft -= ($troopsLeft < $troopsPerSlot) ? $troopsLeft : $troopsPerSlot
	Next
EndFunc   ;==>eightFingerBlossomMulti

Func eightFingerBlossomDropOnEdge($kind, $dropAmount, $position = 0)
	Local $troopsPerEdge = Ceiling($dropAmount / 4)

	If $dropAmount = 0 Or isProblemAffect(True) Then Return

	If _SleepAttack($iDelayDropOnEdge1) Then Return
	SelectDropTroop($kind) ; Select Troop
	If _SleepAttack($iDelayDropOnEdge2) Then Return

	Switch $position
		Case 1
			multiSingle($troopsPerEdge)
		Case 2
			multiDouble($troopsPerEdge)
		Case Else
			Switch $troopsPerEdge
				Case 1
					multiSingle($troopsPerEdge)
				Case 2
					multiDouble($troopsPerEdge)
				Case Else
					eightFingerBlossomMulti($troopsPerEdge, $position)
			EndSwitch
	EndSwitch
EndFunc   ;==>eightFingerBlossomDropOnEdge