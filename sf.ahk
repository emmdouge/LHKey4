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
, instantButton := "i"
, weakKick := "o"
, charge := "Space"
, mediumPunch := "t"
, mediumKick := "y"
, hardPunch := "4"
, hardKick := "3"

Hotkey, %weakPunch%, ONEDOWN
Hotkey, %weakPunch% up, ONEUP

Hotkey, %instantButton%, TWODOWN
Hotkey, %instantButton% up, TWOUP

Hotkey, %weakKick%, THREEDOWN
Hotkey, %weakKick% up, THREEUP

Hotkey, %charge%, CHARGE
Hotkey, %charge% up, CHARGEUP

combo = 60
lag = 25
off = 0		;key immediately pressed on up aka roll can be in progress
on = 200	;key must be overheld to press original key, or rolled to another key within time specified aka roll is currently in progress
lock = -1	;input will not be registered until no keys are being pressed on the keyboard aka roll cannot be in progress
comboInProgress := 0
btwnCombo = 0.035

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
	if(instr(A_PriorKey, instantButton) && ((A_TimeSincePriorHotkey, instantButton) < combo)) {
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
	if (MaxIndex == 1)  {
		roll := off	;roll will be unlocked when no keys on the keyboard are pressed
	}
	else if (roll == lock) {
		exit
	}
	else {
		;prevent rolling from 1 to 3
		if(GetKeyState(instantButton, "P") == 0) {
			;2+1
			if(instr(A_PriorKey, instantButton) && ((A_TimeSincePriorHotkey, instantButton) < combo)) {
				roll := lock
				KeyWait, %weakKick%, d t%btwnCombo%                
				;2+1
				if ErrorLevel {         
					gosub mediumPunch
				}
				;2+1+3
				else {
					KeyWait, %charge%, d t%btwnCombo%
					;2+1+3     
					if ErrorLevel {
						gosub hardPunch
					}
					;2+1+3+C
					else {
						gosub vTrigger
					}
				}
			}
			;3+1
			else if(instr(A_PriorKey, weakKick) && ((A_TimeSincePriorHotkey, weakKick) < combo)) { 
				roll := lock
				KeyWait, %instantButton%, d t%btwnCombo%
				;3+1
				if ErrorLevel {
					gosub grab
				}
				;3+1+2
				else {
					KeyWait, %charge%, d t%btwnCombo%
					;3+1+2****************
					if ErrorLevel {
						;if instantButton is not held for a long time
						if ((A_TimeSincePriorHotkey, instantButton) < combo) {
							gosub hardKick
						}
					}
					;3+1+2+C
					else {
						gosub vTrigger
					}
				}
			}
		}
		;pressing weakpunch while middle button is held
		else if(MaxIndex <= 2 && GetKeyState(instantButton, "P")) {
			gosub weakPunch
		}
		exit
	}
	roll := on
exit

TWODOWN:
	numP := GetAllKeysPressed("P")
	MaxIndex := numP.MaxIndex()
	if (MaxIndex == 1)  {
		roll := off	;roll will be unlocked when no keys on the keyboard are pressed
	}
	else if (roll == lock) {
		exit
	}
	else {
		;3+2
		if(instr(A_PriorKey, weakKick) && ((A_TimeSincePriorHotkey, weakKick) < combo)) {
			roll := lock
			KeyWait, %weakPunch%, d t%btwnCombo%
			if ErrorLevel {        
				KeyWait, %charge%, d t%btwnCombo%
				;3+2     
				if ErrorLevel {            
					gosub mediumKick
				}
				;3+2+C
				else {
					KeyWait, %weakPunch%, d t%btwnCombo%
					;3+2+C       
					if ErrorLevel {      
						gosub threeKick
					}
					;3+2+C+1
					else {
						gosub vTrigger
					}
				}
			}
			;3+2+1
			else {
				KeyWait, %charge%, d t%btwnCombo%
				;3+2+1     
				if ErrorLevel {      
					gosub hardKick
				}
				;3+2+1+C
				else {
					gosub vTrigger
				}
			}
		}
		;1+2
		else if(instr(A_PriorKey, weakPunch) && ((A_TimeSincePriorHotkey, weakPunch) < combo)) {
			roll := lock
			KeyWait, %weakKick%, d t%btwnCombo%           
			;1+2
			if ErrorLevel {        
				KeyWait, %charge%, d t%btwnCombo%
				;1+2
				if ErrorLevel { 
					gosub mediumPunch
				}
				;1+2+C
				else {
					KeyWait, %weakKick%, d t%btwnCombo%
					;1+2+C
					if ErrorLevel {
						gosub threePunch
					}
					;1+2+C+3
					else {
						gosub threePunch
					}
				}
			}
			;1+2+3
			else {
				KeyWait, %charge%, d t%btwnCombo%
				;1+2+3     
				if ErrorLevel {     
					gosub hardPunch
				}
				;1+2+3+C
				else {
					gosub vTrigger
				}
			}
		}
		exit
	}
	roll := on
exit

THREEDOWN: 
	numP := GetAllKeysPressed("P")
	MaxIndex := numP.MaxIndex()
	if (MaxIndex == 1)  {
		roll := off	;roll will be unlocked when no keys on the keyboard are pressed
	}
	else if (roll == lock) {
		exit
	}
	else {
		;prevent rolling from 3 to 1
		if(GetKeyState(instantButton, "P") == 0) {
			;1+3
			if(instr(A_PriorKey, weakPunch) && ((A_TimeSincePriorHotkey, weakPunch) < combo)) { 
				roll := lock
				KeyWait, %instantButton%, d t%btwnCombo%
				;1+3
				if ErrorLevel {
					gosub grab
				}
				;1+3+2
				else {
					KeyWait, %charge%, d t%btwnCombo%
					;1+3+2***************************
					if ErrorLevel { 
						;if instantButton is not held for a long time
						if ((A_TimeSincePriorHotkey, instantButton) < combo) {
							gosub hardPunch
						}
					}
					;1+3+2+C
					else {
						gosub vTrigger
					}
				}
			} 
			;2+3
			else if(instr(A_PriorKey, instantButton) && ((A_TimeSincePriorHotkey, instantButton) < combo)) {
				roll := lock
				KeyWait, %weakPunch%, d t%btwnCombo%       
				if ErrorLevel {  
					KeyWait, %charge%, d t%btwnCombo%
					;2+3
					if ErrorLevel {       
						gosub mediumKick
					}
					;2+3+C
					else {
						KeyWait, %weakPunch%, d t%btwnCombo%
						;2+3+C     
						if ErrorLevel {      
							gosub threeKick
						}
						;2+3+C+1
						else {
							gosub threeKick
						}
					}
				}
				;2+3+1
				else {
					KeyWait, %charge%, d t%btwnCombo%
					;2+3+1
					if ErrorLevel {     
						gosub hardPunch
					}
					;2+3+1+C
					else {
						gosub vTrigger
					}
				}
			}
		}
		;pressing weakKick while middle button is held
		else if(MaxIndex <= 2 && GetKeyState(instantButton, "P")) {
			gosub weakKick
		}
		exit
	}
	roll := on
exit

ONEUP:
isModified :=  (GetKeyState("Space", "P") || GetKeyState("Control", "P") || GetKeyState("CapsLock", "P") || GetKeyState("Tab", "P"))
;if you overheld 1(or roll is off) or didn't roll
if (!isModified && roll != lock && (((A_TimeSincePriorHotkey, weakPunch) >= roll)  || (instr(A_PriorKey, weakPunch)) || (instr(A_PriorKey, up)) || (instr(A_PriorKey, down)) || (instr(A_PriorKey, left)) || (instr(A_PriorKey, right)))) {
	if(GetKeyState(instantButton, "P") == 0) {
		;gosub weakPunch
	}
	if (roll != lock) {
		roll := off
	}
}
;if you rolled 1 -> 2
else if (roll != lock && instr(A_PriorKey, instantButton) && (A_TimeSincePriorHotkey, instantButton) < roll) {
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
;if you rolled 2 -> 1
else if (roll != lock && instr(A_PriorKey, weakPunch) && (A_TimeSincePriorHotkey, weakPunch) < roll) {
	gosub threePunch
}
;if you rolled 2 -> 3
else if (roll != lock && instr(A_PriorKey, weakKick) && (A_TimeSincePriorHotkey, weakKick) < roll) {
	gosub threeKick
}
exit 


THREEUP:
isModified :=  (GetKeyState("Control", "P") || GetKeyState("CapsLock", "P") || GetKeyState("Tab", "P"))
;if you overheld 3(or roll is off) or didn't roll
if (!isModified && roll != lock && (((A_TimeSincePriorHotkey, weakKick) >= roll) || (instr(A_PriorKey, weakKick)) || (instr(A_PriorKey, up)) || (instr(A_PriorKey, down)) || (instr(A_PriorKey, left)) || (instr(A_PriorKey, right)))) {
	if(GetKeyState(instantButton, "P") == 0) {
		;gosub weakKick
	}
	if (roll != lock) {
		roll := off
	}
}
;if you rolled 3 -> 2
else if (roll != lock && instr(A_PriorKey, instantButton) && (A_TimeSincePriorHotkey, instantButton) < roll) {
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
		sleep %lag%
		while (MaxIndex == 2 && (GetKeyState(instantButton, "P"))) {
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
		sleep %lag%
		while (MaxIndex == 2 && (GetKeyState(instantButton, "P"))) {
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
		numP := GetAllKeysPressed("P")
		MaxIndex := numP.MaxIndex()
		buttonDown := 0
		while (MaxIndex > 0 && (MaxIndex != 1 && GetKeyState(instantButton, "P"))) {
			if(GetKeyState(weakKick, "P") && buttonDown == 0) {
				numP := GetAllKeysPressed("P")
				MaxIndex := numP.MaxIndex()
				buttonDown := 1
				comboInProgress := 0
				send {%weakKick% down}
				sleep %lag%
				while (MaxIndex > 1 && (GetKeyState(weakKick, "P"))) {
					sleep %lag%
					numP := GetAllKeysPressed("P")
					MaxIndex := numP.MaxIndex()
				}
				comboInProgress := 1
				buttonDown := 0
				send {%weakKick% up}
			}
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
		numP := GetAllKeysPressed("P")
		MaxIndex := numP.MaxIndex()
		while (MaxIndex > 0 && (MaxIndex != 1 && GetKeyState(instantButton, "P"))) {
			if(GetKeyState(weakPunch, "P") && buttonDown == 0) {
				numP := GetAllKeysPressed("P")
				MaxIndex := numP.MaxIndex()
				buttonDown := 1
				comboInProgress := 0
				send {%weakPunch% down}
				sleep %lag%
				while (MaxIndex > 1 && (GetKeyState(weakPunch, "P"))) {
					sleep %lag%
					numP := GetAllKeysPressed("P")
					MaxIndex := numP.MaxIndex()
				}
				comboInProgress := 1
				buttonDown := 0
				send {%weakPunch% up}
			}
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
		MaxIndex := 3
		;do this as long as the last button held down is not instantButton
		while ((MaxIndex > 1 && GetKeyState(instantButton, "P") == 0)) {
			sleep %lag%
			numP := GetAllKeysPressed("P")
			MaxIndex := numP.MaxIndex()
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
		MaxIndex := 3
		;do this as long as the last button held down is not instantButton
		while ((MaxIndex > 1 && GetKeyState(instantButton, "P") == 0)) {
			sleep %lag%
			numP := GetAllKeysPressed("P")
			MaxIndex := numP.MaxIndex()
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