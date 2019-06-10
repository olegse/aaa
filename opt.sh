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
ERR_OPT=1
ERR_OPT_ARG=2

#
# Usage: get_arg <variable> <option> <agrument> <0|1>
# Usage: get_arg <variable> $1 $2 ARGUMENT_REQUIRED
#
# Sets ARG to the option argument.
#
function get_arg() {
	echo "in get_arg()"
	echo "\$@: $@"
	for element in ${@} 
	do	
		echo "element: |$element|"
	done
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

	#
	# Handle long option (--opt)
	#
	if [[ $option =~ ^-- ]] 
	then 
		if [ -n "$opt_arg" ]			# option argument follows
		then
			if [[ $opt_arg =~ ^- ]] # there is an option not an argument, 
			then										# check if argument was required
				if [ -n "$required" ]	# <- 
				then
					echo "argument required for the \`$option' option"
					exit $ERR_OPT_ARG
				fi
			fi
			ARG=$opt_arg		# initialize ARG with the option argument

		else
		# no option argument followed, check if it was required	
			if [ -n "$required" ]	# <-
			then
				echo "argument required for the \`$option' option"
				exit $ERR_OPT_ARG
			fi
		fi
	#fi
	else									
		# Otherwise short option follows. Can in be in two 
		#	forms:	-o{ARG} or -o {ARG}
		#
		# If in form of -o{ARG}, try to strip option letter. ARG now is remained
		# argument if initalized.
		ARG=${option/${2:0:2}}	
		
		if [ -n "$ARG" ] 
		then
			count=1		# option argument is part of the option, reset count
		
		else
		# Otherwise assume  -o {ARG}
			if [ -n "$opt_arg" ]		# check if option argument was passed
			then
				if [[ $opt_arg =~ ^- ]] 	# option follows
				then
					if [ -n "$required" ]		# fail if argument was required
					then
						echo "argument required for the \`$option' option"
						exit $ERR_OPT_ARG
					fi
				fi
				ARG=$opt_arg		# initialize ARG with the following option argument
			else
			#
			# No option argument follows
				if [ -n "$required" ]
				then
					echo "argument required for the \`$option' option"
					exit $ERR_OPT_ARG
				fi
			fi
		fi
	fi
	test -n "$ARG" && eval "$variable=$ARG"	# set VAR to ARG
	echo "ARG: $ARG"
}
