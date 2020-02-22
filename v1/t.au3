#cs ----------------------------------------------------------------------------

 AutoIt Version: 3.3.14.5
 Author:         myName

 Script Function:
	Template AutoIt script.

#ce ----------------------------------------------------------------------------

; Script Start - Add your code below here

; Use lure every X time

; Loop
;	If bobble timer up
;		Cast bobble
;	If not casted
; 		Cast pole
;		Search darkest pixel
;		Move mouse
;		If mouse color is gold
;			Wait for splash sound
;			If splash sound
;				Right click
;			Else if timer out
;				Recast pole
;		Else
;			Search darkest pixel again - repeat X timers/timeout
;		If timer up or fish caught
;			End loop

#include <GUIConstantsEx.au3>
#include <ButtonConstants.au3>
#include <GUIConstantsEx.au3>
#include <StaticConstants.au3>
#include <WindowsConstants.au3>
#include <Timers.au3>

Global $SearchWindowCoords[2] = [ "400", "250" ]
Global $FishTimer = 0
Global $PoleCastTime = 20
Global $BobberColors = [ 0x000000, 0x000000 ]
Global $BobberColorSensitivity = 20
Global $SearchWindowIndicators[11]
Global $Active = False
Global $Button1, $Button2
Main()

Func Main()
	Local $SearchWindowGUI = SearchWindowCreate()
	Local $MainWindow = MainWindowCreate()

	While 1
        Switch GUIGetMsg()
            Case $GUI_EVENT_CLOSE
                ExitLoop
			Case $Button1
				$XY = FindDarkestPixelInSearchWindow()
				;$Active = True
			Case $Button2
				;$Active = False
		EndSwitch

    WEnd

EndFunc

Func SearchWindowCreate()
	Local $gui = GUICreate( "crtbsearch", $SearchWindowCoords[0], $SearchWindowCoords[1], @DesktopWidth / 2, @DesktopHeight / 2, -1 )
	For $i = 1 To 10
		$SearchWindowIndicators[$i] = GUICtrlCreatePic( @ScriptDir & "\dot.jpg", 50, 50, 2, 2)
	Next
	WinSetTrans( "crtbsearch","",50)
	GUISetState( @SW_SHOW, $gui )
	Return $gui
EndFunc

Func MainWindowCreate()
	$Form1 = GUICreate("Form1", 174, 94, 192, 124)
	Global $Button1 = GUICtrlCreateButton("Start", 8, 8, 75, 25)
	Global $Button2 = GUICtrlCreateButton("Stop", 88, 8, 75, 25)
	Global $Label1 = GUICtrlCreateLabel("Casts: 0000000", 8, 40, 78, 17)
	Global $Label2 = GUICtrlCreateLabel("Caught: 0000000", 8, 56, 86, 17)
	Global $Label3 = GUICtrlCreateLabel("Uptime: 00:00:00", 8, 72, 85, 17)
	GUISetState(@SW_SHOW)
	Return $form1
EndFunc


Func FindDarkestPixelInSearchWindow()

	Local $COLOR = 0x303365
	Local $SHADE_VARIANT = 10
	Local $STEP = 1
	Local $Darkspot[2]

	Local $searchwinpos = WinGetPos( "crtbsearch" )

	Local $Found = 0
	While $Found == 0
		$Darkspot = PixelSearch( $searchwinpos[0], $searchwinpos[1], $searchwinpos[0] + $SearchWindowCoords[0], $searchwinpos[1] + $SearchWindowCoords[1], $COLOR, $SHADE_VARIANT, $STEP )
		If @error Then
			$Found = 0
			$SHADE_VARIANT += 5
		Else
			$Found = 1
			MouseMove( $Darkspot[0], $Darkspot[1], 10 )
		EndIf
	WEnd



EndFunc





#cs
Func CastPole()
	$FishTimer = _Timer_Init()
EndFunc

Func SearchBobber()
	If _Timer_Diff( $FishTimer ) > $PoleCastTime Then
		CastPole()
		Return 1
	Else
		Local $Coords[10]
		Local $SearchWindowPosition = WinGetPos( "crtbsearch" )
		For $i = 1 To 10
			$Coords[$i] = PixelSearch( $SearchWindowPosition[0], $SearchWindowPosition[1], $SearchWindowCoords[0], $SearchWindowCoords[1], $BobberColors[$i], $BobberColorSensitivity )
			GUICtrlSetPos( $SearchWindowIndicators[$i], $Coords[$i][0], $Coords[$i][1], 1, 1 )
		Next
	EndIf
EndFunc
#ce

