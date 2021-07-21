#!/bin/bash

# echo "Enter the URL";
# read URL;

# echo "Enter the dir name";
# read dir;

if [ $# -lt 2 ]; then
    echo "USAGE $0 <URL> <DIR-NAME>"
    exit 1
else
    URL=$1
    dir=$2
fi

if [ -d "$dir" ]; then
    rm -r $dir
fi

mkdir $dir

preSearchHtml="$dir/PRE_SEARCH_HTML.txt"
imgsURL="$dir/IMAGE_URL.txt"
anchorURL="$dir/ANCHOR_TAGS.txt"

function get_base_url() {
    baseURL=`echo $URL | grep -Eo  "[^/]*//[^/]*"`
    # echo $baseURL;
}

function dump_webpage() {
    echo " "
    echo "Searching For URL \"$URL\" :"
    curl -so $preSearchHtml $URL;
    echo "Got Responce!!!"
}

function select_img_tags() {
    cat $preSearchHtml | grep "<img.*src=\""  | sed -n 's/.*src="\([^"]*\).*/\1/p' | sort | uniq > $imgsURL;
    cat $preSearchHtml | grep "<a.*href=\""  | sed -n 's/.*href="\([^"]*\).*/\1/p' | sort | uniq > $anchorURL;
}

function downloadImgs() {
    mkdir $dir/imgs;
    count=1;
    maxURL=`wc -l $imgsURL | awk '{ print $1 }'`;
    while read p; do
        if echo "$p" | grep "^/"
        then
            # "relative url"
            img_url=$baseURL$p
            echo img_url | grep -i ".[a-z]*$"
            # echo $img_url
        else
            img_url=$p
            # echo "correct url"
        fi
        
        imgExtension=`echo $img_url | grep -oi "\.[a-z]*$"`

        if [ -z "$imgExtension" ]
        then
            filename=file$count.jpeg
        else
            filename=file$count$imgExtension
        fi
        # echo $img_url
        curl -s $img_url > $dir/imgs/$filename;
        echo "> Downloading $count Image out of $maxURL"
        count=`echo $count + 1 | bc -l`
    done < $imgsURL
}

get_base_url;
dump_webpage;
select_img_tags;
downloadImgs;