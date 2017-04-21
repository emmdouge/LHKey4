﻿#InstallKeybdHook
SetCapsLockState, AlwaysOff
roll := 50

numP := GetAllKeysPressed("P") ; see function below

MaxIndex := numP.MaxIndex()
;if MaxIndex > 1
if MaxIndex > 2
  roll := 0
return

e:: Send, {}
$~e up::
pressed :=  (GetKeyState("w", "P") ||  GetKeyState("r", "P") || GetKeyState("Space", "P") || GetKeyState("Control", "P"))
if !pressed && (A_TimeSincePriorHotkey, "r") > roll && (A_TimeSincePriorHotkey, "w") > roll
    send {e}
if instr(A_PriorKey, "w")
	send {u}
if instr(A_PriorKey, "r")
	send {o}
pressed := 0 
return 

w:: Send, {}
$~w up::
pressed :=  (GetKeyState("e", "P") || GetKeyState("Space", "P") || GetKeyState("Control", "P"))
if !pressed && (A_TimeSincePriorHotkey, "e") > roll
    send {w}
pressed := 0 
return 

r:: Send, {}
$~r up::
pressed :=  (GetKeyState("e", "P") || GetKeyState("Space", "P") || GetKeyState("Control", "P"))
if !pressed && (A_TimeSincePriorHotkey, "e") > roll
    send {r}
if instr(A_PriorKey, "e")
	send {i}
pressed := 0 
return 

;

s:: Send, {}
$~s up::
pressed :=  (GetKeyState("a", "P") || GetKeyState("Space", "P") || GetKeyState("Control", "P"))
if !pressed && (A_TimeSincePriorHotkey, "a") > roll
    send {s}
if instr(A_PriorKey, "a")
	send {h}
pressed := 0 
return 

a:: Send, {}
$~a up::
pressed :=  (GetKeyState("s", "P") || GetKeyState("Space", "P") || GetKeyState("Control", "P"))
if !pressed && (A_TimeSincePriorHotkey, "s") > roll
    send {a}
if instr(A_PriorKey, "s")
	send {j}
pressed := 0 
return 

d:: Send, {}
$~d up::
pressed :=  (GetKeyState("f", "P") || GetKeyState("Space", "P") || GetKeyState("Control", "P"))
if !pressed && (A_TimeSincePriorHotkey, "f") > roll
    send {d}
if instr(A_PriorKey, "f")
	send {l}
pressed := 0 
return 

f:: Send, {}
$~f up::
pressed :=  (GetKeyState("d", "P") || GetKeyState("Space", "P") || GetKeyState("Control", "P"))
if !pressed && (A_TimeSincePriorHotkey, "d") > roll
    send {f}
if instr(A_PriorKey, "d")
	send {k}
pressed := 0 
return 

c:: Send, {}
$~c up::
pressed :=  (GetKeyState("x", "P") || GetKeyState("Space", "P") || GetKeyState("Control", "P"))
if !pressed && (A_TimeSincePriorHotkey, "v") > roll && (A_TimeSincePriorHotkey, "x")
    send {c}
if instr(A_PriorKey, "x")
	send {n}
pressed := 0 
return 

x:: Send, {}
$~x up::
pressed :=  (GetKeyState("c", "P") || GetKeyState("Space", "P") || GetKeyState("Control", "P"))
if !pressed && (A_TimeSincePriorHotkey, "c") > roll
    send {x}
if instr(A_PriorKey, "c")
	send {m}
if instr(A_PriorKey, "v")
	send {.}
pressed := 0 
return 

v:: Send, {}
$~v up::
pressed :=  (GetKeyState("z", "P") || GetKeyState("Space", "P") || GetKeyState("Control", "P"))
if !pressed && (A_TimeSincePriorHotkey, "z") > roll
    send {v}
if instr(A_PriorKey, "z")
	send {,}
pressed := 0 
return 

z:: Send, {}
$~z up::
pressed :=  (GetKeyState("v", "P") || GetKeyState("Space", "P") || GetKeyState("Control", "P"))
if !pressed && (A_TimeSincePriorHotkey, "v") > roll
    send {z}
if instr(A_PriorKey, "v")
	send {.}
pressed := 0 
return 

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

+e up::
pressed :=  (GetKeyState("w", "P") ||  GetKeyState("r", "P"))
if !pressed && (A_TimeSincePriorHotkey, "r") > roll && (A_TimeSincePriorHotkey, "w") > roll && GetKeyState("Space", "P")=0 && GetKeyState("LAlt", "P")=0
    send {E}
if instr(A_PriorKey, "w")
	send {U}
if instr(A_PriorKey, "r")
	send {O}
pressed := 0 
return 

+w up::
pressed :=  (GetKeyState("e", "P"))
if !pressed && (A_TimeSincePriorHotkey, "e") > roll && GetKeyState("Space", "P")=0 && GetKeyState("LAlt", "P")=0
    send {W}
pressed := 0 
return 

+r up::
pressed :=  (GetKeyState("e", "P"))
if !pressed && (A_TimeSincePriorHotkey, "e") > roll && GetKeyState("Space", "P")=0 && GetKeyState("LAlt", "P")=0
    send {R}
if instr(A_PriorKey, "e")
	send {I}
pressed := 0 
return 

+s up::
pressed :=  (GetKeyState("a", "P"))
if !pressed && (A_TimeSincePriorHotkey, "a") > roll && GetKeyState("Space", "P")=0 && GetKeyState("LAlt", "P")=0
    send {S}
if instr(A_PriorKey, "a")
	send {H}
pressed := 0 
return 

+a up::
pressed :=  (GetKeyState("s", "P"))
if !pressed && (A_TimeSincePriorHotkey, "s") > roll && GetKeyState("Space", "P")=0 && GetKeyState("LAlt", "P")=0
    send {A}
if instr(A_PriorKey, "s")
	send {J}
pressed := 0 
return 

+d up::
pressed :=  (GetKeyState("f", "P"))
if !pressed && (A_TimeSincePriorHotkey, "f") > roll && GetKeyState("Space", "P")=0 && GetKeyState("LAlt", "P")=0
    send {D}
if instr(A_PriorKey, "f")
	send {L}
pressed := 0 
return 

+f up::
pressed :=  (GetKeyState("d", "P"))
if !pressed && (A_TimeSincePriorHotkey, "d") > roll && GetKeyState("Space", "P")=0 && GetKeyState("LAlt", "P")=0
    send {F}
if instr(A_PriorKey, "d")
	send {K}
pressed := 0 
return  

+c up::
pressed :=  (GetKeyState("x", "P"))
if !pressed && (A_TimeSincePriorHotkey, "x") > roll && GetKeyState("Space", "P")=0 && GetKeyState("LAlt", "P")=0
    send {C}
if instr(A_PriorKey, "x")
	send {N}
pressed := 0 
return 

+x up::
pressed :=  (GetKeyState("c", "P"))
if !pressed && (A_TimeSincePriorHotkey, "c") > roll && GetKeyState("Space", "P")=0 && GetKeyState("LAlt", "P")=0
    send {X}
if instr(A_PriorKey, "c")
	send {M}
pressed := 0 
return 

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

Capslock::Enter
LAlt::LAlt   
Tab Up::Send {Tab}

Tab & 1:: Send, {=}
Tab & 2:: Send, {_}
Tab & 3:: Send, {?}
Tab & 4:: Send, {\}

Tab & Q:: Send, {>}
Tab & W:: Send, {<}

Capslock & A:: Send, {[}
Capslock & S:: Send, {]}

Capslock & Q:: Send, {{}
Capslock & W:: Send, {}}

Space Up:: Send {Space}
Space & Capslock:: Send, {Backspace}

Space & W:: Send, {Up}
Space & A:: Send, {Left}
Space & S:: Send, {Down}
Space & D:: Send, {Right}

Space & Z:: Send, {+}
Space & X:: Send, {-}
Space & C:: Send, {*}
Space & V:: Send, {/}

Space & E:: Send, {(}
Space & R:: Send, {)}

Space & Q:: Send, {y}
Space & T:: Send, {p}

#If GetKeyState("Shift")=1
Space & 4:: Send, ^/
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
LAlt & Q:: Send, {!}
LAlt & W:: Send, {@}
LAlt & E:: Send, {#}
LAlt & A:: Send, {&}
LAlt & S:: Send, {|}
LAlt & D:: Send,  % "%"
LAlt & F:: Send, {^}
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


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