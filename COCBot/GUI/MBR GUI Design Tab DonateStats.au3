; #FUNCTION# ====================================================================================================================
; Name ..........: MBR GUI Design
; Description ...: This file Includes GUI Design
; Syntax ........:
; Parameters ....: None
; Return values .: None
; Author ........: Cutidudz (2016)
; Modified ......:
; Remarks .......: This file is part of MyBot, previously known as ClashGameBot. Copyright 2015-2016
;                  MyBot is distributed under the terms of the GNU GPL
; Related .......:
; Link ..........: https://github.com/MyBotRun/MyBot/wiki
; Example .......: No
; ===============================================================================================================================

;~ -------------------------------------------------------------
;~ DonateStats Tab
;~ -------------------------------------------------------------
#include <ListViewConstants.au3>
#include <GuiListView.au3>

Local $hImage, $lvDonatedTroops

If Not FileExists($dirTemp & "DonateStats\") Then DirCreate($dirTemp & "DonateStats\")

$tabDonateStats = GUICtrlCreateTabItem("Donate Stats")
Local $x = 30, $y = 145
$lvDonatedTroops = GUICtrlCreateListView("Name|Barbarians|Archers|Giants|Goblins|WallBreakers|Balloons|Wizards|Healers|Dragons|Pekkas|Minions|HogRiders|Valkyries|Golems|Witches|LavaHounds|Bowler|Poison|EarthQuake|Haste", $x - 25, $y, 459, 363, $LVS_REPORT)
_GUICtrlListView_SetExtendedListViewStyle($lvDonatedTroops, $LVS_EX_GRIDLINES+$LVS_EX_FULLROWSELECT)
;_GUICtrlListView_HideColumn ($lvDonatedTroops, 0)
_GUICtrlListView_SetColumnWidth($lvDonatedTroops, 0, 139)
$DonateStatsReset = GUICtrlCreateButton("Reset Stats", $x + 366, $y - 20, 67, 20)
_GUICtrlListView_SetExtendedListViewStyle(-1, $WS_EX_TOPMOST+$WS_EX_TRANSPARENT)
GUICtrlSetOnEvent(-1, "DonateStatsReset")

For $x = 0 To 18
	_GUICtrlListView_JustifyColumn($lvDonatedTroops, $x, 2) ; Center text in all columns
Next

LoadDonateStats()

