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

oneBiTwo := "8"
oneToFour := "e"
twoBiThree := "7"
threeBiFour := "8"
onePlusTwo := "t"
twoPlusThree := "y"
threePlusFour := "m" 
onePlusFour := "r"
onePlusTwoPlusThree := "+"
fourToOne := "q"


oneString := "u"
twoString := "i"
threeString := "o"
fourString := "p"

Hotkey, %oneString%, ONEDOWN
Hotkey, %oneString% up, ONEUP

Hotkey, %twoString%, TWODOWN
Hotkey, %twoString% up, TWOUP

Hotkey, %threeString%, THREEDOWN
Hotkey, %threeString% up, THREEUP

Hotkey, %fourString%, FOURDOWN
Hotkey, %fourString% up, FOURUP


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
if MaxIndex < 1 || GetKeyState("Shift", "P")==1
  roll := 0

ONEDOWN:
	roll := cons
	;1 + 2
	if(instr(A_PriorKey, twoString) && ((A_TimeSincePriorHotkey, twoString) < combo)) {
		KeyWait, %threeString%, d t0.025           ; Making sure  you pressed home twice
		if ErrorLevel {                           ; If it was only pressed one send the default action
			send {%onePlusTwo% down}
			sleep %lag%
			send {%onePlusTwo% up}
		}
		else {
			send {%onePlusTwoPlusThree% down}
			sleep %lag%
			send {%onePlusTwoPlusThree% up}
		}
	}
	;1 + 4
	if(instr(A_PriorKey, fourString) && ((A_TimeSincePriorHotkey, fourString) < combo)) {
		send {%oneString% down}
		send {%fourString% down}
		sleep %lag%
		send {%oneString% up}
		send {%fourString% up}
	}
exit

TWODOWN:
;the moment you press a key, unlock the roll
	roll := cons
	;2 + 3
	if(instr(A_PriorKey, threeString) && ((A_TimeSincePriorHotkey, threeString) < combo)) {
		KeyWait, %oneString%, d t0.025           ; Making sure  you pressed home twice
		if ErrorLevel {             
			send {%twoString% down}
			send {%threeString% down}
			sleep %lag%
			send {%twoString% up}
			send {%threeString% up}
		}
		else {
			send {%onePlusTwoPlusThree% down}
			sleep %lag%
			send {%onePlusTwoPlusThree% up}
		}
	}
	;2 + 1
	if(instr(A_PriorKey, oneString) && ((A_TimeSincePriorHotkey, oneString) < combo)) {
		KeyWait, %threeString%, d t0.025           ; Making sure  you pressed home twice
		if ErrorLevel {             
			send {%onePlusTwo% down}
			sleep %lag%
			send {%onePlusTwo% up}
		}
		else {
			send {%onePlusTwoPlusThree% down}
			sleep %lag%
			send {%onePlusTwoPlusThree% up}
		}
	}
exit

THREEDOWN: 
;the moment you press a key, unlock the roll
	roll := cons
	;3 + 2
	if(instr(A_PriorKey, twoString) && ((A_TimeSincePriorHotkey, twoString) < combo)) {
		KeyWait, %oneString%, d t0.025           ; Making sure  you pressed home twice
		if ErrorLevel {             
			send {%twoString% down}
			send {%threeString% down}
			sleep %lag%
			send {%twoString% up}
			send {%threeString% up}
		}
		else {
			send {%onePlusTwoPlusThree% down}
			sleep %lag%
			send {%onePlusTwoPlusThree% up}
		}
	}
	;3 + 4
	if(instr(A_PriorKey, fourString) && ((A_TimeSincePriorHotkey, fourString) < combo)) {
		send {%threePlusFour% down}
		sleep %lag%
		send {%threePlusFour% up}
	}
exit

FOURDOWN:
;the moment you press a key, unlock the roll
	roll := cons
	;4 + 3
	if(instr(A_PriorKey, threeString) && ((A_TimeSincePriorHotkey, threeString) < combo)) {
		send {%threePlusFour% down}
		sleep %lag%
		send {%threePlusFour% up}
	}
	;4 + 1
	if(instr(A_PriorKey, oneString) && ((A_TimeSincePriorHotkey, oneString) < combo)) {
		send {%oneString% down}
		send {%fourString% down}
		sleep %lag%
		send {%oneString% up}
		send {%fourString% up}
	}
exit

ONEUP:
isModified :=  (GetKeyState("Space", "P") || GetKeyState("Control", "P") || GetKeyState("CapsLock", "P") || GetKeyState("Tab", "P"))
;if you overheld 1(did not activate roll mechanism) or pressed 1 again
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
;if you rolled 1 -> 2
if (instr(A_PriorKey, twoString) && (A_TimeSincePriorHotkey, twoString) < roll) {
		send {%oneString% down}
		send {%twoString% down}
		sleep %lag%
		send {%oneString% up}
		send {%twoString% up}
}
;if you rolled 1 -> 4 
if (instr(A_PriorKey, fourString) && (A_TimeSincePriorHotkey, fourString) < roll) {
		send {%threeString% down}
		send {%fourString% down}
		send {%threePlusFour% down}
		sleep %lag%
		send {%threeString% up}
		send {%fourString% up}
		send {%threePlusFour% up}
}
exit 


TWOUP:
isModified :=  (GetKeyState("Space", "P") || GetKeyState("Control", "P") || GetKeyState("CapsLock", "P") || GetKeyState("Tab", "P"))
;if you overheld 2(did not activate roll mechanism) or pressed 2 again
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
;if you rolled 2 -> 3
if (instr(A_PriorKey, threeString) && (A_TimeSincePriorHotkey, threeString) < roll) {
	send {%twoBiThree% down}
	sleep %lag%
	send {%twoBiThree% up}
}
;if you rolled 2 -> 1
if (instr(A_PriorKey, oneString) && (A_TimeSincePriorHotkey, oneString) < roll) {
		send {%oneString% down}
		send {%twoString% down}
		sleep %lag%
		send {%oneString% up}
		send {%twoString% up}
}
exit 


THREEUP:
isModified :=  (GetKeyState("Spaceh", "P") || GetKeyState("Control", "P") || GetKeyState("CapsLock", "P") || GetKeyState("Tab", "P"))
;if you overheld 3(did not activate roll mechanism) or pressed 3 again
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
;if you rolled 3 -> 2
if (instr(A_PriorKey, twoString) && (A_TimeSincePriorHotkey, twoString) < roll) {
	send {%twoBiThree% down}
	sleep %lag%
	send {%twoBiThree% up}
}
;if you rolled 3 -> 4
if (instr(A_PriorKey, fourString) && (A_TimeSincePriorHotkey, fourString) < roll) {
		send {%threeString% down}
		send {%fourString% down}
		sleep %lag%
		send {%threeString% up}
		send {%fourString% up}
}
exit 

FOURUP:
isModified :=  (GetKeyState("Space", "P") || GetKeyState("Control", "P") || GetKeyState("CapsLock", "P") || GetKeyState("Tab", "P"))
;if you overheld 4(did not activate roll mechanism) or pressed 4 again
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
;if you rolled 4 -> 1
if (instr(A_PriorKey, oneString) && (A_TimeSincePriorHotkey, oneString) < roll) {
		send {%oneString% down}
		send {%twoString% down}
		send {%onePlusTwo% down}
		sleep %lag%
		send {%oneString% up}
		send {%twoString% up}
		send {%onePlusTwo% up}
}
;if you rolled 4 -> 3
if (instr(A_PriorKey, threeString) && (A_TimeSincePriorHotkey, threeString) < roll) {
		send {%threeString% down}
		send {%fourString% down}
		sleep %lag%
		send {%threeString% up}
		send {%fourString% up}
}
exit 
