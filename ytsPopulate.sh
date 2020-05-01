#!/bin/bash

#if [ $(whoami) != "root" ]; then echo "run as root" && exit; fi

cd /home/load/Desktop/yts.ag_yearly/yts.ag_movies 

while read moviePageLink
do	
		magnetLink=$(wget -O - "$moviePageLink" | tac - | tac - | grep -m 1 -oe "magnet:.*720p.*\">"  | sed -e 's/"\ class=.*//g')
		aria2c --bt-max-peers=0 --file-allocation=none -d . --enable-dht=true --seed-time=0 --bt-stop-timeout=200 --bt-tracker-timeout=200 --max-overall-upload-limit=20K "$magnetLink"
		echo "$moviePageLink" >> /home/load/Desktop/yts.ag_yearly/DownloadedMovies.list
done < /home/load/Desktop/yts.ag_yearly/moviePageLinks.list