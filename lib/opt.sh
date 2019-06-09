#!/bin/bash
#
# option parsing function routines
#
# the expected option parsing loop in the main
# script should be:
#
# for option; do
#		case $option in
#			 '-a')	action;;
#		esac
#		shift $count
#		count=1
#
#
# variables:		count		shift step
#
# To do: 
# 		- set ARGUMENT_REGUIRED to be seen globally 
#
# 


count=1		# loops count

#
# Usage: get_arg variable $1 $2 ARGUMENT_REQUIRED
#
# Sets ARG to the option argument.
#
function get_arg() {

	if [[ $2 =~ ^-- ]] 
	# long option found (--opt)
	#
	then ARG=$3				# following argument is the option argument
	else									
	# try to strip a short option 
		ARG=${2/${2:0:2}}		# argument is passed as a part of the short option (-oARG)
		if [ ! $ARG ]       # argument was passed separately or ARGUMENT_REQUIRED flag (-o ARG|ARGUMENT_REQUIRED)
		then
			ARG=$3	
		fi
	fi

	#
	# Final check 
	#

	if [[ $ARG =~ ^- || $ARG == "ARGUMENT_REQUIRED" ]]		
	# if ARG was not set or set to the following option (has dash at the beginning), or set to the ARGUMENT_REQUIRED
	# flag
	then
		if [ $ARG == "$ARGUMENT_REQUIRED" ]		# fail if argument was required
		then
				echo "argument required for the \`$2' option"
				exit 1
    else
        unset ARG		# ARG was set to the following option, thus should be unset
		fi
	elif [[ -n "$ARG" ]]		# it was set; otherwise - ignore
	then
		eval "$1=$ARG"	# set VAR to ARG
		count=2		# jump over the argument in the initial loop
	fi
}
