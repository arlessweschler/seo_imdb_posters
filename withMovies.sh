#!/bin/bash

wget -O - "$1" | tac - | tac - | grep -oe 'title/tt[0-9]\{7\}' | uniq >> sorted.list

while read line
do
	movie_name=$(wget -O - "https://www.imdb.com/$line" | grep -oe "<title>.*</title>" | cut -c 8- | sed -e 's/\ - IMDb.*>//g');
	if [ ! -d "$movie_name" ]
	then mkdir "$movie_name";
	fi
	cd "$movie_name";
	img_link=$(wget -O - "https://www.imdb.com/$line" | tac - | tac - | grep -m 1 -oe 'https://m.media-amazon.com/images/M.*\.jpg');
	if [ ! -e "$movie_name.jpg" ]
	then
		wget -O "$movie_name.jpg" "$img_link"
	fi

	youtube_search_URL="https://www.youtube.com/results?search_query=$(echo $movie_name | sed -e 's/\ /+/g')+official+trailer"
	if ( [ ! -e *.mp4 ] && [ ! -e *.mkv ] && [ ! -e *.webm ] )
	then
		youtube-dl -w --cookies ~/cookies.txt --yes-playlist --max-downloads 1 "$youtube_search_URL"
	fi

	if [ -e *.mp4 ]
	then
		mv *.mp4 "$movie_name"_trailer.mp4
	fi

	if [ -e *.mkv ]
	then
		mv *.mkv "$movie_name"_trailer.mkv
	fi

	if [ -e *.webm ]
	then
		mv *.webm "$movie_name"_trailer.webm
	fi

	
			## here goes the main movie download module -- this is in no way ready !! go through it line by line
			## ========================================= ##

	#1337x_search_suffix=$(echo "$movie_name" | sed -e 's/\ /+/g')
	yts_search_string_url="https://yifytorrenthd.net/result?name=$(echo "$movie_name" | sed -e 's/\ /+/g')"
	magnet_link_page=$(wget -O - "$yts_search_string_url" | grep -oe "\"https://yifytorrenthd.net/movie/[0-9]*[-0-9A-Za-z]*\"" | uniq | sed -e "s/\"//g")
	magnet_link=$(wget -O - "$magnet_link_page" | grep -oe "href=\"magnet:\?.*>" | sed -e 's/\"\ rel=\"nofollow\".*//g' | sed -e 's/href=\"//g' | grep -m 1 720p)
	if [ ! -z "$magnet_link" ]
		then 
			if [ ! -d "YTS" ]
			then
				echo "$movie_name    ""$magnet_link" >> ../magnets;
				aria2c --bt-max-peers=0 --file-allocation=none -d . --enable-dht=true --seed-time=0 --bt-stop-timeout=100 --bt-tracker-timeout=100 --max-overall-upload-limit=20K "$magnet_link"
				echo "$movie_name" >> ../downloaded_movies.list;
			fi
	fi

	cd ../
	#echo "$movie_name" >> ../downloaded_movies.list;
done < sorted.list