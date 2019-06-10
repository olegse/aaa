# Declare three arrays:
#  questions - to store generated questions
declare -a {questions,translations,rand_l}

source arrays.sh
source opt.sh
source vt100.sh
source game.sh

shopt -s extglob

DIR=$HOME/dict		# working directory
LIBRARY=$DIR/library						# dictionaries stored here

dict=$LIBRARY/en # full path to the dictionary file

TMP=$DIR/tmp						# temporary file for sort
INDENT=30								# default identation
GAME_MAX=4
RAND_LINE_MAX=4					# this is the...
LIB=$DIR/lib/lib.sh			# definitions file
