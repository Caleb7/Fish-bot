#cs ----------------------------------------------------------------------------
 AutoIt Version: 3.3.14.5
 Author:         Caleb Alexander
 Script Function: Not a fish b0t
#ce ----------------------------------------------------------------------------

; Script Start - Add your code below here

#include <GUIConstantsEx.au3>
#include <ButtonConstants.au3>
#include <StaticConstants.au3>
#include <WindowsConstants.au3>
#include <Timers.au3>
#include <ComboConstants.au3>
#include <SliderConstants.au3>
#include <Array.au3>
#include <GuiEdit.au3>

#Region ### START Koda GUI section ### Form=C:\Users\Dream\Desktop\Camel Royal Turkish Blend\GUI.kxf
$Form1 = GUICreate("Form1", 318, 365, 40, 125, $WS_POPUP )
$edit = GUICtrlCreateEdit( "", 5, 270, 308, 90 )
$Button1 = GUICtrlCreateButton("Setup", 8, 72, 75, 25)
$Button2 = GUICtrlCreateButton("Start", 8, 8, 75, 25)
$Button3 = GUICtrlCreateButton("Stop", 8, 40, 75, 25)
$Label1 = GUICtrlCreateLabel("Uptime: 00:00:00", 88, 8, 85, 17)
$Checkbox1 = GUICtrlCreateCheckbox("Autoreply Whisper", 88, 24, 113, 17)
$Checkbox2 = GUICtrlCreateCheckbox("Pause on move", 88, 40, 100, 17)
$Combo1 = GUICtrlCreateCombo("", 88, 96, 217, 25, BitOR($CBS_DROPDOWNLIST,$CBS_AUTOHSCROLL))
GUICtrlSetData(-1, "Autostop: 1 hour|Autostop: 2 hours|Autostop: 4 hours|Autostop: 5 hours|Autostop: 6 hours|Autostop: 7 hours|Autostop: 8 hours|Autostop: 10 hours|Autostop: 12 hours|Autostop: 18 hours|Autostop: 24 hours|Autostop: Never")
$Combo2 = GUICtrlCreateCombo("", 88, 120, 217, 25, BitOR($CBS_DROPDOWNLIST,$CBS_AUTOHSCROLL))
GUICtrlSetData(-1, "Autopause Every: 30 minutes|Autopause Every: 1 hour|Autopause Every: 2 hours|Autopause Every: 3 hours|Autopause Every: 6 hours|Autopause Every: 8 hours|Autopause: Never")
$Checkbox3 = GUICtrlCreateCheckbox("Random talking", 88, 56, 97, 17)
$Checkbox4 = GUICtrlCreateCheckbox("Random other", 88, 72, 97, 17)
$Label2 = GUICtrlCreateLabel("Search Coordinates: 000, 000 -> 000, 000", 88, 144, 202, 17)
$Label3 = GUICtrlCreateLabel("Bobber Color1: 0x000000", 88, 160, 124, 17)
$Label4 = GUICtrlCreateLabel("Bobber Color2: 0x000000", 88, 176, 124, 17)
$Label5 = GUICtrlCreateLabel("Bobber Color3 0x000000", 88, 192, 121, 17)
$Label6 = GUICtrlCreateLabel("Volume Bar Color: 0x000000", 88, 208, 138, 17)
$Button4 = GUICtrlCreateButton("Save Profile", 8, 104, 75, 25)
$Slider1 = GUICtrlCreateSlider(160, 222, 142, 21, BitOR($GUI_SS_DEFAULT_SLIDER,$TBS_NOTICKS))
$Label7 = GUICtrlCreateLabel("Sensitivity: 00", 88, 224, 69, 17)
$Pic1 = GUICtrlCreatePic(@ScriptDir & "\icon.jpg", 220, 8, 84, 84)
$Label8 = GUICtrlCreateLabel("License: Free", 88, 240, 68, 17)
$Label9 = GUICtrlCreateLabel("v1.137", 272, 240, 37, 17)
$Button5 = GUICtrlCreateButton("Exit", 8, 232, 75, 25)
$Button6 = GUICtrlCreateButton("Help", 8, 136, 75, 25)
$Button7 = GUICtrlCreateButton("About", 8, 168, 75, 25)
$Button8 = GUICtrlCreateButton("Activate", 8, 200, 75, 25)
WinSetOnTop( "Form1", "", $WINDOWS_ONTOP )
;GUISetControlsVisible($Form1)
GUISetState(@SW_SHOW)
#EndRegion ### END Koda GUI section ###

Global $Setup_GUI

GUIRegisterMsg( $WM_NCHITTEST, "WM_NCHITTEST" )
Func WM_NCHITTEST($hWnd, $iMsg, $iwParam, $ilParam)
	If $hWnd == $Form1 And $iMsg = $WM_NCHITTEST Then Return $HTCAPTION
EndFunc

Global  $FishingBobberColor1, $FishingBobberColor2, $FishingBobberColor3, _
		$FishingSearchCoordinatesLeft, $FishingSearchCoordinatesRight, _
		$FishingSearchCoordinatesTop, $FishingSearchCoordinatesBottom, _
		$ColorSensitivity, $AutoreplyWhisper, $PauseOnMove, $RandomTalking, _
		$RandomOther, $Autopause, $AutoStop, $Version, $LicenseKey, _
		$FishingTimer, $PauseTimer, $StopTimer, $FishingButton, $BobbleButton, _
		$On, $LureTimer, _
		$DataSize
Global $found = 0

Global $DataFile = @ScriptDir & "\settings.ini"

Opt("WinTitleMatchMode", 2)

Load()

Print( "Waiting for window to become active..." )
WinWaitActive( "World of Warcraft" )
Print( "Found window!" )
Global $hWnd = WinGetHandle( "[ACTIVE]" )
Local $xy = WinGetPos( $hWnd )
WinMove( $form1, "", $xy[0], $xy[1] )
Print( "Searching for volume mixer..." )
Global $hWndVol = WinGetHandle( "Volume Mixer" )
WinSetOnTop( $hWndVol, "", $WINDOWS_ONTOP )

While 1
    Switch GUIGetMsg()
		Case $Button1
			SetupButton()
		Case $Button2
			StartButton()
		Case $Button3
			StopButton()
		Case $Button4
			SaveProfileButton()
		Case $Button5
            ExitButton()
			ExitLoop
		Case $Button6
			HelpButton()
		Case $Button7
			AboutButton()
		Case $Button8
			ActivateButton()
	EndSwitch

	Loop()

WEnd

Func SetupButton()
	Local $step = 1
	While $step < 8
		Switch $step
			Case 1
				Setup_1()
			Case 2
				Setup_2()
			Case 3
				Setup_3()
			Case 4
				Setup_4()
			Case 5
				Setup_5()
			Case 6
				Setup_6()
			Case 7
				Setup_7()
		EndSwitch
	WEnd
EndFunc

Func StartButton()
	; start the bot
EndFunc

Func StopButton()
	; stop the bot
EndFunc

Func SaveProfileButton()
	; save stuff to profile
EndFunc

Func ExitButton()
	; stuff to do before app exits
EndFunc

Func HelpButton()
	; how to use the app
EndFunc

Func AboutButton()
	; about the app
EndFunc

Func ActivateButton()
	; activate license
EndFunc

Func Loop()

	If _Timer_Diff( $FishingTimer ) > Random( 30500, 32500 ) Then
		CastPole()
	EndIf

	If $found == 0 Then
		Local $pos = WinGetPos( $hWnd )
		Local $size = WinGetClientSize( $hWnd )

		$pos[0] = $pos[0] + ( $size[0] / 3.5 )
		$pos[1] = $pos[1] + ( $size[1] / 3.5 )
		$size[0] = $size[0] - ( $size[0] / 3.5 )
		$size[1] = $size[1] - ( $size[1] / 3.5 )


		;Local $coords = PixelSearch( $pos[0], $pos[1], $size[0], $size[1], 0x1E2D55, 15 )
		Local $coords = PixelSearch( $pos[0], $pos[1], $size[0], $size[1], 0x351C17, 15 )

		If @error Then
			$found = 0
		Else
			Print( "Bobber found!" )
			MouseMove( $coords[0] + Random( 10, 20 ), $coords[1] + Random( 10, 20 ), 5 )
			Print( "Waiting for fish to bite..." )
			$found = 1
			Sleep( 250 )
		EndIf
	EndIf

	If $found == 1 Then
		Local $color =  PixelGetColor( 1722, 946 )
		If $color <> 0xE7EAEA Then
			MouseClick( "left", MouseGetPos( 0 ), MouseGetPos( 1 ) )
			Sleep( Random( 1500, 2500 ) )
			CastPole()
		Else
			Sleep( 500 )
		EndIf
	EndIf

EndFunc

Func CastPole()
	WinActivate( $hWnd )
	Send( "{" & $FishingButton & "}" )
	Print( "Casting pole..." )
	$FishingTimer = _Timer_Init()
	Sleep( 2000 )
	Print( "Searching for bobber..." )
	$found = 0
EndFunc

Func CastLure()
	WinActivate( "World of Warcraft" )
	Send( "{" & $BobbleButton & "}" )
EndFunc

Func Load()
	$FishingBobberColor1 = IniRead( $DataFile, "Settings", "BobberColor1", "" )
	$FishingBobberColor2 = IniRead( $DataFile, "Settings", "BobberColor2", "" )
	$FishingBobberColor3 = IniRead( $DataFile, "Settings", "BobberColor3", "" )
	$FishingSearchCoordinatesLeft = IniRead( $DataFile, "Settings", "SearchCoordinatesLeft", "" )
	$FishingSearchCoordinatesRight = IniRead( $DataFile, "Settings", "SearchCoordinatesRight", "" )
	$FishingSearchCoordinatesTop = IniRead( $DataFile, "Settings", "SearchCoordinatesTop", "" )
	$FishingSearchCoordinatesBottom = IniRead( $DataFile, "Settings", "SearchCoordinatesBottom", "" )
	$ColorSensitivity = IniRead( $DataFile, "Settings", "ColorSensitivity", "30" )
	$AutoreplyWhisper = IniRead( $DataFile, "Settings", "AutoreplyWhisper", "True" )
	$PauseOnMove = IniRead( $DataFile, "Settings", "PauseOnMove", "True" )
	$RandomTalking = IniRead( $DataFile, "Settings", "RandomTalking", "False" )
	$RandomOther = IniRead( $DataFile, "Settings", "RandomOther", "False" )
	$Autopause = IniRead( $DataFile, "Settings", "AutoPause", "False" )
	$PauseTimer = IniRead( $DataFile, "Settings", "PauseTimer", "5" )
	$AutoStop = IniRead( $DataFile, "Settings", "AutoStop", "False" )
	$StopTimer = IniRead( $DataFile, "Settings", "StopTimer", "300" )
	$Version = IniRead( $DataFile, "Settings", "Version", "1.0" )
	$LicenseKey = IniRead( $DataFile, "Settings", "License", "free" )
	$FishingButton = IniRead( $DataFile, "Settings", "CastPoleButton", "y" )
	$BobbleButton = IniRead( $DataFile, "Settings", "CastLureButton", "2" )
EndFunc

Func Setup_1()

EndFunc

Func Setup_2()

EndFunc

Func Setup_3()

EndFunc

Func Setup_4()

EndFunc

Func Setup_5()

EndFunc

Func Setup_6()

EndFunc

Func Setup_7()

EndFunc

Func Print( $data )
	_GUICtrlEdit_AppendText( $edit, $data & @CRLF )
EndFunc

Func GUISetControlsVisible($hWnd)
    Local $aClassList, $aM_Mask, $aCtrlPos, $aMask

    $aClassList = StringSplit(_WinGetClassListEx($hWnd), @LF)
    $aM_Mask = DllCall("gdi32.dll", "long", "CreateRectRgn", "long", 0, "long", 0, "long", 0, "long", 0)

    For $i = 1 To UBound($aClassList) - 1
        $aCtrlPos = ControlGetPos($hWnd, '', $aClassList[$i])
        If Not IsArray($aCtrlPos) Then ContinueLoop

        $aMask = DllCall("gdi32.dll", "long", "CreateRectRgn", _
            "long", $aCtrlPos[0], _
            "long", $aCtrlPos[1], _
            "long", $aCtrlPos[0] + $aCtrlPos[2], _
            "long", $aCtrlPos[1] + $aCtrlPos[3])
        DllCall("gdi32.dll", "long", "CombineRgn", "long", $aM_Mask[0], "long", $aMask[0], "long", $aM_Mask[0], "int", 2)
    Next
    DllCall("user32.dll", "long", "SetWindowRgn", "hwnd", $hWnd, "long", $aM_Mask[0], "int", 1)
EndFunc

Func _WinGetClassListEx($sTitle)
    Local $sClassList = WinGetClassList($sTitle)
    Local $aClassList = StringSplit($sClassList, @LF)
    Local $sRetClassList = "", $sHold_List = "|"
    Local $aiInHold, $iInHold

    For $i = 1 To UBound($aClassList) - 1
        If $aClassList[$i] = "" Then ContinueLoop

        If StringRegExp($sHold_List, "\|" & $aClassList[$i] & "~(\d+)\|") Then
            $aiInHold = StringRegExp($sHold_List, ".*\|" & $aClassList[$i] & "~(\d+)\|.*", 1)
            $iInHold = Number($aiInHold[UBound($aiInHold)-1])

            If $iInHold = 0 Then $iInHold += 1

            $aClassList[$i] &= "~" & $iInHold + 1
            $sHold_List &= $aClassList[$i] & "|"

            $sRetClassList &= $aClassList[$i] & @LF
        Else
            $aClassList[$i] &= "~1"
            $sHold_List &= $aClassList[$i] & "|"
            $sRetClassList &= $aClassList[$i] & @LF
        EndIf
    Next

    Return StringReplace(StringStripWS($sRetClassList, 3), "~", "")
EndFunc












