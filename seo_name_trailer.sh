#!/bin/bash

wget -O - "$1" | tac - | tac - | grep -oe 'title/tt[0-9]\{7\}' | uniq >> sorted.list

while read line
do
	movie_name=$(wget -O - "https://www.imdb.com/$line" | grep -oe "<title>.*</title>" | cut -c 8- | sed -e 's/\ - IMDb.*>//g');
	if[ [ ! -z "$movie_name" ] && [ ! -d "$movie_name" ] ]
	then
		mkdir "$movie_name";
	else
		echo "error extracting movie name";
		exit;
	fi
	cd "$movie_name";
	img_link=$(wget -O - "https://www.imdb.com/$line" | tac - | tac - | grep -m 1 -oe 'https://m.media-amazon.com/images/M.*\.jpg');
	wget -o "$movie_name.jpg" "$img_link"
	# if I can manage to make youtube-dl download the first video from the search page in a consistent manner, the next lines can be replaced with a neat one liner
	## youtube-dl --yes-playlist <downloadOnlyOneFile>
	video_id=$(wget -O - "https://www.youtube.com/results?search_query=$line official trailer" | grep -m 1 -oe "watch?v=[a-zA-Z0-9]\{11\}")
	youtube-dl "https://www.youtube.com/$video_id"

			## here goes the main movie download module -- this is in no way ready !! go through it line by line
			## ========================================= ##

			1337x_search_suffix=$(echo "$movie_name" | sed -e 's/\ /+/g')
			1337x_search_string_url="https://www.1337x.to/search/$1337x_search_suffix+yts+720p/1"
			movie_magnet_link=$(wget -O - "$1337x_search_string_url" | grep #)
			if [ -z "$movie_magnet_link" ]
			then
				echo "no such movie from yts.ag in 720p"
				movie_magnet_link=$(wget -O - "https://www.1337x.to/search/$1337x_search_suffix")
			fi
			aria2c "$movie_magnet link"


			## ========================================= ##

	cd ../
	echo "$movie_name" >> downloaded_movies.list;
done < sorted.list


if [ -z "$movie_name" ]
then
	echo "error encountered while extracting movie name";
	exit;
fi

if [ -d "$movie_name" ]
then
	cd "$movie_name"
	## continue download link