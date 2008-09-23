#!/bin/bash

# Written by Dieter Plaetinck
# http://dieter.plaetinck.be
# This code is licensed under GPL v3. See http://www.gnu.org/licenses/gpl-3.0.txt

# this is a useful plugin for selection datasets: upon execution new files are added and old ones purged ( ordered alphabetically)

# grepstring is a regex that will be used by egrep to find matching history entries.  You do not need to specify the filenames yourself.
# be precise to have good, valid hits on the history ( eg 'mplayer.*series\/Lost')
# subpath (optional) denotes a subpath inside the dataset/repository.  This can be used if you're working on a specific path inside a repo/dataset
# (as is usually the case, eg a specific series inside a video repository).  This is used for rsyncing, not for grepping.  Use '' to omit. (and work in the root of the dataset/repository)
# Note that the subpath does not need to exist (yet) in the dataset.  It must exist in the repository however.

slidewindow ()
{
	# $1 subpath
	# $2 grepstring
	# $3 get-new: how many 'spare' files (in advance) you want (optional.  defaults to 10)
	# $4 keep-old: how many 'consumed' files do you want to keep? (most recently consumed are kept) (optional.  defaults to 0)
	# $5 sort:  what sort command do you want to use to sort the files? (optional.  defaults to 'sort')

	if [ -z "$1" ]
	then
		echo_die 'Specify a subpath to act on' 100
	fi
	if [ -z "$2" ]
	then
		echo_die "Specify a string to grep on as first argument to slidewindow function" 100
	fi

	SUBPATH=$1
	GREPSTRING=$2
	GET_NEW=${3:-'10'}
	KEEP_OLD=${4:-'0'}
	SORT=${5:-'sort'}

	echo_debug "SUBPATH: $SUBPATH"
	echo_debug "GREPSTRING: $GREPSTRING"
	echo_debug "GET_NEW: $GET_NEW"
	echo_debug "KEEPOLD: $KEEP_OLD"
	echo_debug "SORT: $SORT"
	
	history -a #TODO:this doesnt work ? does work when executed from terminal o_O

	if [ ! -d "$REPOSITORY_FULL/$SUBPATH" ]
	then
		echo_die "Invalid subpath.  $REPOSITORY_FULL/$SUBPATH does not exist" 100
	fi
	
	currentlist_base=`ls -1 "$DATASET_LOCAL_FULL/$SUBPATH" 2>/dev/null` #not really used except when no stuff in history found
	currentlistsize=` ls -1 "$DATASET_LOCAL_FULL/$SUBPATH" 2>/dev/null | wc -l`
	
	usedlist_full=`grep "$GREPSTRING" ~/.bash_history | grep -v '*' | grep -v '?' | grep -v grep | uniq | awk '{print $NF }'` #note: the _full aspect can be relative path, absolute path, ... !
	usedlistsize=` grep "$GREPSTRING" ~/.bash_history | grep -v '*' | grep -v '?' | grep -v grep | uniq | wc -l`
	usedlist_base=''
	OLDIFS=$IFS
	IFS=$'\n'
	for used in `echo "$usedlist_full"`; do [ -z "$usedlist_base" ] && usedlist_base="`basename $used`" || usedlist_base="$usedlist_base"$'\n'"`basename $used`"; done
	IFS=$OLDIFS
	echo_debug "usedlist_full: $usedlist_full"
	echo_debug "currentlist_base: $currentlist_base"
	echo_debug "currentlistsize: $currentlistsize"
	echo_debug "usedlist_base : $usedlist_base"
	echo_debug "usedlistsize: $usedlistsize"
	if [ -z "$usedlist_base" ]
	then
		echo_debug "Branch: no used files"
		echo_verbose "Could not find any matching entries in your history.  I will only add stuff (maybe), and delete nothing"
		deletelist_base=''
		keeplist_base=`ls -1 "$DATASET_LOCAL_FULL/$SUBPATH" 2>/dev/null`
		last=''
		if [ "$GET_NEW" -gt $currentlistsize ]
		then
			echo_debug "Branch: $GET_NEW -gt  $currentlistsize"
			# we can add some files because no files are consumed and we want more files then we currently have
			if [ "$currentlistsize" -gt 1 ]
			then
				echo_debug "Branch: $currentlistsize -gt 1"
				todo=$(($GET_NEW - $currentlistsize))
				echo_verbose "Files in dataset: $currentlistsize, wanted new files : $GET_NEW. I will fetch $todo new files (if available)."
				last=`echo "$currentlist_base" | $sort | tail -n 1`
				if [ -n "$last" ] 
				then
					# we know what file was consumed last.  get the $GET_NEW ones after it
					tmplist_base=`ls -1 "$REPOSITORY_FULL/$SUBPATH" | $SORT | grep "$last" -A $GET_NEW`
					if [ $? -gt 0 ]
					then
						echo_die "Could not find last known element ( from dataset ) $last in repository $REPOSITORY_FULL" 100
					fi
					getlist_base=`echo "$tmplist_base" | tail -n +2`
				else
					# we don't know which file was consumed last.  get/sync the $GET_NEW first
					getlist_base=`ls -1 "$REPOSITORY_FULL/$SUBPATH" | $SORT | head -n "$GET_NEW"`
				fi
			else
				echo_debug "Branch: $currentlistsize not -gt 1"
				# also get the $GET_NEW first
				getlist_base=`ls -1 "$REPOSITORY_FULL/$SUBPATH" | $SORT | head -n "$GET_NEW"`
			fi
		else
			echo_debug "Branch: $GET_NEW not -gt  $currentlistsize"
			getlist_base=''
		fi
	else
		echo_debug "Branch: used files"
		deletelist_base=`echo "$usedlist_base" | head --lines=-$KEEP_OLD`
		keeplist_base=`  echo "$usedlist_base" | tail -n $KEEP_OLD`
		last=`echo "$usedlist_base" | tail -n 1 | xargs echo`
		last=`basename "$last"` #*after* this entry the entries start that we want. we know that -z "last" cause we checked $usedlist_base
		tmplist_base=`ls -1 "$REPOSITORY_FULL/$SUBPATH" | $SORT | grep -A $GET_NEW "$last"`
		if [ $? -gt 0 ]
		then
			echo_debug "command: ls -1 $REPOSITORY_FULL/$SUBPATH | $SORT | grep -A $GET_NEW $last"
			echo_die "Could not find last known element ( from used files ) $last in repository[/subpath] $REPOSITORY_FULL/$SUBPATH" 100
		fi
		getlist_base=`echo "$tmplist_base" | tail -n +2`
	
	fi
	echo_debug "last: $last"
	echo_debug "getlist_base: $getlist_base"
	echo_debug "deletelist_base: $deletelist_base"
	echo_debug "keeplist_base: $keeplist_base"
	deletelist=
	keeplist=
	getlist=
	OLDIFS=$IFS
	IFS=$'\n'
	for delete in `echo "$deletelist_base"`; do [ -z "$deletelist" ] && deletelist="${deletelist}$SUBPATH/$delete" || deletelist="$deletelist"$'\n'"$SUBPATH/$delete"; done
	for keep   in `echo   "$keeplist_base"`; do [ -z   "$keeplist" ] &&   keeplist="${keeplist}$SUBPATH/$keep"     ||   keeplist="$keeplist"$'\n'"$SUBPATH/$keep"; done
	for get    in `echo    "$getlist_base"`; do [ -z    "$getlist" ] &&    getlist="${getlist}$SUBPATH/$get"       ||    getlist="$getlist"$'\n'"$SUBPATH/$get"; done
	IFS=$OLDIFS
	if [ -n "$SUBPATH" -a ! -d "$DATASET_LOCAL_FULL/$SUBPATH" ]
	then
		wrap_mkdir "$DATASET_LOCAL_FULL/$SUBPATH"
	fi
	deletefiles "$deletelist"
	keepfiles   "$keeplist"	#NOTE: there might be more files kept actually.. just files that are also in the dir...
	getfiles    "$getlist"

}

return 0

