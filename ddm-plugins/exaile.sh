#!/bin/bash

# Written by Dieter Plaetinck
# http://dieter.plaetinck.be
# This code is licensed under GPL v3. See http://www.gnu.org/licenses/gpl-3.0.txt


# this plugin is useful for selection datasets : it gets songs from an exaile database based on a rating


# exaile_strip
# You can use this variable to strip paths from the filenames of the songs in your exaile database.
# This is useful for example when you use a symlink that points to the actual location ( $REPOSITORY_FULL ) in your exaile config.
# You can override this in your ddmrc or per-dataset .ddm (so don't edit it here)
# syntax : exaile_strip="PATH1|PATH2" (will be feeded to sed)
exaile_strip=""

# exaile_db
# this variable constitutes the path to your exaile database.
# You can override this in your ddmrc or per-dataset .ddm (so don't edit it here)
exaile_db=~/.exaile/music.db


get_exaile ()
{
	if [ ! -r $exaile_db ]
	then
		echo_die "Cannot find exaile database $exaile_db"
	fi
	MIN_RATING=${1:-'8'}
	LIMIT=${2:-1000}
	if [ $LIMIT -gt 0 ]
	then
		LIMIT="LIMIT $LIMIT"
	else
		LIMIT=""
	fi
	
	if ! which sqlite3 &> /dev/null
	then
		echo_die "sqlite3 command-line client must be installed to query the exaile database"
	fi		
	
	query="SELECT paths.name FROM tracks JOIN paths on tracks.path = paths.id\
	       WHERE tracks.user_rating != 0\
	       AND tracks.user_rating != ''\
	       AND tracks.user_rating >= $MIN_RATING\
	       ORDER BY tracks.user_rating DESC $LIMIT"
	       
	echo_debug "Gonna execute : sqlite3 $exaile_db $query"
	echo_debug "----"
	wantedfiles=`sqlite3 "$exaile_db" "$query"`
	if [ $? -gt 0 ]
	then
		echo_die "Something went wrong while querying... bailing out"
	fi
	
	#TODO : list current files. delete what is not in wantedfiles. get new and keep some
	#recreate directory structure !
	# this can probably be done by specifying all wanted files at once and rsync with --delete
#	IFS_OLD=$IFS
#	IFS=$'\n'
#	for song in $wantedfiles
#	do
#		song=`echo $song | $strip`
	
#		echo "RSINC $REPOSITORY_FULL/$song -> $DATASET_LOCAL/"
	#getfiles
	#deletefiles 
#	done
#	IFS=$IFS_OLD
	echo "FIRST"
	echo "$wantedfiles"
	if [ -n "$exaile_strip" ]
	then
		strip="$REPOSITORY_FULL|$exaile_strip"
	else
		strip="$REPOSITORY_FULL"
	fi
	echo_debug "Stripping away paths : $strip"
	wantedfiles=`sed -e 's#'$strip'##g' <<< "$wantedfiles"`
	echo "SECOND"
	echo "$wantedfiles"
	# | sed 's#/$##'`	        
}

return 0
