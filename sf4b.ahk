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
, grab := "i"
, weakKick := "o"
, charge := "Space"
, mediumPunch := "t"
, mediumKick := "y"
, hardPunch := "4"
, hardKick := "3"

Hotkey, %weakPunch%, ONEDOWN
Hotkey, %weakPunch% up, ONEUP

Hotkey, %grab%, TWODOWN
Hotkey, %grab% up, TWOUP

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
pollingRate := 40

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
		gosub exPunch
	}
	;2+C
	if(instr(A_PriorKey, grab) && ((A_TimeSincePriorHotkey, grab) < combo)) {
		roll := lock
		gosub vSkill
	}
	;3+C
	if(instr(A_PriorKey, weakKick) && ((A_TimeSincePriorHotkey, weakKick) < combo)) {
		roll := lock
		gosub exKick
	}
	;C
	if(roll != lock) {
		roll := on
		send {%charge% down}
		gosub vTrigger
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
				KeyWait, %weakKick%, d t0.025
				;2+1
				if ErrorLevel {       
					gosub hardPunch
				}
				;2+1+3
				else {      
                    gosub threeKick
				}
			}
			;2+1+C
			else {
				gosub threePunch
			}
		}
		else {          
            ;pressing weakpunch while middle button is held
            if(MaxIndex == 2 && GetKeyState(grab, "P")) {
                roll := lock
                gosub mediumPunch
            }
            else if (MaxIndex == 1) {
                roll := lock
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
    if(instr(A_PriorKey, grab) && ((A_TimeSincePriorHotkey, grab) < 100) && ((A_TimeSincePriorHotkey, grab) > pollingRate)) {
        roll := lock
        gosub grab
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
					gosub hardKick
				}
				;2+3+C
				else {      
                    gosub threeKick
				}
			}
			;2+3+1
			else {
				KeyWait, %charge%, d t0.025
				;2+3+1
				if ErrorLevel {     
					gosub threeKick
				}
				;2+3+1+C
				else {
					gosub vTrigger
				}
			}
		}
		else {          
            ;pressing weakKick while middle button is held
            if(MaxIndex == 2 && GetKeyState(grab, "P")) {
                roll := lock
                gosub mediumKick
            }
            else if (MaxIndex == 1) {
                roll := lock
			    gosub weakKick
            }
		}
		exit
	}
	roll := on
exit

ONEUP:
isModified :=  (GetKeyState("Space", "P") || GetKeyState("Control", "P") || GetKeyState("CapsLock", "P") || GetKeyState("Tab", "P"))
;if you overheld 1(or roll is off) or didn't roll
if (!isModified && roll != lock && (((A_TimeSincePriorHotkey, weakPunch) >= roll))) {
	if(!GetKeyState(grab, "P")) {
		gosub weakPunch
	}
	if (roll != lock) {
		roll := off
	}
}
;if you rolled 1 -> 2
else if (roll != lock && instr(A_PriorKey, grab) && (A_TimeSincePriorHotkey, grab) < roll) {
	gosub exPunch
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
isModified :=  (GetKeyState("Space", "P") || GetKeyState("Control", "P") || GetKeyState("CapsLock", "P") || GetKeyState("Tab", "P"))
;if you overheld 2(or roll is off) or didn't roll
if (!isModified && roll != lock && (instr(A_PriorKey, grab)) || (instr(A_PriorKey, up)) || (instr(A_PriorKey, down)) || (instr(A_PriorKey, left)) || (instr(A_PriorKey, right))) {
	;gosub grab
	if (roll != lock) {
		roll := off
	}
}
numP := GetAllKeysPressed("P")
MaxIndex := numP.MaxIndex()
if (MaxIndex < 1 && comboInProgress == 0)  {
  roll := off	;roll will be unlocked when no keys on the keyboard are pressed
}
exit 


THREEUP:
isModified :=  (GetKeyState("Spaceh", "P") || GetKeyState("Control", "P") || GetKeyState("CapsLock", "P") || GetKeyState("Tab", "P"))
;if you overheld 3(or roll is off) or didn't roll
if (!isModified && roll != lock && (((A_TimeSincePriorHotkey, weakKick) >= roll))) {
	if(!GetKeyState(grab, "P")) {
		gosub weakKick
	}
	if (roll != lock) {
		roll := off
	}
}
;if you rolled 3 -> 2
else if (roll != lock && instr(A_PriorKey, grab) && (A_TimeSincePriorHotkey, grab) < roll) {
	gosub exKick
}
;if you rolled 3 -> 1
else if (roll != lock && instr(A_PriorKey, weakPunch) && (A_TimeSincePriorHotkey, weakPunch) < roll) {
	gosub threeKick
}
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

threeKick:
	send {%weakKick% down}
	send {%mediumKick% down}
	send {%hardKick% down}
	sleep %lag%
	send {%weakKick% up}
	send {%mediumKick% up}
	send {%hardKick% up}
	roll := lock
return

exPunch:
	send {%weakPunch% down}
	send {%mediumPunch% down}
	sleep %lag%
	send {%weakPunch% up}
	send {%mediumPunch% up}
	roll := lock
return

exKick:
	send {%weakKick% down}
	send {%mediumKick% down}
	sleep %lag%
	send {%weakKick% up}
	send {%mediumKick% up}
	roll := lock
return

weakPunch:
	if(comboInProgress == 0) {
		comboInProgress := 1
		send {%weakPunch% down}
        numP := GetAllKeysPressed("P")
        MaxIndex := numP.MaxIndex()
		while (MaxIndex > 0 && GetKeyState(grab, "P") == 0) {
			sleep %lag%
			numP := GetAllKeysPressed("P")
			MaxIndex := numP.MaxIndex()
		}
		send {%weakPunch% up}
    	comboInProgress := 0 
		roll := off
	}
return


weakKick:
	if(comboInProgress == 0) {
		comboInProgress := 1
		send {%weakKick% down}
        numP := GetAllKeysPressed("P")
        MaxIndex := numP.MaxIndex()
		while (MaxIndex > 0 && GetKeyState(grab, "P") == 0) {
			sleep %lag%
			numP := GetAllKeysPressed("P")
			MaxIndex := numP.MaxIndex()
		}
		send {%weakKick% up}
    	comboInProgress := 0 
		roll := off
	}
return

mediumPunch:
	if(comboInProgress == 0) {
		comboInProgress := 1
		send {%mediumPunch% down}
		MaxIndex := 2
		while (MaxIndex > 1) {
			sleep %lag%
			numP := GetAllKeysPressed("P")
			MaxIndex := numP.MaxIndex()
		}
		send {%mediumPunch% up}
    	comboInProgress := 0 
		roll := off
	}
return


mediumKick:
	if(comboInProgress == 0) {
		comboInProgress := 1
		send {%mediumKick% down}
		MaxIndex := 2
		while (MaxIndex > 1) {
			sleep %lag%
			numP := GetAllKeysPressed("P")
			MaxIndex := numP.MaxIndex()
		}
		send {%mediumKick% up}
    	comboInProgress := 0 
		roll := off
	}
return

hardPunch:
	if(comboInProgress == 0) {
		comboInProgress := 1
		send {%hardPunch% down} 
		numP := GetAllKeysPressed("P") 
		MaxIndex := numP.MaxIndex() 
		buttonDown := 0
        hardPunchRelease := 0
		sleep %lag% 
		while (MaxIndex > 0) { 
			if(GetKeyState(weakPunch, "P") && buttonDown == 0 && hardPunchRelease == 1) { 
				numP := GetAllKeysPressed("P") 
				MaxIndex := numP.MaxIndex() 
				buttonDown := 1 
				comboInProgress := 0 
				send {%mediumPunch% down} 
				sleep %lag% 
				while (MaxIndex > 1 && (GetKeyState(weakPunch, "P"))) { 
					sleep %lag% 
					numP := GetAllKeysPressed("P") 
					MaxIndex := numP.MaxIndex() 
				} 
				comboInProgress := 1 
				buttonDown := 0 
				send {%mediumPunch% up} 
			}
			if(GetKeyState(weakKick, "P") && buttonDown == 0 && hardPunchRelease == 1) { 
				numP := GetAllKeysPressed("P") 
				MaxIndex := numP.MaxIndex() 
				buttonDown := 1 
				comboInProgress := 0 
				send {%mediumKick% down} 
				sleep %lag% 
				while (MaxIndex > 1 && (GetKeyState(weakKick, "P"))) { 
					sleep %lag% 
					numP := GetAllKeysPressed("P") 
					MaxIndex := numP.MaxIndex() 
				} 
				comboInProgress := 1 
				buttonDown := 0 
				send {%mediumKick% up} 
			} 	 
            if(GetKeyState(weakPunch, "P") == 0) {
                hardPunchRelease := 1
            }
		}
		send {%hardPunch% up} 
		comboInProgress := 0
		roll := off
	}
return

hardKick:
	if(comboInProgress == 0) {
		comboInProgress := 1
		send {%hardKick% down} 
		numP := GetAllKeysPressed("P") 
		MaxIndex := numP.MaxIndex() 
		buttonDown := 0
        hardKickRelease := 0
		sleep %lag% 
		while (MaxIndex > 0) { 
			if(GetKeyState(weakKick, "P") && buttonDown == 0 && hardKickRelease == 1) { 
				numP := GetAllKeysPressed("P") 
				MaxIndex := numP.MaxIndex() 
				buttonDown := 1 
				comboInProgress := 0 
				send {%mediumKick% down} 
				sleep %lag% 
				while (MaxIndex > 1 && (GetKeyState(weakKick, "P"))) { 
					sleep %lag% 
					numP := GetAllKeysPressed("P") 
					MaxIndex := numP.MaxIndex() 
				} 
				comboInProgress := 1 
				buttonDown := 0 
				send {%mediumKick% up} 
			} 	 
			if(GetKeyState(weakPunch, "P") && buttonDown == 0 && hardKickRelease == 1) { 
				numP := GetAllKeysPressed("P") 
				MaxIndex := numP.MaxIndex() 
				buttonDown := 1 
				comboInProgress := 0 
				send {%mediumPunch% down} 
				sleep %lag% 
				while (MaxIndex > 1 && (GetKeyState(weakPunch, "P"))) { 
					sleep %lag% 
					numP := GetAllKeysPressed("P") 
					MaxIndex := numP.MaxIndex() 
				} 
				comboInProgress := 1 
				buttonDown := 0 
				send {%mediumPunch% up} 
			}
            if(GetKeyState(weakKick, "P") == 0) {
                hardKickRelease := 1
            }
		}
		send {%hardKick% up} 
		comboInProgress := 0
		roll := off
	}
return

grab:
	if(comboInProgress == 0) {
		comboInProgress := 1
		send {%weakPunch% down} 
		send {%weakKick% down} 
		MaxIndex := 2
		while (MaxIndex > 0) {
			sleep %lag%
			numP := GetAllKeysPressed("P")
			MaxIndex := numP.MaxIndex()
		}
		send {%weakPunch% up} 
		send {%weakKick% up}
    	comboInProgress := 0 
		roll := off
	}
return

vSkill:
	if(comboInProgress == 0) {
		comboInProgress := 1
		send {%mediumPunch% down}
		send {%mediumKick% down}
		numP := GetAllKeysPressed("P")
		oldMaxIndex := numP.MaxIndex()
		MaxIndex := 2
		while (MaxIndex > 0) {
			sleep %lag%
			numP := GetAllKeysPressed("P")
			MaxIndex := numP.MaxIndex()
		}
		send {%mediumPunch% up}
		send {%mediumKick% up}
    	comboInProgress := 0 
		if(oldMaxIndex == 1) {
			roll := off
		}
		else {
			roll := lock
		}
	}
return 

vTrigger: 
  if(comboInProgress == 0) { 
		comboInProgress := 1 
		send {%hardPunch% down}
		send {%hardKick% down}
		MaxIndex := 1
		while (MaxIndex > 0) {
			sleep %lag%
			numP := GetAllKeysPressed("P")
			MaxIndex := numP.MaxIndex()
		}
		send {%hardPunch% up}
		send {%hardKick% up}
		comboInProgress := 0
		roll := off 
  } 
return 