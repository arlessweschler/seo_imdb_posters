#!/bin/bash
 
rm todaysMovies.list

cd /home/load/Desktop/movies_downloader_dev/yts.ag

wget -O - "https://www.yts.ag" | tac - | tac - | grep -m 4 -o -e "href=\"https://yts.mx/movie/[-a-zA-Z0-9]*\" class=\"browse-movie-link\"" | sed -e 's/href="//g' | sed -e 's/" class.*//g' >> todaysMovies.list

while read moviePageLink
do
	magnetLink=$(wget -O - "$moviePageLink" | tac - | tac - | grep -m 1 -oe "magnet:.*720p.*\">"  | sed -e 's/"\ class=.*//g')
	aria2c --bt-max-peers=0 --file-allocation=none -d . --enable-dht=true --seed-time=0 --bt-stop-timeout=200 --bt-tracker-timeout=200 --max-overall-upload-limit=150K "$magnetLink"
	echo "$moviePageLink" >> moviePages.list
done < todaysMovies.list