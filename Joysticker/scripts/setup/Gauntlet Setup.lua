--
-- This script takes joystick input, maps it to the keys given, and writes it out as a valid Joysticker script
--

--If you already know some of the Joystick input/key mappings you want setup, you can go ahead and do that in 
--this table, otherwise it must be an empty table
--ex: you could do this if you already know you want to map the analog directions to the arrow keys
--local mappings = { u = Keys.Up, d = Keys.Down, l = Keys.Left, r = Keys.Right}
--Or you must at least do:
local mappings = Map{}

--Put a description of the inputs you want to setup here along with the actual keyboard key to press when that joystick
--input is triggered
local setup = Map {l = Keys.Left, r = Keys.Right, u = Keys.Up, d = Keys.Down,
["Attack1/Cast"] = Keys.S, ["Attack"] = Keys.A, ["Special"] = Keys.D, ["Grab"] = Keys.W, ["Dodge"] = Keys.LShift,
["Swap Dimension"] = Keys.Q, ["Pollo Power"] = Keys.E, ["Bubble"] = Keys.T, ["Map"] = Keys.Tab, 
["Pause"] = Keys.Esc,name="Player 1"}

JS.AddMapping(mappings)

--Now call the setup function with the setup table and the output filename as the arguments
--When the setup completes, the output file will contain a valid script that can be used to
--configure the joystick to the mappings chosen in the setup process
--This makes it easier when configuring a joystick for which you do not know which button is which
--i.e. which button is b0, b1, and so on
JS.SetupKeys(setup, "Gauntlet.lua")
