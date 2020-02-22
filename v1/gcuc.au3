#cs ----------------------------------------------------------------------------

 AutoIt Version: 3.3.14.5
 Author:         myName

 Script Function:
	Template AutoIt script.

#ce ----------------------------------------------------------------------------

; Script Start - Add your code below here

;red
;0x351C17

;blue
;0x1E2D55

;bobber
;0x7C695B

;volume
;0x51342D

HotKeySet( "{SPACE}", "test" )

Func test()
	MsgBox( 0, "", "Color: " & Hex( PixelGetColor( MouseGetPos( 0 ) - 2, MouseGetPos( 1 ) - 2 ), 6 ) & @CRLF & "Mouse: " & MouseGetPos( 0 ) & ", " & MouseGetPos( 1 ) )
EndFunc

While 1
	Sleep( 10 )
WEnd