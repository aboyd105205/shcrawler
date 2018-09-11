#!/bin/bash

DIR=data

if [[ ! -d "$DIR" ]]; then
	mkdir $DIR
fi

cd "$DIR"

getLinks() {
	wget -O temp1 $1
	rm temp2
	grep "<a.*>.*</a>" temp1 | grep -o "href=\"\S*\"" | grep -o "\".*\"" >> temp2

}

getLinks $1
