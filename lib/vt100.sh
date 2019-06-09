#!/bin/bash
#
# Cursor manipulation functions.

# Clear the screen and move cursor to the upper left corner.
function clear_screen()
{
	echo -e "\033[2J\033[H"
}
