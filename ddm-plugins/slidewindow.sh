#!/bin/bash

# Written by Dieter Plaetinck
# http://dieter.plaetinck.be
# This code is licensed under GPL v3. See http://www.gnu.org/licenses/gpl-3.0.txt

# this is a useful plugin for selection datasets: upon execution new files are added and old ones purged ( ordered alphabetically)
# grepstring is everything (but the space) that comes in front of the filepath/names ( eg 'mplayer <args>')

slidewindow ()
{
	if [ -z "$1" ]
	then
		echo_die "Specify a string to grep on as first argument to slidewindow function"
	fi
	
	GREPSTRING=$1
	GET_NEW=${2:-'10'}
	KEEP_OLD=${3:-'0'}
	SORT=${4:-'sort'}

	echo_debug "GREPSTRING: $GREPSTRING"
	echo_debug "GET_NEW: $GET_NEW"
	echo_debug "KEEPOLD: $KEEP_OLD"
	echo_debug "DATASET_DIR_NAME: $DATASET_DIR_NAME"
	echo_debug "DATASET_REMOTE: $DATASET_REMOTE"
	echo_debug "SORT: $SORT"
	
	history -a #TODO:this doesnt work ? does work when executed from terminal o_O

	currentlist=`ls -1 "$DATASET_LOCAL_FULL"` #not really used except when no stuff in history found
	currentlistsize=`ls -1 "$DATASET_LOCAL_FULL" | wc -l`
	
	usedlist=`grep "$GREPSTRING" ~/.bash_history | grep "$DATASET_LOCAL_BASE" | grep -v '*' | grep -v '?' | grep -v grep | uniq`
	usedlist="${usedlist//$GREPSTRING /}"
	
	echo_debug "usedlist : $usedlist"
	
	if [ -z "$usedlist" ]
	then
		echo_verbose "Could not find any matching entries in your history.  I will only add stuff (maybe), and delete nothing"
		deletelist=''
		keeplist=`ls -1 "$DATASET_LOCAL_FULL"`
		last=''
		if [ "$GET_NEW" -gt $currentlistsize ]
		then
			# we can add some files
			if [ "$currentlistsize" > 1 ]
			then
				todo=$(($GET_NEW - $currentlistsize))
				echo_verbose "Files in dataset: $currentlistsize, wanted new files : $GET_NEW. I will fetch $todo new files."
				last=`echo "$currentlist" | $sort | tail -n 1`
				if [ -n "$last" ] 
				then	
					tmplist=`ls -1 "$REPOSITORY_FULL" | $SORT | grep "$last" -A $GET_NEW`
					if [ $? -gt 0 ]
					then
						echo_die "Could not find last known element ( from dataset ) $last in repository $REPOSITORY_FULL"
					fi
					getlist=`echo "$tmplist" | tail -n +2`
				else
					getlist=`ls -1 "$REPOSITORY_FULL" | $SORT | head -n "$GET_NEW"`
				fi
			else
				getlist=`ls -1 "$REPOSITORY_FULL" | $SORT | head -n "$GET_NEW"`
			fi
		else
			getlist=''
		fi
	
	else
		deletelist=`echo "$usedlist" | head --lines=-$KEEP_OLD`
		keeplist=`  echo "$usedlist" | tail -n $KEEP_OLD`
		
		last=`echo "$usedlist" | tail -n 1 | xargs echo`
		last=`basename "$last"` #*after* this entry the entries start that we want. we know that -z "last" cause we checked $usedlist
		tmplist=`ls -1 "$REPOSITORY_FULL" | $SORT | grep -A $GET_NEW "$last"`
		if [ $? -gt 0 ]
		then
			echo_debug "command: ls -1 $REPOSITORY_FULL | $SORT | grep -A $GET_NEW $last"
			echo_die "Could not find last known element ( from used files ) $last in repository $REPOSITORY_FULL"
		fi
		getlist=`echo "$tmplist" | tail -n +2`
	
	fi
	
	deletefiles "$deletelist"
	keepfiles   "$keeplist"	#NOTE: there might be more files kept actually.. just files that are also in the dir...
	getfiles    "$getlist"

}

return 0

