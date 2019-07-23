# Declare three arrays:
#  questions - to store generated questions
declare -a {questions,translations,rand_l}

source arrays.sh
source vt100.sh
source game.sh

shopt -s extglob

### Variables ###
DIR=$HOME/dict		      # working directory
DICT_FILE=en

LIBRARY=$DIR/library		# dictionaries stored here
DICT_FILE_PATH=$LIBRARY/$DICT_FILE # full path to the dictionary file

TMP=$DIR/tmp						# temporary file for sort
INDENT=30								# default identation
GAMES_DEF=4
RAND_LINE_MAX=4					# this is the...

LIB=$DIR/lib/lib.sh			# definitions file (this file)
