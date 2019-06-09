#!/bin/bash
#

# Sets FLEN to the file length.
#
#  flen <FILE>
#


# Set FLEN variable to the line count within file.Shall we
# pass the file name or examine $dict strictly?
function flen(){			# 'a

	test $# -eq 1 || { echo "error in flen()"; exit 1; }

	FLEN=`wc -l $1 | awk '{print $1}'`
	# DEBUG
	#echo "[DEBUG] FLEN: $FLEN"; exit 5
}


#
#	rand LIMIT [LOW_LIMIT]
#
# Generate number in range of 0 - 32767. RAND is set to the generated number.
# LOW_LIMIT is 0 defaults to 0
#
# 
function rand(){			# 'r
		LIMIT=$1
		LOW_LIMIT=$2
		RAND_LIMIT=${#LIMIT} 		# number of digits in $LIMIT

		test $LOW_LIMIT || LOW_LIMIT=0	# if LOW_LIMIT was not set, set it to 0
		while [ 1 ]
		do
			RAND=$RANDOM
	
			if [ ${#RAND} -gt $RAND_LIMIT ]; then
			# Get only $RAND_LIMIT digits
				RAND=${RAND:((${#RAND}-$RAND_LIMIT))}			# only digits starting from the index of RAND-RAND_LIMIT
			fi
	
			# Remove leading 0-es 
			if [ $RAND_LIMIT -gt 1 ] 
			then 
				RAND=${RAND/+(0)}	
			fi

			if [[ $RAND -ge $LOW_LIMIT && $RAND -le $LIMIT ]]		
			then 
			 	break
			fi
	
		done
}

# Generate four random numbers and store them in the rand_l[] 
#
# Resulting is the $WORD variable with the examined word
#
function rand_line()		# 'r
{

	local i			# declare local i

	# Poplulate rand_l
	for((i=0; $i < $RAND_LINE_MAX; i++))
	do 
		while [ 1 ] 
		do
			rand $FLEN 1			# get a random line
			dup $RAND rand_l[@]			# 'c
			test $duplicate || break
		done

		rand_l+=($RAND)		# append generated number
	done


	# Choosing the word

 	rand $(( ${#rand_l[@]} - 1 )) 		
	word=`sed -n "${rand_l[$RAND]} s/\(.*\S\) \s.*/\1/p" $dict`		# get the word

	TRUE=$((RAND + 1))				# correct index for the answer; will be +1 on select prompt
}


# Display questions
#
# 	questions				array to hold a word in question
# 	translations		array to
#		rand_l					array with generated random lines
# 	rand
#
# Sets $RAND.
function quest()
{

	declare -a {questions,translations,rand_l}			# make names indexed array (-a)
	declare -g rand_line # get four random line numbers; rand_line is a global variable (-g)
	
	rand_line		# generate random line number, set to $RAND
	for line in ${rand_l[@]}		# 
	do	
	
		IFS=,

		# comment and write out the expression
		translations=( `sed --silent " $line s/.* \s\+//p " $dict | sed 's/,\s\+/,/g'` )
		rand $(( ${#translations[@]} - 1 ))
	
		# comment
		questions+=( ${translations[$RAND]} )
	
	done
	
	PS3="Choose translation for the '$word':   "
	select answer in ${questions[@]}
	do
		clear_screen 				
		echo -en "\033[1m"		# bold

		if [ $REPLY -eq $TRUE ]
		then
			echo -en "\033[42m           CORRECT           "	# colors 
		else
			echo -en "\033[41m            WRONG            "	# colors
		fi
		sleep 0.7
		echo -e "\033[0m"
		break
	done
	clear_screen
}


#
# Start game.
#
function play() {

	setterm -cursor off 		# hide cursor 
	
	# maximum examined line number can not go beyond the last line in the file,
	# reset it to file lenght if needed
	flen $dict

	# create a function for example set_rand_line_max
	if [ $FLEN -lt $RAND_LINE_MAX ]		# RAND_LINE is the number of the linese to be examined translation query
	then		
		RAND_LINE_MAX=$FLEN			# set it to the maximum line numbers in the file if less than 4 (default of RAND_LINE_MAX)
	fi

	# DEBUG
	#echo "in play(): "
	#echo " FLEN: $FLEN"
	#echo " RAND_LINE_MAX: $RAND_LINE_MAX"
	#exit

	# clear the screen 
	clear_screen

	for((i=0; $i < $GAME_MAX; i++))
	do
		quest
	done
	setterm -cursor on
	exit
}
