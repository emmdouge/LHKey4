--
--This script is used with Joysticker
--Mapping:
--
local mappings = Map{u = Keys.W, d = Keys.S, l = Keys.A, r = Keys.D,
b4 = Keys.LeftMouseBtn, b5 = Keys.RightMouseBtn,
b3 = Keys.E, b2 = Keys.C, b9 = Keys.Esc,
b1 = Keys.SpaceBar}

--Add the mapping to Joysticker
JS.AddMapping(mappings)
