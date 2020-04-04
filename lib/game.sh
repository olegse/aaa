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

  while [ 1 ]; do
    RAND=$(( RANDOM % (10**LIMIT) ))    # chop max digits in a number 222; 3 digits 55333 % 1000 = 333 (3 digits)
    test $debug && echo "RAND: $RAND"
    if [ $RAND -ge $MIN_LINE -a $RAND -le $MAX_LINE ]   # confirm range
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
    test "$debug" && arr_d      # print rand_l[] elements if $debug is set
	done

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
  declare OLDIFS=$IFS   # for translation splitting

	rand_line		# generate random line number, set to $RAND

  #
	# Choosing the word
  #

  # Generate RAND_MAX possible answers, one from each line
	IFS=,
	for line in ${rand_l[@]}
	do	
		# Retrieve only translations part
    #sed -n "$line p" $DICT_FILE | sed 's/,\s\+/,/g' | awk '{print $2}'
		translations=( $(sed -n "$line p" $DICT_FILE | sed 's/,\s\+/,/g' | awk '{print $2}' ) )
    # Generate random index in translations[]; index starts from 0
		rand $(( ${#translations[@]} - 1 )) 0
		# Store possible answer in questions[]
		questions+=( ${translations[$RAND]} )
	done


  # Generate random index for the line user will be questioned.
 	rand $(( ${#rand_l[@]} - 1 )) # index in rand_l[] (returned in RAND)
  # random line number
  line=${rand_l[$RAND]}   
  
  # Correct word (answer)
  word=$( awk 'NR=='"$line"' {print $1}' $DICT_FILE )

  # correct index for the answer; will be +1 on select prompt
	TRUE=$((RAND + 1))				

	# Display quest prompt. REPLY is compared with TRUE that is the index
  # of the correct line. Questioned words are stored under the same indexes.
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
  IFS=$OLDIFS
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
