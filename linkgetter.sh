#!/bin/bash

# put us in the same directory as this script
cd $(dirname ${BASH_SOURCE[0]})

# where we store all our gathered information
outdir=data

if [[ ! -d "$outdir" ]]; then
	mkdir $outdir
fi

cd "$outdir"

debug=false

siteName() {
	sitename=$1
	# remove trailing forward slashes, replace /. with /_, remove http(s)://, remove www., remove trailing #
	echo $sitename | sed -E -e "s/\/$//" -e "s/\/\./\/_/g" -e "s/^https?:\/\///" -e "s/^www\.//" -e "s/#$//"
}

# site re-visiting prevention
list=visited.sites

siteVisited() {
	if grep -q $1 "$list"; then
		echo true
	fi
}

getLinks() {
	for i in $@; do

		if [[ $(siteVisited $i) = true ]]; then
			continue
		else
			echo $(siteName $i) >> $list
		fi

		wget -qO htmldump.tmp $i && echo "Downloaded $i"

		# make sure we arent appending to an old file
		rm -f urlfilter.tmp
		# for getting the site/page names later
		echo $i >> urlfilter.tmp
		# extract link URLs
		grep -o "<a.*>.*</a>" htmldump.tmp | grep -o "href=\"\S*\"" | grep -o "\".*\"" >> urlfilter.tmp
		
		if [ $debug = true ]; then
			cp urlfilter.tmp unfilteredurls.tmp
		fi
		
		# remove quotes
		sed -i -E "s/^\"|\"$//g" urlfilter.tmp
		# remove http(s)://
		sed -i -E "s/https?:\/\///g" urlfilter.tmp
		# remove www.
		sed -i "s/^www.//g" urlfilter.tmp
		# replace leading periods
		sed -i "s/\/\./\/_/g" urlfilter.tmp
		# remove ending forward slashes
		sed -i "s/\/$//g" urlfilter.tmp
		# remove trailing #s
		sed -i "s/#$//g" urlfilter.tmp

		page=$(head -n 1 urlfilter.tmp)
		sed -i "1 s/\/.*//" urlfilter.tmp
		site=$(head -n 1 urlfilter.tmp)
		# correct website-local addresses
		sed -i "s,^\/,""$site""\/,g" urlfilter.tmp
		# correct same-page # id links
		sed -i 's,^#,'"$page"'#,g' urlfilter.tmp

		# mimic the site directories
		# but also make sure we dont create a needless directory
		# this basically checks if there is no forward slash (/) between the beginning and end of the line
		# if there isnt we obviously dont need to make a new directory, because $DIR is the root directory
		dir=$(dirname $page)
		if [[ -n $dir ]] && [[ $dir != "." ]] && [[ ! -d $dir ]]; then
			mkdir -p $dir && echo "Made directory $dir"
		fi
		
		cp urlfilter.tmp $page.links && echo "Recorded $page.links"
	done
	
	#get rid of temp data
	if [ $debug = false ]; then
		find ./ -name ".tmp" -exec rm -f
	fi
}

if [[ $1 = "--sitename" ]]; then
	echo $(siteName $2)
	exit 0
fi

if [[ $1 = "--sitevisited" ]]; then
	echo $(siteVisited $2)
	exit 0
fi

getLinks $@
