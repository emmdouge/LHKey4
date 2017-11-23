--
--This script is used with joysticker
--Mapping: directions = arrow keys, 2 buttons mapped to z and x
--
local mappings = Map{u = Keys.Up, d = Keys.Down, l = Keys.Left, r = Keys.Right, b0 = Keys.Z, b3 = Keys.X, b1 = Keys.C, b4 = Keys.V}

--Add the mappings
JS.AddMapping(mappings)
