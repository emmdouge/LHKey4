#SingleInstance force
#Persistent
#UseHook On
#NoEnv
#InstallKeybdHook
SetBatchLines, -1                 ;makes the script run at max speed
SetKeyDelay , -1, -1              ;faster response (might be better with -1, 0)
ListLines, Off
#KeyHistory 3

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


SetCapsLockState, AlwaysOff
cons = 200
combo = 25
global skey

roll := cons
numP := GetAllKeysPressed("P")
MaxIndex := numP.MaxIndex()
#if MaxIndex < 1 || GetKeyState("Shift", "P")=1
  roll := 0
  skey := 0
return

ONEDOWN: 
;the moment you press a key, unlock the roll
	roll := cons
	if(instr(A_PriorKey, twoString) && ((A_TimeSincePriorHotkey, twoString) < combo)) {
		send {%onePlusTwo%}
	}
	if(instr(A_PriorKey, fourString) && ((A_TimeSincePriorHotkey, fourString) < combo)) {
		send {%onePlusFour%}
	}
return

TWODOWN:
;the moment you press a key, unlock the roll
	roll := cons
	if(instr(A_PriorKey, threeString) && ((A_TimeSincePriorHotkey, threeString) < combo)) {
		send {%twoPlusThree%}
	}
	if(instr(A_PriorKey, oneString) && ((A_TimeSincePriorHotkey, oneString) < combo)) {
		send {%onePlusTwo%}
	}
return

THREEDOWN: 
;the moment you press a key, unlock the roll
	roll := cons
	if(instr(A_PriorKey, twoString) && ((A_TimeSincePriorHotkey, twoString) < combo)) {
		send {%twoPlusThree%}
	}
	if(instr(A_PriorKey, fourString) && ((A_TimeSincePriorHotkey, fourString) < combo)) {
		send {%threePlusFour%}
	}
return

FOURDOWN:
;the moment you press a key, unlock the roll
	roll := cons
	if(instr(A_PriorKey, threeString) && ((A_TimeSincePriorHotkey, threeString) < combo)) {
		send {%threePlusFour%}
	}
	if(instr(A_PriorKey, oneString) && ((A_TimeSincePriorHotkey, oneString) < combo)) {
		send {%onePlusFour%}
	}
return

ONEUP:
isModified :=  (GetKeyState("Space", "P") || GetKeyState("Control", "P") || GetKeyState("CapsLock", "P") || GetKeyState("Tab", "P"))
;if you overheld h or pressed h again
if (!isModified && (A_TimeSincePriorHotkey, oneString) >= roll)  || (instr(A_PriorKey, oneString) && !isModified){
	if(GetKeyState("Shift", "P") && GetKeyState("LAlt", "P")=0) {
		send {%oneString%}
	}
    else if GetKeyState("LAlt", "P")=0 {
		send {%oneString%}
	}
	roll := 0
}
;if you pressed j -> k
if (instr(A_PriorKey, twoString) && (A_TimeSincePriorHotkey, twoString) < roll) {
	send {%oneBiTwo%}
}
if (instr(A_PriorKey, fourString) && (A_TimeSincePriorHotkey, fourString) < roll) {
	send {%oneToFour%}
}
isModified := 0 
return 


TWOUP:
isModified :=  (GetKeyState("Space", "P") || GetKeyState("Control", "P") || GetKeyState("CapsLock", "P") || GetKeyState("Tab", "P"))
;if you overheld j or pressed j again
if (!isModified && (A_TimeSincePriorHotkey, twoString) >= roll)  || (instr(A_PriorKey, twoString) && !isModified){
	if(GetKeyState("Shift", "P") && GetKeyState("LAlt", "P")=0) {
		send {%twoString%}
	}
    else if GetKeyState("LAlt", "P")=0 {
		send {%twoString%}
	}
	roll := 0
}
;if you pressed j -> k
if (instr(A_PriorKey, threeString) && (A_TimeSincePriorHotkey, threeString) < roll) {
	send {%twoBiThree%}
}
if (instr(A_PriorKey, oneString) && (A_TimeSincePriorHotkey, oneString) < roll) {
	send {%oneBiTwo%}
}
isModified := 0 
return 


THREEUP:
isModified :=  (GetKeyState("Spaceh", "P") || GetKeyState("Control", "P") || GetKeyState("CapsLock", "P") || GetKeyState("Tab", "P"))
;if you overheld k or pressed k again
if (!isModified && (A_TimeSincePriorHotkey, threeString) >= roll)  || (instr(A_PriorKey, threeString) && !isModified){
	if(GetKeyState("Shift", "P") && GetKeyState("LAlt", "P")=0) {
		send {%threeString%}
	}
    else if GetKeyState("LAlt", "P")=0 {
		send {%threeString%}
	}
	roll := 0
}
;if you pressed k -> j
if (instr(A_PriorKey, twoString) && (A_TimeSincePriorHotkey, twoString) < roll) {
	send {%twoBiThree%}
}
if (instr(A_PriorKey, fourString) && (A_TimeSincePriorHotkey, fourString) < roll) {
	send {%threeBiFour%}
}
isModified := 0 
return 

FOURUP:
isModified :=  (GetKeyState("Space", "P") || GetKeyState("Control", "P") || GetKeyState("CapsLock", "P") || GetKeyState("Tab", "P"))
;if you overheld l or pressed l again
if (!isModified && (A_TimeSincePriorHotkey, fourString) >= roll)  || (instr(A_PriorKey, fourString) && !isModified){
	if(GetKeyState("Shift", "P") && GetKeyState("LAlt", "P")=0) {
		send {%fourString%}
	}
    else if GetKeyState("LAlt", "P")=0 {
		send {%fourString%}
	}
	roll := 0
}
if (instr(A_PriorKey, oneString) && (A_TimeSincePriorHotkey, oneString) < roll) {
	send {%fourToOne%}
}
if (instr(A_PriorKey, threeString) && (A_TimeSincePriorHotkey, threeString) < roll) {
	send {%threeBiFour%}
}
isModified := 0
return 

GetAllKeysPressed(mode = "L") {
	
	pressed := Array()
	i := 1 
		
	keys = ``|1|2|3|4|5|6|7|8|9|0|-|=|[|]\|;|'|,|.|/|a|b|c|d|e|f|g|h|i|j|k|l|m|n|o|p|q|r|s|t|u|v|w|x|y|z|Esc|Tab|CapsLock|LShift|RShift|LCtrl|RCtrl|LWin|RWin|LAlt|RAlt|Space|AppsKey|Up|Down|Left|Right|Enter|BackSpace|Delete|Home|End|PGUP|PGDN|PrintScreen|ScrollLock|Pause|Insert|NumLock|F1|F2|F3|F4|F5|F6|F7|F8|F9|F10|F11|F12|F13|F14|F15|F16|F17|F18|F19|F20
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

Exit