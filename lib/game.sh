#!/bin/bash
#
# Serious hacking follows...
#
# Functions:
#
# flen()    : FLEN  
#

# Sets FLEN to the file length.
#
#  flen <FILE>
#


# Set FLEN variable to the line count within file.
function flen(){			# 'b

	test $# -eq 1 || { echo "error in flen()"; exit 1; }

	FLEN=`wc --lines $1 | awk '{print $1}'`
	# DEBUG
	#echo "[DEBUG] FLEN: $FLEN"; exit 5
}


#
#	rand LIMIT [LOW_LIMIT]
#
# Generate number in range of 0 - 32767. RAND is set to the generated number.
# LOW_LIMIT if not specified, defaults to 0
#
# rand $FLEN 1
function rand(){
  LIMIT=${#1}    # here LIMIT is the number of digits to be generated and not overlap

  MAX_LINE=$1      # the highest line number in a file (for readability changed to MAX_LINE)
  MIN_LINE=${2:-1} # the lowest line number in a file (default 1 if not passed)

  # DEBUG
  echo "[DEBUG] in rand()"
  echo "[DEBUG] LIMIT: $LIMIT"
  echo "[DEBUG] MIN_LINE: $MIN_LINE"
  echo "[DEBUG] MAX_LINE: $MAX_LINE"

  while [ 1 ]; do
    RAND=$(( RANDOM % (10**LIMIT) ))
    #echo "RAND: $RAND"
    if [ $RAND -ge $MIN_LINE -a $RAND -le $MAX_LINE ]
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

	# Populate rand_l
  #
  # RAND_LINE_MAX is the lines to offer in a question
	for((i=0; $i < $RAND_LINE_MAX; i++))
	do 
		while [ 1 ] 
		do
			rand $FLEN 1			# get a random line
			dup $RAND rand_l[@]			# 'c
			test $duplicate || break
		done

		rand_l+=($RAND)		# append generated number
    test "$debug" && arr_d
	done


	# Choosing the word

 	rand $(( ${#rand_l[@]} - 1 )) # RAND is returned 
	word=`sed -n "${rand_l[$RAND]} s/\(.*\S\) \s.*/\1/p" $dict`		# get the word

	TRUE=$((RAND + 1))				# correct index for the answer; will be +1 on select prompt
}


#
# Display questions
#
# Steps:
#
# 1. First populate rand_l[] with RAND_LINE_MAX line numbers
# 	questions				array to hold a word in question
# 	translations		array to
#		rand_l					array with generated random lines
# 	rand
#
# Sets $RAND.
function quest()
{

	declare -a {questions,translations,rand_l}			# indexed arrays (-a)
	declare -g rand_line # store random line numbers; global array (-g)
	
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
# DICT_FILE - dictionary file
# GAMES - number of games
function play() {

  set_cursor off    # hide cursor 
	
	# Maximum examined line number can not go beyond the last line in the file,
	# reset it to file lenght if needed. 
	flen $DICT_FILE     #  FLEN is returned

	# Create a function for example set_rand_line_max
  # RAND_LINE_MAX is the number of the lines to be examined/offered by
  # the translation query                                 	

  # adjust RAND_LINE_MAX to not go beyond the last line in a file (RAND_LINE_MAX = 4) 
  $FLEN -lt $RAND_LINE_MAX  && RAND_LINE_MAX=$FLEN			

	# DEBUG
	#echo "in play(): "
	#echo " FLEN: $FLEN"
	#echo " RAND_LINE_MAX: $RAND_LINE_MAX"
	#exit

	# clear the screen 
	clear_screen

  # GAMES was finally set when -x was passed; default is GAMES_DEF
	for((i=0; $i < $GAMES; i++))
	do
		quest
	done
  set_cursor on
	exit
}
