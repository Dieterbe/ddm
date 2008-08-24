#!/bin/bash

# this function is useful for selection datasets : it gets songs from an exaile database based on a rating

get_exaile ()
{
	# need sqlite3
	db=~/.exaile/music.db
	if [ ! -r $db ]
	then
		echo_die "Cannot find exaile database $db"
	fi
	MIN_RATING=${1:-'8'}
	LIMIT=${2:-1000}
	if [ $LIMIT -gt 0 ]
	then
		LIMIT="LIMIT $LIMIT"
	else
		LIMIT=""
	fi
		
	
	query="SELECT paths.name FROM tracks JOIN paths on tracks.path = paths.id\
	       WHERE tracks.user_rating != 0\
	       AND tracks.user_rating != ''\
	       AND tracks.user_rating >= $MIN_RATING\
	       ORDER BY tracks.user_rating DESC $LIMIT"
	       
	echo_debug "Gonna execute : sqlite3 $db $query"
	echo_debug "----"
	wantedfiles=`sqlite3 "$db" "$query"`
	#TODO : list current files. delete what is not in wantedfiles. get new and keep some
	#recreate directory structure !
}

return 0