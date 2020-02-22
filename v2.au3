#cs ----------------------------------------------------------------------------

 AutoIt Version: 3.3.14.5
 Author:         myName

 Script Function:
	Template AutoIt script.

#ce ----------------------------------------------------------------------------

; Script Start - Add your code below here

; ###################################################
; Includes
; ###################################################
#include <GUIConstantsEx.au3>
#include <ButtonConstants.au3>
#include <StaticConstants.au3>
#include <WindowsConstants.au3>
#include <Timers.au3>
#include <ComboConstants.au3>
#include <SliderConstants.au3>
#include <Array.au3>
#include <GuiEdit.au3>
#include <WinAPI.au3>
#include <GuiConstants.au3>
#include <ProgressConstants.au3>
#include <ScreenCapture.au3>

; ###################################################
; Globals
; ###################################################
#interface "IMMDeviceEnumerator"
Global Const $sCLSID_MMDeviceEnumerator = "{BCDE0395-E52F-467C-8E3D-C4579291692E}"
Global Const $sIID_IMMDeviceEnumerator = "{A95664D2-9614-4F35-A746-DE8DB63617E6}"
Global Const $tagIMMDeviceEnumerator = "EnumAudioEndpoints hresult(dword;dword;ptr*);" & _
        "GetDefaultAudioEndpoint hresult(dword;dword;ptr*);" & _
        "GetDevice hresult(wstr;ptr*);" & _
        "RegisterEndpointNotificationCallback hresult(ptr);" & _
        "UnregisterEndpointNotificationCallback hresult(ptr);"
#interface "IMMDevice"
Global Const $sIID_IMMDevice = "{D666063F-1587-4E43-81F1-B948E807363F}"
Global Const $tagIMMDevice = "Activate hresult(clsid;dword;variant*;ptr*);" & _
        "OpenPropertyStore hresult(dword;ptr*);" & _
        "GetId hresult(ptr*);" & _
        "GetState hresult(dword*);"
#interface "IAudioMeterInformation"
Global Const $sIID_IAudioMeterInformation = "{C02216F6-8C67-4B5B-9D00-D008E73E0064}"
Global Const $tagIAudioMeterInformation = "GetPeakValue hresult(float*);" & _
        "GetMeteringChannelCount hresult(dword*);" & _
        "GetChannelsPeakValues hresult(dword;float*);" & _
        "QueryHardwareSupport hresult(dword*);"
Global $oAudioMeterInformation = _AudioVolObject()
If Not IsObj($oAudioMeterInformation) Then Exit -1 ; Will happen on non-supported systems

Global $GUIMain, $GUISearch, $GUISearch_Overlay, $hWnd_WOW = 0
Global $ButtonStart, $ButtonSetup, $ButtonExit
Global $LabelLog1, $LabelLog2, $LabelLog3, $LabelLog4
Global $LabelUptime, $LabelCasts, $LabelFailed, $LabelSuccess
Global $hWnd_GUIMain, $hWnd_GUISearch, $hWnd_VolumeMixer
Global $LastPeak
Global $SetupProceed
Global $CaptureColorRed = 0xA5340C, $CaptureColorBlue, $CaptureColorBrown
Global $CaptureMovementDetectionColor, $CaptureMovementDetectionCoordinatesX, $CaptureMovementDetectionCoordinatesY, $ImageControlCapture
Global $ColorSensitivity = 18

; temp
Global $FoundBobber = 0
Global $Running = False
Global $FishingTimer
Global $FishingButton = "y"
Global $SearchLeft, $SearchTop, $SearchRight, $SearchBottom
Global $JumpTimer = 0
Global $JumpTimerRandom = 0
Global $DeleteTimer = 0
Global $DeleteTimerRandom = 0
Global $LureTimer = _Timer_Init()
Global $LureTimerRandom = -99999999
Global $TimerUptime
Global $ClamTimer = _Timer_Init()
Global $ClamTimerRandom = 0

; ###################################################
; Main
; ###################################################
GUIRegisterMsg( $WM_NCHITTEST, "WM_NCHITTEST" )
GUIMain_Create()
GUISearch_Create()

While 1
	$nMsg = GUIGetMsg( $GUIMain )
	Switch $nMsg
		Case $ButtonStart
			If $Running Then
				Stop()
				GUICtrlSetData( $ButtonStart, "Start" )
			Else
				Start()
				GUICtrlSetData( $ButtonStart, "Stop" )
			EndIf
		Case $ButtonSetup
			Setup()
		Case $ButtonExit
			Exit
	EndSwitch

	If $Running == True Then
		GUICtrlSetData( $LabelUptime, Round(_Timer_Diff( $TimerUptime ) / 1000, 0 ) )
		If _Timer_Diff( $FishingTimer ) > Random( 30500, 32500 ) Then
			CastPole()
		EndIf
		If $FoundBobber == 0 Then
			Local $coords = PixelSearch( $SearchLeft, $SearchTop, $SearchRight, $SearchBottom, $CaptureColorRed, $ColorSensitivity )
			If Not @error Then
				Print( "Bobber found!" )
				MouseMove( $coords[0] + Random( 5, 10 ), $coords[1] + Random( 5, 10 ), 5 )
				Print( "Waiting for fish to bite..." )
				$FoundBobber = 1
				Sleep( 50 )
			EndIf
		EndIf
		If $FoundBobber == 1 Then
			If GetCurrentSoundPeak() >= 10 Then
				Sleep( Random( 500, 1000 ) )
				MouseClick( "left", MouseGetPos( 0 ), MouseGetPos( 1 ) )
				Sleep( Random( 1000, 2000 ) )
				CastPole()
			Else
				Sleep( 1 )
			EndIf
		EndIf
	EndIf
WEnd

; ###################################################
; Functions
; ###################################################
Func Print( $message )
	; remove top message, rotate all up 1, append $message to bottom
	GUICtrlSetData( $LabelLog1, GUICtrlRead( $LabelLog2 ) )
	GUICtrlSetData( $LabelLog2, GUICtrlRead( $LabelLog3 ) )
	GUICtrlSetData( $LabelLog3, GUICtrlRead( $LabelLog4 ) )
	GUICtrlSetData( $LabelLog4, $message )
EndFunc

Func GUIMain_Create()
	$GUIMain = GUICreate("Form1", 44, 53, 0, ( @Desktopheight / 3 ) , $WS_POPUP)
	GUISetBkColor( $GUI_BKCOLOR_TRANSPARENT, $GUIMain )
	$ButtonStart = GUICtrlCreateButton("Start", 0, 0, 43, 17)
	GUICtrlSetColor( -1, 0x00FF00 )
	GUICtrlSetBkColor( -1, 0x000000 )
	$ButtonSetup = GUICtrlCreateButton("Setup", 0, 16, 43, 17)
	GUICtrlSetColor( -1, 0x00FF00 )
	GUICtrlSetBkColor( -1, 0x000000 )
	$ButtonExit = GUICtrlCreateButton("Exit", 0, 34, 43, 17)
	GUICtrlSetColor( -1, 0x00FF00 )
	GUICtrlSetBkColor( -1, 0x000000 )
	GUISetState(@SW_SHOW)
	$hWnd_GUIMain = $GUIMain
	WinSetOnTop( $hWnd_GUIMain, "", $WINDOWS_ONTOP )
	GUISetControlsVisibleAndHideGUIBackground($GUIMain)
EndFunc

Func GUISearch_Create()
	$GUISearch = GUICreate("", 561, 192, 720, 452, $WS_POPUPWINDOW + $WS_SIZEBOX, $WS_EX_LAYERED)
	GUISetBkColor( 0xFFFFFF, $GUISearch )
	WinSetTrans( $GUISearch, "", 100 )
	$hWnd_GUISearch = $GUISearch
	WinSetOnTop( $hWnd_GUISearch, "", $WINDOWS_ONTOP )
EndFunc

Func CastPole()

	WinActivate( $hWnd_WOW )

	If _Timer_Diff( $DeleteTimer ) > (60000 * 2) + $DeleteTimerRandom Then
		Send( "^5" )
		$DeleteTimer = _Timer_Init()
		Sleep( 2000 )
		$DeleteTimerRandom = Random( 0, 30000 )
	EndIf

	If _Timer_Diff( $JumpTimer ) > 60000 + $JumpTimerRandom Then
		Send( "{SPACE}" )
		$JumpTimer = _Timer_Init()
		Sleep( 2500 )
		$JumpTimerRandom = Random( 0, 60000 * 10 )
	EndIf

	If _Timer_Diff( $ClamTimer ) > (60000 * 2) + $ClamTimerRandom Then
		Send( "{ENTER}" )
		Sleep( 50 )
		Send( "/use Big-mouth Clam" )
		Sleep( 50 )
		Send( "{ENTER}" )
		$ClamTimer = _Timer_Init()
		Sleep( 2500 )
		$ClamTimerRandom = Random( 0, 60000 )
	EndIf

	If _Timer_Diff( $LureTimer ) > (60000 * 10) + $LureTimerRandom Then
		Send( "^6" )
		$LureTimer = _Timer_Init()
		Sleep( 6500 )
		$LureTimerRandom = Random( 0, 30000 )
	EndIf

	Send( "^7" )
	Print( "Casting pole..." )
	$FishingTimer = _Timer_Init()
	Sleep( 3000 )
	Print( "Searching for bobber..." )
	$FoundBobber = 0
EndFunc

Func Start()
	Print( "Starting bot..." )
	$Running = True
	$TimerUptime = _Timer_Init()
	GUISetState( @SW_HIDE, $GUISearch )
EndFunc

Func Stop()
	Print( "Stopping bot..." )
	$Running = False
EndFunc

Func Pause()
	;
EndFunc

Func Setup_1()
	Local $pos = WinGetPos( $GUISearch )
	Local $size = WinGetClientSize( $GUISearch )
	WinSetTrans( $GUISearch, "", 255 )
	GUISetState( @SW_HIDE, $GUISearch )
	_ScreenCapture_Capture(@ScriptDir & "\bobber_capture.jpg", $pos[0], $pos[1], $pos[0] + $size[0], $pos[1] + $size[1])
	$ImageControlCapture = GUICtrlCreatePic( @ScriptDir & "\bobber_capture.jpg", 0, 0, $size[0], $size[1] )
	GUISetState( @SW_SHOW, $GUISearch )
	Sleep(10)
	ConsoleWrite( "Pos: " & $pos[0] & "," & $pos[1] & @CRLF )
	ConsoleWrite( "Size: " & $size[0] & "," & $size[1] & @CRLF )
	$SetupProceed = 1
EndFunc

Func Setup_2()
	$CaptureColorRed = "0x" & Hex( PixelGetColor( MouseGetPos( 0 ) - 1, MouseGetPos( 1 ) - 1 ), 6 )
	ConsoleWrite( "Color: " & $CaptureColorRed & @CRLF )
	$SetupProceed = 1
EndFunc

Func Setup_3()
	$CaptureColorBlue = "0x" & Hex( PixelGetColor( MouseGetPos( 0 ) - 1, MouseGetPos( 1 ) - 1 ), 6 )
	$SetupProceed = 1
EndFunc

Func Setup_4()
	$CaptureColorBrown = "0x" & Hex( PixelGetColor( MouseGetPos( 0 ) - 1, MouseGetPos( 1 ) - 1 ), 6 )
	$SetupProceed = 1
EndFunc

Func Setup_5()
	$CaptureMovementDetectionColor = Hex( PixelGetColor( MouseGetPos( 0 ) - 1, MouseGetPos( 1 ) - 1 ), 6 )
	Local $coords = MouseGetPos()
	$CaptureMovementDetectionCoordinatesX = $coords[0]
	$CaptureMovementDetectionCoordinatesY = $coords[1]
	$SetupProceed = 1
EndFunc

Func Setup_6()
	$SetupProceed = 1
EndFunc

Func WaitForEnter()
	While 1
		If $SetupProceed == 1 Then
			$SetupProceed = 0
			ExitLoop
		EndIf
		If $ButtonExit == GUIGetMsg( $GUIMain ) Then Exit
		Sleep( 1 )
	WEnd
EndFunc

Func Setup()

	$SetupProceed = 0

	GUISetState( @SW_HIDE, $GUIMain )
	GUISetState( @SW_SHOW, $GUISearch )

	ToolTip( "Click the World of Warcraft window.", @DesktopWidth / 2, 10, "", 1, 2 )
	WinWaitActive( "World of Warcraft" )
	If $hWnd_WOW == 0 Then
		If WinActive( "World of Warcraft" ) Then
			$hWnd_WOW = WinGetHandle( "[ACTIVE]" )
		EndIf
	EndIf

	HotKeySet( "{ENTER}", "Setup_1" )
	ToolTip( "Adjust the search window over your fishing area, CAST your pole till it's in the middle, and press ENTER", @DesktopWidth / 2, 10, "", 1, 2 )
	WaitForEnter()

	Sleep( 150 )

	Local $pos = WinGetPos( $GUISearch )
	Local $size = WinGetClientSize( $GUISearch )
	$SearchLeft = $pos[0]
	$SearchTop = $pos[1]
	$SearchRight = $pos[0] + $size[0]
	$SearchBottom = $pos[1] + $size[1]
	;MsgBox( 0, "", $SearchLeft & @CRLF & $SearchTop & @CRLF & $SearchRight & @CRLF & $SearchBottom, 5 )

	HotKeySet( "{ENTER}", "Setup_2" )
	Tooltip( "Hover your mouse over the PRIMARY COLOR on the bobber and press ENTER", @DesktopWidth / 2, 10, "", 1, 2 )
	WaitForEnter()

	;HotKeySet( "{ENTER}", "Setup_3" )
	;Tooltip( "Hover your mouse over the #2 PRIMARY COLOR on the bobber and press ENTER", @DesktopWidth / 2, 10, "", 1, 2 )
	;WaitForEnter()

	;HotKeySet( "{ENTER}", "Setup_4" )
	;Tooltip( "Hover your mouse over the #3 PRIMARY COLOR on the bobber and press ENTER", @DesktopWidth / 2, 10, "", 1, 2 )
	;WaitForEnter()

	;HotKeySet( "{ENTER}", "Setup_5" )
	;Tooltip( "Hover your mouse over a stationary object (IN WORLD) and press ENTER", @DesktopWidth / 2, 10, "", 1, 2 )
	;WaitForEnter()

	HotKeySet( "{ENTER}" )
	GUICtrlDelete( $ImageControlCapture )
	WinSetTrans( $GUISearch, "", 75 )

	#CS
	Local $setupdata = "Red: " & $CaptureColorRed & @CRLF & _
						"Blue: " & $CaptureColorBlue & @CRLF & _
						"Brown: " & $CaptureColorBrown & @CRLF & _
						"Movement detection color: " & $CaptureMovementDetectionColor & @CRLF & _
						"Movement detection coordinates: " & $CaptureMovementDetectionCoordinatesX & "," & $CaptureMovementDetectionCoordinatesY

	HotKeySet( "{ENTER}", "Setup_6" )
	Tooltip( "Setup complete - press ENTER" & @CRLF & @CRLF & $setupdata, @DesktopWidth / 2, 55, "", 1, 2 )
	WaitForEnter()
	#CE

	Tooltip( "" )
	HotKeySet( "{ENTER}" )
	GUISetState( @SW_SHOW, $GUIMain )
	GUISetState( @SW_HIDE, $GUISearch )
	Local $debug = "Debug: " & @CRLF & "RED: " & $CaptureColorRed & @CRLF & "Search: " & $SearchLeft & "," & $SearchTop & " " & $SearchRight & "," & $SearchBottom

EndFunc

Func LoadProfile()
	;
EndFunc

Func Load()
	;
EndFunc

; ###################################################
; Functions - internal / one use
; ###################################################

Func InitSettings()

EndFunc

Func SaveSettings()

EndFunc

Func GetCurrentSoundPeak()
	Local $iPeak
	If $oAudioMeterInformation.GetPeakValue($iPeak) = $S_OK Then
        Return Round( 100 * $iPeak, 0 )
	EndIf
	Return 0
EndFunc

Func WM_NCHITTEST($hWnd, $iMsg, $iwParam, $ilParam)
	If $hWnd == $GUIMain And $iMsg = $WM_NCHITTEST Then Return $HTCAPTION
	If $hWnd == $GUISearch Then
		Local $MousePos = MouseGetPos()
		Local $WinPos = WinGetPos($hWnd)
		If $hWnd =  $GUISearch And $iMsg = 0x0084 And $MousePos[1] > $WinPos[1] + 5 And $MousePos[0] > $WinPos[0]+5 And $MousePos[0]+5 < $WinPos[0]+$WinPos[2] And $MousePos[1]+5 < $WinPos[1]+$WinPos[3] Then
			Return 2
		Else
			If $iMsg == $GUISearch And $iMsg == $WM_NCHITTEST Then
				Return $HTCAPTION
			EndIf
		EndIf
	EndIf
EndFunc

; unused
Func GUISetControlsVisibleAndHideGUIBackground($hWnd)
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

Func _AudioVolObject()
    ; Sequences of code below are taken from the source of plugin written for AutoIt for setting master volume on Vista and above systems.
    ; Code was written by wraithdu in C++.
    ; MMDeviceEnumerator
    Local $oMMDeviceEnumerator = ObjCreateInterface($sCLSID_MMDeviceEnumerator, $sIID_IMMDeviceEnumerator, $tagIMMDeviceEnumerator)
    If @error Then Return SetError(1, 0, 0)
    Local Const $eRender = 0
    Local Const $eConsole = 0
    ; DefaultAudioEndpoint
    Local $pDefaultDevice
    $oMMDeviceEnumerator.GetDefaultAudioEndpoint($eRender, $eConsole, $pDefaultDevice)
    If Not $pDefaultDevice Then Return SetError(2, 0, 0)
    ; Turn that pointer into object
    Local $oDefaultDevice = ObjCreateInterface($pDefaultDevice, $sIID_IMMDevice, $tagIMMDevice)
    Local Const $CLSCTX_INPROC_SERVER = 0x1
    ; AudioMeterInformation
    Local $pAudioMeterInformation
    $oDefaultDevice.Activate($sIID_IAudioMeterInformation, $CLSCTX_INPROC_SERVER, 0, $pAudioMeterInformation)
    If Not $pAudioMeterInformation Then Return SetError(3, 0, 0)
    Return ObjCreateInterface($pAudioMeterInformation, $sIID_IAudioMeterInformation, $tagIAudioMeterInformation)
EndFunc   ;==>_AudioVolObject




; ideas
; open app
;	tooltip/toast pops up asking you to select the wow window and jump
;		window is now selected
;			embed buttons
;			click setup
;				tooltip/toast asks you to position the search window and press space - search window goes invis with borders
;				tooltip/toast pops up asking you to cast the bobber a few times till its in
;					the middle range & hover mouse over it to show gold color - press space
;				search window is filled with screenshot of the middle of the search window
;				tooltip/toast asks you to hover over average color of red - press space - repeat 5 times in different red spots
;				repeat for blue
;				repeat for bobber base
;				repeat for gold color thing
;				tooltip/toast asks you to open volume mixer
;				automatically grab control? otherwise hover over detection point - hit space
;				tooltip/toast asks you to select a non-moving point in the map for movement detection - hit space
;				bot is now set up
;					click start/stop/pause to work the bot

; buttons/main gui
; start - set fishing state
; stop - set stop state
; pause - set pause state
; setup - set setup state
; load profile - set load state
; exit - set exit state
; uptime
; casts counter
; successful clicks counter

; main loop
;	switch state
;		case setup states
;			do setup
;		case fishing state
;			do lure if needed
;			do fishing
;				cast
;				detect bobber
;					move mouse
;					check for gold color to see if mouse is on bobber
;		case movement detected
;			pause bot - say something?
;	end switch

; main flow
;	detect window
;	create gui's
;	embed
;	loop

; globals
;	window handles
;	timers
;	stats
;	buttons
