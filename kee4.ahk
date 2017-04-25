﻿#SingleInstance force
#Persistent
#UseHook On
#NoEnv
#InstallKeybdHook
SetBatchLines, -1                 ;makes the script run at max speed
SetKeyDelay , -1, -1              ;faster response (might be better with -1, 0)
ListLines, Off
#KeyHistory 3
SetCapsLockState, AlwaysOff
cons = 70

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;SetDefaultMouseSpeed, 0 
; -distance := 63  how far the mouse moves each turn of the timer
;multiplier = 1.15     ; - how much farther (exponentially) the mouse moves in
                      ;   a direction the longer you hold that direction down
;CFKM = 45             ; - how often to run the timer

;SetTimer, CheckForKeyMouse, %CFKM%

;return

;CheckForKeyMouse:
;	if GetKeyState("Space", "P") {
;	GetKeyState("K", "P") ? (d*=multiplier) : (d:=1)
;	GetKeyState("I", "P") ? (u*=multiplier) : (u:=1)
;	GetKeyState("L", "P") ? (r*=multiplier) : (r:=1)
;	GetKeyState("J", "P") ? (l*=multiplier) : (l:=1)
;	distance := 55
;	y := (d-u) * distance
;	x := (r-l) * distance
;	MouseMove, x, y, , R
;	}
;
;	if GetKeyState("Alt", "P") {
;	GetKeyState("K", "P") ? (d*=multiplier) : (d:=1)
;	GetKeyState("I", "P") ? (u*=multiplier) : (u:=1)
;	GetKeyState("L", "P") ? (r*=multiplier) : (r:=1)
;	GetKeyState("J", "P") ? (l*=multiplier) : (l:=1)
;	distance := 700
;	y := (d-u) * distance
;	x := (r-l) * distance
;	MouseMove, x, y, , R
;	}
;return

;Space & `;::
;   if( not GetKeyState("LButton" , "P") )
;        Click down
;return

;Space & `; Up::Click up

;Space & u:: Send, {MButton}
;Space & o:: Send, {Click right}
;.:: 
;if not GetKeyState("Space", "P") {
;    send {.}
;}
;return
;$~. up::
;pressed :=  (GetKeyState("Space", "P") || GetKeyState("Control", "P") || GetKeyState("CapsLock", "P"))
;if (!pressed) {
;    send {}
;}
;return 
;
;i:: 
;if not GetKeyState("Space", "P") {
;    send {i}
;}
;return
;$~i up::
;pressed :=  (GetKeyState("Space", "P") || GetKeyState("Control", "P") || GetKeyState("CapsLock", "P"))
;if (!pressed) {
;    send {}
;}
;return 

;j::
;if not GetKeyState("Space", "P") {
;    send {j}
;}
;return
;$~j up::
;pressed :=  (GetKeyState("Space", "P") || GetKeyState("Control", "P") || GetKeyState("CapsLock", "P"))
;if (!pressed) {
;    send {}
;}
;return 
;
;k:: 
;if not GetKeyState("Space", "P") {
;    send {k}
;}
;return
;$~k up::
;pressed :=  (GetKeyState("Space", "P") || GetKeyState("Control", "P") || GetKeyState("CapsLock", "P"))
;if (!pressed) {
;    send {}
;}
;return

;l:: 
;if not GetKeyState("Space", "P") {
;    send {l}
;}
;return
;$~l up::
;pressed :=  (GetKeyState("Space", "P") || GetKeyState("Control", "P") || GetKeyState("CapsLock", "P"))
;if (!pressed) {
;    send {}
;}
;return

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
roll := cons
numP := GetAllKeysPressed("P")
MaxIndex := numP.MaxIndex()
#if MaxIndex < 1 || GetKeyState("Shift", "P")=1
  roll := 0
return

+e:: return
e:: return
$~*e up::
pressed :=  (GetKeyState("w", "P") ||  GetKeyState("r", "P") || GetKeyState("Space", "P") || GetKeyState("Control", "P") || GetKeyState("CapsLock", "P") || GetKeyState("Tab", "P"))
if (!pressed && (A_TimeSincePriorHotkey, "w") > roll && (A_TimeSincePriorHotkey, "r") > roll)  || (instr(A_PriorKey, "e") && !pressed){
	if(GetKeyState("Shift", "P") && GetKeyState("LAlt", "P")=0) {
		send {E}
	}
	else if GetKeyState("LAlt", "P")=0 {
    	send {e}
	}
	roll := 0
}
if instr(A_PriorKey, "w") {
	if(GetKeyState("Shift", "P") && GetKeyState("LAlt", "P")=0) {
		send {U}
	}
	else if GetKeyState("LAlt", "P")=0 {
		send {u}
	}
	roll := cons
}
if instr(A_PriorKey, "r") {
	if(GetKeyState("Shift", "P") && GetKeyState("LAlt", "P")=0) {
		send {O}
	}
	else if GetKeyState("LAlt", "P")=0 {
		send {o}
	}
	roll := cons
}
pressed := 0 
return 

+w:: return
w:: return
$~*w up::
pressed :=  (GetKeyState("r", "P") || GetKeyState("Space", "P") || GetKeyState("Control", "P") || GetKeyState("CapsLock", "P") || GetKeyState("Tab", "P"))
if (!pressed && (A_TimeSincePriorHotkey, "r") > roll)  || (instr(A_PriorKey, "w") && !pressed) {
	if(GetKeyState("Shift", "P") && GetKeyState("LAlt", "P")=0) {
		send {W}
	}
	else if GetKeyState("LAlt", "P")=0 {
    	send {w}
	}
	roll := 0
}
if instr(A_PriorKey, "r") {
	if(GetKeyState("Shift", "P") && GetKeyState("LAlt", "P")=0) {
		send {P}
	}
	else if GetKeyState("LAlt", "P")=0 {
		send {p}
	}
	roll := cons
}
pressed := 0 
return 

+r:: return
r:: return
$~*r up::
pressed :=  (GetKeyState("e", "P") || GetKeyState("w", "P") || GetKeyState("q", "P") || GetKeyState("Space", "P") || GetKeyState("Control", "P") || GetKeyState("CapsLock", "P") || GetKeyState("Tab", "P"))
if (!pressed && (A_TimeSincePriorHotkey, "e") > roll && (A_TimeSincePriorHotkey, "q") > roll && (A_TimeSincePriorHotkey, "q") > roll) || (instr(A_PriorKey, "r") && !pressed) {
	if(GetKeyState("Shift", "P") && GetKeyState("LAlt", "P")=0) {
		send {R}
	}
	else if GetKeyState("LAlt", "P")=0 {
    	send {r}
	}
	roll := 0
}
if instr(A_PriorKey, "e") {
	if(GetKeyState("Shift", "P") && GetKeyState("LAlt", "P")=0) {
		send {I}
	}
	else if GetKeyState("LAlt", "P")=0 {
		send {i}
	}
	roll := cons
}if instr(A_PriorKey, "w") {
	if(GetKeyState("Shift", "P") && GetKeyState("LAlt", "P")=0) {
		send {Y}
	}
	else if GetKeyState("LAlt", "P")=0 {
		send {y}
	}
	roll := cons
}
if instr(A_PriorKey, "q") {
	send {Home}
	roll := cons
}
pressed := 0 
return 

+q:: return
q:: return
$~*q up::
pressed :=  (GetKeyState("r", "P") || GetKeyState("Space", "P") || GetKeyState("Control", "P") || GetKeyState("CapsLock", "P") || GetKeyState("Tab", "P"))
if (!pressed && (A_TimeSincePriorHotkey, "r") > roll) || (instr(A_PriorKey, "q") && !pressed) {
	if(GetKeyState("Shift", "P") && GetKeyState("LAlt", "P")=0) {
		send {Q}
	}
    else if GetKeyState("LAlt", "P")=0 {
		send {q}
	}
	roll := 0
}
if instr(A_PriorKey, "r") {
	send {End}
	roll := cons
}
pressed := 0 
return 

+s:: return
s:: return
$~*s up::
pressed := (GetKeyState("d", "P") || GetKeyState("Space", "P") || GetKeyState("Control", "P") || GetKeyState("CapsLock", "P") || GetKeyState("Tab", "P"))
if (!pressed && (A_TimeSincePriorHotkey, "d") > roll)  || (instr(A_PriorKey, "s") && !pressed){
	if(GetKeyState("Shift", "P") && GetKeyState("LAlt", "P")=0) {
		send {S}
	}
    else if GetKeyState("LAlt", "P")=0 {
		send {s}
	}
	roll := 0
}
if instr(A_PriorKey, "d") {
	if(GetKeyState("Shift", "P") && GetKeyState("LAlt", "P")=0) {
		send {J}
	}
	else if GetKeyState("LAlt", "P")=0 {
		send {j}
	}
	roll := cons
}
pressed := 0 
return 

+a:: return
a:: return
$~*a up::
pressed :=  (GetKeyState("g", "P") || GetKeyState("f", "P") || GetKeyState("Space", "P") || GetKeyState("Control", "P") || GetKeyState("CapsLock", "P") || GetKeyState("Tab", "P"))
if (!pressed && (A_TimeSincePriorHotkey, "s") > roll && (A_TimeSincePriorHotkey, "g") > roll && (A_TimeSincePriorHotkey, "f") > roll) || (instr(A_PriorKey, "a") && !pressed) {
	if(GetKeyState("Shift", "P") && GetKeyState("LAlt", "P")=0) {
		send {A}
	}
    else if GetKeyState("LAlt", "P")=0 {
		send {a}
	}
	roll := 0
}
if instr(A_PriorKey, "g") {
	send {;}
	roll := cons
}
if instr(A_PriorKey, "f") {
	send {"}
	roll := cons
}
pressed := 0 
return 

+d:: return
d:: return
$~*d up::
pressed :=  (GetKeyState("f", "P") || GetKeyState("Space", "P") || GetKeyState("s", "P") || GetKeyState("Control", "P") || GetKeyState("CapsLock", "P"))
if (!pressed && (A_TimeSincePriorHotkey, "f") > roll) || (instr(A_PriorKey, "d") && !pressed) {
	if(GetKeyState("Shift", "P") && GetKeyState("LAlt", "P")=0) {
		send {D}
	}
    else if GetKeyState("LAlt", "P")=0 {
		send {d}
	}
	roll := 0
}
if instr(A_PriorKey, "f") {
	if(GetKeyState("Shift", "P") && GetKeyState("LAlt", "P")=0) {
		send {L}
	}
	else if GetKeyState("LAlt", "P")=0 {
		send {l}
	}
	roll := cons
}
if instr(A_PriorKey, "s") {
	if(GetKeyState("Shift", "P") && GetKeyState("LAlt", "P")=0) {
		send {H}
	}
	else if GetKeyState("LAlt", "P")=0 {
		send {h}
	}
	roll := cons
}
pressed := 0 
return 

+f:: return
f:: return
$~*f up::
pressed :=  (GetKeyState("d", "P") || GetKeyState("a", "P") || GetKeyState("Space", "P") || GetKeyState("Control", "P") || GetKeyState("CapsLock", "P") || GetKeyState("Tab", "P"))
if (!pressed && (A_TimeSincePriorHotkey, "d") > roll && (A_TimeSincePriorHotkey, "a") > roll) || (instr(A_PriorKey, "f")&& !pressed) {
	if(GetKeyState("Shift", "P") && GetKeyState("LAlt", "P")=0) {
		send {F}
	}
    else if GetKeyState("LAlt", "P")=0 {
		send {f}
	}
	roll := 0
}
if instr(A_PriorKey, "d") {
	if(GetKeyState("Shift", "P") && GetKeyState("LAlt", "P")=0) {
		send {K}
	}
	else if GetKeyState("LAlt", "P")=0 {
		send {k}
	}
	roll := cons
}
if instr(A_PriorKey, "a") {
	send {'}
	roll := cons
}
pressed := 0 
return 

+g:: return
g:: return
$~*g up::
pressed :=  (GetKeyState("a", "P") || GetKeyState("Space", "P") || GetKeyState("Control", "P") || GetKeyState("CapsLock", "P") || GetKeyState("Tab", "P"))
if (!pressed && (A_TimeSincePriorHotkey, "a") > roll) || (instr(A_PriorKey, "g") && !pressed){
	if(GetKeyState("Shift", "P") && GetKeyState("LAlt", "P")=0) {
		send {G}
	}
    else if GetKeyState("LAlt", "P")=0 {
		send {g}
	}
	roll := 0
}
if instr(A_PriorKey, "a") {
	send {:}
	roll := cons
}
pressed := 0 
return 

+c:: return
c:: return
$~*c up::
pressed :=  (GetKeyState("x", "P") || GetKeyState("v", "P") || GetKeyState("Space", "P") || GetKeyState("Control", "P") || GetKeyState("CapsLock", "P") || GetKeyState("Tab", "P"))
if (!pressed && (A_TimeSincePriorHotkey, "x") > roll && (A_TimeSincePriorHotkey, "v") > roll) || (instr(A_PriorKey, "c") && !pressed){
	if(GetKeyState("Shift", "P") && GetKeyState("LAlt", "P")=0) {
		send {C}
	}
    else if GetKeyState("LAlt", "P")=0 {
		send {c}
	}
	roll := 0
}
if instr(A_PriorKey, "x") {
	if(GetKeyState("Shift", "P") && GetKeyState("LAlt", "P")=0) {
		send {N}
	}
	else if GetKeyState("LAlt", "P")=0 {
		send {n}
	}
	roll := cons
}
if instr(A_PriorKey, "v") {
	send {,}
	roll := cons
}
pressed := 0 
return 

+x:: return
x:: return
$~*x up::
pressed :=  (GetKeyState("c", "P") || GetKeyState("Space", "P") || GetKeyState("Control", "P") || GetKeyState("CapsLock", "P") || GetKeyState("Tab", "P"))
if (!pressed && (A_TimeSincePriorHotkey, "c") > roll) || (instr(A_PriorKey, "x") && !pressed){
	if(GetKeyState("Shift", "P") && GetKeyState("LAlt", "P")=0) {
		send {X}
	}
    else if GetKeyState("LAlt", "P")=0 {
		send {x}
	}
	roll := 0
}
if instr(A_PriorKey, "c") {
	if(GetKeyState("Shift", "P") && GetKeyState("LAlt", "P")=0) {
		send {M}
	}
	else if GetKeyState("LAlt", "P")=0 {
		send {m}
	}
	roll := cons
}
pressed := 0 
return 

+v:: return
v:: return
$~*v up::
pressed :=  (GetKeyState("Space", "P") || GetKeyState("Control", "P") || GetKeyState("CapsLock", "P") || GetKeyState("Tab", "P"))
if (!pressed && (A_TimeSincePriorHotkey, "c") > roll)  || (instr(A_PriorKey, "v") && !pressed){
	if(GetKeyState("Shift", "P") && GetKeyState("LAlt", "P")=0) {
		send {V}
	}
    else if GetKeyState("LAlt", "P")=0 {
		send {v}
	}
	roll := 0
}
pressed := 0 
return 

+z:: return
z:: return
$~*z up::
pressed :=  (GetKeyState("v", "P") || GetKeyState("Space", "P") || GetKeyState("Control", "P") || GetKeyState("CapsLock", "P") || GetKeyState("Tab", "P"))
if (!pressed && (A_TimeSincePriorHotkey, "v") > roll)  || (instr(A_PriorKey, "z") && !pressed){
	if(GetKeyState("Shift", "P") && GetKeyState("LAlt", "P")=0) {
		send {Z}
	}
    else if GetKeyState("LAlt", "P")=0 {
		send {z}
	}
	roll := 0
}
if instr(A_PriorKey, "v") {
	send {.}
	roll := cons
}
pressed := 0 
return 

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;



Capslock & A:: Send, {[}
Capslock & S:: Send, {]}

Capslock & Q:: Send, {{}
Capslock & W:: Send, {}}

Space & E:: Send, {(}
Space & R:: Send, {)}

Space & Q:: Send, ^/

Space Up:: Send {Space}																				
Space & Capslock Up:: Send, {Backspace}

#if GetKeyState("Space")=0
Capslock::Enter
Tab Up::Send {Tab}								
Tab & 1:: Send, {=}																									
Tab & 2:: Send, {_}
Tab & 3:: Send, {?}
Tab & 4:: Send, {\}																				
Tab & Q:: Send, {>}
Tab & W:: Send, {<}

#If GetKeyState("Shift")=0
Space & W:: Send, {Up}
Space & A:: Send, {Left}										
Space & S:: Send, {Down}
Space & D:: Send, {Right}
Space & Z:: Send, {+}
Space & X:: Send, {-}
Space & C:: Send, {*}
Space & V:: Send, {/}						
Space & Tab:: return
Space & Tab up:: Send, {WheelDown 3}
Space & 1 up:: Send, {WheelUp 3}

#If GetKeyState("Shift")=1
Space & Tab:: Send, {0}
Space & Q:: Send, {7}
Space & W:: Send, {8}
Space & E:: Send, {9}
Space & A:: Send, {4}
Space & S:: Send, {5}
Space & D:: Send, {6}
Space & Z:: Send, {1}
Space & X:: Send, {2}
Space & C:: Send, {3}
Alt & A:: Send, {&}
Alt & S:: Send, {|}
Alt & D:: Send, {^}
Alt & F:: Send,  % "%"

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