
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
#KeyHistory 12
#MaxHotkeysPerInterval 99000000
#HotkeyInterval 99000000
#MaxThreadsPerHotkey 255
Process, Priority, , A
SetBatchLines, -1                 ;makes the script run at max speed
SetKeyDelay , -1, -1              ;faster response (might be better with -1, 0)
ListLines, Off
SendMode Input
SetCapsLockState, AlwaysOff
SetNumLockState, AlwaysOn

joyup := "empty"
, joydown := "empty"
, joyleft := "empty"
, joyright := "empty"

up := "w" 
, down := "s" 
, left := "a" 
, right := "d" 

; IMPORTANT: USE joy button #s defined in joystick test
, one = "1joy3"
, two = "1joy4"
, three = "1joy5"
, four = "1joy2"

, buttonA := "Numpad7" ;1
, grab := "i" ;2 gave it an arbitrary val to work with default keys
, buttonD := "Numpad4" ;3 gave it an arbitrary val to work with default keys
, barrierG := "Space" ;4

, buttonB := "Numpad8"
, buttonC := "Numpad9"

Hotkey, %buttonA%, ONEDOWN
Hotkey, %buttonA% up, ONEUP

Hotkey, %grab%, TWODOWN
Hotkey, %grab% up, TWOUP

Hotkey, %buttonD%, THREEDOWN
Hotkey, %buttonD% up, THREEUP

Hotkey, %barrierG%, BARRIER
Hotkey, %barrierG% up, BARRIERUP

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
	GetKeyState, joy_buttons, 1JoyButtons
	Loop, %joy_buttons%
	{
		GetKeyState, joy%a_index%, 1joy%a_index%
		if joy%a_index% = D
			buttons_down = %buttons_down%%a_space%1joy%a_index%
		i++
	}
	pressed := StrSplit(buttons_down," ")
	for index, element in pressed ; Recommended approach in most cases.
	{
		if(element == joyup || element == joydown || element == joyleft || element == joyright) {
			pressed.remove(index)
		}
	}
	m := pressed.MaxIndex()
	;ToolTip, `nNum Buttons Down: %m%`nButtons Down: %buttons_down%`n`n(right-click the tray icon to exit)
	return pressed
}

roll := on

BARRIER:
	;1+C
	if(instr(A_PriorKey, buttonA) && ((A_TimeSincePriorHotkey, buttonA) < combo)) {
		roll := lock
		gosub exPunch
	}
	;2+C
	if(instr(A_PriorKey, grab) && ((A_TimeSincePriorHotkey, grab) < combo)) {
		roll := lock
		gosub grab
	}
	;3+C
	if(instr(A_PriorKey, buttonD) && ((A_TimeSincePriorHotkey, buttonD) < combo)) {
		roll := lock
		gosub exKick
	}
	;C
	if(roll != lock) {
		roll := on
		gosub barrierG
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
		if(instr(A_PriorKey, grab) && ((A_TimeSincePriorHotkey, grab) < combo)) {
			roll := lock
			KeyWait, %three%, d t0.025           
			;2+1
			if ErrorLevel {         
				gosub buttonB
			}
			;2+1+3
			else {
				KeyWait, %four%, d t0.025
				;2+1+3     
				if ErrorLevel {
					gosub buttonC
				}
				;2+1+3+C
				else {
					gosub buttonC
				}
			}
		}
		;3+1
		else if(instr(A_PriorKey, buttonD) && ((A_TimeSincePriorHotkey, buttonD) < combo)) { 
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
					gosub buttonC
				}
				;3+1+2+C
				else {
					gosub buttonC
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
		if(instr(A_PriorKey, buttonD) && ((A_TimeSincePriorHotkey, buttonD) < combo)) {
			roll := lock
			KeyWait, %one%, d t0.025
			if ErrorLevel {        
				KeyWait, %four%, d t0.025
				;3+2     
				if ErrorLevel {            
					gosub cancel
				}
				;3+2+C
				else {
					KeyWait, %one%, d t0.025
					;3+2+C       
					if ErrorLevel {      
						gosub buttonC
					}
					;3+2+C+1
					else {
						gosub buttonC
					}
				}
			}
			;3+2+1
			else {
				KeyWait, %four%, d t0.025
				;3+2+1     
				if ErrorLevel {      
					gosub burst
				}
				;3+2+1+C
				else {
					gosub buttonC
				}
			}
		}
		;1+2
		else if(instr(A_PriorKey, buttonA) && ((A_TimeSincePriorHotkey, buttonA) < combo)) {
			roll := lock
			KeyWait, %three%, d t0.025           
			;1+2
			if ErrorLevel {        
				KeyWait, %four%, d t0.025
				;1+2
				if ErrorLevel { 
					gosub buttonB
				}
				;1+2+C
				else {
					KeyWait, %three%, d t0.025
					;1+2+C
					if ErrorLevel {
						gosub buttonC
					}
					;1+2+C+3
					else {
						gosub buttonC
					}
				}
			}
			;1+2+3
			else {
				KeyWait, %four%, d t0.025
				;1+2+3     
				if ErrorLevel {      
					gosub buttonC
				}
				;1+2+3+C
				else {
					gosub buttonC
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
		if(instr(A_PriorKey, buttonA) && ((A_TimeSincePriorHotkey, buttonA) < combo)) { 
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
					gosub buttonC
				}
				;1+3+2+C
				else {
					gosub buttonC
				}
			}
		} 
		;2+3
		else if(instr(A_PriorKey, grab) && ((A_TimeSincePriorHotkey, grab) < combo)) {
			roll := lock
			KeyWait, %one%, d t0.025       
			if ErrorLevel {  
				KeyWait, %four%, d t0.025
				;2+3
				if ErrorLevel {       
					gosub cancel
				}
				;2+3+C
				else {
					KeyWait, %one%, d t0.025
					;2+3+C     
					if ErrorLevel {      
						gosub buttonC
					}
					;2+3+C+1
					else {
						gosub buttonC
					}
				}
			}
			;2+3+1
			else {
				KeyWait, %four%, d t0.025
				;2+3+1
				if ErrorLevel {     
					gosub buttonC
				}
				;2+3+1+C
				else {
					gosub buttonC
				}
			}
		}
		exit
	}
	roll := on
exit

ONEUP:
isModified :=  (GetKeyState("Control", "P") || GetKeyState("CapsLock", "P") || GetKeyState("Tab", "P"))
;if you overheld 1(or roll is off) or didn't roll
if (!isModified && roll != lock && (((A_TimeSincePriorHotkey, buttonA) >= roll)  || (instr(A_PriorKey, buttonA)) || (instr(A_PriorKey, up)) || (instr(A_PriorKey, down)) || (instr(A_PriorKey, left)) || (instr(A_PriorKey, right)))) {
	if(GetKeyState("Shift", "P") && GetKeyState("LAlt", "P")=0) {
		gosub buttonA
	}
    else if GetKeyState("LAlt", "P")=0 {
		gosub buttonA
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
else if (roll != lock && instr(A_PriorKey, buttonD) && (A_TimeSincePriorHotkey, buttonD) < roll) {
	gosub threePunch
}
numP := GetAllKeysPressed("P")
MaxIndex := numP.MaxIndex()
if (MaxIndex < 1)  {
  roll := off	;roll will be unlocked when no keys on the keyboard are pressed
}
exit 


TWOUP:
isModified :=  (GetKeyState("Control", "P") || GetKeyState("CapsLock", "P") || GetKeyState("Tab", "P"))
;if you overheld 2(or roll is off) or didn't roll
if (!isModified && roll != lock && (((A_TimeSincePriorHotkey, grab) >= roll)  || (instr(A_PriorKey, grab)))) {
	if(GetKeyState("Shift", "P") && GetKeyState("LAlt", "P")=0) {
		gosub grab
	}
    else if GetKeyState("LAlt", "P")=0 {
		gosub grab
	}
	if (roll != lock) {
		roll := off
	}
}
;if you rolled 2 -> 3
else if (roll != lock && instr(A_PriorKey, buttonD) && (A_TimeSincePriorHotkey, buttonD) < roll) {
	gosub exKick
}
;if you rolled 2 -> 1
else if (roll != lock && instr(A_PriorKey, buttonA) && (A_TimeSincePriorHotkey, buttonA) < roll) {
	gosub exPunch
}
numP := GetAllKeysPressed("P")
MaxIndex := numP.MaxIndex()
if (MaxIndex < 1 && comboInProgress == 0)  {
  roll := off	;roll will be unlocked when no keys on the keyboard are pressed
}
exit 


THREEUP:
isModified :=  (GetKeyState("Control", "P") || GetKeyState("CapsLock", "P") || GetKeyState("Tab", "P"))
;if you overheld 3(or roll is off) or didn't roll
if (!isModified && roll != lock && (((A_TimeSincePriorHotkey, buttonD) >= roll) || (instr(A_PriorKey, buttonD)) || (instr(A_PriorKey, up)) || (instr(A_PriorKey, down)) || (instr(A_PriorKey, left)) || (instr(A_PriorKey, right)))) {
	if(GetKeyState("Shift", "P") && GetKeyState("LAlt", "P")=0) {
		gosub buttonD
	}
    else if GetKeyState("LAlt", "P")=0 {
		gosub buttonD
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
else if (roll != lock && instr(A_PriorKey, buttonA) && (A_TimeSincePriorHotkey, buttonA) < roll) {
	gosub threeKick
}
numP := GetAllKeysPressed("P")
MaxIndex := numP.MaxIndex()
if (MaxIndex < 1) {
  roll := off	;roll will be unlocked when no keys on the keyboard are pressed
}
exit 

BARRIERUP:
numP := GetAllKeysPressed("P")
MaxIndex := numP.MaxIndex()
if (MaxIndex < 1)  {
  roll := off	;roll will be unlocked when no keys on the keyboard are pressed
}
exit 

threePunch:
	send {%buttonA% down}
	send {%buttonB% down}
	send {%buttonC% down}
	sleep %lag%
	send {%buttonA% up}
	send {%buttonB% up}
	send {%buttonC% up}
	roll := lock
return

threeKick:
	send {%buttonD% down}
	send {%cancel% down}
	send {%cancel% down}
	sleep %lag%
	send {%buttonD% up}
	send {%cancel% up}
	send {%cancel% up}
	roll := lock
return

exPunch:
	send {%buttonA% down}
	send {%buttonB% down}
	sleep %lag%
	send {%buttonA% up}
	send {%buttonB% up}
	roll := lock
return

exKick:
	send {%buttonD% down}
	send {%cancel% down}
	sleep %lag%
	send {%buttonD% up}
	send {%cancel% up}
	roll := lock
return

buttonA:
	if(comboInProgress == 0) {
		comboInProgress := 1
		send {%buttonA% down}
		MaxIndex := 1
		while (MaxIndex > 0) {
			sleep %lag%
			numP := GetAllKeysPressed("P")
			MaxIndex := numP.MaxIndex()
		}
		send {%buttonA% up}
    	comboInProgress := 0 
		roll := off
	}
return


buttonD:
	if(comboInProgress == 0) {
		comboInProgress := 1
		send {%buttonD% down}
		MaxIndex := 1
		while (MaxIndex > 0) {
			sleep %lag%
			numP := GetAllKeysPressed("P")
			MaxIndex := numP.MaxIndex()
		}
		send {%buttonD% up}
    	comboInProgress := 0 
		roll := off
	}
return

buttonB:
	if(comboInProgress == 0) {
		comboInProgress := 1
		send {%buttonB% down}
		MaxIndex := 2
		while (MaxIndex > 0) {
			sleep %lag%
			numP := GetAllKeysPressed("P")
			MaxIndex := numP.MaxIndex()
		}
		send {%buttonB% up}
    	comboInProgress := 0 
		roll := off
	}
return


cancel:
	if(comboInProgress == 0) {
		comboInProgress := 1
		send {%buttonA% down}
		send {%buttonB% down}
		send {%buttonC% down}
		MaxIndex := 3
		while (MaxIndex > 0) {
			sleep %lag%
			numP := GetAllKeysPressed("P")
			MaxIndex := numP.MaxIndex()
		}
		send {%buttonA% up}
		send {%buttonB% up}
		send {%buttonC% up}
    	comboInProgress := 0 
		roll := off
	}
return

buttonC:
	if(comboInProgress == 0) {
		comboInProgress := 1
		send {%buttonC% down}
		MaxIndex := 3
		while (MaxIndex > 0) {
			sleep %lag%
			numP := GetAllKeysPressed("P")
			MaxIndex := numP.MaxIndex()
		}
		send {%buttonC% up}
		comboInProgress := 0
		roll := off
	}
return

burst:
	if(comboInProgress == 0) {
		comboInProgress := 1
		send {%buttonA% down}
		send {%buttonB% down}
		send {%buttonC% down}
		send {%buttonD% down}
		MaxIndex := 3
		while (MaxIndex > 0) {
			sleep %lag%
			numP := GetAllKeysPressed("P")
			MaxIndex := numP.MaxIndex()
		}
		send {%buttonA% up}
		send {%buttonB% up}
		send {%buttonC% up}
		send {%buttonD% up}
		comboInProgress := 0
		roll := off
	}
return

grab:
	if(comboInProgress == 0) {
		comboInProgress := 1
		send {%buttonB% down}
		send {%buttonC% down}
		numP := GetAllKeysPressed("P")
		oldMaxIndex := numP.MaxIndex()
		MaxIndex := 2
		while (MaxIndex > 0) {
			sleep %lag%
			numP := GetAllKeysPressed("P")
			MaxIndex := numP.MaxIndex()
		}
		send {%buttonB% up}
		send {%buttonC% up}
    	comboInProgress := 0 
		if(oldMaxIndex == 1) {
			roll := off
		}
		else {
			roll := lock
		}
	}
return 

barrierG: 
  if(comboInProgress == 0) { 
		comboInProgress := 1 
		send {%buttonA% down}
		send {%buttonB% down}
		MaxIndex := 1
		while (MaxIndex > 0) {
			sleep %lag%
			numP := GetAllKeysPressed("P")
			MaxIndex := numP.MaxIndex()
		}
		send {%buttonA% up}
		send {%buttonB% up}
		comboInProgress := 0
		roll := off 
  } 
return 