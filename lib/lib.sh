source arrays.sh
source vt100.sh
source game.sh

shopt -s extglob

### Variables ###
DIR=$HOME/dict		      # working directory
DICT_FILE_NAME=en

LIBRARY=$DIR/library		# dictionaries stored here
DICT_FILE=$LIBRARY/$DICT_FILE_NAME # full path to the dictionary file

TMP=$DIR/tmp						# temporary file for sort
INDENT=30								# default identation
GAMES_DEF=4
RAND_LINE_MAX=4					# number of lines to offer in each game question

LIB=$DIR/lib/lib.sh			# definitions file (this file)
