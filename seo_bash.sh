#!/bin/bash

wget -O - "$1" | tac - | tac - | grep -oe 'title/tt[0-9]\{7\}' | uniq >> sorted.list

while read line; do img_link=$(wget -O - "https://www.imdb.com/$line" | tac - | tac - | grep -m 1 -oe 'https://m.media-amazon.com/images/M.*\.jpg'); wget "$img_link"; done < sorted.list

rm sorted.list
rm *.jpg.+
rm *.jpg.+