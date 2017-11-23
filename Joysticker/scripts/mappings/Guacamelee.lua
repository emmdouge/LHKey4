--
--This script is used with joysticker
--Mapping: directions = arrow keys, 2 buttons mapped to z and x
--
local mappings = Map{name = "Player 1", u = Keys.Up, d = Keys.Down, l = Keys.Left, r = Keys.Right, b0 = Keys.S, b1 = Keys.W, b3 = Keys.A, b2 = Keys.D, b7 = Keys.LShift, b4 = Keys.Q, b5 = Keys.E, b6 = Keys.T, b9 = Keys.Enter, b8 = Keys.Tab}

--Add the mappings
JS.AddMapping(mappings)
