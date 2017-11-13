; Always run as admin
;if not A_IsAdmin
;{
;   Run *RunAs "%A_ScriptFullPath%"  ; Requires v1.0.92.01+
;   ExitApp
;}
#SingleInstance force
#Persistent
#NoEnv
#InstallKeybdHook
#UseHook On
SetBatchLines, -1                 ;makes the script run at max speed
SetKeyDelay , -1, -1              ;faster response (might be better with -1, 0)
ListLines, Off
#KeyHistory 6
#MaxHotkeysPerInterval 99000000
#HotkeyInterval 99000000
#MaxThreadsPerHotkey 255
SendMode Input
SetCapsLockState, AlwaysOff

oneBiTwo := "i"
oneToFour := "e"
twoBiThree := "u"
threeBiFour := "o"
onePlusTwo := "t"
twoPlusThree := "y"
threePlusFour := "m" 
onePlusFour := "r"
fourToOne := "q"


oneString := "h"
twoString := "j"
threeString := "k"
fourString := "l"

Hotkey, h, ONEDOWN
Hotkey, $~*h up, ONEUP

Hotkey, j, TWODOWN
Hotkey, $~*j up, TWOUP

Hotkey, k, THREEDOWN
Hotkey, $~*k up, THREEUP

Hotkey, l, FOURDOWN
Hotkey, $~*l up, FOURUP


cons = 200
combo = 50
lag = 25

;;;;;;;;;;;;;;;;;;;;;;;;
;	LOGIC
;;;;;;;;;;;;;;;;;;;;;;;;


GetAllKeysPressed(mode = "L") {
	
	pressed := Array()
	i := 1 
		
	;removed wasd and arrow keys from keys to check	to perform command normals
	keys = ``|1|2|3|4|5|6|7|8|9|0|-|=|[|]\|;|'|,|.|/|b|c|e|f|g|h|i|j|k|l|m|n|o|p|q|r|t|u|v|x|y|z|Esc|Tab|CapsLock|LShift|RShift|LCtrl|RCtrl|LWin|RWin|LAlt|RAlt|Space|AppsKey|Enter|BackSpace|Delete|Home|End|PGUP|PGDN|PrintScreen|ScrollLock|Pause|Insert|NumLock|F1|F2|F3|F4|F5|F6|F7|F8|F9|F10|F11|F12|F13|F14|F15|F16|F17|F18|F19|F20 
  	; '|' isn't a key itself (with '\' being the "actual" key), so okay to use is as a delimiter
	Loop Parse, keys, |
	{		
		key = %A_LoopField%				
		isDown :=  GetKeyState(key, mode)
		if(isDown)
		{
			pressed[i] := key ; using 'i' instead of array.insert() for efficiency
			i++
		}
	}   
	
	return pressed
}

roll := cons
numP := GetAllKeysPressed("P")
MaxIndex := numP.MaxIndex()
if MaxIndex < 1 || GetKeyState("Shift", "P")=1
  roll := 0

ONEDOWN: 
;the moment you press a key, unlock the roll
	roll := cons
	if(instr(A_PriorKey, twoString) && ((A_TimeSincePriorHotkey, twoString) < combo)) {
		send {%onePlusTwo% down}
		sleep %lag%
		send {%onePlusTwo% up}
	}
	if(instr(A_PriorKey, fourString) && ((A_TimeSincePriorHotkey, fourString) < combo)) {
		send {%onePlusFour% down}
		sleep %lag%
		send {%onePlusFour% up}
	}
exit

TWODOWN:
;the moment you press a key, unlock the roll
	roll := cons
	if(instr(A_PriorKey, threeString) && ((A_TimeSincePriorHotkey, threeString) < combo)) {
		send {%twoPlusThree% down}
		sleep %lag%
		send {%twoPlusThree% up}
	}
	if(instr(A_PriorKey, oneString) && ((A_TimeSincePriorHotkey, oneString) < combo)) {
		send {%onePlusTwo% down}
		sleep %lag%
		send {%onePlusTwo% up}
	}
exit

THREEDOWN: 
;the moment you press a key, unlock the roll
	roll := cons
	if(instr(A_PriorKey, twoString) && ((A_TimeSincePriorHotkey, twoString) < combo)) {
		send {%twoPlusThree% down}
		sleep %lag%
		send {%twoPlusThree% up}
	}
	if(instr(A_PriorKey, fourString) && ((A_TimeSincePriorHotkey, fourString) < combo)) {
		send {%threePlusFour% down}
		sleep %lag%
		send {%threePlusFour% up}
	}
exit

FOURDOWN:
;the moment you press a key, unlock the roll
	roll := cons
	if(instr(A_PriorKey, threeString) && ((A_TimeSincePriorHotkey, threeString) < combo)) {
		send {%threePlusFour% down}
		sleep %lag%
		send {%threePlusFour% up}
	}
	if(instr(A_PriorKey, oneString) && ((A_TimeSincePriorHotkey, oneString) < combo)) {
		send {%onePlusFour% down}
		sleep %lag%
		send {%onePlusFour% up}
	}
exit

ONEUP:
isModified :=  (GetKeyState("Space", "P") || GetKeyState("Control", "P") || GetKeyState("CapsLock", "P") || GetKeyState("Tab", "P"))
;if you overheld h or pressed h again
if (!isModified && (A_TimeSincePriorHotkey, oneString) >= roll)  || (instr(A_PriorKey, oneString) && !isModified){
	if(GetKeyState("Shift", "P") && GetKeyState("LAlt", "P")=0) {
		send {%oneString% down}
		sleep %lag%
		send {%oneString% up}
	}
    else if GetKeyState("LAlt", "P")=0 {
		send {%oneString% down}
		sleep %lag%
		send {%oneString% up}
	}
	roll := 0
}
;if you pressed j -> k
if (instr(A_PriorKey, twoString) && (A_TimeSincePriorHotkey, twoString) < roll) {
	send {%oneBiTwo% down}
	sleep %lag%
	send {%oneBiTwo% up}
}
if (instr(A_PriorKey, fourString) && (A_TimeSincePriorHotkey, fourString) < roll) {
	send {%oneToFour% down}
	sleep %lag%
	send {%oneToFour% up}
}
isModified := 0 
exit 


TWOUP:
isModified :=  (GetKeyState("Space", "P") || GetKeyState("Control", "P") || GetKeyState("CapsLock", "P") || GetKeyState("Tab", "P"))
;if you overheld j or pressed j again
if (!isModified && (A_TimeSincePriorHotkey, twoString) >= roll)  || (instr(A_PriorKey, twoString) && !isModified){
	if(GetKeyState("Shift", "P") && GetKeyState("LAlt", "P")=0) {
		send {%twoString% down}
		sleep %lag%
		send {%twoString% up}
	}
    else if GetKeyState("LAlt", "P")=0 {
		send {%twoString% down}
		sleep %lag%
		send {%twoString% up}
	}
	roll := 0
}
;if you pressed j -> k
if (instr(A_PriorKey, threeString) && (A_TimeSincePriorHotkey, threeString) < roll) {
	send {%twoBiThree% down}
	sleep %lag%
	send {%twoBiThree% up}
}
if (instr(A_PriorKey, oneString) && (A_TimeSincePriorHotkey, oneString) < roll) {
	send {%oneBiTwo% down}
	sleep %lag%
	send {%oneBiTwo% up}
}
isModified := 0 
exit 


THREEUP:
isModified :=  (GetKeyState("Spaceh", "P") || GetKeyState("Control", "P") || GetKeyState("CapsLock", "P") || GetKeyState("Tab", "P"))
;if you overheld k or pressed k again
if (!isModified && (A_TimeSincePriorHotkey, threeString) >= roll)  || (instr(A_PriorKey, threeString) && !isModified){
	if(GetKeyState("Shift", "P") && GetKeyState("LAlt", "P")=0) {
		send {%threeString% down}
		sleep %lag%
		send {%threeString% up}
	}
    else if GetKeyState("LAlt", "P")=0 {
		send {%threeString% down}
		sleep %lag%
		send {%threeString% up}
	}
	roll := 0
}
;if you pressed k -> j
if (instr(A_PriorKey, twoString) && (A_TimeSincePriorHotkey, twoString) < roll) {
	send {%twoBiThree% down}
	sleep %lag%
	send {%twoBiThree% up}
}
if (instr(A_PriorKey, fourString) && (A_TimeSincePriorHotkey, fourString) < roll) {
	send {%threeBiFour% down}
	sleep %lag%
	send {%threeBiFour% up}
}
isModified := 0 
exit 

FOURUP:
isModified :=  (GetKeyState("Space", "P") || GetKeyState("Control", "P") || GetKeyState("CapsLock", "P") || GetKeyState("Tab", "P"))
;if you overheld l or pressed l again
if (!isModified && (A_TimeSincePriorHotkey, fourString) >= roll)  || (instr(A_PriorKey, fourString) && !isModified){
	if(GetKeyState("Shift", "P") && GetKeyState("LAlt", "P")=0) {
		send {%fourString% down}
		sleep %lag%
		send {%fourString% up}
	}
    else if GetKeyState("LAlt", "P")=0 {
		send {%fourString% down}
		sleep %lag%
		send {%fourString% up}
	}
	roll := 0
}
if (instr(A_PriorKey, oneString) && (A_TimeSincePriorHotkey, oneString) < roll) {
	send {%fourToOne% down}
	sleep %lag%
	send {%fourToOne% up}
}
if (instr(A_PriorKey, threeString) && (A_TimeSincePriorHotkey, threeString) < roll) {
	send {%threeBiFour% down}
	sleep %lag%
	send {%threeBiFour% up}
}
isModified := 0
exit 
