# Installation For Joystick

1. Drag xbox360ce to C:\Program Files (x86)<br />\Steam\steamapps\common\StreetFighterV\StreetFighterV\Binaries\Win64<br /><br />
2. Delete Input.ini file in C:\Program Files (x86)\Steam\steamapps\common\StreetFighterV\StreetFighterV\Intermediate\Config\CoalescedSourceConfigs<br /><br />
3. Load it up and set your joystick to player 2<br /><br />

This allows your joystick to bypass getting set as p1 when sf5 loads up<br /><br />
set buttons in lua script to emulate keyboard on joystick (run joysticker to see button names)<br />
set keys on keyboard directly inside the ahk script (run joysticktest.ahk to see button names)<br />
set movement keys using joy2key or any alternative<br />
run the joystick version of the ahk script and joysticker<br /><br />

when setting keyboard inputs in sf5 the order is:<br /><br />

A: weak punch <br />
B: medium punch <br />
X: medium kick<br />
Y: weak kick<br />
RB: hard kick<br />
LB: hard punch<br /><br />

the rest don't matter as they are not used by the script<br />