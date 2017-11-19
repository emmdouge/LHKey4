; Always run as admin
;if not A_IsAdmin
;{
;   Run *RunAs "%A_ScriptFullPath%"  ; Requires v1.0.92.01+
;   ExitApp
;}
#SingleInstance force
#include CvJoyInterface.ahk
#Persistent
#NoEnv
#InstallKeybdHook
#UseHook On
SetBatchLines, -1                 ;makes the script run at max speed
SetKeyDelay , -1, -1              ;faster response (might be better with -1, 0)
ListLines, Off
#KeyHistory 12
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
twoPlusThreePlusFour := "-"
allButtons := "*"
fourToOne := "q"
 
; Create an object from vJoy Interface Class.
vJoyInterface := new CvJoyInterface()
myStick := vJoyInterface.Devices[1]

; Was vJoy installed and the DLL Loaded?
if (!vJoyInterface.vJoyEnabled()){
	; Show log of what happened
	Msgbox % vJoyInterface.LoadLibraryLog
	ExitApp
}

oneString := "u"
twoString := "i"
threeString := "o"
fourString := "p"
grab := "Space"

Hotkey, %oneString%, ONEDOWN
Hotkey, %oneString% up, ONEUP

Hotkey, %twoString%, TWODOWN
Hotkey, %twoString% up, TWOUP

Hotkey, %threeString%, THREEDOWN
Hotkey, %threeString% up, THREEUP

Hotkey, %fourString%, FOURDOWN
Hotkey, %fourString% up, FOURUP

Hotkey, %grab%, GRAB

combo = 50
lag = 25
off = 0		;key immediately pressed on up
on = 200	;key must be overheld to press original key, or rolled to another key within time specified
lock = -1	;input will not be registered until no keys are being pressed on the keyboard

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

roll := on

ONEDOWN:
	;1 + 2
	if(instr(A_PriorKey, twoString) && ((A_TimeSincePriorHotkey, twoString) < combo)) {
		roll := lock
		KeyWait, %threeString%, d t0.025           
		;1+2
		if ErrorLevel {                          
			send {%onePlusTwo% down}
			sleep %lag%
			send {%onePlusTwo% up}
		}
		;1+2+3
		else {
			KeyWait, %fourString%, d t0.025
			;1+2+3     
			if ErrorLevel {
				send {%oneString% down}
				send {%twoString% down}
				send {%onePlusTwo% down}
				sleep %lag%
				send {%oneString% up}
				send {%twoString% up}
				send {%onePlusTwo% up}
			}
			;1+2+3+4
			else {
				send {%onePlusTwo% down}
				send {%threePlusFour% down}
				sleep %lag%
				send {%onePlusTwo% up}
				send {%threePlusFour% up}
			}
		}
	}
	;1 + 4 
	else if(instr(A_PriorKey, fourString) && ((A_TimeSincePriorHotkey, fourString) < combo)) { 
		roll := lock
		KeyWait, %threeString%, d t0.025
		if ErrorLevel {
			send {%oneString% down} 
			send {%fourString% down} 
			sleep %lag% 
			send {%oneString% up} 
			send {%fourString% up} 
		}
		;1+4+3
		else {
			send {%onePlusTwo% down}
			send {%threePlusFour% down}
			sleep %lag%
			send {%onePlusTwo% up}
			send {%threePlusFour% up}
		}
	} 
	if (roll != lock) {
		roll := on
	}
exit

TWODOWN:
	;2 + 3
	if(instr(A_PriorKey, threeString) && ((A_TimeSincePriorHotkey, threeString) < combo)) {
		roll := lock
		KeyWait, %oneString%, d t0.025
		if ErrorLevel {        
			KeyWait, %fourString%, d t0.025
			;2+3     
			if ErrorLevel {             
				send {%twoString% down}
				send {%threeString% down}
				sleep %lag%
				send {%twoString% up}
				send {%threeString% up}
			}
			;2+3+4
			else {
				KeyWait, %oneString%, d t0.025
				;2+3+4       
				if ErrorLevel {      
					send {%threeString% down}
					send {%fourString% down}
					send {%threePlusFour% down}
					sleep %lag%
					send {%threeString% up}
					send {%fourString% up}
					send {%threePlusFour% up}
				}
				;2+3+4+1
				else {
					send {%onePlusTwo% down}
					send {%threePlusFour% down}
					sleep %lag%
					send {%onePlusTwo% up}
					send {%threePlusFour% up}
				}
			}
		}
		;2+3+1
		else {
			KeyWait, %fourString%, d t0.025
			;2+3+1     
			if ErrorLevel {      
				send {%oneString% down}
				send {%twoString% down}
				send {%onePlusTwo% down}
				sleep %lag%
				send {%oneString% up}
				send {%twoString% up}
				send {%onePlusTwo% up}
			}
			;2+3+1+4
			else {
				send {%onePlusTwo% down}
				send {%threePlusFour% down}
				sleep %lag%
				send {%onePlusTwo% up}
				send {%threePlusFour% up}
			}
		}
	}
	;2 + 1
	else if(instr(A_PriorKey, oneString) && ((A_TimeSincePriorHotkey, oneString) < combo)) {
		roll := lock
		KeyWait, %threeString%, d t0.025           
		;2+1
		if ErrorLevel {        
			KeyWait, %fourString%, d t0.025
			;2+1
			if ErrorLevel { 
				send {%onePlusTwo% down}
				sleep %lag%
				send {%onePlusTwo% up}
			}
			;2+1+4 might as well be all four lol
			else {
				send {%onePlusTwo% down}
				send {%threePlusFour% down}
				sleep %lag%
				send {%onePlusTwo% up}
				send {%threePlusFour% up}
			}
		}
		;2+1+3
		else {
			KeyWait, %fourString%, d t0.025
			;2+1+3     
			if ErrorLevel {      
				send {%oneString% down}
				send {%twoString% down}
				send {%onePlusTwo% down}
				sleep %lag%
				send {%oneString% up}
				send {%twoString% up}
				send {%onePlusTwo% up}
			}
			;2+1+3+4
			else {
				send {%onePlusTwo% down}
				send {%threePlusFour% down}
				sleep %lag%
				send {%onePlusTwo% up}
				send {%threePlusFour% up}
			}
		}
	}
	;2 + 4
	else if(instr(A_PriorKey, fourString) && ((A_TimeSincePriorHotkey, fourString) < combo)) {
		roll := lock
		KeyWait, %threeString%, d t0.025           
		;2+4
		if ErrorLevel {        
			KeyWait, %oneString%, d t0.025
			;2+4
			if ErrorLevel { 
					send {%threeString% down}
					send {%fourString% down}
					send {%threePlusFour% down}
					sleep %lag%
					send {%threeString% up}
					send {%fourString% up}
					send {%threePlusFour% up}
			}
			;2+4+1
			else {
				KeyWait, %threeString%, d t0.025
				;2+4+1
				if ErrorLevel { 
					send {%onePlusTwo% down}
					send {%threePlusFour% down}
					sleep %lag%
					send {%onePlusTwo% up}
					send {%threePlusFour% up}
				}
				;2+4+1+3
				else {
					send {%onePlusTwo% down}
					send {%threePlusFour% down}
					sleep %lag%
					send {%onePlusTwo% up}
					send {%threePlusFour% up}
				}
			}
		}
		;2+4+3
		else {
			KeyWait, %oneString%, d t0.025
			;2+4+3     
			if ErrorLevel {      
					send {%threeString% down}
					send {%fourString% down}
					send {%threePlusFour% down}
					sleep %lag%
					send {%threeString% up}
					send {%fourString% up}
					send {%threePlusFour% up}
			}
			;2+4+3+1
			else {
				send {%onePlusTwo% down}
				send {%threePlusFour% down}
				sleep %lag%
				send {%onePlusTwo% up}
				send {%threePlusFour% up}
			}
		}
	}
	if(roll != lock) {
		roll := on
	}
exit

THREEDOWN: 
	;3 + 2
	if(instr(A_PriorKey, twoString) && ((A_TimeSincePriorHotkey, twoString) < combo)) {
		roll := lock
		KeyWait, %oneString%, d t0.025       
		if ErrorLevel {  
			KeyWait, %fourString%, d t0.025
			;3+2
			if ErrorLevel {             
				send {%twoString% down}
				send {%threeString% down}
				sleep %lag%
				send {%twoString% up}
				send {%threeString% up}
			}
			;3+2+4
			else {
				KeyWait, %oneString%, d t0.025
				;3+2+4     
				if ErrorLevel {      
					send {%threeString% down}
					send {%fourString% down}
					send {%threePlusFour% down}
					sleep %lag%
					send {%threeString% up}
					send {%fourString% up}
					send {%threePlusFour% up}
				}
				;3+2+4+1
				else {
					send {%allButtons% down}
					sleep %lag%
					send {%allButtons% up}
				}
			}
		}
		;3+2+1
		else {
			KeyWait, %fourString%, d t0.025
			;3+2+1
			if ErrorLevel {      
				send {%oneString% down}
				send {%twoString% down}
				send {%onePlusTwo% down}
				sleep %lag%
				send {%oneString% up}
				send {%twoString% up}
				send {%onePlusTwo% up}
			}
			;3+2+1+4
			else {
				send {%onePlusTwo% down}
				send {%threePlusFour% down}
				sleep %lag%
				send {%onePlusTwo% up}
				send {%threePlusFour% up}
			}
		}
	}
	;3 + 4
	else if(instr(A_PriorKey, fourString) && ((A_TimeSincePriorHotkey, fourString) < combo)) {
		roll := lock
		KeyWait, %twoString%, d t0.025           
		;3+4
		if ErrorLevel {   	
			KeyWait, %oneString%, d t0.025 
			if ErrorLevel { 
				send {%threePlusFour% down}
				sleep %lag%
				send {%threePlusFour% up}
			}   
			;3+4+1 might as well be all four lol
			else {
				send {%onePlusTwo% down}
				send {%threePlusFour% down}
				sleep %lag%
				send {%onePlusTwo% up}
				send {%threePlusFour% up}
			}                 
		}
		;3+4+2
		else {
			KeyWait, %oneString%, d t0.025
			;3+4+2
			if ErrorLevel {      
				send {%threeString% down}
				send {%fourString% down}
				send {%threePlusFour% down}
				sleep %lag%
				send {%threeString% up}
				send {%fourString% up}
				send {%threePlusFour% up}
			}
			;3+4+2+1
			else {
				send {%onePlusTwo% down}
				send {%threePlusFour% down}
				sleep %lag%
				send {%onePlusTwo% up}
				send {%threePlusFour% up}
			}
		}
	}
	if(roll != lock) {
		roll := on
	}
exit

FOURDOWN:
	;4 + 3
	if(instr(A_PriorKey, threeString) && ((A_TimeSincePriorHotkey, threeString) < combo)) {
		roll := lock
		KeyWait, %twoString%, d t0.025           
		;4+3
		if ErrorLevel {                          
			send {%threePlusFour% down}
			sleep %lag%
			send {%threePlusFour% up}
		}
		;4+3+2
		else {
			KeyWait, %oneString%, d t0.015
			;4+3+2;
			if ErrorLevel {      
				send {%threeString% down}
				send {%fourString% down}
				send {%threePlusFour% down}
				sleep %lag%
				send {%threeString% up}
				send {%fourString% up}
				send {%threePlusFour% up}
			}
			;4+3+2+1
			else {
				send {%onePlusTwo% down}
				send {%threePlusFour% down}
				sleep %lag%
				send {%onePlusTwo% up}
				send {%threePlusFour% up}
			}
		}
	}
	;4 + 1 
	else if(instr(A_PriorKey, oneString) && ((A_TimeSincePriorHotkey, oneString) < combo)) { 
		roll := lock
		KeyWait, %threeString%, d t0.025
		;4+1
		if ErrorLevel {
			send {%oneString% down} 
			send {%fourString% down} 
			sleep %lag% 
			send {%oneString% up} 
			send {%fourString% up} 
		}
		;4+1+3
		else {
			send {%onePlusTwo% down}
			send {%threePlusFour% down}
			sleep %lag%
			send {%onePlusTwo% up}
			send {%threePlusFour% up}
		}
	} 
	if (roll != lock) {
		roll := on
	}
exit

ONEUP:
isModified :=  (GetKeyState("Space", "P") || GetKeyState("Control", "P") || GetKeyState("CapsLock", "P") || GetKeyState("Tab", "P"))
;if you overheld 1(or roll is off) or didn't roll
if (!isModified && roll != lock && (((A_TimeSincePriorHotkey, oneString) >= roll)  || (instr(A_PriorKey, oneString)))) {
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
	if (roll != lock) {
		roll := off
	}
}
;if you rolled 1 -> 2
else if (roll != lock && instr(A_PriorKey, twoString) && (A_TimeSincePriorHotkey, twoString) < roll) {
		send {%oneString% down}
		send {%twoString% down}
		sleep %lag%
		send {%oneString% up}
		send {%twoString% up}
		roll := lock
}
numP := GetAllKeysPressed("P")
MaxIndex := numP.MaxIndex()
if (MaxIndex < 1 || GetKeyState("Shift", "P")==1) 
  roll := off	;roll will be unlocked when no keys on the keyboard are pressed
exit 


TWOUP:
isModified :=  (GetKeyState("Space", "P") || GetKeyState("Control", "P") || GetKeyState("CapsLock", "P") || GetKeyState("Tab", "P"))
;if you overheld 2(or roll is off) or didn't roll
if (!isModified && roll != lock && (((A_TimeSincePriorHotkey, twoString) >= roll)  || (instr(A_PriorKey, twoString)))) {
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
	if (roll != lock) {
		roll := off
	}
}
;if you rolled 2 -> 3
else if (roll != lock && instr(A_PriorKey, threeString) && (A_TimeSincePriorHotkey, threeString) < roll) {
	send {%twoBiThree% down}
	sleep %lag%
	send {%twoBiThree% up}
	roll := lock
}
;if you rolled 2 -> 1
else if (roll != lock && instr(A_PriorKey, oneString) && (A_TimeSincePriorHotkey, oneString) < roll) {
	send {%oneString% down}
	send {%twoString% down}
	sleep %lag%
	send {%oneString% up}
	send {%twoString% up}
	roll := lock
}
numP := GetAllKeysPressed("P")
MaxIndex := numP.MaxIndex()
if (MaxIndex < 1 || GetKeyState("Shift", "P")==1) 
  roll := off	;roll will be unlocked when no keys on the keyboard are pressed
exit 


THREEUP:
isModified :=  (GetKeyState("Spaceh", "P") || GetKeyState("Control", "P") || GetKeyState("CapsLock", "P") || GetKeyState("Tab", "P"))
;if you overheld 3(or roll is off) or didn't roll
if (!isModified && roll != lock && (((A_TimeSincePriorHotkey, threeString) >= roll) || (instr(A_PriorKey, threeString)))) {
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
	if (roll != lock) {
		roll := off
	}
}
;if you rolled 3 -> 2
else if (roll != lock && instr(A_PriorKey, twoString) && (A_TimeSincePriorHotkey, twoString) < roll) {
	send {%twoBiThree% down}
	sleep %lag%
	send {%twoBiThree% up}
	roll := lock
}
;if you rolled 3 -> 4
else if (roll != lock && instr(A_PriorKey, fourString) && (A_TimeSincePriorHotkey, fourString) < roll) {
	send {%threeString% down}
	send {%fourString% down}
	sleep %lag%
	send {%threeString% up}
	send {%fourString% up}
	roll := lock
}
numP := GetAllKeysPressed("P")
MaxIndex := numP.MaxIndex()
if (MaxIndex < 1 || GetKeyState("Shift", "P")==1) 
  roll := off	;roll will be unlocked when no keys on the keyboard are pressed
exit 

FOURUP:
isModified :=  (GetKeyState("Space", "P") || GetKeyState("Control", "P") || GetKeyState("CapsLock", "P") || GetKeyState("Tab", "P"))
;if you overheld 4(or roll is off) or didn't roll
if (!isModified && roll != lock && (((A_TimeSincePriorHotkey, fourString) >= roll)  || (instr(A_PriorKey, fourString)))) {
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
	if (roll != lock) {
		roll := off
	}
}
;if you rolled 4 -> 3
else if (roll != lock && instr(A_PriorKey, threeString) && (A_TimeSincePriorHotkey, threeString) < roll) {
	send {%threeString% down}
	send {%fourString% down}
	sleep %lag%
	send {%threeString% up}
	send {%fourString% up}
	roll := lock
}
numP := GetAllKeysPressed("P")
MaxIndex := numP.MaxIndex()
if (MaxIndex < 1 || GetKeyState("Shift", "P")==1) 
  roll := off	;roll will be unlocked when no keys on the keyboard are pressed
exit 

GRAB:
	;1+4
    send {%oneString% down} 
    send {%fourString% down} 
    sleep %lag% 
    send {%oneString% up} 
    send {%fourString% up} 
exit
