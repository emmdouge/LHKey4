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
, weakPunch := "u"
, upperQ := "U"
, grab := "i"
, upperGrab := "I"
, weakKick := "o"
, upperE := "O"
, charge := "Space"
, mediumPunch := "7"
, mediumKick := "c"
, hardPunch := "4"
, hardKick := "3"

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
facingRight := 1

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
		gosub qcfA
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
            else if (MaxIndex == 1) {
				send {%up% down}
				sleep %lag%
				while(GetKeyState(up, "P")) {
					if(GetKeyState(right, "P") && MaxIndex == 2) {	
						numP := GetAllKeysPressed("P")
						MaxIndex := numP.MaxIndex()
						send {%right% down}
						while(MaxIndex == 2) {
							numP := GetAllKeysPressed("P")
							MaxIndex := numP.MaxIndex()
						}
						if(GetKeyState(up, "P")) {
							send {%right% up}
							continue
						}
					}
					else if(GetKeyState(left, "P") && MaxIndex == 2) {	
						numP := GetAllKeysPressed("P")
						MaxIndex := numP.MaxIndex()
						send {%left% down}
						while(MaxIndex == 2) {
							numP := GetAllKeysPressed("P")
							MaxIndex := numP.MaxIndex()
						}
						if(GetKeyState(up, "P")) {
							send {%left% up}
							continue
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
						if(GetKeyState(up, "P")) {
							send {%down% up}
							continue
						}
					}
				}
				send {%up% up}
            }
		}
		exit
	}
	roll := on
exit

DownPRESSED:
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
            else if (MaxIndex == 1) {
				send {%down% down}
				sleep %lag%
				while(GetKeyState(down, "P")) {
					if(GetKeyState(right, "P") && MaxIndex == 2) {	
						numP := GetAllKeysPressed("P")
						MaxIndex := numP.MaxIndex()
						send {%right% down}
						while(MaxIndex == 2) {
							numP := GetAllKeysPressed("P")
							MaxIndex := numP.MaxIndex()
						}
						if(GetKeyState(down, "P")) {
							send {%right% up}
							continue
						}
					}
					else if(GetKeyState(left, "P") && MaxIndex == 2) {	
						numP := GetAllKeysPressed("P")
						MaxIndex := numP.MaxIndex()
						send {%left% down}
						while(MaxIndex == 2) {
							numP := GetAllKeysPressed("P")
							MaxIndex := numP.MaxIndex()
						}
						if(GetKeyState(down, "P")) {
							send {%left% up}
							continue
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
						if(GetKeyState(down, "P")) {
							send {%up% up}
							continue
						}
					}
				}
				send {%down% up}
            }
		}
		exit
	}
	roll := on
exit

LeftPRESSED:
    facingRight := 0
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
            else if (MaxIndex == 1) {
				send {%left% down}
				sleep %lag%
				while(GetKeyState(left, "P")) {
					if(GetKeyState(right, "P") && MaxIndex == 2) {	
						numP := GetAllKeysPressed("P")
						MaxIndex := numP.MaxIndex()
						send {%right% down}
						while(MaxIndex == 2) {
							numP := GetAllKeysPressed("P")
							MaxIndex := numP.MaxIndex()
						}
						if(GetKeyState(left, "P")) {
							send {%right% up}
							continue
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
						if(GetKeyState(left, "P")) {
							send {%down% up}
							continue
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
						if(GetKeyState(left, "P")) {
							send {%up% up}
							continue
						}
					}
				}
				send {%left% up}
            }
		}
		exit
	}
	roll := on
exit

RightPRESSED:
    facingRight := 1
	numP := GetAllKeysPressed("P")
	MaxIndex := numP.MaxIndex()
	if (roll == lock) {
		exit
	}
	else {
        if(instr(A_PriorKey, down) && ((A_TimeSincePriorHotkey, down) < combo)) {
			roll := lock
			KeyWait, %weakPunch%, d t0.025       
			;down+right
			if ErrorLevel {       
				KeyWait, %weakKick%, d t0.050
				;2+1
				if ErrorLevel {       
					;gosub ZAttack
				}
				;2+1+3
				else {      
                    ;gosub special
				}
			}              
			;down+right+weakPunch
			else {
                if(facingRight) {
                    gosub qcfA
                }
                else {
                    gosub qcBA
                }
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
            else if (MaxIndex == 1) {
				send {%right% down}
				sleep %lag%
				while(GetKeyState(right, "P")) {
					if(GetKeyState(left, "P") && MaxIndex == 2) {	
						numP := GetAllKeysPressed("P")
						MaxIndex := numP.MaxIndex()
						send {%left% down}
						while(MaxIndex == 2) {
							numP := GetAllKeysPressed("P")
							MaxIndex := numP.MaxIndex()
						}
						if(GetKeyState(right, "P")) {
							send {%left% up}
							continue
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
							continue
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
							continue
						}
					}
				}
				send {%right% up}
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
			    gosub QAttack
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
			    gosub EAttack
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

qcfA:
	numP := GetAllKeysPressed("P")
	MaxIndex := numP.MaxIndex()
    Send {Blind}{%mediumPunch% down}
	sleep %lag%
	sleep %lag%
	sleep %lag%
	while(MaxIndex > 1) 
	{
	}
    send {%mediumPunch% up}
	roll := lock
return

qcbA:
	numP := GetAllKeysPressed("P")
	MaxIndex := numP.MaxIndex()
    send {%mediumKick% down}
	sleep %lag%
	while(MaxIndex > 1) 
	{
	}
    send {%mediumKick% up}
	roll := lock
return

QAttack:
	if(GetKeyState("LShift", "P") == 0) {
    	send {q down}
	}
	sleep %lag%
	sleep %lag%
	numP := GetAllKeysPressed("P")
	MaxIndex := numP.MaxIndex()
    if(GetKeyState(up, "P")) {
		send {Click, down, right}
		sleep %lag%
		send {Click, up, right}
    	send {q up}
    }
    else if(GetKeyState("LShift", "P")) {
		send {1 down}
		sleep %lag%
		numP := GetAllKeysPressed("P")
		MaxIndex := numP.MaxIndex()
        while(MaxIndex > 1)
        {
			numP := GetAllKeysPressed("P")
			MaxIndex := numP.MaxIndex()
		}
		send {1 up}
    }
    else {
		send {Click down}
		sleep %lag%
		send {Click up}
    	send {q up}
    }
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