#!/bin/bash
# 
# Learning program.
#
# Dictionary file ($dict) is one that read and examined depends on the options specified.
# Program expects word on input to search dictionary file for. All the lines matching ^word will be displayed.
# Translation comma-separated list can be specified following the word. Word and its translatoins will be learned.
#
# Game mode can be issued using -q/--game option. Optional games count can be specified to control number of games.
#
# Dictionary file can be changed temporary or permanently using -d/--dictionary option. If option argument is ommitted the
# current dictionary file name is displayed. Filename if followed will be used either to search word translation or to be
# set to a default one if word is not specified.
#
# Global Variables:
#
#   OPTARG  - set to the option argument after call to get_arg()
#

source init.sh

function usage() {
	echo "Usage: `basename $0 .sh` WORD [TRANSLATION]..."
	echo "Print word translation. Word translations can be specified in comma-separated list."
	echo ""
	echo "Options:"
	echo "  -q, --game [GAMES]       run in a game mode number of GAMES"
	echo "  -d, --dictionary [FILE]   set or print current dictionary file; if word is specified "
	echo "                            dictionary file is used as temporary otherwise used permanently"
	echo "  -h                        print usage and exit"
	exit 0
}


test "$1" || usage		# print usage and exit if no argument specified

while [ "$1" ]; do
# parse command line parameters
	case "$1" in 
		-h|--help)	usage
	
			;;
	
		-g|--game)
								game=1 
								get_arg GAME_MAX "$1" $2 
			;;
	
		-d|--dictionary)
								get_arg arg "$1" $2

								if [ -n "$arg" ]
								then
									dict=$arg			
									rw=1
								else	# argument was not passed
								#  only print current dictionary file used
									echo "Dictionary file:  $dict"      # see lib.sh for the default value
									exit 0
								fi
		  ;;
	
		-*) echo "invalid option: \`$1'" >&2
				echo "Try \``basename $0 .sh` --help' for more information." >&2
		 ;;
	
		*)	word="$1"		# word catched, translation string follows
		
		 ;;	

	esac

	shift $count			# $word is shifted
	#test  $count -eq 1 || count=1		, why?
	if [ "$word" ]
	 then break			# stop parsing on the word definition
	fi
done

if ! [[ "$word" || $game  ]]  # no word specifie and no game will run
then
	if [ $rw ]			# dictionary file name was specified, dictionary file permanently
	then
		if [ ! -e "$LIBRARY/$dict" ]
		then
			echo "Can not find file '$dict'"
			exit 1
		fi

		# The expression:
		#		consider slash if dict file is a relative path
		#if sed -n "/dict=/ s/\(=[^ \t\/]*\/\?\)\w\+/\1$dict/p" $LIB
		if sed -i "/dict=/ s/\(=[^ \t\/]*\/\?\)\w\+/\1$dict/" $LIB
		then
			echo "Dictionary file is set to: $dict"
			exit 0
		fi
	fi
fi


# Quest mode. We allow to change dictionary file before.
if [ $game ] 
then
	play
fi

if [ -z "$*" ] 
# no translations passed; display all the words starting from ^word
then
	grep "^$word" $dict

else
	# Continue to store translations...
	
	# Die on duplicate
	#
	if grep -qw "$word" $dict
	then
		echo "\`$word' already exists" >&2
		exit 1
	fi
	
	# handle space indent

	let "spaces = (($INDENT - ${#word}))"

	if [ $spaces -eq 1 ]			
	then 			
						
		$((spaces++))	# lets say word had length of 29, so only one space will be printed
									# need to add one more space to be able to distinguish word with translation	fi		
	fi

	while let "((spaces--))"	# when spaces reaches 0, let returns false
	do
	 	word="$word"' '	# append space each iteration
	done
	
	# translations after space indent

	word="$word`echo $* | sed 's/\s*,/,/'`"		# delete any preceding whitespaces before ,
	
	
	# write dictionary file

	echo "$word" >> $dict
	

	# sort file to TMP and restore to dictionary	
	sort $dict > $TMP && mv $TMP $dict
fi
