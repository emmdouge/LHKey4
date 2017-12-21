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
, mediumPunch := "t"
, mediumKick := "y"
, hardPunch := "4"
, hardKick := "3"


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

;CHANGE LEFT SIDE
RAlt::RAlt

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

CHARGE:
	;1+C
	if(instr(A_PriorKey, weakPunch) && ((A_TimeSincePriorHotkey, weakPunch) < combo)) {
		roll := lock
		gosub action
	}
	;2+C
	if(instr(A_PriorKey, grab) && ((A_TimeSincePriorHotkey, grab) < combo)) {
		roll := lock
		gosub dodge
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
				gosub threePunch
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
;if you rolled 1 -> 2
if (roll != lock && instr(A_PriorKey, grab) && (A_TimeSincePriorHotkey, grab) < roll) {
	gosub action
}
;if you rolled 1 -> 3
else if (roll != lock && instr(A_PriorKey, weakKick) && (A_TimeSincePriorHotkey, weakKick) < roll) {
	gosub threePunch
}
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


threePunch:
	send {%weakPunch% down}
	send {%mediumPunch% down}
	send {%hardPunch% down}
	sleep %lag%
	send {%weakPunch% up}
	send {%mediumPunch% up}
	send {%hardPunch% up}
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

special:
	; Move the mouse slowly (speed 50 vs. 2) by 20 pixels to the right and 30 pixels down
	; from its current location:
	MouseMove, 500, 50, 0, R
	sleep %lag%
	numP := GetAllKeysPressed("P")
	MaxIndex := numP.MaxIndex()
	while(MaxIndex > 0) 
	{
		numP := GetAllKeysPressed("P")
		MaxIndex := numP.MaxIndex()
	}
	roll := lock
return

QAttack:
    send {q down}
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
    	send {q up}
		send {Numpad1 down}
		sleep %lag%
		numP := GetAllKeysPressed("P")
		MaxIndex := numP.MaxIndex()
        while(MaxIndex > 0)
        {
			numP := GetAllKeysPressed("P")
			MaxIndex := numP.MaxIndex()
		}
		send {Numpad1 up}
    }
    else {
		send {Click down}
		sleep %lag%
		send {Click up}
    	send {q up}
    }
return


EAttack: 
    send {e down}
	sleep %lag%
	sleep %lag%
    if(GetKeyState(up, "P")) {
		send {Click, down, right}
		sleep %lag%
		send {Click, up, right}
    }
    else if(GetKeyState("LShift", "P")) {
    	send {q up}
		send {Numpad3 down}
		sleep %lag%
		numP := GetAllKeysPressed("P")
		MaxIndex := numP.MaxIndex()
        while(MaxIndex > 0)
        {
			numP := GetAllKeysPressed("P")
			MaxIndex := numP.MaxIndex()
		}
		send {Numpad3 up}
    }
    else {
		send {Click down}
		sleep %lag%
		send {Click up}
    }
    send {e up}
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