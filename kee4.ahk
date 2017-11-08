#SingleInstance force
#Persistent
#UseHook On
#NoEnv
#InstallKeybdHook
SetBatchLines, -1                 ;makes the script run at max speed
SetKeyDelay , -1, -1              ;faster response (might be better with -1, 0)
ListLines, Off
#KeyHistory 3

SetCapsLockState, AlwaysOff
cons = 200
combo = 40
global skey

roll := cons
numP := GetAllKeysPressed("P")
MaxIndex := numP.MaxIndex()
#if MaxIndex < 1 || GetKeyState("Shift", "P")=1
  roll := 0
  skey := 0
return

+j:: return
j:: 
;the moment you press a key, unlock the roll
	roll := cons
	if(instr(A_PriorKey, "k") && ((A_TimeSincePriorHotkey, "k") < combo)) {
		send {t}
	}
return
$~*j up::
isModified :=  (GetKeyState("Space", "P") || GetKeyState("Control", "P") || GetKeyState("CapsLock", "P") || GetKeyState("Tab", "P"))
;if you overheld h or pressed h again
if (!isModified && (A_TimeSincePriorHotkey, "j") >= roll)  || (instr(A_PriorKey, "j") && !isModified){
	if(GetKeyState("Shift", "P") && GetKeyState("LAlt", "P")=0) {
		send {j}
	}
    else if GetKeyState("LAlt", "P")=0 {
		send {j}
	}
	roll := 0
}
;if you pressed j -> k
if (instr(A_PriorKey, "k") && (A_TimeSincePriorHotkey, "k") < roll) {
	send {i}
}
isModified := 0 
return 


+k:: return
k:: 
;the moment you press a key, unlock the roll
	roll := cons
	if(instr(A_PriorKey, "l") && ((A_TimeSincePriorHotkey, "l") < combo)) {
		send {y}
	}
	if(instr(A_PriorKey, "j") && ((A_TimeSincePriorHotkey, "j") < combo)) {
		send {t}
	}
return
$~*k up::
isModified :=  (GetKeyState("Space", "P") || GetKeyState("Control", "P") || GetKeyState("CapsLock", "P") || GetKeyState("Tab", "P"))
;if you overheld j or pressed j again
if (!isModified && (A_TimeSincePriorHotkey, "k") >= roll)  || (instr(A_PriorKey, "k") && !isModified){
	if(GetKeyState("Shift", "P") && GetKeyState("LAlt", "P")=0) {
		send {K}
	}
    else if GetKeyState("LAlt", "P")=0 {
		send {k}
	}
	roll := 0
}
;if you pressed j -> k
if (instr(A_PriorKey, "l") && (A_TimeSincePriorHotkey, "l") < roll) {
	send {u}
}
if (instr(A_PriorKey, "j") && (A_TimeSincePriorHotkey, "j") < roll) {
	send {i}
}
isModified := 0 
return 

+l:: return
l:: 
;the moment you press a key, unlock the roll
	roll := cons
	if(instr(A_PriorKey, "k") && ((A_TimeSincePriorHotkey, "k") < combo)) {
		send {y}
	}
	if(instr(A_PriorKey, ";") && ((A_TimeSincePriorHotkey, ";") < combo)) {
		send {m}
	}
return
$~*l up::
isModified :=  (GetKeyState("Space", "P") || GetKeyState("Control", "P") || GetKeyState("CapsLock", "P") || GetKeyState("Tab", "P"))
;if you overheld k or pressed k again
if (!isModified && (A_TimeSincePriorHotkey, "l") >= roll)  || (instr(A_PriorKey, "l") && !isModified){
	if(GetKeyState("Shift", "P") && GetKeyState("LAlt", "P")=0) {
		send {L}
	}
    else if GetKeyState("LAlt", "P")=0 {
		send {l}
	}
	roll := 0
}
;if you pressed k -> j
if (instr(A_PriorKey, "k") && (A_TimeSincePriorHotkey, "k") < roll) {
	send {u}
}
isModified := 0 
return 

+`;:: return
`;:: 
;the moment you press a key, unlock the roll
	roll := cons
	if(instr(A_PriorKey, "l") && ((A_TimeSincePriorHotkey, "l") < combo)) {
		send {m}
	}
return
$~*`; up::
isModified :=  (GetKeyState("Space", "P") || GetKeyState("Control", "P") || GetKeyState("CapsLock", "P") || GetKeyState("Tab", "P"))
;if you overheld l or pressed l again
if (!isModified && (A_TimeSincePriorHotkey, ";") >= roll)  || (instr(A_PriorKey, ";") && !isModified){
	if(GetKeyState("Shift", "P") && GetKeyState("LAlt", "P")=0) {
		send {;}
	}
    else if GetKeyState("LAlt", "P")=0 {
		send {;}
	}
	roll := 0
}
isModified := 0 
return 

GetAllKeysPressed(mode = "L") {
	
	pressed := Array()
	i := 1 
		
	keys = ``|1|2|3|4|5|6|7|8|9|0|-|=|[|]\|;|'|,|.|/|a|b|c|d|e|f|g|h|i|j|k|l|m|n|o|p|q|r|s|t|u|v|w|x|y|z|Esc|Tab|CapsLock|LShift|RShift|LCtrl|RCtrl|LWin|RWin|LAlt|RAlt|Space|AppsKey|Up|Down|Left|Right|Enter|BackSpace|Delete|Home|End|PGUP|PGDN|PrintScreen|ScrollLock|Pause|Insert|NumLock|F1|F2|F3|F4|F5|F6|F7|F8|F9|F10|F11|F12|F13|F14|F15|F16|F17|F18|F19|F20
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

Exit