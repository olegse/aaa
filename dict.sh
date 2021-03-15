#!/bin/bash

WORK_DIR=~/dict
cd $WORK_DIR
source init.sh
# At this point we source libraries in ./lib/
# Following variables are available 
#  DIR=$HOME/dict		      # working directory
#  DICT_FILE_NAME=cz       # dictionary filename
#  LIBRARY=$DIR/library		# dictionaries stored here
#  DICT_FILE=$LIBRARY/$DICT_FILE_NAME # full path to the dictionary file
#  TMP=$DIR/tmp						# temporary file for sorting
#  INDENT=30								# default identation
#  GAMES_DEF=4             # games count (default=4)
#  RAND_LINE_MAX=4					# number of lines to offer in each game question (default=4)
#  LIB=$DIR/lib/lib.sh			# definitions file (this file)

function usage() {
	echo "Usage: `basename $0 .sh` WORD [TRANSLATION]..."
	echo "Print word translation. Word translations can be specified in comma-separated list."
	echo ""
	echo "Options:"
	echo "  -x [N]                     play N games"
	echo "  -d [FILE]                  set or print current dictionary file"
  echo "  -e                         print script environment"
  echo "  -l                         list available dictionaries"
	echo "  -h                         print usage and exit"
  echo ""
  echo "First option found takes precedence."
	exit 0
}


test "$1" || usage		# print usage and exit if no argument specified

while [ "$1" ]; do
# parse command line parameters
	case "$1" in 
		-h|--help)	usage
	
			;;
	
		-x*)
         option=${1:0:2}   # -x
         GAMES=${1##${1:0:2}}  #  remove first -x; case of -oARG
         if [ -z "$GAMES" ]   # -o [ARG]
         then
           if [[ -z "$2" || $2 =~ ^- ]] # case of single -x
           then
					   GAMES=$GAMES_DEF   # 4
           else
             GAMES=$2         # -o ARG
             shift    # shift option argument
           fi
           echo "GAMES: $GAMES"
         fi
         if ! [[ $GAMES =~ ^[[:digit:]]*$ ]]
         then
           echo "'$GAMES' requires numeric value" 1>&2
           exit
         fi
        
			;;
	
    # Set or if no arguments were given display dictionary file
		-d*)
        
        rewrite_dictionary_file=1
        option=-d
        if [ -z "${1##$option}" ] # -o ARG or -o ''
        then # argument is not part of the option
          if [[ -z "$2" || $2 =~ ^- ]] # and following is an option or nothing
          then                         #+ meaning argument is not present
					  # Only print current dictionary file used
	          # file_used   - report dictionary file
					  echo "Dictionary file in use:  $DICT_FILE_NAME"
					  exit 0
	        else # argument follows the option
						DICT_FILE_NAME=$2     # set new dictionary value
	        fi
        else  # -oARG
          DICT_FILE_NAME=${1##$option} 
        fi
        shift
		  ;;
	
		-*) echo "invalid option: \`$1'" >&2
				echo "Try \``basename $0 .sh` --help' for more information." >&2
		 ;;
	
		*)	#echo "word found"
        word="$1"		# word catched, translation string follows
		 ;;	
	esac

	shift   # be ready to process next element
	if [ "$word" ]   # stop parsing on the word definition
	 then break			 # now the "$*" is the translations that follow ($word was shifted)
	fi
done

# Apply actions depending on the option
case "$option" in
  -d) # change dictionary file name in 
		  # DIR=$HOME/dict
		  # LIBRARY=$DIR/library
		  # DICT_FILE_NAME=en
		  # DICT_FILE=$LIBRARY/$DICT_FILE_NAME
		  # LIB=$DIR/lib/lib.sh   - default variables file
			
			# check for existence of the new dictionary file before rewriting
			if [ ! -e "$LIBRARY/$DICT_FILE_NAME" ]
			then
				echo "Can not find file '$DICT_FILE_NAME' in '$LIBRARY'"
				exit 1
			fi
			  
		  # Edit lib.sh
		  sed -i "/\(DICT_FILE_NAME=\).*/ s//\1$DICT_FILE_NAME/" $LIB
		  exit 0
      # [!] no need to exit here; just allow change and then play or translate with it
  ;;

  -x) # Quest mode. We allow to change dictionary file before.
      echo "Entering to play()"
	    play
  ;;

  *)  # Display or store word translation
		if [ -z "$*" ] # no translations passed; display all the words starting from ^word
		then
			if ! grep "^$word" $DICT_FILE
      then
        echo "Translation for the '$word' was not found. Use"
        echo "'$word' following by it's translation to add."
		  fi
		else

		  # Continue to store translations...
		
		  # Die on duplicate; maybe rewrite translations later?
		  #
	  	if grep -qw "$word" $DICT_FILE
	  	then
		  	echo "\`$word' already exists" >&2
		  	exit 1
		  fi
 	
  	  # handle space indent
	    let "spaces = (($INDENT - ${#word}))"
  	  if [ $spaces -eq 1 ]			
  	  then 			
						
	  	  $((spaces++))	
        # lets say word had length of 29, so only one space will be printed
			  # need to add one more space to be able to distinguish word with translation,
        # and this is why?
	    fi

	    while let "((spaces--))"	# when spaces reaches 0, let returns false
  	  do
	   	  word="$word"' '	# append space each iteration
  	  done
	
	    # translations after space indent
	    word="$word`echo $* | sed 's/\s*,/,/g'`"		# delete any preceding whitespaces before ,
	  
	  
	    # write dictionary file
	    echo "$word" >> $DICT_FILE
	  
	    # sort file to TMP and restore to dictionary	
	    sort $DICT_FILE > $TMP && mv $TMP $DICT_FILE
    fi
  ;;
esac
