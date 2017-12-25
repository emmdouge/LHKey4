﻿; Always run as admin
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
#KeyHistory 6
#MaxHotkeysPerInterval 99000000
#HotkeyInterval 99000000
#MaxThreadsPerHotkey 255
;Process, Priority, , A
SetBatchLines, -1                 ;makes the script run at max speed
SetKeyDelay , -1, -1              ;faster response (might be better with -1, 0)
ListLines, Off
SendMode Input
SetCapsLockState, AlwaysOff

up := "w"
, down := "s"
, left := "a"
, right := "d"
, ZplusR := "e"
, buttonA := "u"
, modA := "U"
, buttonZ := "i"
, modZ := "I"
, buttonB := "o"
, modB := "O"
, buttonR := "Space"
, special0 := "0"
, special1 := "1"
, special2 := "2"
, special3 := "3"
, special4 := "4"
, special5 := "5"
, special6 := "6"
, special7 := "7"
, special8 := "8"

Hotkey, %up%, UpPRESSED
Hotkey, ~$*%up% up, UpRELEASED
Hotkey, ~$*%down%, DownPRESSED
Hotkey, ~$*%down% up, DownRELEASED
Hotkey, ~$*%left%, LeftPRESSED
Hotkey, ~$*%left% up, LeftRELEASED
Hotkey, ~$*%right%, RightPRESSED
Hotkey, ~$*%right% up, RightRELEASED

Hotkey, +%buttonA%, ButtonAPressed
Hotkey, +%buttonA% up, ButtonAReleased
Hotkey, ~$*%buttonA%, ButtonAPressed
Hotkey, ~$*%buttonA% up, ButtonAReleased

Hotkey, ~$*%buttonZ%, ButtonZPressed
Hotkey, ~$*%buttonZ% up, ButtonZReleased

Hotkey, +%buttonB%, ButtonBPressed
Hotkey, +%buttonB% up, ButtonBReleased
Hotkey, ~$*%buttonB%, ButtonBPressed
Hotkey, ~$*%buttonB% up, ButtonBReleased

Hotkey, %buttonR%, ButtonRPressed
Hotkey, ~$*%buttonR% up, ButtonRReleased

combo = 75
lag = 25
off = 0		;key immediately pressed on up aka roll can be in progress
on = 200	;key must be overheld to press original key, or rolled to another key within time specified aka roll is currently in progress
lock = -1	;input will not be registered until no keys are being pressed on the keyboard aka roll cannot be in progress
comboInProgress := 0
pollingRate := 35
buttonAHeld := 0
buttonBHeld := 0
facingRight = 1

;CHANGE LEFT SIDE
RAlt::RAlt

;;;;;;;;;;;;;;;;;;;;;;;;
;	LOGIC
;;;;;;;;;;;;;;;;;;;;;;;;


GetAllKeysPressed(mode = "P") {
	
	pressed := Array()
	i := 1 
		
	;removed wasd and arrow keys from keys to check	to perform command normals
	keys = ``|1|2|3|4|5|6|7|8|9|0|-|=|[|]\|;|'|,|.|/|b|w|a|s|d|up|left|right|down|c|e|f|g|h|i|j|k|l|m|n|o|p|q|r|t|u|v|x|y|z|Esc|Tab|CapsLock|LShift|RShift|LCtrl|RCtrl|LWin|RWin|LAlt|RAlt|Space|AppsKey|Enter|BackSpace|Delete|Home|End|PGUP|PGDN|PrintScreen|ScrollLock|Pause|Insert|NumLock|F1|F2|F3|F4|F5|F6|F7|F8|F9|F10|F11|F12|F13|F14|F15|F16|F17|F18|F19|F20 
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
	if(pressed.MaxIndex() < 1) {
		gosub release
	}
	return pressed
}

roll := on

ButtonRPressed:
	;1+C
	if(instr(A_PriorKey, buttonA) && ((A_TimeSincePriorHotkey, buttonA) < combo)) {
		roll := lock
		gosub action
	}
	;2+C
	if(instr(A_PriorKey, buttonZ) && ((A_TimeSincePriorHotkey, buttonZ) < combo)) {
		roll := lock
		gosub ZplusR
	}
	;3+C
	if(instr(A_PriorKey, buttonB) && ((A_TimeSincePriorHotkey, buttonB) < combo)) {
		roll := lock
		gosub special0
	}
	numP := GetAllKeysPressed("P")
	MaxIndex := numP.MaxIndex()
	;C
	if(MaxIndex <= 3) {
		gosub buttonR
	}
exit

UpPRESSED:
	numP := GetAllKeysPressed("P")
	MaxIndex := numP.MaxIndex()
	if (roll == lock || comboInProgress == 1) {
		exit
	}
	else {
        if(instr(A_PriorKey, buttonZ) && ((A_TimeSincePriorHotkey, buttonZ) < combo)) {
			roll := lock
			KeyWait, %buttonR%, d t0.025                
			;2+1
			if ErrorLevel {       
				KeyWait, %buttonB%, d t0.050
				;2+1
				if ErrorLevel {       
					gosub ZplusA
				}
				;2+1+3
				else {      
                    gosub special0
				}
			}
			;2+1+C
			else {
				gosub action
			}
		}
		else {
            ;pressing buttonA while middle button is held
            if((MaxIndex == 2 && GetKeyState(buttonZ, "P")) || (MaxIndex == 3 && GetKeyState(upperbuttonZ, "P"))) {
                roll := lock
                gosub modA
            }
            else if(MaxIndex == 2 && GetKeyState(buttonZ, "P") && GetKeyState(buttonR, "P")) {
                roll := lock
                gosub doubleZ
            }
            else if (MaxIndex <= 1) {
				send {%up% down}
				while(GetKeyState(up, "P") && comboInProgress == 0) {
					if(GetKeyState(right, "P") && MaxIndex == 2) {	
						numP := GetAllKeysPressed("P")
						MaxIndex := numP.MaxIndex()
						send {%right% down}
						while(MaxIndex == 2 && comboInProgress == 0) {
							numP := GetAllKeysPressed("P")
							MaxIndex := numP.MaxIndex()
						}
						if(GetKeyState(up, "P")) {
							send {%right% up}
							send {%up% down}
						}
						else {
							send {%up% up} 
							goto RightPRESSED
						}
					}
					else if(GetKeyState(left, "P") && MaxIndex == 2) {	
						numP := GetAllKeysPressed("P")
						MaxIndex := numP.MaxIndex()
						send {%left% down}
						while(MaxIndex == 2 && comboInProgress == 0) {
							numP := GetAllKeysPressed("P")
							MaxIndex := numP.MaxIndex()
						}
						if(GetKeyState(up, "P")) {
							send {%left% up}
							send {%up% down}
						}
						else {
							send {%up% up} 
							goto LeftPRESSED
						}
					}
					else if(GetKeyState(down, "P") && MaxIndex == 2) {	
						numP := GetAllKeysPressed("P")
						MaxIndex := numP.MaxIndex()
						send {%down% down}
						while(MaxIndex == 2 && comboInProgress == 0) {
							numP := GetAllKeysPressed("P")
							MaxIndex := numP.MaxIndex()
						}
						if(GetKeyState(up, "P")) {
							send {%down% up}
							send {%up% down}
						}
						else {
							send {%up% up} 
							goto DownPRESSED
						}
					}
					else if(GetKeyState(buttonR, "P") && MaxIndex <= 3) {	
						gosub buttonR
					}
					if(GetKeyState(up, "P") == 0) {
						send {%up% up}
					}
				}
				if(GetKeyState(up, "P") == 0) {
					send {%up% up}
				}
            }
		}
		exit
	}
	roll := on
exit

DownPRESSED:
	numP := GetAllKeysPressed("P")
	MaxIndex := numP.MaxIndex()
	if (roll == lock || comboInProgress == 1) {
		exit
	}
	else {
        if(instr(A_PriorKey, right) && ((A_TimeSincePriorHotkey, right) < combo)) {
			KeyWait, %right%, d t0.075              
			send  {%right%}
			facingRight := 1           
			;dp
			if ErrorLevel {
			}
			;dp+A
			else {
				KeyWait, %buttonA%, d t0.075 
				if ErrorLevel {   
				}
				else {
					gosub dpA
				}
			}
		}
        else if(instr(A_PriorKey, left) && ((A_TimeSincePriorHotkey, left) < combo)) {
			KeyWait, %left%, d t0.075           
			send  {%left%}
			facingRight := 0                 
			;dp
			if ErrorLevel {    
			}
			;dp+A
			else {
				KeyWait, %buttonA%, d t0.075
				if ErrorLevel {
				}
				else {
					gosub dpA
				}
			}
		}
		else {
            ;pressing buttonA while middle button is held
            if((MaxIndex == 2 && GetKeyState(buttonZ, "P")) || (MaxIndex == 3 && GetKeyState(upperbuttonZ, "P"))) {
                roll := lock
                gosub modA
            }
            else if(MaxIndex == 2 && GetKeyState(buttonZ, "P") && GetKeyState(buttonR, "P")) {
                roll := lock
                gosub doubleZ
            }
            else if (MaxIndex <= 1) {
				while(GetKeyState(down, "P") && comboInProgress == 0) {
					if(GetKeyState(right, "P") && MaxIndex == 2) {	
						numP := GetAllKeysPressed("P")
						MaxIndex := numP.MaxIndex()
						send {%right% down}
						while(MaxIndex == 2 && comboInProgress == 0) {
							numP := GetAllKeysPressed("P")
							MaxIndex := numP.MaxIndex()
						}
						if(GetKeyState(down, "P")) {
							send {%right% up}
							send {%down% down}
						}
						else {
							send {%down% up} 
							goto RightPRESSED
						}
					}
					else if(GetKeyState(left, "P") && MaxIndex == 2) {	
						numP := GetAllKeysPressed("P")
						MaxIndex := numP.MaxIndex()
						send {%left% down}
						while(MaxIndex == 2 && comboInProgress == 0) {
							numP := GetAllKeysPressed("P")
							MaxIndex := numP.MaxIndex()
						}
						if(GetKeyState(down, "P")) {
							send {%left% up}
							send {%down% down}
						}
						else {
							send {%down% up} 
							goto LeftPRESSED
						}
					}
					else if(GetKeyState(up, "P") && MaxIndex == 2) {	
						numP := GetAllKeysPressed("P")
						MaxIndex := numP.MaxIndex()
						send {%up% down}
						while(MaxIndex == 2 && comboInProgress == 0) {
							numP := GetAllKeysPressed("P")
							MaxIndex := numP.MaxIndex()
						}
						if(GetKeyState(down, "P")) {
							send {%up% up}
							send {%down% down}
						}
						else {
							send {%down% up} 
							goto UpPRESSED
						}
					}
					else if(GetKeyState(buttonR, "P") && MaxIndex <= 3) {	
						gosub buttonR
					}
					gosub release
				}
				gosub release
            }
		}
		exit
	}
	roll := on
exit

LeftPRESSED:
	if(!instr(A_PriorKey, down))  {
    	facingRight := 0
	}
	numP := GetAllKeysPressed("P")
	MaxIndex := numP.MaxIndex()
	if (roll == lock || comboInProgress == 1) {
		exit
	}
	else {
        if(instr(A_PriorKey, down) && ((A_TimeSincePriorHotkey, down) < combo)) {
			KeyWait, %buttonA%, d t0.025              
			;down+left
			if ErrorLevel {
			}
			;down+left+A
			else {
                if(!facingRight) {     
					send  {%left%}
					facingRight := 0  
                    gosub qcfA
                }
                else {     
					send  {%right%}
					facingRight := 1  
                    gosub qcbA
                }
			}
		}
		else {
            ;pressing buttonA while middle button is held
            if((MaxIndex == 2 && GetKeyState(buttonZ, "P")) || (MaxIndex == 3 && GetKeyState(upperbuttonZ, "P"))) {
                roll := lock
                gosub modA
            }
            else if(MaxIndex == 2 && GetKeyState(buttonZ, "P") && GetKeyState(buttonR, "P")) {
                roll := lock
                gosub doubleZ
            }
            else if (MaxIndex <= 1) {
				send {%left% down}
				while(GetKeyState(left, "P") && comboInProgress == 0) {
					facingRight := 0
					if(GetKeyState(right, "P") && MaxIndex == 2) {	
						numP := GetAllKeysPressed("P")
						MaxIndex := numP.MaxIndex()
						send {%left% up}
						send {%right% down}
						while(MaxIndex == 2 && comboInProgress == 0) {
							numP := GetAllKeysPressed("P")
							MaxIndex := numP.MaxIndex()
						}
						if(GetKeyState(left, "P")) {
							send {%right% up}
							send {%left% down}
						}
						else {
							send {%left% up} 
							goto RightPRESSED
						}
					}
					else if(GetKeyState(down, "P") && MaxIndex == 2) {	
						numP := GetAllKeysPressed("P")
						MaxIndex := numP.MaxIndex()
						send {%down% down}
						while(MaxIndex == 2 && comboInProgress == 0) {
							numP := GetAllKeysPressed("P")
							MaxIndex := numP.MaxIndex()
						}
						if(GetKeyState(left, "P")) {
							send {%down% up}
							send {%left% down}
						}
						else {
							send {%left% up} 
							goto DownPRESSED
						}
					}
					else if(GetKeyState(up, "P") && MaxIndex == 2) {	
						numP := GetAllKeysPressed("P")
						MaxIndex := numP.MaxIndex()
						send {%up% down}
						while(MaxIndex == 2 && comboInProgress == 0) {
							numP := GetAllKeysPressed("P")
							MaxIndex := numP.MaxIndex()
						}
						if(GetKeyState(left, "P")) {
							send {%up% up}
							send {%left% down}
						}
						else {
							send {%left% up} 
							goto UpPRESSED
						}
					}
					else if(GetKeyState(buttonR, "P") && MaxIndex <= 3) {	
						gosub buttonR
					}
				}
				gosub release
            }
		}
		exit
	}
	roll := on
exit

RightPRESSED:
	if(!instr(A_PriorKey, down))  {
    	facingRight := 1
	}
	numP := GetAllKeysPressed("P")
	MaxIndex := numP.MaxIndex()
	if (roll == lock || comboInProgress == 1) {
		exit
	}
	else {
        if(instr(A_PriorKey, down) && ((A_TimeSincePriorHotkey, down) < combo)) {
			KeyWait, %buttonA%, d t0.025       
			;down+right
			if ErrorLevel {
			}      
			;down+right+A
			else {
                if(facingRight) {        
					send  {%right%}
					facingRight := 1  
                    gosub qcfA
                }
                else {     
					send  {%left%}
					facingRight := 0  
                    gosub qcbA
                }
			}
		}
		else {
            ;pressing buttonA while middle button is held
            if((MaxIndex == 2 && GetKeyState(buttonZ, "P")) || (MaxIndex == 3 && GetKeyState(upperbuttonZ, "P"))) {
                roll := lock
                gosub modA
            }
            else if(MaxIndex == 2 && GetKeyState(buttonZ, "P") && GetKeyState(buttonR, "P")) {
                roll := lock
                gosub doubleZ
            }
            else if (MaxIndex <= 1) {
				send {%right% down}
				while(GetKeyState(right, "P") && comboInProgress == 0) {
					facingRight := 1
					if(GetKeyState(left, "P") && MaxIndex == 2) {
						send {%right% up}
						send {%left% down}
						while(MaxIndex == 2 && comboInProgress == 0) {
							numP := GetAllKeysPressed("P")
							MaxIndex := numP.MaxIndex()
						}
						if(GetKeyState(right, "P")) {
							send {%left% up}
							send {%right% down}
						}
						else {
							send {%right% up} 
							goto LeftPRESSED
						}
					}
					else if(GetKeyState(down, "P") && MaxIndex == 2) {	
						numP := GetAllKeysPressed("P")
						MaxIndex := numP.MaxIndex()
						send {%down% down}
						while(MaxIndex == 2 && comboInProgress == 0) {
							numP := GetAllKeysPressed("P")
							MaxIndex := numP.MaxIndex()
						}
						if(GetKeyState(right, "P")) {
							send {%down% up}
							send {%right% down}
						}
						else {
							send {%right% up} 
							goto DownPRESSED
						}
					}
					else if(GetKeyState(up, "P") && MaxIndex == 2) {
						send {%up% down}
						while(MaxIndex == 2 && comboInProgress == 0) {
							numP := GetAllKeysPressed("P")
							MaxIndex := numP.MaxIndex()
						}
						if(GetKeyState(right, "P")) {
							send {%up% up}
							send {%right% down}
						}
						else {
							send {%right% up} 
							goto UpPRESSED
						}
					}
					else if(GetKeyState(buttonR, "P") && MaxIndex <= 3) {	
						gosub buttonR
					}
				}
				gosub release
            }
		}
		exit
	}
	roll := on
exit


UpRELEASED:
gosub release
numP := GetAllKeysPressed("P")
MaxIndex := numP.MaxIndex()
if (MaxIndex < 1)  {
  roll := off	;roll will be unlocked when no keys on the keyboard are pressed
}
exit

DownRELEASED:	
gosub release
numP := GetAllKeysPressed("P")
MaxIndex := numP.MaxIndex()
if (MaxIndex < 1)  {
  roll := off	;roll will be unlocked when no keys on the keyboard are pressed
}
exit 

LeftRELEASED:
gosub release
numP := GetAllKeysPressed("P")
MaxIndex := numP.MaxIndex()
if (MaxIndex < 1)  {
  roll := off	;roll will be unlocked when no keys on the keyboard are pressed
}
exit 

RightRELEASED:
gosub release
numP := GetAllKeysPressed("P")
MaxIndex := numP.MaxIndex()
if (MaxIndex < 1)  {
  roll := off	;roll will be unlocked when no keys on the keyboard are pressed
}
exit  

ButtonAPressed:
	numP := GetAllKeysPressed("P")
	MaxIndex := numP.MaxIndex()
	if (roll == lock) {
		exit
	}
	else {
        if(instr(A_PriorKey, buttonZ) && ((A_TimeSincePriorHotkey, buttonZ) < combo)) {
			KeyWait, %buttonR%, d t0.025                
			;2+1
			if ErrorLevel {       
				KeyWait, %buttonB%, d t0.050
				;2+1
				if ErrorLevel {       
					gosub ZplusA
				}
				;2+1+3
				else {      
                    gosub special0
				}
			}
			;2+1+C
			else {
				gosub action
			}
		}
		else {       
            ;pressing buttonA while middle button is held
            if((MaxIndex == 2 && GetKeyState(buttonZ, "P")) || (MaxIndex == 3 && GetKeyState(upperbuttonZ, "P"))) {
                gosub modA
            }
            else if(MaxIndex == 2 && GetKeyState(buttonZ, "P") && GetKeyState(buttonR, "P")) {
                gosub doubleZ
            }
            else if ((MaxIndex == 1 || (MaxIndex == 2 && GetKeyState(upperQ, "P")) || (MaxIndex == 2 && GetKeyState(up, "P")) || (MaxIndex == 2 && GetKeyState(buttonB, "P")))) {
			    gosub buttonA
            }
		}
		exit
	}
	roll := on
exit

ButtonZPressed:
	numP := GetAllKeysPressed("P")
	MaxIndex := numP.MaxIndex()
    ;2+2
    if(instr(A_PriorKey, buttonZ) && ((A_TimeSincePriorHotkey, buttonZ) < 100) && ((A_TimeSincePriorHotkey, buttonZ) > pollingRate) && (buttonAHeld == 0)) {
        gosub doubleZ
    }
	else if (MaxIndex == 1)  {
		roll := off	;roll will be unlocked when no keys on the keyboard are pressed
	}
	else if (roll == lock) {
		exit
	}
	else {
		exit
	}
	roll := on
exit

ButtonBPressed: 
	numP := GetAllKeysPressed("P")
	MaxIndex := numP.MaxIndex()
	if (roll == lock) {
		exit
	}
	else {
		;2+3
		if(instr(A_PriorKey, buttonZ) && ((A_TimeSincePriorHotkey, buttonZ) < combo)) {
			KeyWait, %buttonA%, d t0.025       
			if ErrorLevel {  
				KeyWait, %buttonR%, d t0.025
				;2+3
				if ErrorLevel {       
					gosub modB
				}
				;2+3+C
				else {      
                    gosub special0
				}
			}
			;2+3+1
			else {
				KeyWait, %buttonR%, d t0.050
				;2+3+1
				if ErrorLevel {     
                    gosub special0
				}
				;2+3+1+C
				else {
					gosub doubleZ
				}
			}
		}
		else {          
            ;pressing buttonB while middle button is held
            if(MaxIndex == 2 && GetKeyState(buttonZ, "P") || (MaxIndex == 3 && GetKeyState(upperbuttonZ, "P"))) {
                gosub modB
            }
            else if(MaxIndex == 2 && GetKeyState(buttonZ, "P") && GetKeyState(buttonR, "P")) {
                gosub doubleZ
            }
            else if ((MaxIndex == 1 || (MaxIndex == 2 && GetKeyState(upperE, "P")) || (MaxIndex == 2 && GetKeyState(up, "P")) || (MaxIndex == 2 && GetKeyState(buttonA, "P")))) {
			    gosub buttonB
            }
		}
		exit
	}
	roll := on
exit

ButtonAReleased:
numP := GetAllKeysPressed("P")
MaxIndex := numP.MaxIndex()
if (MaxIndex < 1)  {
  roll := off	;roll will be unlocked when no keys on the keyboard are pressed
}
exit 


ButtonZReleased:
numP := GetAllKeysPressed("P")
MaxIndex := numP.MaxIndex()
if (MaxIndex < 1 && comboInProgress == 0)  {
  roll := off	;roll will be unlocked when no keys on the keyboard are pressed
}
exit 


ButtonBReleased:
numP := GetAllKeysPressed("P")
MaxIndex := numP.MaxIndex()
if (MaxIndex < 1) {
  roll := off	;roll will be unlocked when no keys on the keyboard are pressed
}
exit 

ButtonRReleased:
numP := GetAllKeysPressed("P")
MaxIndex := numP.MaxIndex()
if (MaxIndex < 1)  {
  roll := off	;roll will be unlocked when no keys on the keyboard are pressed
}
exit 

special0:
	if(comboInProgress == 0) {
		comboInProgress := 1
		send {%special0%  down}
		gosub releaseAllDirections
		while(GetKeyState(special0, "P"))
		{
		}
		send {%special0%  up}
		comboInProgress := 0
		gosub nextSingleDirection
	}
return

dodge:
	send {RAlt down}
	sleep %lag%
	send {RAlt up}
return

action:
	send {f down}
	sleep %lag%
	send {f up}
return

release: 
if(GetKeyState(right, "D") && !GetKeyState(right, "P")) { 
  send {%right% up} 
} 
if(GetKeyState(left, "D") && !GetKeyState(left, "P")) { 
  send {%left% up} 
} 
if(GetKeyState(down, "D") && !GetKeyState(down, "P")) { 
  send {%down% up} 
} 
if(GetKeyState(up, "D") && !GetKeyState(up, "P")) { 
  send {%up% up} 
} 
if(GetKeyState(buttonA, "D") && !GetKeyState(buttonA, "P")) { 
  send {%buttonA% up} 
} 
if(GetKeyState(buttonB, "D") && !GetKeyState(buttonB, "P")) { 
  send {%buttonB% up} 
} 
if(GetKeyState(buttonR, "D") && !GetKeyState(buttonR, "P")) { 
  send {%buttonR% up} 
} 
if(GetKeyState(buttonZ, "D") && !GetKeyState(buttonZ, "P")) { 
  send {%buttonZ% up} 
}
return 
 
releaseDirections: 
numP := GetAllKeysPressed("P") 
MaxIndex := numP.MaxIndex() 
while(MaxIndex > 0) { 
  send {%left% up} 
  send {%right% up} 
  send {%up% up} 
  send {%down% up} 
  numP := GetAllKeysPressed("P") 
  MaxIndex := numP.MaxIndex() 
} 
return

releaseAllDirections:
	send {%left% up}
	send {%right% up}
	send {%up% up}
	send {%down% up}
return

nextSingleDirection: 
numP := GetAllKeysPressed("P") 
MaxIndex := numP.MaxIndex() 
while (MaxIndex > 1) { 
	gosub release
} 
if(MaxIndex == 1) { 
  if(GetKeyState(right, "P")) { 
    goto RightPRESSED 
  } 
  else if(GetKeyState(left, "P")) { 
    goto LeftPRESSED 
  } 
  else if(GetKeyState(down, "P")) { 
    goto DownPRESSED 
  } 
  else if(GetKeyState(up, "P")) { 
    goto UpPRESSED 
  } 
} 
return 

nextDirection:
numP := GetAllKeysPressed("P")
MaxIndex := numP.MaxIndex()
if(MaxIndex <= 1) {
	if(GetKeyState(right, "P")) {
		send {%right% down}
		goto RightPRESSED
	}
	else if(GetKeyState(left, "P")) {
		send {%left% down}
		goto LeftPRESSED
	}
	else if(GetKeyState(down, "P")) {
		send {%down% down}
		goto DownPRESSED
	}
	else if(GetKeyState(up, "P")) {
		send {%up% down}
		goto UpPRESSED
	}
}
return

qcfA:
	if(comboInProgress == 0) {
		comboInProgress := 1
		send {%special1%  down}
		gosub releaseAllDirections
		while(GetKeyState(buttonA, "P"))
		{
			gosub release
		}
		send {%special1%  up}
		comboInProgress := 0
		gosub nextSingleDirection
	}
return

qcbA:
	if(comboInProgress == 0) {
		comboInProgress := 1
		send {%special2%  down}
		gosub releaseAllDirections
		while(GetKeyState(buttonA, "P"))
		{
			gosub release
		}
		gosub releaseAllDirections
		send {%special2%  up}
		comboInProgress := 0
		gosub nextSingleDirection
	}
return

qcfB:
	if(comboInProgress == 0) {
		comboInProgress := 1
		send {%special3%  down}
		gosub releaseAllDirections
		while(GetKeyState(buttonB, "P"))
		{
			gosub release
		}
		send {%special3%  up}
		comboInProgress := 0
		gosub nextSingleDirection
	}
return

qcbB:
	if(comboInProgress == 0) {
		comboInProgress := 1
		send {%special4%  down}
		gosub releaseAllDirections
		while(GetKeyState(buttonB, "P"))
		{
			gosub release
		}
		send {%special4%  up}
		comboInProgress := 0
		gosub nextSingleDirection
	}
return

dpA:
	if(comboInProgress == 0) {
		comboInProgress := 1
		send {%special5%  down}
		numP := GetAllKeysPressed("P")
		MaxIndex := numP.MaxIndex()
		gosub releaseAllDirections
		while(GetKeyState(buttonA, "P") || MaxIndex > 1) {
			numP := GetAllKeysPressed("P")
			MaxIndex := numP.MaxIndex()
			gosub release
		}
		send {%special5%  up}
		comboInProgress := 0
		gosub nextSingleDirection
	}
return

dpB:
	if(comboInProgress == 0) {
		comboInProgress := 1
		send {%special6%  down}
		numP := GetAllKeysPressed("P")
		MaxIndex := numP.MaxIndex()
		gosub releaseAllDirections
		while(GetKeyState(buttonB, "P") || MaxIndex > 1) {
			numP := GetAllKeysPressed("P")
			MaxIndex := numP.MaxIndex()
			gosub release
		}
		send {%special6%  up}
		comboInProgress := 0
		gosub nextSingleDirection
	}
return

huA:
	if(comboInProgress == 0) {
		comboInProgress := 1
		send {%special7%  down}
		numP := GetAllKeysPressed("P")
		MaxIndex := numP.MaxIndex()
		gosub releaseAllDirections
		while(GetKeyState(buttonA, "P") || MaxIndex > 1) {
			numP := GetAllKeysPressed("P")
			MaxIndex := numP.MaxIndex()
		}
		send {%special7%  up}
		comboInProgress := 0
		gosub nextSingleDirection
	}
return

huB:
	if(comboInProgress == 0) {
		comboInProgress := 1
		send {%special8%  down}
		gosub releaseAllDirections
		numP := GetAllKeysPressed("P")
		MaxIndex := numP.MaxIndex()
		while(GetKeyState(buttonB, "P") || MaxIndex > 1) {
			numP := GetAllKeysPressed("P")
			MaxIndex := numP.MaxIndex()
		}
		send {%special8%  up}
		comboInProgress := 0
		gosub nextSingleDirection
	}
return

ZplusR:
    send {%ZplusR% down}
	sleep %lag%
    send {%ZplusR% up}
return

buttonA:
	if(comboInProgress == 0) {
		comboInProgress := 1
		send {%buttonA%  down}
		gosub releaseAllDirections
		while(GetKeyState(buttonA, "P"))
		{
		}
		send {%buttonA%  up}
		comboInProgress := 0
		gosub nextSingleDirection
	}
return

buttonB:
	if(comboInProgress == 0) {
		comboInProgress := 1
		send {%buttonB%  down}
		gosub releaseAllDirections
		while(GetKeyState(buttonB, "P"))
		{
		}
		send {%buttonB%  up}
		comboInProgress := 0
		gosub nextSingleDirection
	}
return

ZplusA:
	if(comboInProgress == 0) {
		comboInProgress := 1
		send {z down}
        sleep %lag%
		sleep %lag%
    	if(GetKeyState(up, "P")) {
			send {Click, down, right}
			sleep %lag%
			numP := GetAllKeysPressed("P")
			MaxIndex := numP.MaxIndex()
			while (MaxIndex > 2) {
				sleep %lag%
				numP := GetAllKeysPressed("P")
				MaxIndex := numP.MaxIndex()
			}
			send {Click, up, right}
		}
		else {
			send {Click down}
			sleep %lag%
			MaxIndex := 2
			while (MaxIndex > 1) {
				sleep %lag%
				numP := GetAllKeysPressed("P")
				MaxIndex := numP.MaxIndex()
			}
			send {Click up}
		}
		send {z up}
    	comboInProgress := 0 
		roll := off
	}
return


ZplusB:
	if(comboInProgress == 0) {
		comboInProgress := 1
		send {c down}
        sleep %lag%
		sleep %lag%
    	if(GetKeyState(up, "P")) {
			send {Click, down, right}
			sleep %lag%
			numP := GetAllKeysPressed("P")
			MaxIndex := numP.MaxIndex()
			while (MaxIndex > 2) {
				sleep %lag%
				numP := GetAllKeysPressed("P")
				MaxIndex := numP.MaxIndex()
			}
			send {Click, up, right}
		}
		else {
			send {Click down}
			sleep %lag%
			MaxIndex := 2
			while (MaxIndex > 1) {
				sleep %lag%
				numP := GetAllKeysPressed("P")
				MaxIndex := numP.MaxIndex()
			}
			send {Click up}
		}
		send {c up}
    	comboInProgress := 0 
		roll := off
	}
return

modA:
	if(comboInProgress == 0) {
		comboInProgress := 1
        numP := GetAllKeysPressed("P")
        MaxIndex := numP.MaxIndex()
		send {Click WheelDown}
        while(MaxIndex > 1) 
        {}
		comboInProgress := 0
		roll := off
	}
return

modB:
	if(comboInProgress == 0) {
		comboInProgress := 1
        numP := GetAllKeysPressed("P")
        MaxIndex := numP.MaxIndex()
		send {Click WheelUp}
        while(MaxIndex > 1) 
        {}
		comboInProgress := 0
		roll := off
	}
return

buttonR:
	send {%buttonR% down}
	sleep %lag% 
	MaxIndex := 1
	buttonZHeld := 1
	buttonDown := 0
	while (buttonZHeld == 1 || GetKeyState(buttonR, "P")) {
		if(GetKeyState(buttonZ, "P") == 0) {
			buttonZHeld := 0
		}	 
	}
	gosub release
	send {%buttonR% up}
return 

doubleZ: 
return 