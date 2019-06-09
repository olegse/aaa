while [ -n "$1" ]
do
	echo "${BASH_ARGV[i++]}"
	shift
done
#argv=("$@")
#for i in "${argv[@]}"
#do
#	echo "$i"
#done
