
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
#KeyHistory 12
#MaxHotkeysPerInterval 99000000
#HotkeyInterval 99000000
#MaxThreadsPerHotkey 255
SendMode Input
SetCapsLockState, AlwaysOff

up := "w"
, down := "s"
, left := "a"
, right := "d"

; IMPORTANT: USE joy button #s defined in joystick test
, one = "2joy4"
, two = "2joy5"
, three = "2joy3"
, four = "2joy2"

, weakPunch := "u"
, vSkill := "i"
, weakKick := "o"
, charge := "Space"
, mediumPunch := "t"
, mediumKick := "y"
, hardPunch := "4"
, hardKick := "3"

Hotkey, %weakPunch%, ONEDOWN
Hotkey, %weakPunch% up, ONEUP

Hotkey, %vSkill%, TWODOWN
Hotkey, %vSkill% up, TWOUP

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

;;;;;;;;;;;;;;;;;;;;;;;;
;	LOGIC
;;;;;;;;;;;;;;;;;;;;;;;;


GetAllKeysPressed(mode = "P") {
	
	i := 1 
	GetKeyState, joy_buttons, 2JoyButtons
	Loop, %joy_buttons%
	{
		GetKeyState, joy%a_index%, 2joy%a_index%
		if joy%a_index% = D
			buttons_down = %buttons_down%%a_space%%a_index%
		i++
	}
	pressed := StrSplit(buttons_down," ")
	m := pressed.MaxIndex()
	;ToolTip, `nNum Buttons Down: %m%`nButtons Down: %buttons_down%`n`n(right-click the tray icon to exit)
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
	if(instr(A_PriorKey, vSkill) && ((A_TimeSincePriorHotkey, vSkill) < combo)) {
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
		;2+1
		if(instr(A_PriorKey, vSkill) && ((A_TimeSincePriorHotkey, vSkill) < combo)) {
			roll := lock
			KeyWait, %three%, d t0.025           
			;2+1
			if ErrorLevel {         
				gosub mediumPunch
			}
			;2+1+3
			else {
				KeyWait, %four%, d t0.025
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
			KeyWait, %two%, d t0.025
			;3+1
			if ErrorLevel {
				gosub grab
			}
			;3+1+2
			else {
				KeyWait, %four%, d t0.025
				;3+1+2
				if ErrorLevel {
					gosub hardPunch
				}
				;3+1+2+C
				else {
					gosub vTrigger
				}
			}
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
			KeyWait, %one%, d t0.025
			if ErrorLevel {        
				KeyWait, %four%, d t0.025
				;3+2     
				if ErrorLevel {            
					gosub mediumKick
				}
				;3+2+C
				else {
					KeyWait, %one%, d t0.025
					;3+2+C       
					if ErrorLevel {      
						gosub vTrigger
					}
					;3+2+C+1
					else {
						gosub vTrigger
					}
				}
			}
			;3+2+1
			else {
				KeyWait, %four%, d t0.025
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
			KeyWait, %three%, d t0.025           
			;1+2
			if ErrorLevel {        
				KeyWait, %four%, d t0.025
				;1+2
				if ErrorLevel { 
					gosub mediumPunch
				}
				;1+2+C
				else {
					KeyWait, %three%, d t0.025
					;1+2+C
					if ErrorLevel {
						gosub vTrigger
					}
					;1+2+C+3
					else {
						gosub vTrigger
					}
				}
			}
			;1+2+3
			else {
				KeyWait, %four%, d t0.025
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
		;1+3
		if(instr(A_PriorKey, weakPunch) && ((A_TimeSincePriorHotkey, weakPunch) < combo)) { 
			roll := lock
			KeyWait, %two%, d t0.025
			;1+3
			if ErrorLevel {
				gosub grab
			}
			;1+3+2
			else {
				KeyWait, %four%, d t0.025
				;1+3+2
				if ErrorLevel {
					gosub hardPunch
				}
				;1+3+2+C
				else {
					gosub vTrigger
				}
			}
		} 
		;2+3
		else if(instr(A_PriorKey, vSkill) && ((A_TimeSincePriorHotkey, vSkill) < combo)) {
			roll := lock
			KeyWait, %one%, d t0.025       
			if ErrorLevel {  
				KeyWait, %four%, d t0.025
				;2+3
				if ErrorLevel {       
					gosub mediumKick
				}
				;2+3+C
				else {
					KeyWait, %one%, d t0.025
					;2+3+C     
					if ErrorLevel {      
						gosub vSkill
					}
					;2+3+C+1
					else {
						gosub vTrigger
					}
				}
			}
			;2+3+1
			else {
				KeyWait, %four%, d t0.025
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
		exit
	}
	roll := on
exit

ONEUP:
isModified :=  (GetKeyState("Space", "P") || GetKeyState("Control", "P") || GetKeyState("CapsLock", "P") || GetKeyState("Tab", "P"))
;if you overheld 1(or roll is off) or didn't roll
if (!isModified && roll != lock && (((A_TimeSincePriorHotkey, weakPunch) >= roll)  || (instr(A_PriorKey, weakPunch)) || (instr(A_PriorKey, up)) || (instr(A_PriorKey, down)) || (instr(A_PriorKey, left)) || (instr(A_PriorKey, right)))) {
	if(GetKeyState("Shift", "P") && GetKeyState("LAlt", "P")=0) {
		gosub weakPunch
	}
    else if GetKeyState("LAlt", "P")=0 {
		gosub weakPunch
	}
	if (roll != lock) {
		roll := off
	}
}
;if you rolled 1 -> 2
else if (roll != lock && instr(A_PriorKey, vSkill) && (A_TimeSincePriorHotkey, vSkill) < roll) {
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
if (!isModified && roll != lock && (((A_TimeSincePriorHotkey, vSkill) >= roll)  || (instr(A_PriorKey, vSkill)))) {
	if(GetKeyState("Shift", "P") && GetKeyState("LAlt", "P")=0) {
		gosub vSkill
	}
    else if GetKeyState("LAlt", "P")=0 {
		gosub vSkill
	}
	if (roll != lock) {
		roll := off
	}
}
;if you rolled 2 -> 3
else if (roll != lock && instr(A_PriorKey, weakKick) && (A_TimeSincePriorHotkey, weakKick) < roll) {
	gosub exKick
}
;if you rolled 2 -> 1
else if (roll != lock && instr(A_PriorKey, weakPunch) && (A_TimeSincePriorHotkey, weakPunch) < roll) {
	gosub exPunch
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
if (!isModified && roll != lock && (((A_TimeSincePriorHotkey, weakKick) >= roll) || (instr(A_PriorKey, weakKick)) || (instr(A_PriorKey, up)) || (instr(A_PriorKey, down)) || (instr(A_PriorKey, left)) || (instr(A_PriorKey, right)))) {
	if(GetKeyState("Shift", "P") && GetKeyState("LAlt", "P")=0) {
		gosub weakKick
	}
    else if GetKeyState("LAlt", "P")=0 {
		gosub weakKick
	}
	if (roll != lock) {
		roll := off
	}
}
;if you rolled 3 -> 2
else if (roll != lock && instr(A_PriorKey, vSkill) && (A_TimeSincePriorHotkey, vSkill) < roll) {
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
		MaxIndex := 1
		while (MaxIndex > 0) {
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
		MaxIndex := 1
		while (MaxIndex > 0) {
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
		while (MaxIndex > 0) {
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
		MaxIndex := 3
		while (MaxIndex > 0) {
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
		while (MaxIndex > 0) {
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
		while (MaxIndex > 0) {
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