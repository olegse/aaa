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
# Error codes
ERR_OPT					1
ERR_OPT_ARG			2


count=1		# loops count

#
# Usage: get_arg <variable> <option> <agrument> <0|1>
# Usage: get_arg <variable> $1 $2 ARGUMENT_REQUIRED
#
# Sets ARG to the option argument.
#
function get_arg() {

	variable=$1
	option=$2
	if [ -z "$4" ] 
	then 
		required=$3
	else
		opt_arg=$3
		required=$4
	fi

	if [ -n "$required" ]
	then
		count=2
	fi

	# Handle long option (--opt)
	if [[ $option =~ ^-- ]] 
	then 
		if [ -n "$opt_arg" ]
		then
			if [[ $opt_arg =~ ^- ]] 
			then
				if [ -n "$required" ]
				then
					echo "argument required for the \`$option' option"
					exit $ERR_OPT_ARG
				fi
			fi
			ARG=$opt_arg		# initialize ARG with the following argument
		else
		if [ -n "$required" ]
		then
			echo "argument required for the \`$option' option"
			exit $ERR_OPT_ARG
		fi
	else									
	# Otherwise short option follows. Can in be in twor forms:
	#		-o{ARG} or -o {ARG}

	# -o{ARG}
	# Try to strip option letter
		ARG=${opt/${2:0:2}}		# ARG now is remained argument if initalized
		if [ -n "$ARG" ]       # argument was passed separately or ARGUMENT_REQUIRED flag (-o ARG|ARGUMENT_REQUIRED)
		then
			count=1
		else
			if [ -n "$opt_arg" ]
			then
				if [[ $opt_arg =~ ^- ]] 
				then
					if [ -n "$required" ]
					then
						echo "argument required for the \`$option' option"
						exit $ERR_OPT_ARG
					fi
				fi
				ARG=$opt_arg		# initialize ARG with the following argument
			else
			if [ -n "$required" ]
			then
				echo "argument required for the \`$option' option"
				exit $ERR_OPT_ARG
			fi
		fi
	fi
	eval "$variable=$ARG"	# set VAR to ARG
	count=2		# jump over the argument in the initial loop
}
