﻿; Always run as admin
;if not A_IsAdmin
;{
;   Run *RunAs "%A_ScriptFullPath%"  ; Requires v1.0.92.01+
;   ExitApp
;}
JoystickNumber = 0
if JoystickNumber <= 0
{
	Loop 16  ; Query each joystick number to find out which ones exist.
	{
		GetKeyState, JoyName, %A_Index%JoyName
		if JoyName <>
		{
			JoystickNumber = %A_Index%
			break
		}
	}
	if JoystickNumber <= 0
	{
		MsgBox The system does not appear to have any joysticks.
		ExitApp
	}
}
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

Hotkey, ~$*%up%, UpPRESSED
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

combo = 150
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
	
	i := 1 
	GetKeyState, joy_buttons, %JoystickNumber%JoyButtons
	Loop, %joy_buttons%
	{
		GetKeyState, joy%a_index%, %JoystickNumber%joy%a_index%
		if joy%a_index% = D
			buttons_down = %buttons_down%%a_space%%JoystickNumber%joy%a_index%
		i++
	}
	GetKeyState, joy_info, %JoystickNumber%JoyInfo
	IfInString, joy_info, P
	{
		GetKeyState, joyp, %JoystickNumber%JoyPOV
		if(joyp == 0 || joyp == 9000 || joyp == 18000 || joyp == 27000 ) {
			buttons_down = %buttons_down%%a_space%%JoystickNumber%joy%joyP%
		} 
		else if(joyp == 13500 || joyp == 22500 || joyp == 31500 || joyp == 4500) {
			buttons_down = %buttons_down%%a_space%%JoystickNumber%joy%joyP%%a_space%%JoystickNumber%joy%joyP%
		}
	}
	
	pressed := StrSplit(buttons_down," ")
	;ToolTip, `nNum Buttons Down: %m%`nButtons Down: %buttons_down%`n`n(right-click the tray icon to exit)
	if(pressed.MaxIndex() < 1) {
		gosub release
	}
	return pressed
}

GetNextKey(type = "1") {
	if (type == "2") {
		Input, SingleKey, V L2 T0.5, {LControl}{RControl}{LAlt}{RAlt}{LShift}{RShift}{LWin}{RWin}{AppsKey}{F1}{F2}{F3}{F4}{F5}{F6}{F7}{F8}{F9}{F10}{F11}{F12}{Left}{Right}{Up}{Down}{Home}{End}{PgUp}{PgDn}{Del}{Ins}{BS}{Capslock}{Numlock}{PrintScreen}{Pause}
	}
	else if (type == "3") {
		Input, SingleKey, V L3 T0.5, {LControl}{RControl}{LAlt}{RAlt}{LShift}{RShift}{LWin}{RWin}{AppsKey}{F1}{F2}{F3}{F4}{F5}{F6}{F7}{F8}{F9}{F10}{F11}{F12}{Left}{Right}{Up}{Down}{Home}{End}{PgUp}{PgDn}{Del}{Ins}{BS}{Capslock}{Numlock}{PrintScreen}{Pause}
	}
	else {
		Input, SingleKey, V L1 T0.5, {LControl}{RControl}{LAlt}{RAlt}{LShift}{RShift}{LWin}{RWin}{AppsKey}{F1}{F2}{F3}{F4}{F5}{F6}{F7}{F8}{F9}{F10}{F11}{F12}{Left}{Right}{Up}{Down}{Home}{End}{PgUp}{PgDn}{Del}{Ins}{BS}{Capslock}{Numlock}{PrintScreen}{Pause}
	}
	return SingleKey
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
			KeyWait, %four%, d t0.025                
			;2+1
			if ErrorLevel {       
				KeyWait, %three%, d t0.050
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
            comboInProgress := 1
            numP := GetAllKeysPressed("P")
            MaxIndex := numP.MaxIndex()
			key := GetNextKey()
			facingRight := 1   
			;dp
			if (ErrorLevel && instr(key, right) && MaxIndex == 2) {
                key := GetNextKey()
                if (ErrorLevel && instr(key, buttonA)) {
                    gosub ewgfA
                }
            }
            comboInProgress := 0
		}
        else if(instr(A_PriorKey, left) && ((A_TimeSincePriorHotkey, left) < combo)) {
            comboInProgress := 1
            numP := GetAllKeysPressed("P")
            MaxIndex := numP.MaxIndex()
			key := GetNextKey()
			facingRight := 0   
			;dp
			if (ErrorLevel && instr(key, left) && MaxIndex == 2) {
                key := GetNextKey()
                if (ErrorLevel && instr(key, buttonA)) {
                    gosub ewgfA
                }
            }
            comboInProgress := 0
		}
        else if(instr(A_PriorKey, down) && ((A_TimeSincePriorHotkey, down) < combo)) {  
            comboInProgress := 1
            numP := GetAllKeysPressed("P")
            MaxIndex := numP.MaxIndex()
			key := GetNextKey() 
			;dowwn+dowwn+(LorR)+button
			if (ErrorLevel && (instr(key, left) || instr(key, right))  && MaxIndex == 2) {
                key := GetNextKey()
                if (ErrorLevel && instr(key, buttonA)) {
                    gosub ddLRA
                }
            }
            comboInProgress := 0
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
			numP := GetAllKeysPressed("P")
			MaxIndex := numP.MaxIndex()  
			nextKey := GetNextKey()   	
			;down+left+button
			if (ErrorLevel && instr(nextKey, buttonA) && MaxIndex == 2) {
                facingRight := 0
                if(instr(nextKey, buttonA)){
                    gosub qcfA
                }
            }
		}
        else if(instr(A_PriorKey, left) && ((A_TimeSincePriorHotkey, left) < combo)) {  
            comboInProgress := 1
            numP := GetAllKeysPressed("P")
            MaxIndex := numP.MaxIndex()
			key := GetNextKey()
			facingRight := 0   
			;left+left+down+button
			if (ErrorLevel && instr(key, down) && MaxIndex == 2) {
                key := GetNextKey()
                if (ErrorLevel && instr(key, buttonA)) {
                    gosub kbdA
                }
            }
            comboInProgress := 0
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
			numP := GetAllKeysPressed("P")
			MaxIndex := numP.MaxIndex()  
			nextKey := GetNextKey()   	
			;down+right+button
			if (ErrorLevel && instr(nextKey, buttonA) && MaxIndex == 2) {
                facingRight := 1  
                if(instr(nextKey, buttonA)){
                    gosub qcfA
                }
            }
		}
        else if(instr(A_PriorKey, right) && ((A_TimeSincePriorHotkey, right) < combo)) {  
            comboInProgress := 1
            numP := GetAllKeysPressed("P")
            MaxIndex := numP.MaxIndex()
			key := GetNextKey()
			facingRight := 1   
			;dp
			if (ErrorLevel && instr(key, down) && MaxIndex == 2) {
                key := GetNextKey()
                if (ErrorLevel && instr(key, buttonA)) {
                    gosub kbdA
                }
            }
            comboInProgress := 0
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
            else if (MaxIndex <= 2) {
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
            else {
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
while (MaxIndex > 1 || (GetKeyState(buttonA, "P") || GetKeyState(buttonB, "P"))) { 
	numP := GetAllKeysPressed("P") 
	MaxIndex := numP.MaxIndex()
	gosub release
} 
if(GetKeyState(left, "P")) {
	facingRight := 1 
    goto RightPRESSED 
}
else if(GetKeyState(right, "P")) {
	facingRight := 0
    goto LeftPRESSED 
}
if(MaxIndex == 1) {
  if(GetKeyState(down, "P")) { 
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
		numP := GetAllKeysPressed("P")
		MaxIndex := numP.MaxIndex()
		gosub releaseAllDirections
		while(GetKeyState(buttonA, "P") || MaxIndex > 1) 
		{	
			numP := GetAllKeysPressed("P")
			MaxIndex := numP.MaxIndex()
			gosub release
		}
		send {%special1%  up}
		comboInProgress := 0
		gosub nextSingleDirection
	}
return

kbdA:
	if(comboInProgress == 0) {
		comboInProgress := 1
		send {%special3%  down}
		numP := GetAllKeysPressed("P")
		MaxIndex := numP.MaxIndex()
		while(GetKeyState(buttonA, "P") || MaxIndex > 1)
		{
			numP := GetAllKeysPressed("P")
			MaxIndex := numP.MaxIndex()
			gosub release
		}
		send {%special3%  up}
		comboInProgress := 0
		gosub nextSingleDirection
	}
return

ewgfA:
    send {%special2%  down}
    numP := GetAllKeysPressed("P")
    MaxIndex := numP.MaxIndex()
    gosub releaseAllDirections
    while(GetKeyState(buttonA, "P") || MaxIndex > 2) {
        numP := GetAllKeysPressed("P")
        MaxIndex := numP.MaxIndex()
        gosub release
    }
    send {%special2%  up}
    comboInProgress := 0
    gosub nextSingleDirection
return

ddLRA:
    send {%special4%  down}
    numP := GetAllKeysPressed("P")
    MaxIndex := numP.MaxIndex()
    gosub releaseAllDirections
    while(GetKeyState(buttonA, "P") || MaxIndex > 2) {
        numP := GetAllKeysPressed("P")
        MaxIndex := numP.MaxIndex()
    }
    send {%special4%  up}
    comboInProgress := 0
    gosub nextSingleDirection
return

ZplusR:
    send {%ZplusR% down}
	sleep %lag%
    send {%ZplusR% up}
return

buttonA:
    comboInProgress := 1
    send {%buttonA%  down}
    gosub releaseAllDirections
    while(GetKeyState(buttonA, "P"))
    {
    }
    send {%buttonA%  up}
    comboInProgress := 0
return

buttonB:
    comboInProgress := 1
    send {%buttonB%  down}
    gosub releaseAllDirections
    while(GetKeyState(buttonB, "P"))
    {
    }
    send {%buttonB%  up}
    comboInProgress := 0
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