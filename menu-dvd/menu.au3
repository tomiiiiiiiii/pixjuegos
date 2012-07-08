#include <GUIConstantsEx.au3>
#include <WindowsConstants.au3>
;Opt('MustDeclareVars', 1)
Opt('TrayIconHide',1)
Global $gui, $guiPos, $pic, $picPos
Example1()

;----- example 1 ----
Func Example1()
    Local $n, $msg
    
    GUICreate("My GUI picture", 600, 600, -1, -1, $WS_POPUP)  ; will create a dialog box that when displayed is centered

    ;GUISetBkColor(0xE0FFFF)
    GUICtrlCreatePic("images/fondo.jpg", 0, 0, 600, 600)
	GUICtrlSetState(-1,$GUI_DISABLE)

	$cerrar=GUICtrlCreateButton("X",570,10,25,25)
	
	$pixbros=GUICtrlCreatePic("images/pixbros.jpg", 30, 200,166,62)
	$pixpang=GUICtrlCreatePic("images/pixpang.jpg", 30, 290,166,62)
	$pixfrogger=GUICtrlCreatePic("images/pixfrogger.jpg", 220, 200,166,62)
	$garnatron=GUICtrlCreatePic("images/garnatron.jpg", 220, 290,166,62)
	$pixdash=GUICtrlCreatePic("images/pixdash.jpg", 400, 200,166,62)
	$explorar=GUICtrlCreateButton("Explorar el DVD", 400, 290,166,62)

    GUISetState()
    While 1
        $msg = GUIGetMsg()
        If $msg = $cerrar Then ExitLoop
		If $msg = $pixbros Then pon_juego("pixbros")
		If $msg = $pixpang Then pon_juego("pixpang")
		If $msg = $pixdash Then pon_juego("pixdash")
		If $msg = $garnatron Then pon_juego("garnatron")
		If $msg = $pixfrogger Then pon_juego("pixfrogger")
		If $msg = $explorar Then ShellExecute("explorer",@ScriptDir)
			;Run("c:\windows\explorer.exe "+@ScriptDir)
        If $msg = $GUI_EVENT_CLOSE Then ExitLoop
    WEnd
    
    GUIDelete()
EndFunc

Func pon_juego($juego)
	GuiSetState(@SW_HIDE)
	RunWait("windows\"&$juego&".exe")
	GuiSetState(@SW_SHOW)
EndFunc