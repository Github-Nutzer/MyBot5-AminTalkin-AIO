
; #FUNCTION# ====================================================================================================================
; Name ..........: DonateStats
; Description ...: GetTroopColumn(), LoadDonateStats, CompareBitmaps(), part of DonateStats, for collecting total counts of Troops donated
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



Func GetTroopColumn($iTroopName)
	$ColCount = _GUICtrlListView_GetColumnCount($lvDonatedTroops)
	For $ColIndex = 0 To $ColCount
		$ColInfo = _GUICtrlListView_GetColumn($lvDonatedTroops, $ColIndex)
		If Not @error And IsArray($ColInfo) Then
			If $iTroopName = $ColInfo[5] Then
				Return $ColIndex
			EndIf

		EndIf
	Next


EndFunc

Func LoadDonateStats()
	;_GUICtrlListView_DeleteAllItems($lvDonatedTroops)
	$hImage = _GUIImageList_Create(139, 25)

	Local $aFileList = _FileListToArray($dirTemp & "DonateStats\", "*.bmp")

	If Not @error And IsArray($aFileList) Then
		For $x = 1 To $aFileList[0]
			;ConsoleWrite($aFileList[$x] & @CRLF)
			_GUIImageList_AddBitmap($hImage, $dirTemp & "DonateStats\" & $aFileList[$x])
			_GUICtrlListView_AddItem($lvDonatedTroops, $aFileList[$x], $x-1)
			;_ArrayAdd($DonateStats, $aFileList[$x])
		Next

		_GUICtrlListView_SetImageList($lvDonatedTroops, $hImage, 1)

	EndIf

EndFunc

Func CompareBitmaps($bm1, $bm2)

    $Bm1W = _GDIPlus_ImageGetWidth($bm1)
    $Bm1H = _GDIPlus_ImageGetHeight($bm1)
    $BitmapData1 = _GDIPlus_BitmapLockBits($bm1, 0, 0, $Bm1W, $Bm1H, $GDIP_ILMREAD, $GDIP_PXF32RGB)
    $Stride = DllStructGetData($BitmapData1, "Stride")
    $Scan0 = DllStructGetData($BitmapData1, "Scan0")

    $ptr1 = $Scan0
    $size1 = ($Bm1H - 1) * $Stride + ($Bm1W - 1) * 4


    $Bm2W = _GDIPlus_ImageGetWidth($bm2)
    $Bm2H = _GDIPlus_ImageGetHeight($bm2)
    $BitmapData2 = _GDIPlus_BitmapLockBits($bm2, 0, 0, $Bm2W, $Bm2H, $GDIP_ILMREAD, $GDIP_PXF32RGB)
    $Stride = DllStructGetData($BitmapData2, "Stride")
    $Scan0 = DllStructGetData($BitmapData2, "Scan0")

    $ptr2 = $Scan0
    $size2 = ($Bm2H - 1) * $Stride + ($Bm2W - 1) * 4

    $smallest = $size1
    If $size2 < $smallest Then $smallest = $size2
    $call = DllCall("msvcrt.dll", "int:cdecl", "memcmp", "ptr", $ptr1, "ptr", $ptr2, "int", $smallest)



    _GDIPlus_BitmapUnlockBits($bm1, $BitmapData1)
    _GDIPlus_BitmapUnlockBits($bm2, $BitmapData2)

    Return ($call[0]=0)


EndFunc  ;==>CompareBitmaps

Func DonateStatsReset()
	_GUICtrlListView_DeleteAllItems ($lvDonatedTroops)
EndFunc