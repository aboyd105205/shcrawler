#!/bin/bash

#set right dir
cd $(dirname ${BASH_SOURCE[0]})

cd data

visitAllLinks() {
	cat * | \
	while read url; do
		../linkgetter.sh $url
	done
}

if [[ "$1" = "--loop" ]]; then
	echo Looping infinitely
	while true; do
		visitAllLinks
	done
fi

visitAllLinks
