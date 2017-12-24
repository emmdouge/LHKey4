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
#KeyHistory 6
#MaxHotkeysPerInterval 99000000
#HotkeyInterval 99000000
#MaxThreadsPerHotkey 255
Process, Priority, , A
SetBatchLines, -1                 ;makes the script run at max speed
SetKeyDelay , -1, -1              ;faster response (might be better with -1, 0)
ListLines, Off
SendMode Input
SetCapsLockState, AlwaysOff

up := "w"
, down := "s"
, left := "a"
, right := "d"
, evade := "Tab"
, weakPunch := "u"
, upperQ := "U"
, grab := "i"
, upperGrab := "I"
, weakKick := "o"
, upperE := "O"
, charge := "Space"
, mediumPunch := "1"
, mediumKick := "2"
, hardPunch := "3"
, hardKick := "4"

Hotkey, %up%, UpPRESSED
Hotkey, %up% up, UpRELEASED
Hotkey, %down%, DownPRESSED
Hotkey, %down% up, DownRELEASED
Hotkey, %left%, LeftPRESSED
Hotkey, %left% up, LeftRELEASED
Hotkey, %right%, RightPRESSED
Hotkey, %right% up, RightRELEASED

Hotkey, +%weakPunch%, ONEDOWN
Hotkey, +%weakPunch% up, ONEUP
Hotkey, %weakPunch%, ONEDOWN
Hotkey, %weakPunch% up, ONEUP

Hotkey, %grab%, TWODOWN
Hotkey, %grab% up, TWOUP

Hotkey, +%weakKick%, THREEDOWN
Hotkey, +%weakKick% up, THREEUP
Hotkey, %weakKick%, THREEDOWN
Hotkey, %weakKick% up, THREEUP

Hotkey, %charge%, CHARGE
Hotkey, %charge% up, CHARGEUP

combo = 50
lag = 25
off = 0		;key immediately pressed on up aka roll can be in progress
on = 200	;key must be overheld to press original key, or rolled to another key within time specified aka roll is currently in progress
lock = -1	;input will not be registered until no keys are being pressed on the keyboard aka roll cannot be in progress
comboInProgress := 0
pollingRate := 35
weakPunchHeld := 0
weakKickHeld := 0
facingRight = 1

;CHANGE LEFT SIDE
RAlt::RAlt

;;;;;;;;;;;;;;;;;;;;;;;;
;	LOGIC
;;;;;;;;;;;;;;;;;;;;;;;;


GetAllKeysPressed(mode = "L") {
	
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
	return pressed
}

roll := on
r::reload

CHARGE:
	;1+C
	if(instr(A_PriorKey, weakPunch) && ((A_TimeSincePriorHotkey, weakPunch) < combo)) {
		roll := lock
		gosub action
	}
	;2+C
	if(instr(A_PriorKey, grab) && ((A_TimeSincePriorHotkey, grab) < combo)) {
		roll := lock
		gosub evade
	}
	;3+C
	if(instr(A_PriorKey, weakKick) && ((A_TimeSincePriorHotkey, weakKick) < combo)) {
		roll := lock
		gosub special
	}
	;C
	if(roll != lock) {
		roll := on
		send {%charge% down}
		gosub guard
	}
exit

UpPRESSED:
	numP := GetAllKeysPressed("P")
	MaxIndex := numP.MaxIndex()
	if (roll == lock || comboInProgress == 1) {
		exit
	}
	else {
        if(instr(A_PriorKey, grab) && ((A_TimeSincePriorHotkey, grab) < combo)) {
			roll := lock
			KeyWait, %charge%, d t0.025                
			;2+1
			if ErrorLevel {       
				KeyWait, %weakKick%, d t0.050
				;2+1
				if ErrorLevel {       
					gosub ZAttack
				}
				;2+1+3
				else {      
                    gosub special
				}
			}
			;2+1+C
			else {
				gosub action
			}
		}
		else {
            ;pressing weakpunch while middle button is held
            if((MaxIndex == 2 && GetKeyState(grab, "P")) || (MaxIndex == 3 && GetKeyState(upperGrab, "P"))) {
                roll := lock
                gosub switchL
            }
            else if(MaxIndex == 2 && GetKeyState(grab, "P") && GetKeyState(charge, "P")) {
                roll := lock
                gosub guard
            }
            else if (MaxIndex <= 1) {
				send {%up% down}
				sleep %lag%
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
        if(instr(A_PriorKey, grab) && ((A_TimeSincePriorHotkey, grab) < combo)) {
			roll := lock
			KeyWait, %charge%, d t0.025                
			;2+1
			if ErrorLevel {       
				KeyWait, %weakKick%, d t0.050
				;2+1
				if ErrorLevel {       
					gosub ZAttack
				}
				;2+1+3
				else {      
                    gosub special
				}
			}
			;2+1+C
			else {
				gosub action
			}
		}
		else {
            ;pressing weakpunch while middle button is held
            if((MaxIndex == 2 && GetKeyState(grab, "P")) || (MaxIndex == 3 && GetKeyState(upperGrab, "P"))) {
                roll := lock
                gosub switchL
            }
            else if(MaxIndex == 2 && GetKeyState(grab, "P") && GetKeyState(charge, "P")) {
                roll := lock
                gosub guard
            }
            else if (MaxIndex <= 1) {
				send {%down% down}
				sleep %lag%
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
					if(GetKeyState(down, "P") == 0) {
						send {%down% up}
					}
				}
				if(GetKeyState(down, "P") == 0) {
					send {%down% up}
				}
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
			KeyWait, %weakPunch%, d t0.025                
			;down+left
			if ErrorLevel {     
				KeyWait, %weakKick%, d t0.050
				;down+left
				if ErrorLevel {      
					comboInProgress := 1
					Critical  
					send {%left% down}
					facingRight := 0  
					send {%down%  up} 
					send {%left%  up} 
					Critical,  Off
					comboInProgress := 0
				}
				;down+left+B
				else {      
					if(!facingRight) {
						gosub qcfB
					}
					else {
						gosub qcbB
					}
				}
			}
			;down+left+A
			else {
                if(!facingRight) {
					facingRight := 0  
                    gosub qcfA
                }
                else {
					facingRight := 1
                    gosub qcbA
                }
			}
		}
		else {
            ;pressing weakpunch while middle button is held
            if((MaxIndex == 2 && GetKeyState(grab, "P")) || (MaxIndex == 3 && GetKeyState(upperGrab, "P"))) {
                roll := lock
                gosub switchL
            }
            else if(MaxIndex == 2 && GetKeyState(grab, "P") && GetKeyState(charge, "P")) {
                roll := lock
                gosub guard
            }
            else if (MaxIndex <= 1) {
				send {%left% down}
				sleep %lag%
				while(GetKeyState(left, "P") && comboInProgress == 0) {
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
					if(GetKeyState(left, "P") == 0) {
						send {%left% up}
					}
				}
				if(GetKeyState(left, "P") == 0) {
					send {%left% up}
				}
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
			KeyWait, %weakPunch%, d t0.025       
			;down+right
			if ErrorLevel { 
				KeyWait, %weakKick%, d t0.050
				;down+right
				if ErrorLevel {       
					comboInProgress := 1
					Critical 
					send {%right% down}
					facingRight := 1  
					send {%down%  up} 
					send {%right% up}  
					Critical,  Off
					comboInProgress := 0
				}
				;down+right+B
				else {      
					if(facingRight) {
						gosub qcfB
					}
					else {
						gosub qcbB
					}
				}
			}      
			;down+right+A
			else {
                if(facingRight) {
					facingRight := 1  
                    gosub qcfA
                }
                else {
					facingRight := 0  
                    gosub qcbA
                }
			}
		}
		else {
            ;pressing weakpunch while middle button is held
            if((MaxIndex == 2 && GetKeyState(grab, "P")) || (MaxIndex == 3 && GetKeyState(upperGrab, "P"))) {
                roll := lock
                gosub switchL
            }
            else if(MaxIndex == 2 && GetKeyState(grab, "P") && GetKeyState(charge, "P")) {
                roll := lock
                gosub guard
            }
            else if (MaxIndex <= 1) {
				send {%right% down}
				sleep %lag%
				while(GetKeyState(right, "P") && comboInProgress == 0) {
					if(GetKeyState(left, "P") && MaxIndex == 2) {
						send {%right% up}
						send {%left% down}
						while(MaxIndex == 2) {
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
						while(MaxIndex == 2) {
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
						numP := GetAllKeysPressed("P")
						MaxIndex := numP.MaxIndex()
						send {%up% down}
						while(MaxIndex == 2) {
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
					if(GetKeyState(right, "P") == 0) {
						send {%right% up}
					}
				}
				if(GetKeyState(right, "P") == 0) {
					send {%right% up}
				}
            }
		}
		exit
	}
	roll := on
exit


UpRELEASED:
numP := GetAllKeysPressed("P")
MaxIndex := numP.MaxIndex()
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
}
if (MaxIndex < 1)  {
  roll := off	;roll will be unlocked when no keys on the keyboard are pressed
}
exit

DownRELEASED:	
numP := GetAllKeysPressed("P")
MaxIndex := numP.MaxIndex()
if(MaxIndex == 1) {
	if(GetKeyState(right, "P")) {
		goto RightPRESSED
	}
	else if(GetKeyState(left, "P")) {
		goto LeftPRESSED
	}
	else if(GetKeyState(up, "P")) {
		goto UpPRESSED
	}
}
if (MaxIndex < 1)  {
  roll := off	;roll will be unlocked when no keys on the keyboard are pressed
}
exit 

LeftRELEASED:
numP := GetAllKeysPressed("P")
MaxIndex := numP.MaxIndex()
if(MaxIndex == 1) {
	if(GetKeyState(right, "P")) {
		goto RightPRESSED
	}
	else if(GetKeyState(down, "P")) {
		goto DownPRESSED
	}
	else if(GetKeyState(up, "P")) {
		goto UpPRESSED
	}
}
if (MaxIndex < 1)  {
  roll := off	;roll will be unlocked when no keys on the keyboard are pressed
}
exit 

RightRELEASED:
numP := GetAllKeysPressed("P")
MaxIndex := numP.MaxIndex()
if(MaxIndex == 1) {
	if(GetKeyState(left, "P")) {
		goto LeftPRESSED
	}
	else if(GetKeyState(down, "P")) {
		goto DownPRESSED
	}
	else if(GetKeyState(up, "P")) {
		goto UpPRESSED
	}
}
if (MaxIndex < 1)  {
  roll := off	;roll will be unlocked when no keys on the keyboard are pressed
}
exit  

ONEDOWN:
	numP := GetAllKeysPressed("P")
	MaxIndex := numP.MaxIndex()
	if (roll == lock) {
		exit
	}
	else {
        if(instr(A_PriorKey, grab) && ((A_TimeSincePriorHotkey, grab) < combo)) {
			roll := lock
			KeyWait, %charge%, d t0.025                
			;2+1
			if ErrorLevel {       
				KeyWait, %weakKick%, d t0.050
				;2+1
				if ErrorLevel {       
					gosub ZAttack
				}
				;2+1+3
				else {      
                    gosub special
				}
			}
			;2+1+C
			else {
				gosub action
			}
		}
		else {       
            ;pressing weakpunch while middle button is held
            if((MaxIndex == 2 && GetKeyState(grab, "P")) || (MaxIndex == 3 && GetKeyState(upperGrab, "P"))) {
                roll := lock
                gosub switchL
            }
            else if(MaxIndex == 2 && GetKeyState(grab, "P") && GetKeyState(charge, "P")) {
                roll := lock
                gosub guard
            }
            else if ((MaxIndex == 1 || (MaxIndex == 2 && GetKeyState(upperQ, "P")) || (MaxIndex == 2 && GetKeyState(up, "P")) || (MaxIndex == 2 && GetKeyState(weakKick, "P")))) {
			    gosub weakPunch
            }
		}
		exit
	}
	roll := on
exit

TWODOWN:
	numP := GetAllKeysPressed("P")
	MaxIndex := numP.MaxIndex()
    ;2+2
    if(instr(A_PriorKey, grab) && ((A_TimeSincePriorHotkey, grab) < 100) && ((A_TimeSincePriorHotkey, grab) > pollingRate) && (weakPunchHeld == 0)) {
        roll := lock
        gosub LockTarget
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

THREEDOWN: 
	numP := GetAllKeysPressed("P")
	MaxIndex := numP.MaxIndex()
	if (roll == lock) {
		exit
	}
	else {
		;2+3
		if(instr(A_PriorKey, grab) && ((A_TimeSincePriorHotkey, grab) < combo)) {
			roll := lock
			KeyWait, %weakPunch%, d t0.025       
			if ErrorLevel {  
				KeyWait, %charge%, d t0.025
				;2+3
				if ErrorLevel {       
					gosub CAttack
				}
				;2+3+C
				else {      
                    gosub special
				}
			}
			;2+3+1
			else {
				KeyWait, %charge%, d t0.050
				;2+3+1
				if ErrorLevel {     
                    gosub special
				}
				;2+3+1+C
				else {
					gosub LockTarget
				}
			}
		}
		else {          
            ;pressing weakKick while middle button is held
            if(MaxIndex == 2 && GetKeyState(grab, "P") || (MaxIndex == 3 && GetKeyState(upperGrab, "P"))) {
                roll := lock
                gosub switchR
            }
            else if(MaxIndex == 2 && GetKeyState(grab, "P") && GetKeyState(charge, "P")) {
                roll := lock
                gosub guard
            }
            else if ((MaxIndex == 1 || (MaxIndex == 2 && GetKeyState(upperE, "P")) || (MaxIndex == 2 && GetKeyState(up, "P")) || (MaxIndex == 2 && GetKeyState(weakPunch, "P")))) {
			    gosub weakKick
            }
		}
		exit
	}
	roll := on
exit

ONEUP:
numP := GetAllKeysPressed("P")
MaxIndex := numP.MaxIndex()
if (MaxIndex < 1)  {
  roll := off	;roll will be unlocked when no keys on the keyboard are pressed
}
exit 


TWOUP:
numP := GetAllKeysPressed("P")
MaxIndex := numP.MaxIndex()
if (MaxIndex < 1 && comboInProgress == 0)  {
  roll := off	;roll will be unlocked when no keys on the keyboard are pressed
}
exit 


THREEUP:
numP := GetAllKeysPressed("P")
MaxIndex := numP.MaxIndex()
if (MaxIndex < 1) {
  roll := off	;roll will be unlocked when no keys on the keyboard are pressed
}
exit 

CHARGEUP:
numP := GetAllKeysPressed("P")
MaxIndex := numP.MaxIndex()
if (MaxIndex < 1)  {
  roll := off	;roll will be unlocked when no keys on the keyboard are pressed
}
exit 

special:
	numP := GetAllKeysPressed("P")
	MaxIndex := numP.MaxIndex()
	while(MaxIndex > 2) 
	{
		MouseMove, 0, 75,R
		Sleep 25
		MouseMove, 75, 0,R
		Sleep 25
		MouseMove, 0, -75,,R
		Sleep 25
		MouseMove, -75, 0,R
		Sleep 25
		MouseGetPos, NEA, NEB
		numP := GetAllKeysPressed("P")
		MaxIndex := numP.MaxIndex()
	}
	roll := lock
return

dodge:
	send {RAlt down}
	sleep %lag%
	send {RAlt up}
	roll := lock
return

action:
	send {f down}
	sleep %lag%
	send {f up}
	roll := lock
return

release: 
if(GetKeyState(right, "P") == 0) { 
  send {%right% up} 
} 
if(GetKeyState(left, "P") == 0) { 
  send {%left% up} 
} 
if(GetKeyState(down, "P") == 0) { 
  send {%down% up} 
} 
if(GetKeyState(up, "P") == 0) { 
  send {%up% up} 
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
} 
if(MaxIndex == 1) { 
  if(GetKeyState(right, "P")) { 
    send {%right% down} 
    goto RightPRESSED 
  } 
  if(GetKeyState(left, "P")) { 
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

nextDirection:
numP := GetAllKeysPressed("P")
MaxIndex := numP.MaxIndex()
gosub releaseDirections
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
		send {%mediumPunch%  down}
		gosub releaseAllDirections
		while(GetKeyState(weakPunch, "P"))
		{
		}
		send {%mediumPunch%  up}
		comboInProgress := 0
		gosub nextSingleDirection
	}
return

qcbA:
	if(comboInProgress == 0) {
		comboInProgress := 1
		send {%mediumKick%  down}
		gosub releaseAllDirections
		while(GetKeyState(weakPunch, "P"))
		{
		}
		send {%mediumKick%  up}
		comboInProgress := 0
		gosub nextSingleDirection
	}
return

qcfB:
	if(comboInProgress == 0) {
		comboInProgress := 1
		send {%hardPunch%  down}
		gosub releaseAllDirections
		while(GetKeyState(weakKick, "P"))
		{
		}
		send {%hardPunch%  up}
		comboInProgress := 0
		gosub nextSingleDirection
	}
return

qcbB:
	if(comboInProgress == 0) {
		comboInProgress := 1
		send {%hardKick%  down}
		gosub releaseAllDirections
		while(GetKeyState(weakKick, "P"))
		{
		}
		send {%hardKick%  up}
		comboInProgress := 0
		gosub nextSingleDirection
	}
return

evade:
    send {%evade%}
return

weakPunch:
	send {%weakPunch% down}
	sleep %lag%
	send {%weakPunch% up}
return

weakKick:
	send {%weakKick% down}
	sleep %lag%
	send {%weakKick% up}
return


EAttack: 
	if(GetKeyState("LShift", "P") == 0) {
    	send {e down}
	}
	sleep %lag%
	sleep %lag%
    if(GetKeyState(up, "P")) {
		send {Click, down, right}
		sleep %lag%
		send {Click, up, right}
    	send {e up}
    }
    else if(GetKeyState("LShift", "P")) {
		send {3 down}
		sleep %lag%
		numP := GetAllKeysPressed("P")
		MaxIndex := numP.MaxIndex()
        while(MaxIndex > 1)
        {
			numP := GetAllKeysPressed("P")
			MaxIndex := numP.MaxIndex()
		}
		send {3 up}
    }
    else {
		send {Click down}
		sleep %lag%
		send {Click up}
    	send {e up}
    }
return

ZAttack:
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


CAttack:
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

switchL:
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

switchR:
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

guard:
  if(comboInProgress == 0) { 
		comboInProgress := 1 
		send {%charge% down}
		sleep %lag% 
		MaxIndex := 1
        grabHeld := 1
		buttonDown := 0
		while (grabHeld == 1 || GetKeyState(charge, "P")) {
			if(GetKeyState(weakPunch, "P") && buttonDown == 0 && grabHeld == 1) { 
				buttonDown := 1 
				comboInProgress := 0
                gosub ZAttack
			}
			else if(GetKeyState(weakKick, "P") && buttonDown == 0 && grabHeld == 1) { 
				buttonDown := 1 
				comboInProgress := 0
                gosub CAttack
			}
            if(GetKeyState(grab, "P") == 0) {
                grabHeld := 0
            }
			buttonDown := 0 	 
		}
		send {%charge% up}
		comboInProgress := 0
		roll := off 
	}
return 

LockTarget: 
  if(comboInProgress == 0) { 
		comboInProgress := 1 
		send {Click, down, middle}
		MaxIndex := 1
        grabHeld := 1
		buttonDown := 0
		while (grabHeld == 1) {
			if(GetKeyState(weakPunch, "P") && buttonDown == 0 && grabHeld == 1) { 
				buttonDown := 1 
				comboInProgress := 0
                gosub ZAttack
			}
			else if(GetKeyState(weakKick, "P") && buttonDown == 0 && grabHeld == 1) { 
				buttonDown := 1 
				comboInProgress := 0
                gosub CAttack
			} 
			else if(GetKeyState(charge, "P") && buttonDown == 0 && grabHeld == 1) { 
				buttonDown := 1 
				comboInProgress := 0
                gosub guard
			} 
            if(GetKeyState(grab, "P") == 0) {
                grabHeld := 0
            }
			buttonDown := 0 	 
		}
		send {Click, up, middle}
		comboInProgress := 0
		roll := off 
  } 
return 