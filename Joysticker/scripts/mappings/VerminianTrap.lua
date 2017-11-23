--
-- A Simple Joysticker Script
--
--Below is our mapping table which tells Joysticker which keys to press for a corresponding Joystick Input
--Remaps analog dp/down/left/right to the arrow keys, Joystick Button 0 to 'Z', and Joystick Button 3 to 'X'
--
-- For a list of supported keys, check out the keys.txt file
--
local mappings = Map{
name = "Player 1",
u = Keys.W, du = Keys.W,
d = Keys.S, dd = Keys.S,
l = Keys.A, dl = Keys.A,
r = Keys.D, dr = Keys.D,
b3 = Keys.Space
}

local mappings2 = Map{
name = "Player 2",
u = Keys.Up, du = Keys.Up,
d = Keys.Down, dd = Keys.Down,
l = Keys.Left, dl = Keys.Left,
r = Keys.Right, dr = Keys.Right,
b3 = Keys.Enter
}

local mappings3 = Map{
name = "Player 3",
u = Keys.I, du = Keys.I,
d = Keys.K, dd = Keys.K,
l = Keys.J, dl = Keys.J,
r = Keys.L, dr = Keys.L,
b3 = Keys.RShift
}

--Add all the joystick mappings to Joysticker
JS.AddMapping(mappings)
JS.AddMapping(mappings2)
JS.AddMapping(mappings3)
