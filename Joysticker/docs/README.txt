Joysticker Readme

IMPORTANT: Your mileage may vary. Please give the program a try and see if it meets your needs. If you like it, please
            consider donating or "Buying" a copy of it at: http://pixelbyte.itch.io/joysticker to encourage continued development. Thanks!

Joysticker Icon modified from an icon provided by Everaldo / Yellowicon (http://www.everaldo.com/)

- Check out the keys.txt file for all the supported keyboard keys
- For examples, check out the "scripts\examples" directory

Note: As of Version 2.12, Joysticker supports running a script from the command line so typing:
    joysticker.exe myscript.lua
    Will attempt to load and run the "myscript.lua" file on startup.

When writing your own Joy to key mapping scripts, the following functions will come in handy:

Available functions in the Joysticker namespace:

[ To call these functions you must precede them by 'JS.' See the "scripts\examples" directory for examples. ]
====================================================================================================================
GetKeyForValue(t, value): Given a table t and a vale, this function returns the key that corresponds to that value
                          in the table if there is one. Otherwise nil is returned

SetupKeys(setup_map, output_file_name): Given a setup Map and an output file, this function will write out a mapping
                                          script for the setup keys given in the setup table. See the map_keys.lua file
                                          in the example_scripts directory.

AddMapping(mapping): Adds the specified key->joystick mapping to Joysticker.

FindMapping(stick_id): Returns the mapping table (or nil) for a given joystick id

SendKey(key, state): Sends either a key down or key up event given the key. Valid states are 1 = key down, 0 = key up

=====================================================================================================================

Callback Functions

You can provide your own implementations of the state_change callbacks and
do whatever you want in response to joystick input
This handler pretty much does the same thing as the default handler in that
it takes the input type and looks for a corresponding key mapping in the mappings table

valid type parameters:
"bx" - x = 0-31

For the analog stick
"u" - joystick up
"d" - joystick down
"l" - joystick l
"r" - joystick r

For the digital pad
"du"  - pad up
"dr"  - pad right
"dd"  - pad down
"dl"  - pad left

--stick_id => integer id for the joystick that this state change is for
--type => event type (see above)
--state => 1 or 0
--
function state_change(stick_id, type, state)
	--TODO: Your code here
end

You can also implement the state_up function if you need it
Note it is Only called when a joystick input changes from '1' to '0'
--
--stick_id => integer id for the joystick that this state change is for
--type => event type (see above)
--
function state_up(stick_id, type)
	--TODO: Your code here
end