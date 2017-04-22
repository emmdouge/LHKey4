#InstallKeybdHook
SetCapsLockState, AlwaysOff
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
SetDefaultMouseSpeed, 0 
; -distance := 63  how far the mouse moves each turn of the timer
multiplier = 1.15     ; - how much farther (exponentially) the mouse moves in
                      ;   a direction the longer you hold that direction down
CFKM = 45             ; - how often to run the timer

SetTimer, CheckForKeyMouse, %CFKM%

return

CheckForKeyMouse:
	if not GetKeyState("Space", "P")
		return
	GetKeyState("K", "P") ? (d*=multiplier) : (d:=1)
	GetKeyState("I", "P") ? (u*=multiplier) : (u:=1)
	GetKeyState("L", "P") ? (r*=multiplier) : (r:=1)
	GetKeyState("J", "P") ? (l*=multiplier) : (l:=1)
	if GetKeyState(".", "P") {
		distance := 700
	}
	else {
		distance := 63
	}
	y := (d-u) * distance
	x := (r-l) * distance
	MouseMove, x, y, , R
return

Space & p::
    if( not GetKeyState("LButton" , "P") )
        Click down
return

Space & p Up::Click up

Space & u:: Send, {MButton}
Space & o:: Send, {Click right}
Space & `;:: Send, {End}
.:: 
if not GetKeyState("Space", "P") {
    send {.}
}
return
$~. up::
pressed :=  (GetKeyState("Space", "P") || GetKeyState("Control", "P") || GetKeyState("CapsLock", "P"))
if (!pressed) {
    send {}
}
return 

i:: 
if not GetKeyState("Space", "P") {
    send {i}
}
return
$~i up::
pressed :=  (GetKeyState("Space", "P") || GetKeyState("Control", "P") || GetKeyState("CapsLock", "P"))
if (!pressed) {
    send {}
}
return 

j::
if not GetKeyState("Space", "P") {
    send {j}
}
return
$~j up::
pressed :=  (GetKeyState("Space", "P") || GetKeyState("Control", "P") || GetKeyState("CapsLock", "P"))
if (!pressed) {
    send {}
}
return 

k:: 
if not GetKeyState("Space", "P") {
    send {k}
}
return
$~k up::
pressed :=  (GetKeyState("Space", "P") || GetKeyState("Control", "P") || GetKeyState("CapsLock", "P"))
if (!pressed) {
    send {}
}
return

l:: 
if not GetKeyState("Space", "P") {
    send {l}
}
return
$~l up::
pressed :=  (GetKeyState("Space", "P") || GetKeyState("Control", "P") || GetKeyState("CapsLock", "P"))
if (!pressed) {
    send {}
}
return

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
cons = 70;
roll := 70
numP := GetAllKeysPressed("P")
MaxIndex := numP.MaxIndex()
#if MaxIndex < 1
  roll := 0
return

e:: Send, {}
$~e up::
pressed :=  (GetKeyState("w", "P") ||  GetKeyState("r", "P") || GetKeyState("Space", "P") || GetKeyState("Control", "P") || GetKeyState("CapsLock", "P"))
if (!pressed && (A_TimeSincePriorHotkey, "r") > roll && (A_TimeSincePriorHotkey, "w") > roll) {
    send {e}
	roll := 0
}
if instr(A_PriorKey, "w") {
	send {u}
	roll := 60
}
if instr(A_PriorKey, "r") {
	send {o}
	roll := 60
}
pressed := 0 
return 

w:: Send, {}
$~w up::
pressed :=  (GetKeyState("e", "P") || GetKeyState("Space", "P") || GetKeyState("Control", "P") || GetKeyState("CapsLock", "P"))
if (!pressed && (A_TimeSincePriorHotkey, "e") > roll) {
    send {w}
	roll := 0
}
pressed := 0 
return 

r:: Send, {}
$~r up::
pressed :=  (GetKeyState("e", "P") || GetKeyState("q", "P") || GetKeyState("Space", "P") || GetKeyState("Control", "P") || GetKeyState("CapsLock", "P"))
if (!pressed && (A_TimeSincePriorHotkey, "e") > roll && (A_TimeSincePriorHotkey, "q") > roll) {
    send {r}
	roll := 0
}
if instr(A_PriorKey, "e") {
	send {i}
	roll := 60
}
if instr(A_PriorKey, "q") {
	send {y}
	roll := 60
}
pressed := 0 
return 

q:: Send, {}
$~q up::
pressed :=  (GetKeyState("r", "P") || GetKeyState("Space", "P") || GetKeyState("Control", "P") || GetKeyState("CapsLock", "P"))
if (!pressed && (A_TimeSincePriorHotkey, "r") > roll) {
    send {q}
	roll := 0
}
if instr(A_PriorKey, "r") {
	send {p}
	roll := 60
}
pressed := 0 
return 

s:: Send, {}
$~s up::
pressed := (GetKeyState("d", "P") || GetKeyState("Space", "P") || GetKeyState("Control", "P") || GetKeyState("CapsLock", "P"))
if (!pressed && (A_TimeSincePriorHotkey, "d") > roll) {
    send {s}
	roll := 0
}
if instr(A_PriorKey, "d") {
	send {j}
	roll := 60
}
pressed := 0 
return 

a:: Send, {}
$~a up::
pressed :=  (GetKeyState("g", "P") || GetKeyState("f", "P") || GetKeyState("Space", "P") || GetKeyState("Control", "P") || GetKeyState("CapsLock", "P"))
if (!pressed && (A_TimeSincePriorHotkey, "s") > roll && (A_TimeSincePriorHotkey, "g") > roll && (A_TimeSincePriorHotkey, "f") > roll) {
    send {a}
	roll := 0
}
if instr(A_PriorKey, "g") {
	send {;}
	roll := 60
}
if instr(A_PriorKey, "f") {
	send {"}
	roll := 60
}
pressed := 0 
return 

d:: Send, {}
$~d up::
pressed :=  (GetKeyState("f", "P") || GetKeyState("Space", "P") || GetKeyState("s", "P") || GetKeyState("Control", "P") || GetKeyState("CapsLock", "P"))
if (!pressed && (A_TimeSincePriorHotkey, "f") > roll) {
    send {d}
	roll := 0
}
if instr(A_PriorKey, "f") {
	send {l}
	roll := 60
}
if instr(A_PriorKey, "s") {
	send {h}
	roll := 60
}
pressed := 0 
return 

f:: Send, {}
$~f up::
pressed :=  (GetKeyState("d", "P") || GetKeyState("a", "P") || GetKeyState("Space", "P") || GetKeyState("Control", "P") || GetKeyState("CapsLock", "P"))
if (!pressed && (A_TimeSincePriorHotkey, "d") > roll && (A_TimeSincePriorHotkey, "a") > roll) {
    send {f}
	roll := 0
}
if instr(A_PriorKey, "d") {
	send {k}
	roll := 60
}
if instr(A_PriorKey, "a") {
	send {'}
	roll := 60
}
pressed := 0 
return 

g:: Send, {}
$~g up::
pressed :=  (GetKeyState("a", "P") || GetKeyState("Space", "P") || GetKeyState("Control", "P") || GetKeyState("CapsLock", "P"))
if (!pressed && (A_TimeSincePriorHotkey, "a") > roll) {
    send {g}
	roll := 0
}
if instr(A_PriorKey, "a") {
	send {:}
	roll := 60
}
pressed := 0 
return 

c:: Send, {}
$~c up::
pressed :=  (GetKeyState("x", "P") || GetKeyState("Space", "P") || GetKeyState("Control", "P") || GetKeyState("CapsLock", "P"))
if (!pressed && (A_TimeSincePriorHotkey, "x") > roll) {
    send {c}
	roll := 0
}
if instr(A_PriorKey, "x") {
	send {n}
	roll := 60
}
pressed := 0 
return 

x:: Send, {}
$~x up::
pressed :=  (GetKeyState("c", "P") || GetKeyState("v", "P") || GetKeyState("Space", "P") || GetKeyState("Control", "P") || GetKeyState("CapsLock", "P"))
if (!pressed && (A_TimeSincePriorHotkey, "c") > roll && (A_TimeSincePriorHotkey, "v") > roll) {
    send {x}
	roll := 0
}
if instr(A_PriorKey, "c") {
	send {m}
	roll := 60
}
if instr(A_PriorKey, "v") {
	send {.}
	roll := 60
}
pressed := 0 
return 

v:: Send, {}
$~v up::
pressed :=  (GetKeyState("z", "P") || GetKeyState("Space", "P") || GetKeyState("Control", "P") || GetKeyState("CapsLock", "P"))
if (!pressed && (A_TimeSincePriorHotkey, "z") > roll) {
    send {v}
	roll := 0
}
if instr(A_PriorKey, "z") {
	send {,}
	roll := 60
}
pressed := 0 
return 

z:: Send, {}
$~z up::
pressed :=  (GetKeyState("v", "P") || GetKeyState("Space", "P") || GetKeyState("Control", "P") || GetKeyState("CapsLock", "P"))
if (!pressed && (A_TimeSincePriorHotkey, "v") > roll) {
    send {z}
	roll := 0
}
if instr(A_PriorKey, "v") {
	send {.}
	roll := 60
}
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
if !pressed && (A_TimeSincePriorHotkey, "e") > roll && (A_TimeSincePriorHotkey, "r") > roll && GetKeyState("Space", "P")=0 && GetKeyState("LAlt", "P")=0
    send {W}
if instr(A_PriorKey, "r")
	send {P}
pressed := 0 
return 

+r up::
pressed :=  (GetKeyState("e", "P") || GetKeyState("q", "P"))
if !pressed && (A_TimeSincePriorHotkey, "e") > roll && (A_TimeSincePriorHotkey, "q") > roll && GetKeyState("Space", "P")=0 && GetKeyState("LAlt", "P")=0
    send {R}
if instr(A_PriorKey, "e")
	send {I}
if instr(A_PriorKey, "q")
	send {Y}
pressed := 0 
return 

+q up::
pressed :=  (GetKeyState("r", "P") || GetKeyState("Space", "P") || GetKeyState("Control", "P"))
if !pressed && (A_TimeSincePriorHotkey, "r") > roll && GetKeyState("Space", "P")=0 && GetKeyState("LAlt", "P")=0
    send {Q}
if instr(A_PriorKey, "r")
	send {P}
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

#If GetKeyState("Shift")=0
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

Space & Q:: Send, ^/
Space & T:: Send, {^}
Space & 4:: Send, {$}

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
Alt & Q:: Send, {!}
Alt & W:: Send, {@}
Alt & E:: Send, {#}
Alt & A:: Send, {&}
Alt & S:: Send, {|}
Alt & D:: Send,  % "%"
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