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

oneString := "u"
, twoString := "i"
, threeString := "o"
, fourString := "p"
, charge := "Space"
, onePlusTwo := "t"
, twoPlusThree := "y"
, threePlusFour := "m"
, onePlusTwoPlusThree := "4"
, threePlusTwoPlusOne := "3"
, twoPlusThreePlusFour := "1" 

Hotkey, %oneString%, ONEDOWN
Hotkey, %oneString% up, ONEUP

Hotkey, %twoString%, TWODOWN
Hotkey, %twoString% up, TWOUP

Hotkey, %threeString%, THREEDOWN
Hotkey, %threeString% up, THREEUP

Hotkey, %fourString%, FOURDOWN
Hotkey, %fourString% up, FOURUP

combo = 50
lag = 25
off = 0		;key immediately pressed on up aka roll can be in progress
on = 200	;key must be overheld to press original key, or rolled to another key within time specified aka roll is currently in progress
lock = -1	;input will not be registered until no keys are being pressed on the keyboard aka roll cannot be in progress
comboInProgress = 0

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
			gosub onePlusTwo
		}
		;1+2+3
		else {
			KeyWait, %fourString%, d t0.025
			;1+2+3     
			if ErrorLevel {
				gosub onePlusTwoPlusThree
			}
			;1+2+3+4
			else {
				gosub allFour
			}
		}
	}
	;1 + 3
	else if(instr(A_PriorKey, threeString) && ((A_TimeSincePriorHotkey, threeString) < combo)) { 
		roll := lock
		KeyWait, %twoString%, d t0.025
		;1+3
		if ErrorLevel {
			gosub onePlusThree
		}
		;1+3+2
		else {
			KeyWait, %fourString%, d t0.025
			;1+3+2
			if ErrorLevel {
				gosub onePlusTwoPlusThree
			}
			;1+3+2+4
			else {
				gosub allFour
			}
		}
	}
	;1 + 4 
	else if(instr(A_PriorKey, fourString) && ((A_TimeSincePriorHotkey, fourString) < combo)) { 
		roll := lock
		KeyWait, %threeString%, d t0.025
		if ErrorLevel {
			;do nothing
		}
		;1+4+3
		else {
			KeyWait, %threeString%, d t0.025
			;1+4+3
			if ErrorLevel {
				;do nothng
			}
			;1+4+3+2
			else {
				gosub allFour
			}
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
				gosub twoPlusThree
			}
			;2+3+4
			else {
				KeyWait, %oneString%, d t0.025
				;2+3+4       
				if ErrorLevel {      
					gosub twoPlusThreePlusFour
				}
				;2+3+4+1
				else {
					gosub allFour
				}
			}
		}
		;2+3+1
		else {
			KeyWait, %fourString%, d t0.025
			;2+3+1     
			if ErrorLevel {      
				gosub onePlusTwoPlusThree
			}
			;2+3+1+4
			else {
				gosub allFour
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
				gosub onePlusTwo
			}
			;2+1+4
			else {
				KeyWait, %threeString%, d t0.025
				;2+1+4
				if ErrorLevel {
					;do nothing
				}
				;2+1+4+3
				else {
					gosub allFour
				}
			}
		}
		;2+1+3
		else {
			KeyWait, %fourString%, d t0.025
			;2+1+3     
			if ErrorLevel {      
				gosub onePlusTwoPlusThree
			}
			;2+1+3+4
			else {
				gosub allFour
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
				;do nothing
			}
			;2+4+1
			else {
				KeyWait, %threeString%, d t0.025
				;2+4+1
				if ErrorLevel { 
					;do nothing
				}
				;2+4+1+3
				else {
					gosub allFour
				}
			}
		}
		;2+4+3
		else {
			KeyWait, %oneString%, d t0.025
			;2+4+3     
			if ErrorLevel {   
				gosub twoPlusThreePlusFour
			}
			;2+4+3+1
			else {
				gosub allFour
			}
		}
	}
	if(roll != lock) {
		roll := on
	}
exit

THREEDOWN: 
	;3 + 1
	if(instr(A_PriorKey, oneString) && ((A_TimeSincePriorHotkey, oneString) < combo)) { 
		roll := lock
		KeyWait, %twoString%, d t0.025
		;3+1
		if ErrorLevel {
			gosub onePlusThree
		}
		;3+1+2
		else {
			KeyWait, %fourString%, d t0.025
			;3+1+2
			if ErrorLevel {
				gosub threePlusTwoPlusOne
			}
			;3+1+2+4
			else {
				gosub allFour
			}
		}
	} 
	;3 + 2
	else if(instr(A_PriorKey, twoString) && ((A_TimeSincePriorHotkey, twoString) < combo)) {
		roll := lock
		KeyWait, %oneString%, d t0.025       
		if ErrorLevel {  
			KeyWait, %fourString%, d t0.025
			;3+2
			if ErrorLevel {       
				gosub twoPlusThree
			}
			;3+2+4
			else {
				KeyWait, %oneString%, d t0.025
				;3+2+4     
				if ErrorLevel {      
					gosub twoPlusThreePlusFour
				}
				;3+2+4+1
				else {
					gosub allFour
				}
			}
		}
		;3+2+1
		else {
			KeyWait, %fourString%, d t0.025
			;3+2+1
			if ErrorLevel {     
				gosub threePlusTwoPlusOne
			}
			;3+2+1+4
			else {
				gosub allFour
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
				gosub threePlusFour
			}   
			;3+4+1
			else {
				KeyWait, %twoString%, d t0.025
				;3+4+1
				if ErrorLevel {
					;do nothing
				}
				;3+4+1+2
				else {
					gosub allFour
				}
			}                 
		}
		;3+4+2
		else {
			KeyWait, %oneString%, d t0.025
			;3+4+2
			if ErrorLevel {    
				gosub twoPlusThreePlusFour
			}
			;3+4+2+1
			else {
				gosub allFour
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
			gosub threePlusFour
		}
		;4+3+2
		else {
			KeyWait, %oneString%, d t0.015
			;4+3+2;
			if ErrorLevel {  
				gosub twoPlusThreePlusFour
			}
			;4+3+2+1
			else {
				gosub allFour
			}
		}
	}
	;4 + 1 
	else if(instr(A_PriorKey, oneString) && ((A_TimeSincePriorHotkey, oneString) < combo)) { 
		roll := lock
		KeyWait, %threeString%, d t0.025
		;4+1
		if ErrorLevel {
			;do nothing
		}
		;4+1+3
		else {
			KeyWait, %twoString%, d t0.025
			;4+3+1
			if ErrorLevel {
				;do nothing
			}
			;4+3+1+2
			else {
				gosub allFour
			}
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
	gosub oneToTwo
}
;if you rolled 1 -> 3
else if (roll != lock && instr(A_PriorKey, threeString) && (A_TimeSincePriorHotkey, threeString) < roll) {
	gosub oneToThree
}
numP := GetAllKeysPressed("P")
MaxIndex := numP.MaxIndex()
if (MaxIndex < 1 || GetKeyState("Shift", "P")==1)  {
  roll := off	;roll will be unlocked when no keys on the keyboard are pressed
  comboInProgress := 0
}
exit 


TWOUP:
isModified :=  (GetKeyState("Space", "P") || GetKeyState("Control", "P") || GetKeyState("CapsLock", "P") || GetKeyState("Tab", "P"))
;if you overheld 2(or roll is off) or didn't roll
if (!isModified && roll != lock && (((A_TimeSincePriorHotkey, twoString) >= roll)  || (instr(A_PriorKey, twoString)))) {
	if(GetKeyState("Shift", "P") && GetKeyState("LAlt", "P")=0) {
		send {%onePlusTwo% down}
		send {%twoPlusThree% down}
		sleep %lag%
		send {%onePlusTwo% up}
		send {%twoPlusThree% up}
	}
    else if GetKeyState("LAlt", "P")=0 {
		send {%onePlusTwo% down}
		send {%twoPlusThree% down}
		sleep %lag%
		send {%onePlusTwo% up}
		send {%twoPlusThree% up}
	}
	if (roll != lock) {
		roll := off
	}
}
;if you rolled 2 -> 3
else if (roll != lock && instr(A_PriorKey, threeString) && (A_TimeSincePriorHotkey, threeString) < roll) {
	gosub twoToThree
}
;if you rolled 2 -> 1
else if (roll != lock && instr(A_PriorKey, oneString) && (A_TimeSincePriorHotkey, oneString) < roll) {
	gosub twoToOne
}
numP := GetAllKeysPressed("P")
MaxIndex := numP.MaxIndex()
if (MaxIndex < 1 || GetKeyState("Shift", "P")==1)  {
  roll := off	;roll will be unlocked when no keys on the keyboard are pressed
  comboInProgress := 0
}
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
	gosub threeToTwo
}
;if you rolled 3 -> 4
else if (roll != lock && instr(A_PriorKey, fourString) && (A_TimeSincePriorHotkey, fourString) < roll) {
	gosub threeToFour
}
;if you rolled 3 -> 1
else if (roll != lock && instr(A_PriorKey, oneString) && (A_TimeSincePriorHotkey, oneString) < roll) {
	gosub threeToOne
}
numP := GetAllKeysPressed("P")
MaxIndex := numP.MaxIndex()
if (MaxIndex < 1 || GetKeyState("Shift", "P")==1) {
  roll := off	;roll will be unlocked when no keys on the keyboard are pressed
  comboInProgress := 0
}
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
	gosub fourToThree
}
numP := GetAllKeysPressed("P")
MaxIndex := numP.MaxIndex()
if (MaxIndex < 1 || GetKeyState("Shift", "P")==1)  {
  roll := off	;roll will be unlocked when no keys on the keyboard are pressed
  comboInProgress := 0
}
exit 

oneToTwo:
	send {%oneString% down}
	send {%onePlusTwo% down}
	sleep %lag%
	send {%oneString% up}
	send {%onePlusTwo% up}
	roll := lock
return

oneToThree:
	send {%oneString% down}
	send {%onePlusTwo% down}
	send {%threePlusTwoPlusOne% down}
	sleep %lag%
	send {%oneString% up}
	send {%onePlusTwo% up}
	send {%threePlusTwoPlusOne% up}
	roll := lock
return

threeToOne:
	send {%threeString% down}
	send {%twoPlusThree% down}
	send {%onePlusTwoPlusThree% down}
	sleep %lag%
	send {%threeString% up}
	send {%twoPlusThree% up}
	send {%onePlusTwoPlusThree% up}
	roll := lock
return

twoToOne:
	send {%threeString% down}
	send {%twoPlusThree% down}
	sleep %lag%
	send {%oneString% up}
	send {%twoPlusThree% up}
	roll := lock
return

twoToThree:
	send {%threeString% down}
	send {%twoPlusThree% down}
	sleep %lag%
	send {%threeString% up}
	send {%twoPlusThree% up}
	roll := lock
return

threeToTwo:
	send {%threeString% down}
	send {%twoPlusThree% down}
	sleep %lag%
	send {%threeString% up}
	send {%twoPlusThree% up}
	roll := lock
return

threeToFour:
	send {%threeString% down}
	send {%fourString% down}
	sleep %lag%
	send {%threeString% up}
	send {%fourString% up}
	roll := lock
return

fourToThree:
	send {%threeString% down}
	send {%fourString% down}
	sleep %lag%
	send {%threeString% up}
	send {%fourString% up}
	roll := lock
return

onePlusTwo:
	if(comboInProgress == 0) {
		comboInProgress := 1
		send {%onePlusTwo% down}
		sleep %lag%
		send {%onePlusTwo% up}
	}
return

onePlusThree:
	if(comboInProgress == 0) {
		comboInProgress := 1
		send {%oneString% down} 
		send {%threeString% down} 
		sleep %lag% 
		send {%oneString% up} 
		send {%threeString% up}
	}
return

twoPlusThree:
	if(comboInProgress == 0) {
		comboInProgress := 1
		send {%twoPlusThree% down}
		sleep %lag%
		send {%twoPlusThree% up}
	}
return

threePlusFour:
	if(comboInProgress == 0) {
		comboInProgress := 1
		send {%threePlusFour% down}
		sleep %lag%
		send {%threePlusFour% up}
	}
return

onePlusTwoPlusThree:
	if(comboInProgress == 0) {
		comboInProgress := 1
		send {%onePlusTwoPlusThree% down}
		sleep %lag%
		send {%onePlusTwoPlusThree% up}
	}
return

threePlusTwoPlusOne:
	if(comboInProgress == 0) {
		comboInProgress := 1
		send {%threePlusTwoPlusOne% down}
		sleep %lag%
		send {%threePlusTwoPlusOne% up}
	}
return

twoPlusThreePlusFour:
	if(comboInProgress == 0) {
		comboInProgress := 1
		comboInProgress := 1
		send {%onePlusTwo% down}
		send {%threePlusFour% down}
		sleep %lag%
		send {%onePlusTwo% up}
		send {%threePlusFour% up}
	}
return

allFour:
	if(comboInProgress == 0) {
		comboInProgress := 1
		send {%onePlusTwo% down}
		send {%threePlusFour% down}
		sleep %lag%
		send {%onePlusTwo% up}
		send {%threePlusFour% up}
	}
return
