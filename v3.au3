#Region ;**** Directives created by AutoIt3Wrapper_GUI ****
#AutoIt3Wrapper_Compression=0
#AutoIt3Wrapper_Change2CUI=y
#EndRegion ;**** Directives created by AutoIt3Wrapper_GUI ****

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
#include <Misc.au3>

; ###################################################
; Interface
; ###################################################
Global $HWND_GUI
Global $HWND_GUI_TEMP
Global $HWND_SEARCH
Global $HWND_WOW
Global $BUTTON_START
Global $BUTTON_SETUP
Global $BUTTON_EXIT
Global $DLL_USER32
Global $DEBUG = 1
Global $STATE = 0
Global $FISHING = False
Global $TIMER_IDLE
Global $TIMER_IDLE_TIMEOUT
Global $SETTINGS_DIR = @ScriptDir & "\settings.ini"

; ###################################################
; Settings
; ###################################################
Global $AUTOPAUSE_MOUSE_MOVE = 0
Global $AUTOPAUSE_MOUSE_MOVE_DELAY = 0
Global $AUTOSTOP_DISCONNECT = 0
Global $AUTOSTOP_CAMERA_MOVE = 0
Global $AUTOSTOP_CHARACTER_MOVE = 0
Global $ALERT_DISCONNECT = 0
Global $ALERT_CAMERA_MOVE = 0
Global $ALERT_CHARACTER_MOVE = 0
Global $SEARCH_COLOR = ""
Global $SEARCH_COORDINATES_LEFT = ( @DesktopWidth / 2 ) - 200		; default
Global $SEARCH_COORDINATES_TOP = ( @DesktopHeight / 2 ) - 200		; default
Global $SEARCH_COORDINATES_RIGHT = ( @DesktopWidth / 2 ) + 200		; default
Global $SEARCH_COORDINATES_BOTTOM = ( @DesktopHeight / 2 ) + 200	; default
Global $SEARCH_RETRIES = 5
Global $ACTION_FISHING_HOTKEY = ""
Global $ACTION_FISHING_DELAY = 0
Global $ACTION_FISHING_DELAY_RANDOM_MIN = 0
Global $ACTION_FISHING_DELAY_RANDOM_MAX = 0
Global $ACTION_JUMP_HOTKEY = "SPACE"
Global $ACTION_JUMP_DELAY = 2
Global $ACTION_JUMP_DELAY_RANDOM_MIN = 0
Global $ACTION_JUMP_DELAY_RANDOM_MAX = 1
Global $ACTION_JUMP_INTERVAL = 300
Global $ACTION_JUMP_INTERVAL_RANDOM_MIN = 0
Global $ACTION_JUMP_INTERVAL_RANDOM_MAX = 300
Global $ACTION_LURE_HOTKEY = ""
Global $ACTION_LURE_DELAY = 6
Global $ACTION_LURE_DELAY_RANDOM_MIN = 0
Global $ACTION_LURE_DELAY_RANDOM_MAX = 0.75
Global $ACTION_LURE_INTERVAL = 545
Global $ACTION_LURE_INTERVAL_RANDOM_MIN = 0
Global $ACTION_LURE_INTERVAL_RANDOM_MAX = 55
Global $ACTION_1_HOTKEY = ""
Global $ACTION_1_DELAY = 0
Global $ACTION_1_DELAY_RANDOM_MIN = 0
Global $ACTION_1_DELAY_RANDOM_MAX = 0
Global $ACTION_1_INTERVAL = 0
Global $ACTION_1_INTERVAL_RANDOM_MIN = 0
Global $ACTION_1_INTERVAL_RANDOM_MAX = 0
Global $ACTION_2_HOTKEY = ""
Global $ACTION_2_DELAY = 0
Global $ACTION_2_DELAY_RANDOM_MIN = 0
Global $ACTION_2_DELAY_RANDOM_MAX = 0
Global $ACTION_2_INTERVAL = 0
Global $ACTION_2_INTERVAL_RANDOM_MIN = 0
Global $ACTION_2_INTERVAL_RANDOM_MAX = 0
Global $ACTION_3_HOTKEY = ""
Global $ACTION_3_DELAY = 0
Global $ACTION_3_DELAY_RANDOM_MIN = 0
Global $ACTION_3_DELAY_RANDOM_MAX = 0
Global $ACTION_3_INTERVAL = 0
Global $ACTION_3_INTERVAL_RANDOM_MIN = 0
Global $ACTION_3_INTERVAL_RANDOM_MAX = 0
Global $ACTION_4_HOTKEY = ""
Global $ACTION_4_DELAY = 0
Global $ACTION_4_DELAY_RANDOM_MIN = 0
Global $ACTION_4_DELAY_RANDOM_MAX = 0
Global $ACTION_4_INTERVAL = 0
Global $ACTION_4_INTERVAL_RANDOM_MIN = 0
Global $ACTION_4_INTERVAL_RANDOM_MAX = 0
Global $ACTION_5_HOTKEY = ""
Global $ACTION_5_DELAY = 0
Global $ACTION_5_DELAY_RANDOM_MIN = 0
Global $ACTION_5_DELAY_RANDOM_MAX = 0
Global $ACTION_5_INTERVAL = 0
Global $ACTION_5_INTERVAL_RANDOM_MIN = 0
Global $ACTION_5_INTERVAL_RANDOM_MAX = 0

; ###################################################
; Timers and counters
; ###################################################
Global $TIMER_FISHING = _Timer_Init()
Global $TIMER_LURE = _Timer_Init()
Global $TIMER_JUMP = _Timer_Init()
Global $TIMER_ACTION_1 = _Timer_Init()
Global $TIMER_ACTION_2 = _Timer_Init()
Global $TIMER_ACTION_3 = _Timer_Init()
Global $TIMER_ACTION_4 = _Timer_Init()
Global $TIMER_ACTION_5 = _Timer_Init()
Global $COUNTER_BOBBER_SEARCH_RETRIES = 0

; ###################################################
; Audio
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
If Not IsObj($oAudioMeterInformation) Then
	MsgBox( 0, "Error", "Unable to init audio interface" )
	Exit -1
EndIf

; ###################################################
; Main
; ###################################################
If FileExists( $SETTINGS_DIR ) Then
	$SEARCH_COLOR = IniRead( $SETTINGS_DIR, "SEARCH", "SEARCH_COLOR", $SEARCH_COLOR )
	$SEARCH_COORDINATES_LEFT = IniRead( $SETTINGS_DIR, "SEARCH", "SEARCH_COORDINATES_LEFT", $SEARCH_COORDINATES_LEFT )
	$SEARCH_COORDINATES_TOP = IniRead( $SETTINGS_DIR, "SEARCH", "SEARCH_COORDINATES_TOP", $SEARCH_COORDINATES_TOP )
	$SEARCH_COORDINATES_RIGHT = IniRead( $SETTINGS_DIR, "SEARCH", "SEARCH_COORDINATES_RIGHT", $SEARCH_COORDINATES_RIGHT )
	$SEARCH_COORDINATES_BOTTOM = IniRead( $SETTINGS_DIR, "SEARCH", "SEARCH_COORDINATES_BOTTOM", $SEARCH_COORDINATES_BOTTOM )
	$SEARCH_RETRIES = IniRead( $SETTINGS_DIR, "SEARCH", "SEARCH_RETRIES", $SEARCH_RETRIES )
	$AUTOPAUSE_MOUSE_MOVE = IniRead( $SETTINGS_DIR, "AUTOPAUSE", "AUTOPAUSE_MOUSE_MOVE", $AUTOPAUSE_MOUSE_MOVE )
	$AUTOPAUSE_MOUSE_MOVE_DELAY = IniRead( $SETTINGS_DIR, "AUTOPAUSE", "AUTOPAUSE_MOUSE_MOVE_DELAY", $AUTOPAUSE_MOUSE_MOVE_DELAY )
	$AUTOSTOP_DISCONNECT = IniRead( $SETTINGS_DIR, "AUTOSTOP", "AUTOSTOP_DISCONNECT", $AUTOSTOP_DISCONNECT )
	$AUTOSTOP_CAMERA_MOVE = IniRead( $SETTINGS_DIR, "AUTOSTOP", "AUTOSTOP_CAMERA_MOVE", $AUTOSTOP_CAMERA_MOVE )
	$AUTOSTOP_CHARACTER_MOVE = IniRead( $SETTINGS_DIR, "AUTOSTOP", "AUTOSTOP_CHARACTER_MOVE", $AUTOSTOP_CHARACTER_MOVE )
	$ALERT_DISCONNECT = IniRead( $SETTINGS_DIR, "ALERT", "ALERT_DISCONNECT", $ALERT_DISCONNECT )
	$ALERT_CAMERA_MOVE = IniRead( $SETTINGS_DIR, "ALERT", "ALERT_CAMERA_MOVE", $ALERT_CAMERA_MOVE )
	$ALERT_CHARACTER_MOVE = IniRead( $SETTINGS_DIR, "ALERT", "ALERT_CHARACTER_MOVE", $ALERT_CHARACTER_MOVE )
	$ACTION_FISHING_HOTKEY = IniRead( $SETTINGS_DIR, "ACTION", "ACTION_FISHING_HOTKEY", $ACTION_FISHING_HOTKEY )
	$ACTION_FISHING_DELAY = IniRead( $SETTINGS_DIR, "ACTION", "ACTION_FISHING_DELAY", $ACTION_FISHING_DELAY )
	$ACTION_FISHING_DELAY_RANDOM_MIN = IniRead( $SETTINGS_DIR, "ACTION", "ACTION_FISHING_DELAY_RANDOM_MIN", $ACTION_FISHING_DELAY_RANDOM_MIN )
	$ACTION_FISHING_DELAY_RANDOM_MAX = IniRead( $SETTINGS_DIR, "ACTION", "ACTION_FISHING_DELAY_RANDOM_MAX", $ACTION_FISHING_DELAY_RANDOM_MAX )
	$ACTION_JUMP_HOTKEY = IniRead( $SETTINGS_DIR, "ACTION", "ACTION_JUMP_HOTKEY", $ACTION_JUMP_HOTKEY )
	$ACTION_JUMP_DELAY = IniRead( $SETTINGS_DIR, "ACTION", "ACTION_JUMP_DELAY", $ACTION_JUMP_DELAY )
	$ACTION_JUMP_DELAY_RANDOM_MIN = IniRead( $SETTINGS_DIR, "ACTION", "ACTION_JUMP_DELAY_RANDOM_MIN", $ACTION_JUMP_DELAY_RANDOM_MIN )
	$ACTION_JUMP_DELAY_RANDOM_MAX = IniRead( $SETTINGS_DIR, "ACTION", "ACTION_JUMP_DELAY_RANDOM_MAX", $ACTION_JUMP_DELAY_RANDOM_MAX )
	$ACTION_JUMP_INTERVAL = IniRead( $SETTINGS_DIR, "ACTION", "ACTION_JUMP_INTERVAL", $ACTION_JUMP_INTERVAL )
	$ACTION_JUMP_INTERVAL_RANDOM_MIN = IniRead( $SETTINGS_DIR, "ACTION", "ACTION_JUMP_INTERVAL_RANDOM_MIN", $ACTION_JUMP_INTERVAL_RANDOM_MIN )
	$ACTION_JUMP_INTERVAL_RANDOM_MAX = IniRead( $SETTINGS_DIR, "ACTION", "ACTION_JUMP_INTERVAL_RANDOM_MAX", $ACTION_JUMP_INTERVAL_RANDOM_MAX )
	$ACTION_LURE_HOTKEY = IniRead( $SETTINGS_DIR, "ACTION", "ACTION_LURE_HOTKEY", $ACTION_LURE_HOTKEY )
	$ACTION_LURE_DELAY = IniRead( $SETTINGS_DIR, "ACTION", "ACTION_LURE_DELAY", $ACTION_LURE_DELAY )
	$ACTION_LURE_DELAY_RANDOM_MIN = IniRead( $SETTINGS_DIR, "ACTION", "ACTION_LURE_DELAY_RANDOM_MIN", $ACTION_LURE_DELAY_RANDOM_MIN )
	$ACTION_LURE_DELAY_RANDOM_MAX = IniRead( $SETTINGS_DIR, "ACTION", "ACTION_LURE_DELAY_RANDOM_MAX", $ACTION_LURE_DELAY_RANDOM_MAX )
	$ACTION_LURE_INTERVAL = IniRead( $SETTINGS_DIR, "ACTION", "ACTION_LURE_INTERVAL", $ACTION_LURE_INTERVAL )
	$ACTION_LURE_INTERVAL_RANDOM_MIN = IniRead( $SETTINGS_DIR, "ACTION", "ACTION_LURE_INTERVAL_RANDOM_MIN", $ACTION_LURE_INTERVAL_RANDOM_MIN )
	$ACTION_LURE_INTERVAL_RANDOM_MAX = IniRead( $SETTINGS_DIR, "ACTION", "ACTION_LURE_INTERVAL_RANDOM_MAX", $ACTION_LURE_INTERVAL_RANDOM_MAX )
	$ACTION_1_HOTKEY = IniRead( $SETTINGS_DIR, "ACTION", "ACTION_1_HOTKEY", $ACTION_1_HOTKEY )
	$ACTION_1_DELAY = IniRead( $SETTINGS_DIR, "ACTION", "ACTION_1_DELAY", $ACTION_1_DELAY )
	$ACTION_1_DELAY_RANDOM_MIN = IniRead( $SETTINGS_DIR, "ACTION", "ACTION_1_DELAY_RANDOM_MIN", $ACTION_1_DELAY_RANDOM_MIN )
	$ACTION_1_DELAY_RANDOM_MAX = IniRead( $SETTINGS_DIR, "ACTION", "ACTION_1_DELAY_RANDOM_MAX", $ACTION_1_DELAY_RANDOM_MAX )
	$ACTION_1_INTERVAL = IniRead( $SETTINGS_DIR, "ACTION", "ACTION_1_INTERVAL", $ACTION_1_INTERVAL )
	$ACTION_1_INTERVAL_RANDOM_MIN = IniRead( $SETTINGS_DIR, "ACTION", "ACTION_1_INTERVAL_RANDOM_MIN", $ACTION_1_INTERVAL_RANDOM_MIN )
	$ACTION_1_INTERVAL_RANDOM_MAX = IniRead( $SETTINGS_DIR, "ACTION", "ACTION_1_INTERVAL_RANDOM_MAX", $ACTION_1_INTERVAL_RANDOM_MAX )
	$ACTION_2_HOTKEY = IniRead( $SETTINGS_DIR, "ACTION", "ACTION_2_HOTKEY", $ACTION_2_HOTKEY )
	$ACTION_2_DELAY = IniRead( $SETTINGS_DIR, "ACTION", "ACTION_2_DELAY", $ACTION_2_DELAY )
	$ACTION_2_DELAY_RANDOM_MIN = IniRead( $SETTINGS_DIR, "ACTION", "ACTION_2_DELAY_RANDOM_MIN", $ACTION_2_DELAY_RANDOM_MIN )
	$ACTION_2_DELAY_RANDOM_MAX = IniRead( $SETTINGS_DIR, "ACTION", "ACTION_2_DELAY_RANDOM_MAX", $ACTION_2_DELAY_RANDOM_MAX )
	$ACTION_2_INTERVAL = IniRead( $SETTINGS_DIR, "ACTION", "ACTION_2_INTERVAL", $ACTION_2_INTERVAL )
	$ACTION_2_INTERVAL_RANDOM_MIN = IniRead( $SETTINGS_DIR, "ACTION", "ACTION_2_INTERVAL_RANDOM_MIN", $ACTION_2_INTERVAL_RANDOM_MIN )
	$ACTION_2_INTERVAL_RANDOM_MAX = IniRead( $SETTINGS_DIR, "ACTION", "ACTION_2_INTERVAL_RANDOM_MAX", $ACTION_2_INTERVAL_RANDOM_MAX )
	$ACTION_3_HOTKEY = IniRead( $SETTINGS_DIR, "ACTION", "ACTION_3_HOTKEY", $ACTION_3_HOTKEY )
	$ACTION_3_DELAY = IniRead( $SETTINGS_DIR, "ACTION", "ACTION_3_DELAY", $ACTION_3_DELAY )
	$ACTION_3_DELAY_RANDOM_MIN = IniRead( $SETTINGS_DIR, "ACTION", "ACTION_3_DELAY_RANDOM_MIN", $ACTION_3_DELAY_RANDOM_MIN )
	$ACTION_3_DELAY_RANDOM_MAX = IniRead( $SETTINGS_DIR, "ACTION", "ACTION_3_DELAY_RANDOM_MAX", $ACTION_3_DELAY_RANDOM_MAX )
	$ACTION_3_INTERVAL = IniRead( $SETTINGS_DIR, "ACTION", "ACTION_3_INTERVAL", $ACTION_3_INTERVAL )
	$ACTION_3_INTERVAL_RANDOM_MIN = IniRead( $SETTINGS_DIR, "ACTION", "ACTION_3_INTERVAL_RANDOM_MIN", $ACTION_3_INTERVAL_RANDOM_MIN )
	$ACTION_3_INTERVAL_RANDOM_MAX = IniRead( $SETTINGS_DIR, "ACTION", "ACTION_3_INTERVAL_RANDOM_MAX", $ACTION_3_INTERVAL_RANDOM_MAX )
	$ACTION_4_HOTKEY = IniRead( $SETTINGS_DIR, "ACTION", "ACTION_4_HOTKEY", $ACTION_4_HOTKEY )
	$ACTION_4_DELAY = IniRead( $SETTINGS_DIR, "ACTION", "ACTION_4_DELAY", $ACTION_4_DELAY )
	$ACTION_4_DELAY_RANDOM_MIN = IniRead( $SETTINGS_DIR, "ACTION", "ACTION_4_DELAY_RANDOM_MIN", $ACTION_4_DELAY_RANDOM_MIN )
	$ACTION_4_DELAY_RANDOM_MAX = IniRead( $SETTINGS_DIR, "ACTION", "ACTION_4_DELAY_RANDOM_MAX", $ACTION_4_DELAY_RANDOM_MAX )
	$ACTION_4_INTERVAL = IniRead( $SETTINGS_DIR, "ACTION", "ACTION_4_INTERVAL", $ACTION_4_INTERVAL )
	$ACTION_4_INTERVAL_RANDOM_MIN = IniRead( $SETTINGS_DIR, "ACTION", "ACTION_4_INTERVAL_RANDOM_MIN", $ACTION_4_INTERVAL_RANDOM_MIN )
	$ACTION_4_INTERVAL_RANDOM_MAX = IniRead( $SETTINGS_DIR, "ACTION", "ACTION_4_INTERVAL_RANDOM_MAX", $ACTION_4_INTERVAL_RANDOM_MAX )
	$ACTION_5_HOTKEY = IniRead( $SETTINGS_DIR, "ACTION", "ACTION_5_HOTKEY", $ACTION_5_HOTKEY )
	$ACTION_5_DELAY = IniRead( $SETTINGS_DIR, "ACTION", "ACTION_5_DELAY", $ACTION_5_DELAY )
	$ACTION_5_DELAY_RANDOM_MIN = IniRead( $SETTINGS_DIR, "ACTION", "ACTION_5_DELAY_RANDOM_MIN", $ACTION_5_DELAY_RANDOM_MIN )
	$ACTION_5_DELAY_RANDOM_MAX = IniRead( $SETTINGS_DIR, "ACTION", "ACTION_5_DELAY_RANDOM_MAX", $ACTION_5_DELAY_RANDOM_MAX )
	$ACTION_5_INTERVAL = IniRead( $SETTINGS_DIR, "ACTION", "ACTION_5_INTERVAL", $ACTION_5_INTERVAL )
	$ACTION_5_INTERVAL_RANDOM_MIN = IniRead( $SETTINGS_DIR, "ACTION", "ACTION_5_INTERVAL_RANDOM_MIN", $ACTION_5_INTERVAL_RANDOM_MIN )
	$ACTION_5_INTERVAL_RANDOM_MAX = IniRead( $SETTINGS_DIR, "ACTION", "ACTION_5_INTERVAL_RANDOM_MAX", $ACTION_5_INTERVAL_RANDOM_MAX )
EndIf

$HWND_GUI = GUICreate("", 44, 53, 0, ( @Desktopheight / 3 ) , $WS_POPUP)
GUISetBkColor( $GUI_BKCOLOR_TRANSPARENT )
$BUTTON_START = GUICtrlCreateButton("Start", 0, 0, 43, 17)
GUICtrlSetColor( -1, 0x00FF00 )
GUICtrlSetBkColor( -1, 0x000000 )
$BUTTON_SETUP = GUICtrlCreateButton("Setup", 0, 16, 43, 17)
GUICtrlSetColor( -1, 0x00FF00 )
GUICtrlSetBkColor( -1, 0x000000 )
$BUTTON_EXIT = GUICtrlCreateButton("Exit", 0, 34, 43, 17)
GUICtrlSetColor( -1, 0x00FF00 )
GUICtrlSetBkColor( -1, 0x000000 )
If $SEARCH_COLOR == "" Then
	GUICtrlSetState( $BUTTON_START, $GUI_DISABLE )
EndIf
GUISetState(@SW_SHOW)
WinSetOnTop( $HWND_GUI, "", $WINDOWS_ONTOP )

$DLL_USER32 = DllOpen("user32.dll")

While 1

	Local $nMsg = GUIGetMsg( $HWND_GUI )
	Switch $nMsg
		Case $BUTTON_START
			Button_Start()
		Case $BUTTON_SETUP
			Button_Setup()
		Case $BUTTON_EXIT
			Button_Exit()
	EndSwitch

	If $FISHING Then
		If NOT Idling() Then
			If _Timer_Diff( $TIMER_JUMP ) > $ACTION_JUMP_INTERVAL Then
				$STATE = 7
			Else
				If _Timer_Diff( $TIMER_LURE ) > $ACTION_LURE_INTERVAL Then
					$STATE = 0
				Else
					If _Timer_Diff( $TIMER_ACTION_1 ) > $ACTION_1_INTERVAL Then
						$STATE = 1
					Else
						If _Timer_Diff( $TIMER_ACTION_2 ) > $ACTION_2_INTERVAL Then
							$STATE = 2
						Else
							If _Timer_Diff( $TIMER_ACTION_3 ) > $ACTION_3_INTERVAL Then
								$STATE = 3
							Else
								If _Timer_Diff( $TIMER_ACTION_4 ) > $ACTION_4_INTERVAL Then
									$STATE = 4
								Else
									If _Timer_Diff( $TIMER_ACTION_5 ) > $ACTION_5_INTERVAL Then
										$STATE = 5
									Else
										If _Timer_Diff( $TIMER_FISHING ) > 30 Then
											$STATE = 6
										Else
											$STATE = -1
										EndIf
									EndIf
								EndIf
							EndIf
						EndIf
					EndIf
				EndIf
			EndIf

			Switch $STATE
				Case -1
					Sleep( 1 )
				Case 0
					Cast( "lure" )
				Case 1
					Cast( "extra1" )
				Case 2
					Cast( "extra2" )
				Case 3
					Cast( "extra3" )
				Case 4
					Cast( "extra4" )
				Case 5
					Cast( "extra5" )
				Case 6
					Cast( "pole" )
				Case 7
					Cast( "jump" )
				Case 8
					BobberSearch()
				Case 9
					SplashWait()
				Case 10
					BobberLoot()
				Case 11
					$STATE = 6
			EndSwitch
		EndIf
	EndIf

WEnd

; ###################################################
; Functions
; ###################################################
Func BobberSearch()
	Debug( "Searching for bobber..." & @CRLF )

	$COUNTER_BOBBER_SEARCH_RETRIES += 1

	; search for bobber

	; if not found:
		BeginIdle( 1 )
		If $COUNTER_BOBBER_SEARCH_RETRIES >= 5 Then
			$STATE = 11
			$COUNTER_BOBBER_SEARCH_RETRIES = 0
			Return
		EndIf
	; else
		BeginIdle( 1 )
		$STATE = 9
	; end if
EndFunc

Func SplashWait()
	Debug( @CR & "Waiting for splash..." )
	BeginIdle( 1 )
EndFunc

Func BobberLoot()
	; Click logged position
	Debug( @CRLF & "Looting bobber..." & @CRLF )
	BeginIdle( 2 )
	$STATE = 11
EndFunc

Func Cast( $item )
	Debug( "Casting " & "'" & $item & "'..." & @CRLF )
	Switch $item
		Case "pole"
			; Pole
			$TIMER_FISHING = _Timer_Init()
			BeginIdle( $ACTION_FISHING_DELAY + Random( $ACTION_FISHING_DELAY_RANDOM_MIN, $ACTION_FISHING_DELAY_RANDOM_MAX ) )
			$STATE = 8
		Case "lure"
			; Lure
			$TIMER_LURE = _Timer_Init() + Random( $ACTION_LURE_INTERVAL_RANDOM_MIN, $ACTION_LURE_INTERVAL_RANDOM_MAX )
			BeginIdle( $ACTION_LURE_DELAY + Random( $ACTION_LURE_DELAY_RANDOM_MIN, $ACTION_LURE_DELAY_RANDOM_MAX ) )
		Case "extra1"
			; Extra Action 1
			$TIMER_ACTION_1 = _Timer_Init() + Random( $ACTION_1_INTERVAL_RANDOM_MIN, $ACTION_1_INTERVAL_RANDOM_MAX )
			BeginIdle( $ACTION_1_DELAY + Random( $ACTION_1_DELAY_RANDOM_MIN, $ACTION_1_DELAY_RANDOM_MAX ) )
		Case "extra2"
			; Extra Action 2
			$TIMER_ACTION_2 = _Timer_Init() + Random( $ACTION_2_INTERVAL_RANDOM_MIN, $ACTION_2_INTERVAL_RANDOM_MAX )
			BeginIdle( $ACTION_2_DELAY + Random( $ACTION_2_DELAY_RANDOM_MIN, $ACTION_2_DELAY_RANDOM_MAX ) )
		Case "extra3"
			; Extra Action 3
			$TIMER_ACTION_3 = _Timer_Init() + Random( $ACTION_3_INTERVAL_RANDOM_MIN, $ACTION_3_INTERVAL_RANDOM_MAX )
			BeginIdle( $ACTION_3_DELAY + Random( $ACTION_3_DELAY_RANDOM_MIN, $ACTION_3_DELAY_RANDOM_MAX ) )
		Case "extra4"
			; Extra Action 3
			$TIMER_ACTION_4 = _Timer_Init() + Random( $ACTION_4_INTERVAL_RANDOM_MIN, $ACTION_4_INTERVAL_RANDOM_MAX )
			BeginIdle( $ACTION_4_DELAY + Random( $ACTION_4_DELAY_RANDOM_MIN, $ACTION_4_DELAY_RANDOM_MAX ) )
		Case "extra5"
			; Extra Action 3
			$TIMER_ACTION_5 = _Timer_Init() + Random( $ACTION_5_INTERVAL_RANDOM_MIN, $ACTION_5_INTERVAL_RANDOM_MAX )
			BeginIdle( $ACTION_5_DELAY + Random( $ACTION_5_DELAY_RANDOM_MIN, $ACTION_5_DELAY_RANDOM_MAX ) )
	EndSwitch
	If $STATE >= 8 Then
		$STATE += 1
	EndIf
EndFunc

Func Debug( $msg )
	If $DEBUG Then
		ConsoleWrite( $msg )
	EndIf
EndFunc

Func Idling()
	If _Timer_Diff( $TIMER_IDLE ) < $TIMER_IDLE_TIMEOUT Then
		Return True
	EndIf
	Return False
EndFunc

Func BeginIdle( $time )
	Debug( @TAB & "Idling for " & $time & " seconds..." & @CRLF )
	$TIMER_IDLE_TIMEOUT = $time * 1000
	$TIMER_IDLE = _Timer_Init()
EndFunc

Func IsPressed_Enter()
	If _IsPressed( "0D", $DLL_USER32 ) Then
		Return True
	EndIf
	Return False
EndFunc

Func Button_Start()
	;reset all timers except lure
	$STATE = 0
	If NOT $FISHING Then
		$FISHING = True
		GUICtrlSetData( $BUTTON_START, "Stop" )
		GUICtrlSetState( $BUTTON_SETUP, $GUI_DISABLE )
	Else
		$FISHING = False
		GUICtrlSetData( $BUTTON_START, "Start" )
		GUICtrlSetState( $BUTTON_SETUP, $GUI_ENABLE )
	EndIf
EndFunc

Func Button_Setup()
	GUICtrlSetState( $BUTTON_START, $GUI_DISABLE )
	GUICtrlSetState( $BUTTON_SETUP, $GUI_DISABLE )

	Local $STEP = 0

	; Create search GUI
	Local $w = $SEARCH_COORDINATES_RIGHT - $SEARCH_COORDINATES_LEFT
	Local $h = $SEARCH_COORDINATES_BOTTOM - $SEARCH_COORDINATES_TOP
	Local $l = $SEARCH_COORDINATES_LEFT
	Local $t = $SEARCH_COORDINATES_TOP
	$HWND_GUI_TEMP = GUICreate("SEARCH", $w, $h, $l, $t, $WS_POPUPWINDOW + $WS_SIZEBOX, $WS_EX_LAYERED)
	GUISetBkColor( 0xFFFFFF, $HWND_GUI_TEMP )
	WinSetTrans( $HWND_GUI_TEMP, "", 100 )
	WinSetOnTop( $HWND_GUI_TEMP, "", $WINDOWS_ONTOP )
	GUIRegisterMsg( $WM_NCHITTEST, "WM_NCHITTEST" )
	GUISetState( @SW_SHOW, $HWND_GUI_TEMP )

	While $HWND_GUI_TEMP <> 0

		Local $nMsg = GUIGetMsg( $HWND_GUI )
		Switch $nMsg
			Case $BUTTON_EXIT
				Button_Exit()
		EndSwitch

		Switch $STEP
			Case 0
				$LABEL_TEMP = GUICtrlCreateLabel( "Position window over fishing area and press ENTER", 5, 5, 300, 200, -1 )
				$STEP = 1
			Case 1
				; Waiting for gui to be positioned and enter
				If IsPressed_Enter() Then
					$STEP = 2
					Sleep( 150 )
				EndIf
			Case 2
				GUICtrlSetData( $LABEL_TEMP, "Cast fishing pole, and press ENTER" )
				$STEP = 3
			Case 3
				; Waiting for pole cast and enter
				If IsPressed_Enter() Then
					$STEP = 4
					Sleep( 150 )
				EndIf
			Case 4
				; Take screenshot
				Local $SearchPos = WinGetPos( $HWND_GUI_TEMP )
				Local $SearchSiz = WinGetClientSize( $HWND_GUI_TEMP )
				$SEARCH_COORDINATES_LEFT = $SearchPos[0]
				$SEARCH_COORDINATES_TOP = $SearchPos[1]
				$SEARCH_COORDINATES_RIGHT = $SearchPos[0] + $SearchSiz[0]
				$SEARCH_COORDINATES_BOTTOM = $SearchPos[1] + $SearchSiz[1]
				; Add picture to GUI
				; Make sure label is on top of picture
				GUICtrlSetData( $LABEL_TEMP, "Hover over the primary search color and press ENTER" )
				$STEP = 5
			Case 5
				; Waiting for color to be selected
				Sleep( 1 )
				If IsPressed_Enter() Then
					$STEP = 6
					Sleep( 150 )
				EndIf
			Case 6
				$SEARCH_COLOR = "0x" & Hex( PixelGetColor( MouseGetPos( 0 ), MouseGetPos( 1 ) ), 6 )
				$STEP = 7
			Case 7
				GUIDelete( $HWND_GUI_TEMP )
				$HWND_GUI_TEMP = 0
		EndSwitch
	WEnd

	GUICtrlSetState( $BUTTON_START, $GUI_ENABLE )
	GUICtrlSetState( $BUTTON_SETUP, $GUI_ENABLE )
	GUIRegisterMsg( $WM_NCHITTEST, "" )
EndFunc

Func Button_Exit()
	DllClose( $DLL_USER32 )
	IniWrite( $SETTINGS_DIR, "SEARCH", "SEARCH_COLOR", $SEARCH_COLOR )
	IniWrite( $SETTINGS_DIR, "SEARCH", "SEARCH_COORDINATES_LEFT", $SEARCH_COORDINATES_LEFT )
	IniWrite( $SETTINGS_DIR, "SEARCH", "SEARCH_COORDINATES_TOP", $SEARCH_COORDINATES_TOP )
	IniWrite( $SETTINGS_DIR, "SEARCH", "SEARCH_COORDINATES_RIGHT", $SEARCH_COORDINATES_RIGHT )
	IniWrite( $SETTINGS_DIR, "SEARCH", "SEARCH_COORDINATES_BOTTOM", $SEARCH_COORDINATES_BOTTOM )
	IniWrite( $SETTINGS_DIR, "SEARCH", "SEARCH_RETRIES", $SEARCH_RETRIES )
	IniWrite( $SETTINGS_DIR, "AUTOPAUSE", "AUTOPAUSE_MOUSE_MOVE", $AUTOPAUSE_MOUSE_MOVE )
	IniWrite( $SETTINGS_DIR, "AUTOPAUSE", "AUTOPAUSE_MOUSE_MOVE_DELAY", $AUTOPAUSE_MOUSE_MOVE_DELAY )
	IniWrite( $SETTINGS_DIR, "AUTOSTOP", "AUTOSTOP_DISCONNECT", $AUTOSTOP_DISCONNECT )
	IniWrite( $SETTINGS_DIR, "AUTOSTOP", "AUTOSTOP_CAMERA_MOVE", $AUTOSTOP_CAMERA_MOVE )
	IniWrite( $SETTINGS_DIR, "AUTOSTOP", "AUTOSTOP_CHARACTER_MOVE", $AUTOSTOP_CHARACTER_MOVE )
	IniWrite( $SETTINGS_DIR, "ALERT", "ALERT_DISCONNECT", $ALERT_DISCONNECT )
	IniWrite( $SETTINGS_DIR, "ALERT", "ALERT_CAMERA_MOVE", $ALERT_CAMERA_MOVE )
	IniWrite( $SETTINGS_DIR, "ALERT", "ALERT_CHARACTER_MOVE", $ALERT_CHARACTER_MOVE )
	IniWrite( $SETTINGS_DIR, "ACTION", "ACTION_FISHING_HOTKEY", $ACTION_FISHING_HOTKEY )
	IniWrite( $SETTINGS_DIR, "ACTION", "ACTION_FISHING_DELAY", $ACTION_FISHING_DELAY )
	IniWrite( $SETTINGS_DIR, "ACTION", "ACTION_FISHING_DELAY_RANDOM_MIN", $ACTION_FISHING_DELAY_RANDOM_MIN )
	IniWrite( $SETTINGS_DIR, "ACTION", "ACTION_FISHING_DELAY_RANDOM_MAX", $ACTION_FISHING_DELAY_RANDOM_MAX )
	IniWrite( $SETTINGS_DIR, "ACTION", "ACTION_JUMP_HOTKEY", $ACTION_JUMP_HOTKEY )
	IniWrite( $SETTINGS_DIR, "ACTION", "ACTION_JUMP_DELAY", $ACTION_JUMP_DELAY )
	IniWrite( $SETTINGS_DIR, "ACTION", "ACTION_JUMP_DELAY_RANDOM_MIN", $ACTION_JUMP_DELAY_RANDOM_MIN )
	IniWrite( $SETTINGS_DIR, "ACTION", "ACTION_JUMP_DELAY_RANDOM_MAX", $ACTION_JUMP_DELAY_RANDOM_MAX )
	IniWrite( $SETTINGS_DIR, "ACTION", "ACTION_JUMP_INTERVAL", $ACTION_JUMP_INTERVAL )
	IniWrite( $SETTINGS_DIR, "ACTION", "ACTION_JUMP_INTERVAL_RANDOM_MIN", $ACTION_JUMP_INTERVAL_RANDOM_MIN )
	IniWrite( $SETTINGS_DIR, "ACTION", "ACTION_JUMP_INTERVAL_RANDOM_MAX", $ACTION_JUMP_INTERVAL_RANDOM_MAX )
	IniWrite( $SETTINGS_DIR, "ACTION", "ACTION_LURE_HOTKEY", $ACTION_LURE_HOTKEY )
	IniWrite( $SETTINGS_DIR, "ACTION", "ACTION_LURE_DELAY", $ACTION_LURE_DELAY )
	IniWrite( $SETTINGS_DIR, "ACTION", "ACTION_LURE_DELAY_RANDOM_MIN", $ACTION_LURE_DELAY_RANDOM_MIN )
	IniWrite( $SETTINGS_DIR, "ACTION", "ACTION_LURE_DELAY_RANDOM_MAX", $ACTION_LURE_DELAY_RANDOM_MAX )
	IniWrite( $SETTINGS_DIR, "ACTION", "ACTION_LURE_INTERVAL", $ACTION_LURE_INTERVAL )
	IniWrite( $SETTINGS_DIR, "ACTION", "ACTION_LURE_INTERVAL_RANDOM_MIN", $ACTION_LURE_INTERVAL_RANDOM_MIN )
	IniWrite( $SETTINGS_DIR, "ACTION", "ACTION_LURE_INTERVAL_RANDOM_MAX", $ACTION_LURE_INTERVAL_RANDOM_MAX )
	IniWrite( $SETTINGS_DIR, "ACTION", "ACTION_1_HOTKEY", $ACTION_1_HOTKEY )
	IniWrite( $SETTINGS_DIR, "ACTION", "ACTION_1_DELAY", $ACTION_1_DELAY )
	IniWrite( $SETTINGS_DIR, "ACTION", "ACTION_1_DELAY_RANDOM_MIN", $ACTION_1_DELAY_RANDOM_MIN )
	IniWrite( $SETTINGS_DIR, "ACTION", "ACTION_1_DELAY_RANDOM_MAX", $ACTION_1_DELAY_RANDOM_MAX )
	IniWrite( $SETTINGS_DIR, "ACTION", "ACTION_1_INTERVAL", $ACTION_1_INTERVAL )
	IniWrite( $SETTINGS_DIR, "ACTION", "ACTION_1_INTERVAL_RANDOM_MIN", $ACTION_1_INTERVAL_RANDOM_MIN )
	IniWrite( $SETTINGS_DIR, "ACTION", "ACTION_1_INTERVAL_RANDOM_MAX", $ACTION_1_INTERVAL_RANDOM_MAX )
	IniWrite( $SETTINGS_DIR, "ACTION", "ACTION_2_HOTKEY", $ACTION_2_HOTKEY )
	IniWrite( $SETTINGS_DIR, "ACTION", "ACTION_2_DELAY", $ACTION_2_DELAY )
	IniWrite( $SETTINGS_DIR, "ACTION", "ACTION_2_DELAY_RANDOM_MIN", $ACTION_2_DELAY_RANDOM_MIN )
	IniWrite( $SETTINGS_DIR, "ACTION", "ACTION_2_DELAY_RANDOM_MAX", $ACTION_2_DELAY_RANDOM_MAX )
	IniWrite( $SETTINGS_DIR, "ACTION", "ACTION_2_INTERVAL", $ACTION_2_INTERVAL )
	IniWrite( $SETTINGS_DIR, "ACTION", "ACTION_2_INTERVAL_RANDOM_MIN", $ACTION_2_INTERVAL_RANDOM_MIN )
	IniWrite( $SETTINGS_DIR, "ACTION", "ACTION_2_INTERVAL_RANDOM_MAX", $ACTION_2_INTERVAL_RANDOM_MAX )
	IniWrite( $SETTINGS_DIR, "ACTION", "ACTION_3_HOTKEY", $ACTION_3_HOTKEY )
	IniWrite( $SETTINGS_DIR, "ACTION", "ACTION_3_DELAY", $ACTION_3_DELAY )
	IniWrite( $SETTINGS_DIR, "ACTION", "ACTION_3_DELAY_RANDOM_MIN", $ACTION_3_DELAY_RANDOM_MIN )
	IniWrite( $SETTINGS_DIR, "ACTION", "ACTION_3_DELAY_RANDOM_MAX", $ACTION_3_DELAY_RANDOM_MAX )
	IniWrite( $SETTINGS_DIR, "ACTION", "ACTION_3_INTERVAL", $ACTION_3_INTERVAL )
	IniWrite( $SETTINGS_DIR, "ACTION", "ACTION_3_INTERVAL_RANDOM_MIN", $ACTION_3_INTERVAL_RANDOM_MIN )
	IniWrite( $SETTINGS_DIR, "ACTION", "ACTION_3_INTERVAL_RANDOM_MAX", $ACTION_3_INTERVAL_RANDOM_MAX )
	IniWrite( $SETTINGS_DIR, "ACTION", "ACTION_4_HOTKEY", $ACTION_4_HOTKEY )
	IniWrite( $SETTINGS_DIR, "ACTION", "ACTION_4_DELAY", $ACTION_4_DELAY )
	IniWrite( $SETTINGS_DIR, "ACTION", "ACTION_4_DELAY_RANDOM_MIN", $ACTION_4_DELAY_RANDOM_MIN )
	IniWrite( $SETTINGS_DIR, "ACTION", "ACTION_4_DELAY_RANDOM_MAX", $ACTION_4_DELAY_RANDOM_MAX )
	IniWrite( $SETTINGS_DIR, "ACTION", "ACTION_4_INTERVAL", $ACTION_4_INTERVAL )
	IniWrite( $SETTINGS_DIR, "ACTION", "ACTION_4_INTERVAL_RANDOM_MIN", $ACTION_4_INTERVAL_RANDOM_MIN )
	IniWrite( $SETTINGS_DIR, "ACTION", "ACTION_4_INTERVAL_RANDOM_MAX", $ACTION_4_INTERVAL_RANDOM_MAX )
	IniWrite( $SETTINGS_DIR, "ACTION", "ACTION_5_HOTKEY", $ACTION_5_HOTKEY )
	IniWrite( $SETTINGS_DIR, "ACTION", "ACTION_5_DELAY", $ACTION_5_DELAY )
	IniWrite( $SETTINGS_DIR, "ACTION", "ACTION_5_DELAY_RANDOM_MIN", $ACTION_5_DELAY_RANDOM_MIN )
	IniWrite( $SETTINGS_DIR, "ACTION", "ACTION_5_DELAY_RANDOM_MAX", $ACTION_5_DELAY_RANDOM_MAX )
	IniWrite( $SETTINGS_DIR, "ACTION", "ACTION_5_INTERVAL", $ACTION_5_INTERVAL )
	IniWrite( $SETTINGS_DIR, "ACTION", "ACTION_5_INTERVAL_RANDOM_MIN", $ACTION_5_INTERVAL_RANDOM_MIN )
	IniWrite( $SETTINGS_DIR, "ACTION", "ACTION_5_INTERVAL_RANDOM_MAX", $ACTION_5_INTERVAL_RANDOM_MAX )
	Exit
EndFunc

Func GetCurrentSoundPeak()
	Local $iPeak
	If $oAudioMeterInformation.GetPeakValue($iPeak) = $S_OK Then
        Return Round( 100 * $iPeak, 0 )
	EndIf
	Return 0
EndFunc

Func _AudioVolObject()
    Local $oMMDeviceEnumerator = ObjCreateInterface($sCLSID_MMDeviceEnumerator, $sIID_IMMDeviceEnumerator, $tagIMMDeviceEnumerator)
    If @error Then Return SetError(1, 0, 0)
    Local Const $eRender = 0
    Local Const $eConsole = 0
    Local $pDefaultDevice
    $oMMDeviceEnumerator.GetDefaultAudioEndpoint($eRender, $eConsole, $pDefaultDevice)
    If Not $pDefaultDevice Then Return SetError(2, 0, 0)
    Local $oDefaultDevice = ObjCreateInterface($pDefaultDevice, $sIID_IMMDevice, $tagIMMDevice)
    Local Const $CLSCTX_INPROC_SERVER = 0x1
    Local $pAudioMeterInformation
    $oDefaultDevice.Activate($sIID_IAudioMeterInformation, $CLSCTX_INPROC_SERVER, 0, $pAudioMeterInformation)
    If Not $pAudioMeterInformation Then Return SetError(3, 0, 0)
    Return ObjCreateInterface($pAudioMeterInformation, $sIID_IAudioMeterInformation, $tagIAudioMeterInformation)
EndFunc

Func WM_NCHITTEST($hWnd, $iMsg, $iwParam, $ilParam)
	If $hWnd == $HWND_GUI_TEMP Then
		Local $MousePos = MouseGetPos()
		Local $WinPos = WinGetPos($hWnd)
		If $hWnd =  $HWND_GUI_TEMP And $iMsg = 0x0084 And $MousePos[1] > $WinPos[1] + 5 And $MousePos[0] > $WinPos[0]+5 And $MousePos[0]+5 < $WinPos[0]+$WinPos[2] And $MousePos[1]+5 < $WinPos[1]+$WinPos[3] Then
			Return 2
		Else
			If $iMsg == $HWND_GUI_TEMP And $iMsg == $WM_NCHITTEST Then
				Return $HTCAPTION
			EndIf
		EndIf
	EndIf
	Return $GUI_RUNDEFMSG
EndFunc























