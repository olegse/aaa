#!/bin/bash

search_dir='./'		# search in current directory by default
ext=*.sh

test -z "$2" || search_dir=$2
# Display functions declared in the file
basename $(grep --files-with-matches "^\s*function\s*$1" ${search_dir}${ext})
