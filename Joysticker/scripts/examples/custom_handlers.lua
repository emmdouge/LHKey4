--
-- A Simple Joysticker Script
--

--Below is our mapping table which tells Joysticker which keys to press for a corresponding Joystick Input
--Remaps analog dp/down/left/right to the arrow keys, Joystick Button 0 to 'Z', and Joystick Button 3 to 'X'
local mappings = Map{ u = Keys.Up, d = Keys.Down, l = Keys.Left, r = Keys.Right, b0 = Keys.Z, b3 = Keys.X }

JS.AddMapping(mappings)

-------Custom Callbacks:
--state_change() - This hander is called whenever a joystic input changes state from '1' to '0' OR from '0' to '1'
--state_up() - This handler is called only when a joystick input changes from '1' to '0'

--Instead of calling Joysticker.UseDefaultHandlers(mappings)
--You can provide your own implementations of the state_change callbacks and 
--do whatever you want in response to joystick input
--This handler pretty much does the same thing as the default handler in that
--it takes the input type and looks for a corresponding key mapping in the mappings table
--
function state_change(stick_id, type, state)
	local m = JS.FindMapping(stick_id)
	if (m[type] ~= nil) then
	 	print(type .. " =[" .. state .. "]=")
	 	JS.SendKey(m[type], state)
	elseif (state == 1)  then--Only print the message when the input is active
	 	print("Unassigned: ".. type)
	 end
end

--You can also implement the state_up function if you need it
--Note it is Only called when a joystic input changes from '1' to '0'
--
function state_up(stick_id, type)
	print("OFF: " .. type)
end
