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

, one := "4joy3"
, two := "4joy9"
, three := "4joy2"
, four := "4joy8"
, five := "4joy15"

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

GetAllKeysPressed(mode = "P") {
	
	i := 1 
	GetKeyState, joy_buttons, 4JoyButtons
	Loop, %joy_buttons%
	{
		GetKeyState, joy%a_index%, 4joy%a_index%
		if joy%a_index% = D
			buttons_down = %buttons_down%%a_space%4joy%a_index%
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

CHARGE:
	;1+C
	if(instr(A_PriorKey, weakPunch) && ((A_TimeSincePriorHotkey, weakPunch) < combo)) {
		roll := lock
		gosub action
	}
	;2+C
	if(instr(A_PriorKey, grab) && ((A_TimeSincePriorHotkey, grab) < combo*4)) {
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
			KeyWait, %four%, d t0.025                
			;2+1
			if ErrorLevel {       
				KeyWait, %three%, d t0.050
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
            if((MaxIndex == 2 && GetKeyState(two, "D")) || (MaxIndex == 3 && GetKeyState(two, "D"))) {
                roll := lock
                gosub switchL
            }
            else if(MaxIndex == 2 && GetKeyState(two, "D") && GetKeyState(four, "D")) {
                roll := lock
                gosub guard
            }
            else if ((MaxIndex == 1 || (MaxIndex == 2 && GetKeyState(one, "D")) || (MaxIndex == 2 && GetKeyState(up, "D")) || (MaxIndex == 2 && GetKeyState(three, "D")))) {
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
			KeyWait, %one%, d t0.025       
			if ErrorLevel {  
				KeyWait, %four%, d t0.025
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
				KeyWait, %four%, d t0.050
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
            if(MaxIndex == 2 && GetKeyState(two, "D") || (MaxIndex == 3 && GetKeyState(two, "D"))) {
                roll := lock
                gosub switchR
            }
            else if(MaxIndex == 2 && GetKeyState(two, "D") && GetKeyState(four, "D")) {
                roll := lock
                gosub guard
            }
            else if ((MaxIndex == 1 || (MaxIndex == 2 && GetKeyState(three, "D")) || (MaxIndex == 2 && GetKeyState(up, "D")) || (MaxIndex == 2 && GetKeyState(one, "D")))) {
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

QAttack:
	if(GetKeyState(five, "D") == 0) {
    	send {q down}
	}
	sleep %lag%
	sleep %lag%
	numP := GetAllKeysPressed("P")
	MaxIndex := numP.MaxIndex()
    if(GetKeyState(up, "D")) {
		send {Click, down, right}
		sleep %lag%
		send {Click, up, right}
    	send {q up}
    }
    else if(GetKeyState(five, "D")) {
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
	if(GetKeyState(five, "D") == 0) {
    	send {e down}
	}
	sleep %lag%
	sleep %lag%
    if(GetKeyState(up, "D")) {
		send {Click, down, right}
		sleep %lag%
		send {Click, up, right}
    	send {e up}
    }
    else if(GetKeyState(five, "D")) {
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
    	if(GetKeyState(up, "D")) {
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
    	if(GetKeyState(up, "D")) {
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
		while (grabHeld == 1 || GetKeyState(four, "D")) {
			if(GetKeyState(weakPunch, "P") && buttonDown == 0 && grabHeld == 1) { 
				buttonDown := 1 
				comboInProgress := 0
                gosub ZAttack
			}
			else if(GetKeyState(three, "D") && buttonDown == 0 && grabHeld == 1) { 
				buttonDown := 1 
				comboInProgress := 0
                gosub CAttack
			}
            if(GetKeyState(two, "D") == 0) {
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
			else if(GetKeyState(three, "D") && buttonDown == 0 && grabHeld == 1) { 
				buttonDown := 1 
				comboInProgress := 0
                gosub CAttack
			} 
			else if(GetKeyState(four, "D") && buttonDown == 0 && grabHeld == 1) { 
				buttonDown := 1 
				comboInProgress := 0
                gosub guard
			} 
            if(GetKeyState(two, "D") == 0) {
                grabHeld := 0
            }
			buttonDown := 0 	 
		}
		send {Click, up, middle}
		comboInProgress := 0
		roll := off 
  } 
return 