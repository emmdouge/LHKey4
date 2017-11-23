--
--This script is used with joysticker
--Mapping: directions = arrow keys, 2 buttons mapped to z and x
--
local mappings = Map{name = "Player 1", u = Keys.Up, d = Keys.Down, l = Keys.Left, r = Keys.Right, b3 = Keys.Z, b0 = Keys.X, b1 = Keys.S, b4 = Keys.A, b6 = Keys.LShift, b7 = Keys.SpaceBar, b5 = Keys.Esc}
local mappings2 = Map{name = "Player 2", u = Keys.H, d = Keys.I, l = Keys.J, r = Keys.K, b0 = Keys.M, b3 = Keys.L, b4 = Keys.N, b1 = Keys.O, b6 = Keys.P, b7 = Keys.Q}

--Add the mappings
JS.AddMapping(mappings)
JS.AddMapping(mappings2)
