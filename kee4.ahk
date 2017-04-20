#Include <dual/dual>
dual := new Dual
SetCapsLockState, AlwaysOff

w::
    if (GetKeyState("e")=1) {
        SendInput u
    } else {
	SendInput w
    }
    return

if (GetKeyState("e")=0) and  (GetKeyState("w")=1){
} else {
}
return

Capslock::Enter
LAlt::ScrollLock   
Tab Up::Send {Tab}

Tab & 1:: Send, {=}
Tab & 2:: Send, {_}
Tab & 3:: Send, {\}

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