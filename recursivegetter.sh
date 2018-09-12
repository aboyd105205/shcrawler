#!/bin/bash

#set right dir
cd $(dirname ${BASH_SOURCE[0]})

cd data

visitAllLinks() {
	shopt -s globstar # Enable globstar
	for x in **/*.links; do # Whitespace-safe and recursive
		cat "$x" | \
		while read url; do
			../linkgetter.sh $url
		done
	done
}

if [[ "$1" = "--loop" ]]; then
	echo Looping infinitely
	while true; do
		visitAllLinks
	done
fi

visitAllLinks
