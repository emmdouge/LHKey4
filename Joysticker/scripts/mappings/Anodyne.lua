--
--This script is used with Joysticker
--Mapping: directions = arrow keys, 2 buttons mapped to enter and c
--
local mappings = Map{u = Keys.Up, d = Keys.Down, l = Keys.Left, r = Keys.Right, b0 = Keys.Enter, b3 = Keys.C}

--Add the mapping to Joysticker
JS.AddMapping(mappings)
