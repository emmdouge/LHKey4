#InstallKeybdHook  
#HotkeyModifierTimeout 500
#Include <dual/dual>
dual := new Dual
SetCapsLockState, AlwaysOff
roll := 60



e:: Send, {}
$~e up::
pressed :=  (GetKeyState("w", "P") ||  GetKeyState("r", "P"))
if !pressed && (A_TimeSincePriorHotkey, "r") > roll
    send {e}
if instr(A_PriorKey, "w")
	send {u}
if instr(A_PriorKey, "r")
	send {o}
pressed := 0 
return 

w:: Send, {}
$~w up::
pressed :=  (GetKeyState("e", "P"))
if !pressed && (A_TimeSincePriorHotkey, "e") > roll
    send {w}
pressed := 0 
return 

r:: Send, {}
$~r up::
pressed :=  (GetKeyState("e", "P"))
if !pressed && (A_TimeSincePriorHotkey, "e") > roll
    send {r}
if instr(A_PriorKey, "e")
	send {i}
pressed := 0 
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

releaseAllModifiers() 
{ 
   list = LControl|RControl|LShift|RShift 
   Loop Parse, list, | 
   { 
      if (GetKeyState(A_LoopField)) 
         send {Blind}{%A_LoopField% up}       ; {Blind} is added.
   } 
} 

restoreModifierPhysicalState()
{
	list = LControl|RControl|LShift|RShift
	Loop Parse, list, |
	{
		if (GetKeyState(A_LoopField) != GetKeyState(A_LoopField, "P")) ;if logical and physical state do not match
		{
			if (GetKeyState(A_LoopField, "P")) ;send an event to restore the physical key state
				send {%A_LoopField% down}
			else
				send {%A_LoopField% up}
		}
	}
}