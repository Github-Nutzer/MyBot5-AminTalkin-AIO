; #FUNCTION# ====================================================================================================================
; Name ..........: PushBullet
; Description ...: This function will report to your mobile phone your values and last attack
; Syntax ........:
; Parameters ....: None
; Return values .: None
; Author ........: Antidote (2015-03)
; Modified ......: Sardo and Didipe (2015-05) rewrite code
;				   kgns (2015-06) $pushLastModified addition
;				   Sardo (2015-06) compliant with new pushbullet syntax (removed title)
;				   Cutidudz (2016) Fix and Extended features and functions for v5.3+
; Remarks .......: This file is part of MyBot, previously known as ClashGameBot. Copyright 2015-2016
;                  MyBot is distributed under the terms of the GNU GPL
; Related .......:
; Link ..........: https://github.com/MyBotRun/MyBot/wiki
; Example .......: No
; ===============================================================================================================================

#include <Array.au3>
#include <String.au3>

Func _RemoteControl()
   If $pEnabled = 0 and $pEnabled2 = 0 Or $pRemote = 0 Then Return
   If $pEnabled=1 then
		$oHTTP = ObjCreate("WinHTTP.WinHTTPRequest.5.1")
		$access_token = $PushToken
		Local $pushbulletApiUrl
		If $pushLastModified = 0 Then
			$pushbulletApiUrl = "https://api.pushbullet.com/v2/pushes?active=true&limit=1" ; if this is the first time looking for pushes, get the last one
		Else
			$pushbulletApiUrl = "https://api.pushbullet.com/v2/pushes?active=true&modified_after=" & $pushLastModified ; get the one pushed after the last one received
		EndIf
		$oHTTP.Open("Get", $pushbulletApiUrl, False)
		$oHTTP.SetCredentials($access_token, "", 0)
		$oHTTP.SetRequestHeader("Content-Type", "application/json")
		$oHTTP.Send()
		$Result = $oHTTP.ResponseText

		Local $modified = _StringBetween($Result, '"modified":', ',', "", False)
		If UBound($modified) > 0 Then
			$pushLastModified = Number($modified[0]) ; modified date of the newest push that we received
			$pushLastModified -= 120 ; back 120 seconds to avoid loss of messages
		EndIf

		Local $findstr = StringRegExp(StringUpper($Result), '"BODY":"BOT')
		If $findstr = 1 Then
			Local $body = _StringBetween($Result, '"body":"', '"', "", False)
			Local $iden = _StringBetween($Result, '"iden":"', '"', "", False)
			For $x = UBound($body) - 1 To 0 Step -1
				If $body <> "" Or $iden <> "" Then
					$body[$x] = StringUpper(StringStripWS($body[$x], $STR_STRIPLEADING + $STR_STRIPTRAILING + $STR_STRIPSPACES))
					$iden[$x] = StringStripWS($iden[$x], $STR_STRIPLEADING + $STR_STRIPTRAILING + $STR_STRIPSPACES)

					Switch $body[$x]
						Case "BOT HELP"
							Local $txtHelp = "You can remotely control your bot sending commands following this syntax:"
							$txtHelp &= '\n' & "BOT HELP - send this help message"
							$txtHelp &= '\n' & "BOT DELETE  - delete all your previous Push message"
							$txtHelp &= '\n' & "BOT <Village Name> RESTART - restart the bot named <Village Name> and bluestacks"
							$txtHelp &= '\n' & "BOT <Village Name> STOP - stop the bot named <Village Name>"
							$txtHelp &= '\n' & "BOT <Village Name> PAUSE - pause the bot named <Village Name>"
							$txtHelp &= '\n' & "BOT <Village Name> RESUME   - resume the bot named <Village Name>"
							$txtHelp &= '\n' & "BOT <Village Name> STATS - send Village Statistics of <Village Name>"
							$txtHelp &= '\n' & "BOT <Village Name> LOG - send the current log file of <Village Name>"
							$txtHelp &= '\n' & "BOT <Village Name> LASTRAID - send the last raid loot screenshot of <Village Name>"
							$txtHelp &= '\n' & "BOT <Village Name> LASTRAIDTXT - send the last raid loot values of <Village Name>"
							$txtHelp &= '\n' & "BOT <Village Name> SCREENSHOT - send a screenshot of <Village Name>"
							$txtHelp &= '\n' & "BOT <Village Name> START - start the bot named <Village Name>"
							$txtHelp &= '\n' & "BOT <Village Name> RESETSTATS - reset Village Statistics of <Village Name>"
							$txtHelp &= '\n' & "BOT <Village Name> DONATEON <TROOPNAME> <QUANTITY> - turn on donate for troop & quantity."
							$txtHelp &= '\n' & "BOT <Village Name> DONATEOFF <TROOPNAME> <QUANTITY> - turn off donate for troop & quantity."
							$txtHelp &= '\n' & "BOT <Village Name> TROOP&SPELLSTATS - send Troops & Spell Stats of <Village Name>"
							$txtHelp &= '\n' & "BOT <Village Name> HALTATTACKON - Turn On 'Halt Attack' in the 'Misc' Tab with the default options"
							$txtHelp &= '\n' & "BOT <Village Name> HALTATTACKOFF - Turn Off 'Halt Attack' in the 'Misc' Tab"
							$txtHelp &= '\n' & "BOT <Village Name> SWITCHPROFILE <PROFILENAME> - Swap Profile Village and restart bot"
							$txtHelp &= '\n'
							$txtHelp &= '\n' & "Examples:"
							$txtHelp &= '\n' & "Bot MyVillage Pause"
							$txtHelp &= '\n' & "Bot Delete "
							$txtHelp &= '\n' & "Bot MyVillage ScreenShot"
							_Push($iOrigPushB & " | Request for Help" & "\n" & $txtHelp)
							SetLog("Pushbullet: Your request has been received from ' " & $iOrigPushB & ". Help has been sent", $COLOR_GREEN)
							_DeleteMessage($iden[$x])
						Case "BOT " & StringUpper($iOrigPushB) & " PAUSE"
							If $TPaused = False And $Runstate = True Then
								If ( _ColorCheck(_GetPixelColor($NextBtn[0], $NextBtn[1], True), Hex($NextBtn[2], 6), $NextBtn[3])) = False And IsAttackPage() Then
									SetLog("Pushbullet: Unable to pause during attack", $COLOR_RED)
									_Push($iOrigPushB & " | Request to Pause" & "\n" & "Unable to pause during attack, try again later.")
								ElseIf ( _ColorCheck(_GetPixelColor($NextBtn[0], $NextBtn[1], True), Hex($NextBtn[2], 6), $NextBtn[3])) = True And IsAttackPage() Then
									ReturnHome(False, False)
									$Is_SearchLimit = True
									$Is_ClientSyncError = False
									UpdateStats()
									$Restart = True
									TogglePauseImpl("Push")
									Return True
								Else
									TogglePauseImpl("Push")
								EndIf
							Else
								SetLog("Pushbullet: Your bot is currently paused, no action was taken", $COLOR_GREEN)
								_Push($iOrigPushB & " | Request to Pause" & "\n" & "Your bot is currently paused, no action was taken")
							EndIf
							_DeleteMessage($iden[$x])
						Case "BOT " & StringUpper($iOrigPushB) & " RESUME"
							If $TPaused = True And $Runstate = True Then
								TogglePauseImpl("Push")
							Else
								SetLog("Pushbullet: Your bot is currently resumed, no action was taken", $COLOR_GREEN)
								_Push($iOrigPushB & " | Request to Resume" & "\n" & "Your bot is currently resumed, no action was taken")
							EndIf
							_DeleteMessage($iden[$x])
						Case "BOT DELETE"
							_DeletePush($PushToken)
							SetLog("Pushbullet: Your request has been received.", $COLOR_GREEN)
						Case "BOT " & StringUpper($iOrigPushB) & " LOG"
							SetLog("Pushbullet: Your request has been received from " & $iOrigPushB & ". Log is now sent", $COLOR_GREEN)
							_PushFile($sLogFName, "logs", "text/plain; charset=utf-8", $iOrigPushB & " | Current Log " & "\n")
							_DeleteMessage($iden[$x])
						Case "BOT " & StringUpper($iOrigPushB) & " LASTRAID"
							If $AttackFile <> "" Then
								_PushFile($AttackFile, "Loots", "image/jpeg", $iOrigPushB & " | Last Raid " & "\n" & $AttackFile)
							Else
								_Push($iOrigPushB & " | There is no last raid screenshot.")
							EndIf
							SetLog("Pushbullet: Push Last Raid Snapshot...", $COLOR_GREEN)
							_DeleteMessage($iden[$x])
						Case "BOT " & StringUpper($iOrigPushB) & " LASTRAIDTXT"
							SetLog("Pusbullet: Your request has been received. Last Raid txt sent", $COLOR_GREEN)
							_Push($iOrigPushB & " | Last Raid txt" & "\n" & "[G]: " & _NumberFormat($iGoldLast) & " [E]: " & _NumberFormat($iElixirLast) & " [D]: " & _NumberFormat($iDarkLast) & " [T]: " & $iTrophyLast)
							_DeleteMessage($iden[$x])
						Case "BOT " & StringUpper($iOrigPushB) & " STATS"
							SetLog("Pushbullet: Your request has been received. Statistics sent", $COLOR_GREEN)
							Local $GoldGainPerHour = 0
							Local $ElixirGainPerHour = 0
							Local $DarkGainPerHour = 0
							Local $TrophyGainPerHour = 0
							If $FirstAttack = 2 Then
								$GoldGainPerHour = _NumberFormat(Round($iGoldTotal / (Int(TimerDiff($sTimer) + $iTimePassed)) * 3600)) & "K / h"
								$ElixirGainPerHour = _NumberFormat(Round($iElixirTotal / (Int(TimerDiff($sTimer) + $iTimePassed)) * 3600)) & "K / h"
							EndIf
							If $iDarkStart <> "" Then
								$DarkGainPerHour = _NumberFormat(Round($iDarkTotal / (Int(TimerDiff($sTimer) + $iTimePassed)) * 3600 * 1000)) & " / h"
							EndIf
							$TrophyGainPerHour = _NumberFormat(Round($iTrophyTotal / (Int(TimerDiff($sTimer) + $iTimePassed)) * 3600 * 1000)) & " / h"
							Local $txtStats = " | Stats Village Report" & "\n" & "At Start\n[G]: " & _NumberFormat($iGoldStart) & " [E]: "
								  $txtStats &= _NumberFormat($iElixirStart) & " [D]: " & _NumberFormat($iDarkStart) & " [T]: " & $iTrophyStart
								  $txtStats &= "\n\nNow (Current Resources)\n[G]: " & _NumberFormat($iGoldCurrent) & " [E]: " & _NumberFormat($iElixirCurrent)
								  $txtStats &= " [D]: " & _NumberFormat($iDarkCurrent) & " [T]: " & $iTrophyCurrent & " [GEM]: " & $iGemAmount
								  $txtStats &= "\n \nGain per Hour:\n[G]: " & $GoldGainPerHour & " [E]: " & $ElixirGainPerHour
								  $txtStats &= "\n[D]: " & $DarkGainPerHour & " [T]: " & $TrophyGainPerHour
								  $txtStats &= "\n \n[No. of Free Builders]: " & $iFreeBuilderCount & "\n[No. of Wall Up]: G: "
								  $txtStats &= $iNbrOfWallsUppedGold & "/ E: " & $iNbrOfWallsUppedElixir & "\n\nAttacked: "
								  $txtStats &= GUICtrlRead($lblresultvillagesattacked) & "\nSkipped: " & $iSkippedVillageCount
							_Push($iOrigPushB & $txtStats)
							_DeleteMessage($iden[$x])
						Case "BOT " & StringUpper($iOrigPushB) & " SCREENSHOT"
							SetLog("Pushbullet: ScreenShot request received", $COLOR_GREEN)
							$RequestScreenshot = 1
							_DeleteMessage($iden[$x])
						Case "BOT " & StringUpper($iOrigPushB) & " RESTART"
							_DeleteMessage($iden[$x])
							SetLog("Your request has been received. Bot and BS restarting...", $COLOR_GREEN)
							_Push($iOrigPushB & " | Request to Restart..." & "\n" & "Your bot and BS are now restarting...")
							SaveConfig()
							_Restart()
						Case "BOT " & StringUpper($iOrigPushB) & " STOP"
							_DeleteMessage($iden[$x])
							SetLog("Your request has been received. Bot is now stopped", $COLOR_GREEN)
							If $Runstate = True Then
								_Push($iOrigPushB & " | Request to Stop..." & "\n" & "Your bot is now stopping...")
								btnStop()
							Else
								_Push($iOrigPushB & " | Request to Stop..." & "\n" & "Your bot is currently stopped, no action was taken")
							EndIf
						Case "BOT " & StringUpper($iOrigPushB) & " START"
							_DeleteMessage($iden[$x])
							SetLog("Your request has been received. Bot is now started", $COLOR_GREEN)
							If $Runstate = False Then
								_Push($iOrigPushB & " | Request to Start..." & "\n" & "Your bot is now starting...")
								btnStart()
							Else
								_Push($iOrigPushB & " | Request to Start..." & "\n" & "Your bot is currently started, no action was taken")
							EndIf
						Case "BOT " & StringUpper($iOrigPushB) & " RESETSTATS"
							btnResetStats()
							SetLog("Pushbullet: Your request has been received. Statistics resetted", $COLOR_GREEN)
							_Push($iOrigPushB & " | Request for RESETSTATS has been resetted.")
							_DeleteMessage($iden[$x])
						Case "BOT " & StringUpper($iOrigPushB) & " TROOP&SPELLSTATS"
							SetLog("Pushbullet: Your request has been received. Sending Troop Stats...", $COLOR_GREEN)
							Local $txtTroopStats = " | Troops set to Train:" & "\n" & "Barbs:" & $BarbComp & " Arch:" & $ArchComp & " Gobl:" & $GoblComp
							$txtTroopStats &= '\n' & "Giant:" & $GiantComp & " WallB:" & $WallComp & " Wiza:" & $WizaComp
							$txtTroopStats &= '\n' & "Balloon:" & $BallComp & " Heal:" & $HealComp & " Dragon:" & $DragComp & " Pekka:" & $PekkComp
							$txtTroopStats &= '\n' & "Mini:" & $MiniComp & " Hogs:" & $HogsComp & " Valks:" & $ValkComp
							$txtTroopStats &= '\n' & "Golem:" & $GoleComp & " Witch:" & $WitcComp & " Lava:" & $LavaComp & '\n'
							$txtTroopStats &= '\nCurrent Trained Troops & Spells:'
							For $i = 0 to Ubound($TroopSpellStats)-1
								If $TroopSpellStats[$i][0] <> "" Then
									$txtTroopStats &= '\n' & $TroopSpellStats[$i][0] & ":" & $TroopSpellStats[$i][1]
								EndIf
							Next
							$txtTroopStats &= '\n\n' & "Current Army Camp: " & $CurCamp & "/" & $TotalCamp
							_Push($iOrigPushB & $txtTroopStats)
							_DeleteMessage($iden[$x])
						Case "BOT " & StringUpper($iOrigPushB) & " HALTATTACKON"
							GUICtrlSetState($chkBotStop, $GUI_CHECKED)
							btnStop()
							btnStart()
						Case "BOT " & StringUpper($iOrigPushB) & " HALTATTACKOFF"
							GUICtrlSetState($chkBotStop, $GUI_UNCHECKED)
							btnStop()
							btnStart()
						Case Else
							If StringInStr($body[$x], StringUpper($iOrigPushB) & " SENDCHAT") Then
								_DeleteMessage($iden[$x])
								$chatMessage = StringRight($body[$x], StringLen($body[$x]) - StringLen("BOT " & StringUpper($iOrigPushB) & " SENDCHAT "))
								$chatMessage = StringLower($chatMessage)
								ChatbotPushbulletQueueChat($chatMessage)
								_Push($iOrigPushB & " | Chat queued, will send on next idle")
							ElseIf StringInStr($body[$x], StringUpper($iOrigPushB) & " GETCHATS") Then
								$Interval = StringRight($body[$x], StringLen($body[$x]) - StringLen("BOT " & StringUpper($iOrigPushB) & " GETCHATS "))
								If $Interval = "STOP" Then
									ChatbotPushbulletStopChatRead()
									_Push($iOrigPushB & " | Stopping interval sending")
								ElseIf $Interval = "NOW" Then
									ChatbotPushbulletQueueChatRead()
									_Push($iOrigPushB & " | Command queued, will send clan chat image on next idle")
								Else
									If Number($Interval) <> 0 Then
										ChatbotPushbulletIntervalChatRead(Number($Interval))
										_Push($iOrigPushB & " | Command queued, will send clan chat image on interval")
									Else
										SetLog("Chatbot: incorrect command syntax, Example: BOT <VillageName> GETCHATS NOW|STOP|INTERVAL", $COLOR_RED)
										_Push($iOrigPushB & " | Command not recognized" & "\n" & "Example: BOT <VillageName> GETCHATS NOW|STOP|INTERVAL")
									EndIf
								EndIf
								_DeleteMessage($iden[$x])
							ElseIf StringInStr($body[$x], StringUpper($iOrigPushB) & " DONATEON") Then
								$DonateAtivated = 0
								$TroopType = StringRight($body[$x], StringLen($body[$x]) - StringLen("BOT " & StringUpper($iOrigPushB) & " DONATEON "))
								If StringInStr($TroopType, "GOLEM") Then
									$TroopQuantity = Number(StringRight($TroopType, (StringLen($TroopType) - 6)))
									SetLog("Pushbullet: Request to Donate Golem has been activated", $COLOR_GREEN)
									GUICtrlSetData($txtNumGole, $TroopQuantity)
									$GoleComp = $TroopQuantity
									GUICtrlSetState($ChkDonateGolems, $GUI_CHECKED)
									$iChkDonateGolems = 1
									$DonateAtivated = 1
								ElseIf StringInStr($TroopType, "LAVA") Then
									$TroopQuantity = Number(StringRight($TroopType, (StringLen($TroopType) - 5)))
									SetLog("Pushbullet: Request to Donate Lava Hounds has been activated", $COLOR_GREEN)
									GUICtrlSetData($txtNumLava, $TroopQuantity)
									$LavaComp = $TroopQuantity
									GUICtrlSetState($chkDonateLavaHounds, $GUI_CHECKED)
									$ichkDonateLavaHounds = 1
									$DonateAtivated = 1
								ElseIf StringInStr($TroopType, "PEKKA") Then
									$TroopQuantity = Number(StringRight($TroopType, (StringLen($TroopType) - 6)))
									SetLog("Pushbullet: Request to Donate Pekkas has been activated", $COLOR_GREEN)
									GUICtrlSetData($txtNumPekk, $TroopQuantity)
									$PekkComp = $TroopQuantity
									GUICtrlSetState($ChkDonatePekkas, $GUI_CHECKED)
									$iChkDonatePekkas = 1
									$DonateAtivated = 1
								ElseIf StringInStr($TroopType, "BALLOON") Then
									$TroopQuantity = Number(StringRight($TroopType, (StringLen($TroopType) - 5)))
									SetLog("Pushbullet: Request to Donate Balloons has been activated", $COLOR_GREEN)
									GUICtrlSetData($txtNumBall, $TroopQuantity)
									$BallComp = $TroopQuantity
									GUICtrlSetState($chkDonateBalloons, $GUI_CHECKED)
									$ichkDonateBalloons = 1
									$DonateAtivated = 1
								ElseIf StringInStr($TroopType, "HOGS") Then
									$TroopQuantity = Number(StringRight($TroopType, (StringLen($TroopType) - 4)))
									SetLog("Pushbullet: Request to Donate Hog Riders has been activated", $COLOR_GREEN)
									GUICtrlSetData($txtNumHogs, $TroopQuantity)
									$HogsComp = $TroopQuantity
									GUICtrlSetState($ChkDonateHogRiders, $GUI_CHECKED)
									$iChkDonateHogRiders = 1
									$DonateAtivated = 1
								ElseIf StringInStr($TroopType, "DRAGON") Then
									$TroopQuantity = Number(StringRight($TroopType, (StringLen($TroopType) - 7)))
									SetLog("Pushbullet: Request to Donate Dragons has been activated", $COLOR_GREEN)
									GUICtrlSetData($txtNumDrag, $TroopQuantity)
									$DragComp = $TroopQuantity
									GUICtrlSetState($ChkDonateDragons, $GUI_CHECKED)
									$iChkDonateDragons = 1
									$DonateAtivated = 1
								Else
									_Push($iOrigPushB & " | DONATEON Failed, Invalid TroopType\nAvailable Troops: GOLEM|LAVA|PEKKA|BALLOON|HOGS|DRAGON\nExample: DONATEON GOLEM 1")
									$DonateAtivated = 0
								EndIf
								If $DonateAtivated = 1 Then
									_Push($iOrigPushB & " | DONATE Activated" & "\n" & "Troops updated with: " & $TroopType)
									btnStop()
									btnStart()
									_DeleteMessage($iden[$x])
								EndIf
							ElseIf StringInStr($body[$x], StringUpper($iOrigPushB) & " DONATEOFF") Then
								$DonateAtivated = 0
								$TroopType = StringRight($body[$x], StringLen($body[$x]) - StringLen("BOT " & StringUpper($iOrigPushB) & " DONATEOFF "))
								If StringInStr($TroopType, "GOLEM") Then
									$TroopQuantity = Number(StringRight($TroopType, (StringLen($TroopType) - 6)))
									SetLog("Pushbullet: Request to Donate Golems has been de-activated", $COLOR_GREEN)
									GUICtrlSetData($txtNumGole, $TroopQuantity)
									$GoleComp = $TroopQuantity
									GUICtrlSetState($ChkDonateGolems, $GUI_UNCHECKED)
									$iChkDonateGolems = 0
									$DonateAtivated = 1
								ElseIf StringInStr($TroopType, "LAVA") Then
									$TroopQuantity = Number(StringRight($TroopType, (StringLen($TroopType) - 5)))
									SetLog("Pushbullet: Request to Donate Lava Hounds has been de-activated", $COLOR_GREEN)
									GUICtrlSetData($txtNumLava, $TroopQuantity)
									$LavaComp = $TroopQuantity
									GUICtrlSetState($chkDonateLavaHounds, $GUI_UNCHECKED)
									$ichkDonateLavaHounds = 0
									$DonateAtivated = 1
								ElseIf StringInStr($TroopType, "PEKKA") Then
									$TroopQuantity = Number(StringRight($TroopType, (StringLen($TroopType) - 6)))
									SetLog("Pushbullet: Request to Donate Pekkas has been de-activated", $COLOR_GREEN)
									GUICtrlSetData($txtNumPekk, $TroopQuantity)
									$PekkComp = $TroopQuantity
									GUICtrlSetState($ChkDonatePekkas, $GUI_UNCHECKED)
									$iChkDonatePekkas = 0
									$DonateAtivated = 1
								ElseIf StringInStr($TroopType, "BALLOON") Then
									$TroopQuantity = Number(StringRight($TroopType, (StringLen($TroopType) - 5)))
									SetLog("Pushbullet: Request to Donate Balloons has been de-activated", $COLOR_GREEN)
									GUICtrlSetData($txtNumBall, $TroopQuantity)
									$BallComp = $TroopQuantity
									GUICtrlSetState($chkDonateBalloons, $GUI_UNCHECKED)
									$ichkDonateBalloons = 0
									$DonateAtivated = 1
								ElseIf StringInStr($TroopType, "HOGS") Then
									$TroopQuantity = Number(StringRight($TroopType, (StringLen($TroopType) - 4)))
									SetLog("Pushbullet: Request to Donate Hog Riders has been de-activated", $COLOR_GREEN)
									GUICtrlSetData($txtNumHogs, $TroopQuantity)
									$HogsComp = $TroopQuantity
									GUICtrlSetState($ChkDonateHogRiders, $GUI_UNCHECKED)
									$iChkDonateHogRiders = 0
									$DonateAtivated = 1
								ElseIf StringInStr($TroopType, "DRAGON") Then
									$TroopQuantity = Number(StringRight($TroopType, (StringLen($TroopType) - 7)))
									SetLog("Pushbullet: Request to Donate Dragons has been de-activated", $COLOR_GREEN)
									GUICtrlSetData($txtNumDrag, $TroopQuantity)
									$DragComp = $TroopQuantity
									GUICtrlSetState($ChkDonateDragons, $GUI_UNCHECKED)
									$iChkDonateDragons = 0
									$DonateAtivated = 1
								Else
									_Push($iOrigPushB & " | DONATEOFF Failed, Invalid TroopType\nAvailable Troops: GOLEM|LAVA|PEKKA|BALLOON|HOGS|DRAGON\nExample: DONATEOFF GOLEM 1")
									$DonateAtivated = 0
								EndIf
								If $DonateAtivated = 1 Then
									_Push($iOrigPushB & " | DONATE Deactivated" & "\n" & "Troops updated with: " & $TroopType)
									btnStop()
									btnStart()
									_DeleteMessage($iden[$x])
								EndIf
							ElseIf StringInStr($body[$x], StringUpper($iOrigPushB) & " SWITCHPROFILE") Then
								$VillageSelect = StringRight($body[$x], StringLen($body[$x]) - StringLen("BOT " & StringUpper($iOrigPushB) & " SWITCHPROFILE "))
								Local $iIndex = _GUICtrlComboBox_FindString($cmbProfile, $VillageSelect)
								If $iIndex = -1 Then
									SetLog("Pushbullet: Profile Switch failed", $COLOR_RED)
									$profileString = StringReplace(_GUICtrlComboBox_GetList($cmbProfile), "|", "\n")
									_Push($iOrigPushB & " | Error Switch Profile:" & "\n" & "Available Profiles:\n" & $profileString)
								Else
									btnStop()
									_GUICtrlComboBox_SetCurSel($cmbProfile, $iIndex)
									cmbProfile()
									SetLog("Pushbullet: Profile Switch success!", $COLOR_GREEN)
									_Push($iOrigPushB & " | Switched to Profile: " & $VillageSelect & " Success!")
									btnStart()
								EndIf
								_DeleteMessage($iden[$x])
							Else
								Local $lenstr = StringLen("BOT " & StringUpper($iOrigPushB) & " ")
								Local $teststr = StringLeft($body[$x], $lenstr)
								If $teststr = ("BOT " & StringUpper($iOrigPushB) & " ") Then
									SetLog("Pushbullet: received command syntax wrong, command ignored.", $COLOR_RED)
									_Push($iOrigPushB & " | Command not recognized" & "\n" & "Please push BOT HELP to obtain a complete command list.")
									_DeleteMessage($iden[$x])
								EndIf
							EndIf
					EndSwitch

					$body[$x] = ""
					$iden[$x] = ""
				EndIf
			Next
		EndIf
   EndIf

  If $pEnabled2=1 then
	  $oHTTP2 = ObjCreate("WinHTTP.WinHTTPRequest.5.1")
	  $access_token2 = $PushToken2
	  $url= "https://api.telegram.org/bot"
	  $oHTTP2.Open("Get", $url & $access_token2 & "/getupdates", False)
	  $oHTTP2.Send()
	  $Result = $oHTTP2.ResponseText

	  local $chat_id = _StringBetween($Result, 'm":{"id":', ',"f')
	  $chat_id2 = _Arraypop($chat_id)

	  Local $findstr2 = StringRegExp(StringUpper($Result), '"TEXT":"')
      If $findstr2 = 1 Then
	   local $rmessage = _StringBetween($Result, 'text":"' ,'"}}' )           ;take message
	   local $uid = _StringBetween($Result, 'update_id":' ,'"message"' )             ;take update id
	   local $lastmessage = _Arraypop($rmessage)								 ;take last message
	   local $lastuid = _Arraypop($uid)
	   local $body2 = StringUpper(StringStripWS($lastmessage, $STR_STRIPLEADING + $STR_STRIPTRAILING + $STR_STRIPSPACES)) ;upercase & remove space laset message
	   if $first = 0 then
		  $first = 1
		  $lastremote = $lastuid
		  $oHTTP2.Open("Get", $url & $access_token2 & "/getupdates?offset=" & $lastuid  , False)
	      $oHTTP2.Send()
	   EndIf
	   if $lastremote <> $lastuid Then
      	 $lastremote = $lastuid
		 Switch $body2
			case "\/START"
				$oHTTP2.Open("Post", "https://api.telegram.org/bot"&$access_token2&"/sendmessage", False)
				$oHTTP2.SetRequestHeader("Content-Type", "application/json")
;				local $ppush3 = '{"text": "select your remote", "chat_id":' & $chat_id2 &', "reply_markup": {"keyboard": [["stop\n\u25fb","pause\n\II",'
;					 $ppush3 &= '"restart\n\u21aa","resume\n\u25b6"],["help\n\u2753","delete\n\ud83d\udeae","log\n\ud83d\udcd1","stats\n\ud83d\udcca"],['
;					 $ppush3 &= '"screenshot\n\ud83c\udfa6","last raid txt\n\ud83d\udcc4","lastraid\n\ud83d\udcd1"],["troop&spellstats\n\ud83d\udcca",'
;					 $ppush3 &= '"resetstats\n\ud83d\udcca"],["haltattackon\n\u25fb","haltattackoff\n\u25b6"]],"one_time_keyboard": false,"resize_keyboard":true}}}'
				local $ppush3 = '{"text": "select your remote", "chat_id":' & $chat_id2 &', "reply_markup": {"keyboard": [["stop\n\u25fb","pause\n\II",'
					 $ppush3 &= '"resume\n\u25b6"],["help\n\u2753","delete\n\ud83d\udeae","log\n\ud83d\udcd1","stats\n\ud83d\udcca"],['
					 $ppush3 &= '"screenshot\n\ud83c\udfa6","last raid txt\n\ud83d\udcc4","lastraid\n\ud83d\udcd1"],["troop&spellstats\n\ud83d\udcca",'
					 $ppush3 &= '"resetstats\n\ud83d\udcca"],["haltattackon\n\u25fb","haltattackoff\n\u25b6"]],"one_time_keyboard": false,"resize_keyboard":true}}}'
				$oHTTP2.Send($pPush3)
			Case "HELP\N\U2753"
				 Local $txtHelp = "You can remotely control your bot sending commands following this syntax:"
				$txtHelp &= "\n" & "HELP - send this help message"
				$txtHelp &= "\n" & "DELETE  - delete all your previous Push message"
;				$txtHelp &= "\n" & "RESTART - restart the bot named <Village Name> and bluestacks"
				$txtHelp &= "\n" & "STOP - stop the bot named <Village Name>"
				$txtHelp &= "\n" & "PAUSE - pause the bot named <Village Name>"
				$txtHelp &= "\n" & "RESUME   - resume the bot named <Village Name>"
				$txtHelp &= "\n" & "STATS - send Village Statistics of <Village Name>"
				$txtHelp &= "\n" & "LOG - send the current log file of <Village Name>"
				$txtHelp &= "\n" & "LASTRAID - send the last raid loot screenshot of <Village Name>"
				$txtHelp &= "\n" & "LASTRAIDTXT - send the last raid loot values of <Village Name>"
				$txtHelp &= "\n" & "SCREENSHOT - send a screenshot of <Village Name>"
				$txtHelp &= '\n' & "RESETSTATS - reset Village Statistics of <Village Name>"
				$txtHelp &= '\n' & "DONATEON <TROOPNAME> <QUANTITY> - turn on donate for troop & quantity."
				$txtHelp &= '\n' & "DONATEOFF <TROOPNAME> <QUANTITY> - turn off donate for troop & quantity."
				$txtHelp &= '\n' & "TROOP&SPELLSTATS - send Troops & Spells Stats of <Village Name>"
				$txtHelp &= '\n' & "HALTATTACKON - Turn On 'Halt Attack' in the 'Misc' Tab with the default options"
				$txtHelp &= '\n' & "HALTATTACKOFF - Turn Off 'Halt Attack' in the 'Misc' Tab"
				$txtHelp &= '\n' & "SWITCHPROFILE <PROFILENAME> - Swap Profile Village and restart bot"
;				$txtHelp &= "\n"
;				$txtHelp &= "\n" & "Send and recieve chats via Telegram. Use GETCHATS <interval|NOW|STOP> to get the latest clan chat as an image, and SENDCHAT <chat message> to send a chat to your clan"
				_Push($iOrigPushB & " | Request for Help" & "\n" & $txtHelp)
				SetLog("Telegram: Your request has been received from ' " & $iOrigPushB & ". Help has been sent", $COLOR_GREEN)
			 Case "PAUSE\NII"
				If $TPaused = False And $Runstate = True Then
					If ( _ColorCheck(_GetPixelColor($NextBtn[0], $NextBtn[1], True), Hex($NextBtn[2], 6), $NextBtn[3])) = False And IsAttackPage() Then
						SetLog("Telegram: Unable to pause during attack", $COLOR_RED)
						_Push($iOrigPushB & " | Request to Pause" & "\n" & "Unable to pause during attack, try again later.")
					ElseIf ( _ColorCheck(_GetPixelColor($NextBtn[0], $NextBtn[1], True), Hex($NextBtn[2], 6), $NextBtn[3])) = True And IsAttackPage() Then
						ReturnHome(False, False)
						$Is_SearchLimit = True
						$Is_ClientSyncError = False
						UpdateStats()
						$Restart = True
						TogglePauseImpl("Push")
						Return True
					Else
						TogglePauseImpl("Push")
					EndIf
				Else
					SetLog("Telegram: Your bot is currently paused, no action was taken", $COLOR_GREEN)
					_Push($iOrigPushB & " | Request to Pause" & "\n" & "Your bot is currently paused, no action was taken")
				EndIf
			Case "RESUME\N\U25B6"
				If $TPaused = True And $Runstate = True Then
					TogglePauseImpl("Push")
				Else
					SetLog("Telegram: Your bot is currently resumed, no action was taken", $COLOR_GREEN)
					_Push($iOrigPushB & " | Request to Resume" & "\n" & "Your bot is currently resumed, no action was taken")
				EndIf
			Case "DELETE\N\UD83D\UDEAE"
				$oHTTP2.Open("Get", $url & $access_token2 & "/getupdates?offset=" & $lastuid  , False)
				$oHTTP2.Send()
				SetLog("Telegram: Your request has been received.", $COLOR_GREEN)
			Case "LOG\N\UD83D\UDCD1"
				SetLog("Telegram: Your request has been received from " & $iOrigPushB & ". Log is now sent", $COLOR_GREEN)
				_PushFile2($sLogFName, "logs", "text\/plain; charset=utf-8", $iOrigPushB & " | Current Log " & "\n")
			Case "LASTRAID\N\UD83D\UDCD1"
				If $AttackFile <> "" Then
				 _PushFile($AttackFile, "Loots", "image/jpeg", $iOrigPushB & " | Last Raid " & "\n" & $AttackFile)
				Else
				 _Push($iOrigPushB & " | There is no last raid screenshot.")
				EndIf
				SetLog("Telegram: Push Last Raid Snapshot...", $COLOR_GREEN)
			Case "LAST RAID TXT\N\UD83D\UDCC4"
				SetLog("Telegram: Your request has been received. Last Raid txt sent", $COLOR_GREEN)
				_Push($iOrigPushB & " | Last Raid txt" & "\n" & "[G]: " & _NumberFormat($iGoldLast) & " [E]: " & _NumberFormat($iElixirLast) & " [D]: " & _NumberFormat($iDarkLast) & " [T]: " & $iTrophyLast)
			Case "STATS\N\UD83D\UDCCA"
				SetLog("Telegram: Your request has been received. Statistics sent", $COLOR_GREEN)
				Local $GoldGainPerHour = 0
				Local $ElixirGainPerHour = 0
				Local $DarkGainPerHour = 0
				Local $TrophyGainPerHour = 0
				If $FirstAttack = 2 Then
					$GoldGainPerHour = _NumberFormat(Round($iGoldTotal / (Int(TimerDiff($sTimer) + $iTimePassed)) * 3600)) & "K / h"
					$ElixirGainPerHour = _NumberFormat(Round($iElixirTotal / (Int(TimerDiff($sTimer) + $iTimePassed)) * 3600)) & "K / h"
			    EndIf
				If $iDarkStart <> "" Then
					$DarkGainPerHour = _NumberFormat(Round($iDarkTotal / (Int(TimerDiff($sTimer) + $iTimePassed)) * 3600 * 1000)) & " / h"
				EndIf
				$TrophyGainPerHour = _NumberFormat(Round($iTrophyTotal / (Int(TimerDiff($sTimer) + $iTimePassed)) * 3600 * 1000)) & " / h"
				Local $txtStats = " | Stats Village Report" & "\n" & "At Start\n[G]: " & _NumberFormat($iGoldStart) & " [E]: "
					  $txtStats &= _NumberFormat($iElixirStart) & " [D]: " & _NumberFormat($iDarkStart) & " [T]: " & $iTrophyStart
					  $txtStats &= "\n\nNow (Current Resources)\n[G]: " & _NumberFormat($iGoldCurrent) & " [E]: " & _NumberFormat($iElixirCurrent)
					  $txtStats &= " [D]: " & _NumberFormat($iDarkCurrent) & " [T]: " & $iTrophyCurrent & " [GEM]: " & $iGemAmount
					  $txtStats &= "\n \nGain per Hour:\n[G]: " & $GoldGainPerHour & " [E]: " & $ElixirGainPerHour
					  $txtStats &= "\n[D]: " & $DarkGainPerHour & " [T]: " & $TrophyGainPerHour
					  $txtStats &= "\n \n[No. of Free Builders]: " & $iFreeBuilderCount & "\n[No. of Wall Up]: G: "
					  $txtStats &= $iNbrOfWallsUppedGold & "/ E: " & $iNbrOfWallsUppedElixir & "\n\nAttacked: "
					  $txtStats &= GUICtrlRead($lblresultvillagesattacked) & "\nSkipped: " & $iSkippedVillageCount
				_Push($iOrigPushB & $txtStats)
			Case "RESETSTATS\N\UD83D\UDCCA"
				btnResetStats()
				SetLog("Telegram: Your request has been received. Statistics resetted", $COLOR_GREEN)
				_Push($iOrigPushB & " | Request for RESETSTATS has been resetted.")
			Case "TROOP&SPELLSTATS\N\UD83D\UDCCA"
				SetLog("Telegram: Your request has been received. Sending Troop Stats...", $COLOR_GREEN)
				Local $txtTroopStats = " | Troops set to Train:" & "\n" & "Barbs:" & $BarbComp & " Arch:" & $ArchComp & " Gobl:" & $GoblComp
				$txtTroopStats &= '\n' & "Giant:" & $GiantComp & " WallB:" & $WallComp & " Wiza:" & $WizaComp
				$txtTroopStats &= '\n' & "Balloon:" & $BallComp & " Heal:" & $HealComp & " Dragon:" & $DragComp & " Pekka:" & $PekkComp
				$txtTroopStats &= '\n' & "Mini:" & $MiniComp & " Hogs:" & $HogsComp & " Valks:" & $ValkComp
				$txtTroopStats &= '\n' & "Golem:" & $GoleComp & " Witch:" & $WitcComp & " Lava:" & $LavaComp & '\n'
				$txtTroopStats &= '\nCurrent Trained Troops & Spells:'
				For $i = 0 to Ubound($TroopSpellStats)-1
					If $TroopSpellStats[$i][0] <> "" Then
						$txtTroopStats &= '\n' & $TroopSpellStats[$i][0] & ":" & $TroopSpellStats[$i][1]
					EndIf
				Next
				$txtTroopStats &= '\n\n' & "Current Army Camp: " & $CurCamp & "/" & $TotalCamp
				_Push($iOrigPushB & $txtTroopStats)
			Case "SCREENSHOT\N\UD83C\UDFA6"
				SetLog("Telegram: ScreenShot request received", $COLOR_GREEN)
				$RequestScreenshot = 1
			Case "RESTART\N\U21AA"
				SetLog("Telegram: Your request has been received. Bot and BS restarting...", $COLOR_GREEN)
				_Push($iOrigPushB & " | Request to Restart..." & "\n" & "Your bot and BS are now restarting...")
				SaveConfig()
				_Restart()
			Case "STOP\N\U25FB"
				SetLog("Telegram: Your request has been received. Bot is now stopped", $COLOR_GREEN)
				If $Runstate = True Then
				 _Push($iOrigPushB & " | Request to Stop..." & "\n" & "Your bot is now stopping...")
				 btnStop()
				Else
				 _Push($iOrigPushB & " | Request to Stop..." & "\n" & "Your bot is currently stopped, no action was taken")
				EndIf
			Case "HALTATTACKON\N\U25FB"
				GUICtrlSetState($chkBotStop, $GUI_CHECKED)
				btnStop()
				btnStart()
			Case "HALTATTACKOFF\N\U25B6"
				GUICtrlSetState($chkBotStop, $GUI_UNCHECKED)
				btnStop()
				btnStart()
		    Case Else
				If StringInStr($body2, "SENDCHAT") Then
					$chatMessage = StringRight($body2, StringLen($body2) - StringLen("SENDCHAT "))
					$chatMessage = StringLower($chatMessage)
					ChatbotPushbulletQueueChat($chatMessage)
					_Push($iOrigPushB & " | Chat queued, will send on next idle")
				ElseIf StringInStr($body2, "GETCHATS") Then
					$Interval = StringRight($body2, StringLen($body2) - StringLen("GETCHATS "))
					If $Interval = "STOP" Then
						ChatbotPushbulletStopChatRead()
						_Push($iOrigPushB & " | Stopping interval sending")
					ElseIf $Interval = "NOW" Then
						ChatbotPushbulletQueueChatRead()
						_Push($iOrigPushB & " | Command queued, will send clan chat image on next idle")
					Else
						If Number($Interval) <> 0 Then
							ChatbotPushbulletIntervalChatRead(Number($Interval))
							_Push($iOrigPushB & " | Command queued, will send clan chat image on interval")
						Else
							SetLog("Chatbot: incorrect command syntax, Example: GETCHATS NOW|STOP|INTERVAL", $COLOR_RED)
							_Push($iOrigPushB & " | Command not recognized" & "\n" & "Example: GETCHATS NOW|STOP|INTERVAL")
						EndIf
					EndIf
				ElseIf StringInStr($body2, "DONATEON") Then
					$DonateAtivated = 0
					$TroopType = StringRight($body2, StringLen($body2) - StringLen("DONATEON "))
					If StringInStr($TroopType, "GOLEM") Then
						$TroopQuantity = Number(StringRight($TroopType, (StringLen($TroopType) - 6)))
						SetLog("Telegram: Request to Donate Golem has been activated", $COLOR_GREEN)
						GUICtrlSetData($txtNumGole, $TroopQuantity)
						$GoleComp = $TroopQuantity
						GUICtrlSetState($ChkDonateGolems, $GUI_CHECKED)
						$iChkDonateGolems = 1
						$DonateAtivated = 1
					ElseIf StringInStr($TroopType, "LAVA") Then
						$TroopQuantity = Number(StringRight($TroopType, (StringLen($TroopType) - 5)))
						SetLog("Telegram: Request to Donate Lava Hounds has been activated", $COLOR_GREEN)
						GUICtrlSetData($txtNumLava, $TroopQuantity)
						$LavaComp = $TroopQuantity
						GUICtrlSetState($chkDonateLavaHounds, $GUI_CHECKED)
						$ichkDonateLavaHounds = 1
						$DonateAtivated = 1
					ElseIf StringInStr($TroopType, "PEKKA") Then
						$TroopQuantity = Number(StringRight($TroopType, (StringLen($TroopType) - 6)))
						SetLog("Telegram: Request to Donate Pekkas has been activated", $COLOR_GREEN)
						GUICtrlSetData($txtNumPekk, $TroopQuantity)
						$PekkComp = $TroopQuantity
						GUICtrlSetState($ChkDonatePekkas, $GUI_CHECKED)
						$iChkDonatePekkas = 1
						$DonateAtivated = 1
					ElseIf StringInStr($TroopType, "BALLOON") Then
						$TroopQuantity = Number(StringRight($TroopType, (StringLen($TroopType) - 5)))
						SetLog("Telegram: Request to Donate Balloons has been activated", $COLOR_GREEN)
						GUICtrlSetData($txtNumBall, $TroopQuantity)
						$BallComp = $TroopQuantity
						GUICtrlSetState($chkDonateBalloons, $GUI_CHECKED)
						$ichkDonateBalloons = 1
						$DonateAtivated = 1
					ElseIf StringInStr($TroopType, "HOGS") Then
						$TroopQuantity = Number(StringRight($TroopType, (StringLen($TroopType) - 4)))
						SetLog("Telegram: Request to Donate Hog Riders has been activated", $COLOR_GREEN)
						GUICtrlSetData($txtNumHogs, $TroopQuantity)
						$HogsComp = $TroopQuantity
						GUICtrlSetState($ChkDonateHogRiders, $GUI_CHECKED)
						$iChkDonateHogRiders = 1
						$DonateAtivated = 1
					ElseIf StringInStr($TroopType, "DRAGON") Then
						$TroopQuantity = Number(StringRight($TroopType, (StringLen($TroopType) - 7)))
						SetLog("Telegram: Request to Donate Dragons has been activated", $COLOR_GREEN)
						GUICtrlSetData($txtNumDrag, $TroopQuantity)
						$DragComp = $TroopQuantity
						GUICtrlSetState($ChkDonateDragons, $GUI_CHECKED)
						$iChkDonateDragons = 1
						$DonateAtivated = 1
					Else
						_Push($iOrigPushB & " | DONATEON Failed, Invalid TroopType\nAvailable Troops: GOLEM|LAVA|PEKKA|BALLOON|HOGS|DRAGON\nExample: DONATEON GOLEM 1")
						$DonateAtivated = 0
					EndIf
					If $DonateAtivated = 1 Then
						_Push($iOrigPushB & " | DONATE Activated" & "\n" & "Troops updated with: " & $TroopType)
					EndIf
				ElseIf StringInStr($body2, "DONATEOFF") Then
					$DonateAtivated = 0
					$TroopType = StringRight($body2, StringLen($body2) - StringLen("DONATEOFF "))
					If StringInStr($TroopType, "GOLEM") Then
						$TroopQuantity = Number(StringRight($TroopType, (StringLen($TroopType) - 6)))
						SetLog("Telegram: Request to Donate Golems has been de-activated", $COLOR_GREEN)
						GUICtrlSetData($txtNumGole, $TroopQuantity)
						$GoleComp = $TroopQuantity
						GUICtrlSetState($ChkDonateGolems, $GUI_UNCHECKED)
						$iChkDonateGolems = 0
						$DonateAtivated = 1
					ElseIf StringInStr($TroopType, "LAVA") Then
						$TroopQuantity = Number(StringRight($TroopType, (StringLen($TroopType) - 5)))
						SetLog("Telegram: Request to Donate Lava Hounds has been de-activated", $COLOR_GREEN)
						GUICtrlSetData($txtNumLava, $TroopQuantity)
						$LavaComp = $TroopQuantity
						GUICtrlSetState($chkDonateLavaHounds, $GUI_UNCHECKED)
						$ichkDonateLavaHounds = 0
						$DonateAtivated = 1
					ElseIf StringInStr($TroopType, "PEKKA") Then
						$TroopQuantity = Number(StringRight($TroopType, (StringLen($TroopType) - 6)))
						SetLog("Telegram: Request to Donate Pekkas has been de-activated", $COLOR_GREEN)
						GUICtrlSetData($txtNumPekk, $TroopQuantity)
						$PekkComp = $TroopQuantity
						GUICtrlSetState($ChkDonatePekkas, $GUI_UNCHECKED)
						$iChkDonatePekkas = 0
						$DonateAtivated = 1
					ElseIf StringInStr($TroopType, "BALLOON") Then
						$TroopQuantity = Number(StringRight($TroopType, (StringLen($TroopType) - 5)))
						SetLog("Telegram: Request to Donate Balloons has been de-activated", $COLOR_GREEN)
						GUICtrlSetData($txtNumBall, $TroopQuantity)
						$BallComp = $TroopQuantity
						GUICtrlSetState($chkDonateBalloons, $GUI_UNCHECKED)
						$ichkDonateBalloons = 0
						$DonateAtivated = 1
					ElseIf StringInStr($TroopType, "HOGS") Then
						$TroopQuantity = Number(StringRight($TroopType, (StringLen($TroopType) - 4)))
						SetLog("Telegram: Request to Donate Hog Riders has been de-activated", $COLOR_GREEN)
						GUICtrlSetData($txtNumHogs, $TroopQuantity)
						$HogsComp = $TroopQuantity
						GUICtrlSetState($ChkDonateHogRiders, $GUI_UNCHECKED)
						$iChkDonateHogRiders = 0
						$DonateAtivated = 1
					ElseIf StringInStr($TroopType, "DRAGON") Then
						$TroopQuantity = Number(StringRight($TroopType, (StringLen($TroopType) - 7)))
						SetLog("Telegram: Request to Donate Dragons has been de-activated", $COLOR_GREEN)
						GUICtrlSetData($txtNumDrag, $TroopQuantity)
						$DragComp = $TroopQuantity
						GUICtrlSetState($ChkDonateDragons, $GUI_UNCHECKED)
						$iChkDonateDragons = 0
						$DonateAtivated = 1
					Else
						_Push($iOrigPushB & " | DONATEOFF Failed, Invalid TroopType\nAvailable Troops: GOLEM|LAVA|PEKKA|BALLOON|HOGS|DRAGON\nExample: DONATEOFF GOLEM 1")
						$DonateAtivated = 0
					EndIf
					If $DonateAtivated = 1 Then
						_Push($iOrigPushB & " | DONATE Deactivated" & "\n" & "Troops updated with: " & $TroopType)
					EndIf
				ElseIf StringInStr($body2, "SWITCHPROFILE") Then
					$VillageSelect = StringRight($body2, StringLen($body2) - StringLen("SWITCHPROFILE "))
					Local $iIndex = _GUICtrlComboBox_FindString($cmbProfile, $VillageSelect)
					If $iIndex = -1 Then
						SetLog("Telegram: Profile Switch failed", $COLOR_RED)
						$profileString = StringReplace(_GUICtrlComboBox_GetList($cmbProfile), "|", "\n")
						_Push($iOrigPushB & " | Error Switch Profile:" & "\n" & "Available Profiles:\n" & $profileString)
					Else
						btnStop()
						_GUICtrlComboBox_SetCurSel($cmbProfile, $iIndex)
						cmbProfile()
						SetLog("Telegram: Profile Switch success!", $COLOR_GREEN)
						_Push($iOrigPushB & " | Switched to Profile: " & $VillageSelect & " Success!")
						btnStart()
					EndIf
				Else
					SetLog("Telegram: received command syntax wrong, command ignored.", $COLOR_RED)
					_Push($iOrigPushB & " | Command not recognized" & "\n" & "Please push HELP to obtain a complete command list.")
				EndIf

		EndSwitch
	   EndIf
      EndIf
   EndIf

EndFunc   ;==>_RemoteControl

Func _PushBullet($pMessage = "")
    If ($pEnabled = 0 and $pEnabled2 = 0)  Or ($PushToken = "" and $PushToken2 = "") Then Return
    If $pEnabled = 1 Then
		$oHTTP = ObjCreate("WinHTTP.WinHTTPRequest.5.1")
		$access_token = $PushToken
		$oHTTP.Open("Get", "https://api.pushbullet.com/v2/devices", False)
		$oHTTP.SetCredentials($access_token, "", 0)
		$oHTTP.Send()
		$Result = $oHTTP.ResponseText
		Local $device_iden = _StringBetween($Result, 'iden":"', '"')
		Local $device_name = _StringBetween($Result, 'nickname":"', '"')
		Local $device = ""
		Local $pDevice = 1
		$oHTTP.Open("Post", "https://api.pushbullet.com/v2/pushes", False)
		$oHTTP.SetCredentials($access_token, "", 0)
		$oHTTP.SetRequestHeader("Content-Type", "application/json")
		Local $Date = @YEAR & "-" & @MON & "-" & @MDAY
		Local $Time = @HOUR & "." & @MIN
		Local $pPush = '{"type": "note", "body": "' & $pMessage & "\n" & $Date & "__" & $Time & '"}'
		$oHTTP.Send($pPush)
    EndIf
	if $pEnabled2 = 1 then
		 $oHTTP2 = ObjCreate("WinHTTP.WinHTTPRequest.5.1")
		; if $chat_id2 = 0 Then
		 $access_token2 = $PushToken2
		 $oHTTP2.Open("Get", "https://api.telegram.org/bot" & $access_token2 & "/getupdates" , False)
		 $oHTTP2.Send()
		 $Result = $oHTTP2.ResponseText
		 local $chat_id = _StringBetween($Result, 'm":{"id":', ',"f')
		 $chat_id2 = _Arraypop($chat_id)
		; endif
		 $oHTTP2.Open("Post", "https://api.telegram.org/bot" & $access_token2&"/sendmessage", False)
		 $oHTTP2.SetRequestHeader("Content-Type", "application/json")
	     Local $Date = @YEAR & '-' & @MON & '-' & @MDAY
		 Local $Time = @HOUR & '.' & @MIN
		 local $pPush3 = '{"text":"' & $pmessage & '\n' & $Date & '__' & $Time & '", "chat_id":' & $chat_id2 & '}}'
		 $oHTTP2.Send($pPush3)
	  EndIf

EndFunc   ;==>_PushBullet

Func _Push($pMessage)
    If ($pEnabled = 0 and $pEnabled2 = 0)  Or ($PushToken = "" and $PushToken2 = "") Then Return
	If $pEnabled = 1 Then
		$oHTTP = ObjCreate("WinHTTP.WinHTTPRequest.5.1")
		$access_token = $PushToken
		$oHTTP.Open("Post", "https://api.pushbullet.com/v2/pushes", False)
		$oHTTP.SetCredentials($access_token, "", 0)
		$oHTTP.SetRequestHeader("Content-Type", "application/json")
		Local $Date = @YEAR & "-" & @MON & "-" & @MDAY
		Local $Time = @HOUR & "." & @MIN
		Local $pPush = '{"type": "note", "body": "' & $pMessage & "\n" & $Date & "__" & $Time & '"}'
		$oHTTP.Send($pPush)
	EndIf
	If $pEnabled2 = 1 then
	   $access_token2 = $PushToken2
	   $oHTTP2 = ObjCreate("WinHTTP.WinHTTPRequest.5.1")
	   $url= "https://api.telegram.org/bot"
	   $oHTTP2.Open("Post",  $url & $access_token2 & "/sendMessage", False)
	   $oHTTP2.SetRequestHeader("Content-Type", "application/json")
	   Local $Date = @YEAR & '-' & @MON & '-' & @MDAY
	   Local $Time = @HOUR & '.' & @MIN
	   local $pPush3 = '{"text":"' & $pmessage & '\n' & $Date & '__' & $Time & '", "chat_id":' & $chat_id2 & '}}'
	   $oHTTP2.Send($pPush3)
	EndIf
EndFunc   ;==>_Push

Func _PushFile($File, $Folder, $FileType, $body)
    If ($pEnabled = 0 and $pEnabled2 = 0)  Or ($PushToken = "" and $PushToken2 = "") Then Return
    If $pEnabled = 1 Then
		If FileExists($sProfilePath & "\" & $sCurrProfile & '\' & $Folder & '\' & $File) Then
			$oHTTP = ObjCreate("WinHTTP.WinHTTPRequest.5.1")
			$access_token = $PushToken
			$oHTTP.Open("Post", "https://api.pushbullet.com/v2/upload-request", False)
			$oHTTP.SetCredentials($access_token, "", 0)
			$oHTTP.SetRequestHeader("Content-Type", "application/json")

			Local $pPush = '{"file_name": "' & $File & '", "file_type": "' & $FileType & '"}'
			$oHTTP.Send($pPush)
			$Result = $oHTTP.ResponseText

			Local $upload_url = _StringBetween($Result, 'upload_url":"', '"')
			Local $awsaccesskeyid = _StringBetween($Result, 'awsaccesskeyid":"', '"')
			Local $acl = _StringBetween($Result, 'acl":"', '"')
			Local $key = _StringBetween($Result, 'key":"', '"')
			Local $signature = _StringBetween($Result, 'signature":"', '"')
			Local $policy = _StringBetween($Result, 'policy":"', '"')
			Local $file_url = _StringBetween($Result, 'file_url":"', '"')

			If IsArray($upload_url) And IsArray($awsaccesskeyid) And IsArray($acl) And IsArray($key) And IsArray($signature) And IsArray($policy) Then
				$Result = RunWait($pCurl & " -i -X POST " & $upload_url[0] & ' -F awsaccesskeyid="' & $awsaccesskeyid[0] & '" -F acl="' & $acl[0] & '" -F key="' & $key[0] & '" -F signature="' & $signature[0] & '" -F policy="' & $policy[0] & '" -F content-type="' & $FileType & '" -F file=@"' & $sProfilePath & "\" & $sCurrProfile & '\' & $Folder & '\' & $File & '"', "", @SW_HIDE)

				$oHTTP.Open("Post", "https://api.pushbullet.com/v2/pushes", False)
				$oHTTP.SetCredentials($access_token, "", 0)
				$oHTTP.SetRequestHeader("Content-Type", "application/json")
				Local $pPush = '{"type": "file", "file_name": "' & $File & '", "file_type": "' & $FileType & '", "file_url": "' & $file_url[0] & '", "body": "' & $body & '"}'
				$oHTTP.Send($pPush)
			Else
				SetLog("Pusbullet: Unable to send file " & $File, $COLOR_RED)
				_Push($iOrigPushB & " | Unable to Upload File" & "\n" & "Occured an error type 1 uploading file to PushBullet server...")
			EndIf
		Else
			SetLog("Pushbullet: Unable to send file " & $File, $COLOR_RED)
			_Push($iOrigPushB & " | Unable to Upload File" & "\n" & "Occured an error type 2 uploading file to PushBullet server...")
		EndIf
	EndIf
	If $pEnabled2=1 then
		If FileExists($sProfilePath & "\" & $sCurrProfile & '\' & $Folder & '\' & $File) Then
			$access_token2 = $PushToken2
			$oHTTP2 = ObjCreate("WinHTTP.WinHTTPRequest.5.1")
			Local $telegram_url = "https://api.telegram.org/bot" & $access_token2 & "/sendPhoto"
			$Result = RunWait($pCurl & " -i -X POST " & $telegram_url & ' -F chat_id="' & $chat_id2 &' " -F photo=@"' & $sProfilePath & "\" & $sCurrProfile & '\' & $Folder & '\' & $File  & '"', "", @SW_HIDE)
			$oHTTP2.Open("Post", "https://api.telegram.org/bot" & $access_token2 & "/sendPhoto", False)
			$oHTTP2.SetRequestHeader("Content-Type", "application/json")
			Local $pPush = '{"type": "file", "file_name": "' & $File & '", "file_type": "' & $FileType & '", "file_url": "' & $telegram_url & '", "body": "' & $body & '"}'
			$oHTTP2.Send($pPush)
		Else
			SetLog("Telegram: Unable to send file " & $File, $COLOR_RED)
			_Push($iOrigPushB & " | Unable to Upload File" & "\n" & "Occured an error type 2 uploading file to PushBullet server...")
		EndIf
	EndIf

EndFunc   ;==>_PushFile

Func _PushFile2($File, $Folder, $FileType, $body)
	 If FileExists($sProfilePath & "\" & $sCurrProfile & '\' & $Folder & '\' & $File) Then
		$access_token2 = $PushToken2
		$oHTTP2 = ObjCreate("WinHTTP.WinHTTPRequest.5.1")
		Local $telegram_url = "https://api.telegram.org/bot" & $access_token2 & "/SendDocument"
		$Result = RunWait($pCurl & " -i -X POST " & $telegram_url & ' -F chat_id="' & $chat_id2 &' " -F document=@"' & $sProfilePath & "\" & $sCurrProfile & '\' & $Folder & '\' & $File & '";filename="' & StringTrimRight($File, 3) & 'txt"', "", @SW_HIDE)
		$oHTTP2.Open("Post", $telegram_url, False)
		$oHTTP2.SetRequestHeader("Content-Type", "application/json")
		Local $pPush2 = '{"type": "file", "file_name": "' & $File & '", "file_type": "' & $FileType & '", "file_url": "' & $telegram_url & '"}'
		$oHTTP2.Send($pPush2)
	 Else
		SetLog("Telegram: Unable to send file " & $File, $COLOR_RED)
		_Push($iOrigPushB & " | Unable to Upload File" & "\n" & "Occured an error type 2 uploading file to PushBullet server...")
	 EndIf

EndFunc   ;==>_PushFile

Func ReportPushBullet()

    If ($pEnabled = 0 and $pEnabled2 = 0)  Or ($PushToken = "" and $PushToken2 = "") Then Return
	If $iAlertPBVillage = 1 Then
		_PushBullet($iOrigPushB & " | My Village:" & "\n" & " [G]: " & _NumberFormat($iGoldCurrent) & " [E]: " & _NumberFormat($iElixirCurrent) & " [D]: " & _NumberFormat($iDarkCurrent) & "  [T]: " & _NumberFormat($iTrophyCurrent) & " [FB]: " & _NumberFormat($iFreeBuilderCount))
	EndIf

	If $iLastAttack = 1 Then
		If Not ($iGoldLast = "" And $iElixirLast = "") Then _PushBullet($iOrigPushB & " | Last Gain :" & "\n" & " [G]: " & _NumberFormat($iGoldLast) & " [E]: " & _NumberFormat($iElixirLast) & " [D]: " & _NumberFormat($iDarkLast) & "  [T]: " & _NumberFormat($iTrophyLast))
	EndIf
	If _Sleep($iDelayReportPushBullet1) Then Return
	checkMainScreen(False)

EndFunc   ;==>ReportPushBullet


Func _DeletePush($token)

    If $pEnabled = 0 Or $PushToken = "" Then Return
	$oHTTP = ObjCreate("WinHTTP.WinHTTPRequest.5.1")
	$access_token = $token
	$oHTTP.Open("DELETE", "https://api.pushbullet.com/v2/pushes", False)
	$oHTTP.SetCredentials($access_token, "", 0)
	$oHTTP.SetRequestHeader("Content-Type", "application/json")
	$oHTTP.Send()

EndFunc   ;==>_DeletePush

Func _DeleteMessage($iden)

    If $pEnabled = 0 Or $PushToken = "" Then Return
	$oHTTP = ObjCreate("WinHTTP.WinHTTPRequest.5.1")
	$access_token = $PushToken
	$oHTTP.Open("Delete", "https://api.pushbullet.com/v2/pushes/" & $iden, False)
	$oHTTP.SetCredentials($access_token, "", 0)
	$oHTTP.SetRequestHeader("Content-Type", "application/json")
	$oHTTP.Send()
	$iden = ""

EndFunc   ;==>_DeleteMessage

Func PushMsg($Message, $Source = "")

    If $pEnabled = 0 and $pEnabled2 = 0 Then Return
	Local $hBitmap_Scaled
	Switch $Message
		Case "Restarted"
			If ($pEnabled = 1 or $pEnabled2 = 1 ) And $pRemote = 1 Then _Push($iOrigPushB & " | Bot restarted")
		Case "OutOfSync"
			If ($pEnabled = 1 or $pEnabled2 = 1 ) And $pOOS = 1 Then _Push($iOrigPushB & " | Restarted after Out of Sync Error" & "\n" & "Attacking now...")
		Case "LastRaid"
			If ($pEnabled = 1 or $pEnabled2 = 1 ) And $iAlertPBLastRaidTxt = 1 Then
				_Push($iOrigPushB & " | Last Raid txt" & "\n" & "[G]: " & _NumberFormat($iGoldLast) & " [E]: " & _NumberFormat($iElixirLast) & " [D]: " & _NumberFormat($iDarkLast) & " [T]: " & $iTrophyLast)
				If _Sleep($iDelayPushMsg1) Then Return
				SetLog("Pushbullet/Telegram: Last Raid Text has been sent!", $COLOR_GREEN)
			EndIf
			If ($pEnabled = 1 or $pEnabled2 = 1 ) And $pLastRaidImg = 1 Then
				_CaptureRegion(0, 0, $DEFAULT_WIDTH, $DEFAULT_HEIGHT - 45)
				;create a temporary file to send with pushbullet...
				Local $Date = @YEAR & "-" & @MON & "-" & @MDAY
				Local $Time = @HOUR & "." & @MIN
				If $ScreenshotLootInfo = 1 Then
					$AttackFile = $Date & "__" & $Time & " G" & $iGoldLast & " E" & $iElixirLast & " DE" & $iDarkLast & " T" & $iTrophyLast & " S" & StringFormat("%3s", $SearchCount) & ".jpg" ; separator __ is need  to not have conflict with saving other files if $TakeSS = 1 and $chkScreenshotLootInfo = 0
				Else
					$AttackFile = $Date & "__" & $Time & ".jpg" ; separator __ is need  to not have conflict with saving other files if $TakeSS = 1 and $chkScreenshotLootInfo = 0
				EndIf
				$hBitmap_Scaled = _GDIPlus_ImageResize($hBitmap, _GDIPlus_ImageGetWidth($hBitmap) / 2, _GDIPlus_ImageGetHeight($hBitmap) / 2) ;resize image
				_GDIPlus_ImageSaveToFile($hBitmap_Scaled, $dirLoots & $AttackFile)
				_GDIPlus_ImageDispose($hBitmap_Scaled)
				;push the file
				SetLog("Pushbullet/Telegram: Last Raid screenshot has been sent!", $COLOR_GREEN)
				_PushFile($AttackFile, "Loots", "image/jpeg", $iOrigPushB & " | Last Raid" & "\n" & $AttackFile)
				;wait a second and then delete the file
				If _Sleep($iDelayPushMsg1) Then Return
				Local $iDelete = FileDelete($dirLoots & $AttackFile)
				If Not ($iDelete) Then SetLog("Pushbullet/Telegram: An error occurred deleting temporary screenshot file.", $COLOR_RED)
			EndIf
		Case "FoundWalls"
			If ($pEnabled = 1 or $pEnabled2 = 1 ) And $pWallUpgrade = 1 Then _Push($iOrigPushB & " | Found Wall level " & $icmbWalls + 4 & "\n" & " Wall segment has been located...\nUpgrading ...")
		Case "SkypWalls"
			If ($pEnabled = 1 or $pEnabled2 = 1 ) And $pWallUpgrade = 1 Then _Push($iOrigPushB & " | Cannot find Wall level " & $icmbWalls + 4 & "\n" & "Skip upgrade ...")
		Case "AnotherDevice3600"
			If ($pEnabled = 1 or $pEnabled2 = 1 ) And $pAnotherDevice = 1 Then _Push($iOrigPushB & " | 1. Another Device has connected" & "\n" & "Another Device has connected, waiting " & Floor(Floor($sTimeWakeUp / 60) / 60) & " hours " & Floor(Mod(Floor($sTimeWakeUp / 60), 60)) & " minutes " & Floor(Mod($sTimeWakeUp, 60)) & " seconds")
		Case "AnotherDevice60"
			If ($pEnabled = 1 or $pEnabled2 = 1 ) And $pAnotherDevice = 1 Then _Push($iOrigPushB & " | 2. Another Device has connected" & "\n" & "Another Device has connected, waiting " & Floor(Mod(Floor($sTimeWakeUp / 60), 60)) & " minutes " & Floor(Mod($sTimeWakeUp, 60)) & " seconds")
		Case "AnotherDevice"
			If ($pEnabled = 1 or $pEnabled2 = 1 ) And $pAnotherDevice = 1 Then _Push($iOrigPushB & " | 3. Another Device has connected" & "\n" & "Another Device has connected, waiting " & Floor(Mod($sTimeWakeUp, 60)) & " seconds")
		Case "TakeBreak"
			If ($pEnabled = 1 or $pEnabled2 = 1 ) And $pTakeAbreak = 1 Then _Push($iOrigPushB & " | Chief, we need some rest!" & "\n" & "Village must take a break..")
		Case "CocError"
			If ($pEnabled = 1 or $pEnabled2 = 1 ) And $pOOS = 1 Then _Push($iOrigPushB & " | CoC Has Stopped Error .....")
		Case "Pause"
			If ($pEnabled = 1 or $pEnabled2 = 1 ) And $pRemote = 1 And $Source = "Push" Then _Push($iOrigPushB & " | Request to Pause..." & "\n" & "Your request has been received. Bot is now paused")
		Case "Resume"
			If ($pEnabled = 1 or $pEnabled2 = 1 ) And $pRemote = 1 And $Source = "Push" Then _Push($iOrigPushB & " | Request to Resume..." & "\n" & "Your request has been received. Bot is now resumed")
		Case "OoSResources"
			If ($pEnabled = 1 or $pEnabled2 = 1 ) And $pOOS = 1 Then _Push($iOrigPushB & " | Disconnected after " & StringFormat("%3s", $SearchCount) & " skip(s)" & "\n" & "Cannot locate Next button, Restarting Bot...")
		Case "MatchFound"
			If ($pEnabled = 1 or $pEnabled2 = 1 ) And $pMatchFound = 1 Then _Push($iOrigPushB & " | " & $sModeText[$iMatchMode] & " Match Found! after " & StringFormat("%3s", $SearchCount) & " skip(s)" & "\n" & "[G]: " & _NumberFormat($searchGold) & "; [E]: " & _NumberFormat($searchElixir) & "; [D]: " & _NumberFormat($searchDark) & "; [T]: " & $searchTrophy)
		Case "UpgradeWithGold"
			If ($pEnabled = 1 or $pEnabled2 = 1 ) And $pWallUpgrade = 1 Then _Push($iOrigPushB & " | Upgrade completed by using GOLD" & "\n" & "Complete by using GOLD ...")
		Case "UpgradeWithElixir"
			If ($pEnabled = 1 or $pEnabled2 = 1 ) And $pWallUpgrade = 1 Then _Push($iOrigPushB & " | Upgrade completed by using ELIXIR" & "\n" & "Complete by using ELIXIR ...")
		Case "NoUpgradeWallButton"
			If ($pEnabled = 1 or $pEnabled2 = 1 ) And $pWallUpgrade = 1 Then _Push($iOrigPushB & " | No Upgrade Gold Button" & "\n" & "Cannot find gold upgrade button ...")
		Case "NoUpgradeElixirButton"
			If ($pEnabled = 1 or $pEnabled2 = 1 ) And $pWallUpgrade = 1 Then _Push($iOrigPushB & " | No Upgrade Elixir Button" & "\n" & "Cannot find elixir upgrade button ...")
		Case "RequestScreenshot"
			Local $Date = @YEAR & "-" & @MON & "-" & @MDAY
			Local $Time = @HOUR & "." & @MIN
			_CaptureRegion(0, 0, $DEFAULT_WIDTH, $DEFAULT_HEIGHT)
			$hBitmap_Scaled = _GDIPlus_ImageResize($hBitmap, _GDIPlus_ImageGetWidth($hBitmap) / 2, _GDIPlus_ImageGetHeight($hBitmap) / 2) ;resize image
			Local $Screnshotfilename = "Screenshot_" & $Date & "_" & $Time & ".jpg"
			_GDIPlus_ImageSaveToFile($hBitmap_Scaled, $dirTemp & $Screnshotfilename)
			_GDIPlus_ImageDispose($hBitmap_Scaled)
			_PushFile($Screnshotfilename, "Temp", "image/jpeg", $iOrigPushB & " | Screenshot of your village " & "\n" & $Screnshotfilename)
			SetLog("Pushbullet/Telegram: Screenshot sent!", $COLOR_GREEN)
			$RequestScreenshot = 0
			;wait a second and then delete the file
			If _Sleep($iDelayPushMsg2) Then Return
			Local $iDelete = FileDelete($dirTemp & $Screnshotfilename)
			If Not ($iDelete) Then SetLog("Pushbullet/Telegram: An error occurred deleting the temporary screenshot file.", $COLOR_RED)
		Case "DeleteAllPBMessages"
			_DeletePush(GUICtrlRead($PushBTokenValue))
			SetLog("PushBullet/Telegram: All messages deleted.", $COLOR_GREEN)
			$iDeleteAllPushesNow = False ; reset value
		Case "CampFull"
			If ($pEnabled = 1 or $pEnabled2 = 1 ) And $ichkAlertPBCampFull = 1 Then
				If $ichkAlertPBCampFullTest = 0 Then
					_Push($iOrigPushB & " | Your Army Camps are now Full")
					$ichkAlertPBCampFullTest = 1
 				EndIf
 			EndIf
		Case "CheckBuilderIdle"
			If $pEnabled = 1 And $ichkAlertBuilderIdle = 1 Then
				Local $iAvailBldr = $iFreeBuilderCount - $iSaveWallBldr
				if $iAvailBldr > 0 Then
					if $iReportIdleBuilder <> $iAvailBldr Then
						_Push($iOrigPushB & " | You have "&$iAvailBldr&" builder(s) idle.")
						SetLog("Pushbullet: You have "&$iAvailBldr&" builder(s) idle.", $COLOR_GREEN)
						$iReportIdleBuilder = $iAvailBldr
					EndIf
				Else
					$iReportIdleBuilder = 0
				EndIf
			EndIf
 	EndSwitch

EndFunc   ;==>PushMsg


Func _DeleteOldPushes()

    If $pEnabled = 0 Or $PushToken = "" Or $ichkDeleteOldPushes = 0 Then Return
	;local UTC time
	Local $tLocal = _Date_Time_GetLocalTime()
	Local $tSystem = _Date_Time_TzSpecificLocalTimeToSystemTime(DllStructGetPtr($tLocal))
	Local $timeUTC = _Date_Time_SystemTimeToDateTimeStr($tSystem, 1)

	;local $timestamplimit = _DateDiff( 's',"1970/01/01 00:00:00", _DateAdd("h",-48,$timeUTC) ) ; limit to 48h read push, antiban purpose
	Local $timestamplimit = 0

	$oHTTP = ObjCreate("WinHTTP.WinHTTPRequest.5.1")
	$access_token = $PushToken
	$oHTTP.Open("Get", "https://api.pushbullet.com/v2/pushes?active=true&modified_after=" & $timestamplimit, False) ; limit to 48h read push, antiban purpose
	$oHTTP.SetCredentials($access_token, "", 0)
	$oHTTP.SetRequestHeader("Content-Type", "application/json")
	$oHTTP.Send()
	$Result = $oHTTP.ResponseText
	Local $findstr = StringRegExp($Result, ',"created":')
	Local $msgdeleted = 0
	If $findstr = 1 Then
		Local $body = _StringBetween($Result, '"body":"', '"', "", False)
		Local $iden = _StringBetween($Result, '"iden":"', '"', "", False)
		Local $created = _StringBetween($Result, '"created":', ',', "", False)
		If IsArray($body) And IsArray($iden) And IsArray($created) Then
			For $x = 0 To UBound($created) - 1
				If $iden <> "" And $created <> "" Then
					Local $hdif = _DateDiff('h', _GetDateFromUnix($created[$x]), $timeUTC)
					If $hdif >= $icmbHoursPushBullet Then
						;	setlog("Pushbullet, deleted message: (+" & $hdif & "h)" & $body[$x] )
						$msgdeleted += 1
						_DeleteMessage($iden[$x])
						;else
						;	setlog("Pushbullet, skypped message: (+" & $hdif & "h)" & $body[$x] )
					EndIf
				EndIf
				$body[$x] = ""
				$iden[$x] = ""
			Next
		EndIf
	EndIf
	If $msgdeleted > 0 Then
		setlog("Pushbullet: removed " & $msgdeleted & " messages older than " & $icmbHoursPushBullet & " h ", $COLOR_GREEN)
		;_Push($iOrigPushB & " | removed " & $msgdeleted & " messages older than " & $icmbHoursPushBullet & " h ")
	EndIf

EndFunc   ;==>_DeleteOldPushes


Func _GetDateFromUnix($nPosix)

    If $pEnabled = 0 and $pEnabled2 = 0 Then Return

	Local $nYear = 1970, $nMon = 1, $nDay = 1, $nHour = 00, $nMin = 00, $nSec = 00, $aNumDays = StringSplit("31,28,31,30,31,30,31,31,30,31,30,31", ",")
	While 1
		If (Mod($nYear + 1, 400) = 0) Or (Mod($nYear + 1, 4) = 0 And Mod($nYear + 1, 100) <> 0) Then; is leap year
			If $nPosix < 31536000 + 86400 Then ExitLoop
			$nPosix -= 31536000 + 86400
			$nYear += 1
		Else
			If $nPosix < 31536000 Then ExitLoop
			$nPosix -= 31536000
			$nYear += 1
		EndIf
	WEnd
	While $nPosix > 86400
		$nPosix -= 86400
		$nDay += 1
	WEnd
	While $nPosix > 3600
		$nPosix -= 3600
		$nHour += 1
	WEnd
	While $nPosix > 60
		$nPosix -= 60
		$nMin += 1
	WEnd
	$nSec = $nPosix
	For $i = 1 To 12
		If $nDay < $aNumDays[$i] Then ExitLoop
		$nDay -= $aNumDays[$i]
		$nMon += 1
	Next
	;   Return $nDay & "/" & $nMon & "/" & $nYear & " " & $nHour & ":" & $nMin & ":" & $nSec
	Return $nYear & "-" & $nMon & "-" & $nDay & " " & $nHour & ":" & $nMin & ":" & StringFormat("%02i", $nSec)

EndFunc   ;==>_GetDateFromUnix