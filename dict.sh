#!/bin/bash

source init.sh

function usage() {
	echo "Usage: `basename $0 .sh` WORD [TRANSLATION]..."
	echo "Print word translation. Word translations can be specified in comma-separated list."
	echo ""
	echo "Options:"
	echo "  -x [N]                     play N games"
	echo "  -d [FILE]                  set or print current dictionary file"
  echo "                             if word is specified dictionary file is used as temporary,"
  echo "                             otherwise used permanently"
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
         option=-x
         games_count=${1##$option}
         if [ -z "$games_count" ]
         then
           if [[ -z "$2" || $2 =~ ^- ]]
           then
					   games_count=$GAMES_DEF
           else
             games_count=$2
             shift    # shift option argument
           fi
         fi
         if ! [ $games_count =~ ^[[:digit:]]*$ ]
         then
           echo "'$games_count' is a wrong value for the games" 1>&2
         fi
			;;
	
    # Set or display dictionary file
		-d*)
        
        rewrite_dictionary_file=1
        option=-d
        if [ -z "${1##$option}" ]
        then # argument is not part of the option
          if [[ -z "$2" || $2 =~ ^- ]] # and is not following the option
          then 
					  # Only print current dictionary file used
	          # file_used   - report dictionary file
					  echo "Dictionary file in use:  $DICT_FILE"
					  exit 0
	        else # argument follows the option
						DICT_FILE=$2     # set new dictionary value
	        fi
        else
          DICT_FILE=${1##$option} 
        fi
        shift
		  ;;
	
		-*) echo "invalid option: \`$1'" >&2
				echo "Try \``basename $0 .sh` --help' for more information." >&2
		 ;;
	
		*)	word="$1"		# word catched, translation string follows
		
		 ;;	

	esac

	shift   # be ready to process next element
	if [ "$word" ]   # stop parsing on the word definition
	 then break			 # now the "$*" is the translations that follow ($word was shifted)
	fi
done

# Apply actions depending on the option
case "$option" in
  -d)  # change dictionary file name in 
		  # DIR=$HOME/dict
		  # LIBRARY=$DIR/library
		  # DICT_FILE=en
		  # DICT_FILE_PATH=$LIBRARY/$DICT_FILE
		  # LIB=$DIR/lib/lib.sh   - default variables file
			
			  # check for existence of the new dictionary file before rewriting
				if [ ! -e "$LIBRARY/$DICT_FILE" ]
				then
					echo "Can not find file '$DICT_FILE' in '$LIBRARY'"
					exit 1
				fi
			  
			  # Edit lib.sh
			  sed -i "/\(DICT_FILE=\).*/ s//\1$DICT_FILE/" $LIB
			  exit 0
  ;;

  -x) # Quest mode. We allow to change dictionary file before.
	    play
  ;;

  *)  # Display or store word translation
		if [ -z "$*" ] # no translations passed; display all the words starting from ^word
		then
			grep "^$word" $DICT_FILE_PATH
		
		else

		  # Continue to store translations...
		
		  # Die on duplicate; maybe rewrite translations later?
		  #
	  	if grep -qw "$word" $DICT_FILE_PATH
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
	    echo "$word" >> $DICT_FILE_PATH
	  
	    # sort file to TMP and restore to dictionary	
	    sort $DICT_FILE_PATH > $TMP && mv $TMP $DICT_FILE_PATH
    fi
  ;;
esac
