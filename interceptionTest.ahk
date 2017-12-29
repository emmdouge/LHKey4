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
;Process, Priority, , A
SetBatchLines, -1                 ;makes the script run at max speed
SetKeyDelay , -1, -1              ;faster response (might be better with -1, 0)
ListLines, Off
SendMode Event
SetCapsLockState, AlwaysOff

interception := "Interception\samples\InterceptionDLL2\InterceptionDLL2\x64\Debug\Interception.dll"
hModule := DllCall("LoadLibrary", "Str", interception)  ; "ptr" optional for 32-bit.
if !hModule  ; "If the function fails, the return value is NULL" (0)
{
	MsgBox, 48, API - Error, Failed to load API.dll; error %A_LastError%.`nProgram will exit.
	ExitApp
}
context := DllCall("interception\interception_create_context", "Ptr*")
Tooltip, c:%context%
stroke := ""
VarSetCapacity(stroke, 8)
DllCall("interception\interception_set_KBfilter", "Ptr*", context, "Int", 3)

w::
random, r, 0, 9
device := DllCall("interception\interception_wait", "Ptr*", context)
if(device > 0) {	
    Tooltip, r: %r% d: %device% c:%context% s:%stroke%
    stroke := DllCall("interception\interception_receive", "Ptr", context*, "Int", device, "Ptr*", stroke)
}
send {1}
return
