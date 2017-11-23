--
--This script is used with Joysticker
--Mapping: directions = arrow keys, 2 buttons mapped to enter and c
--
local mappings = Map{u = Keys.W, d = Keys.S, l = Keys.A, r = Keys.D, b0 = Keys.Space, b3 = Keys.Enter}

--Add the mapping to Joysticker
JS.AddMapping(mappings)
