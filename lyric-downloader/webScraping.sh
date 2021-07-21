#!/bin/bash

#web scraping https://www.lyrics.com/

############################################
preSearchHtml="PRE_SEARCH_HTML.txt"
level1Filter="PRE_SEARCH_LEVEL1_FILTER.txt"
level2Filter="PRE_SEARCH_LEVEL2_FILTER.txt"
lyricPageHtml="LYRICS_HTML.txt"
lyricPageFiltered="LYRICS_HTML_FILTERED.txt"
LYRICS_FILE="LYRICS_FILE.txt"
############################################

echo "Welcome To Scrapy!!!"
echo "We make you Sing the correct Lyric XD";
echo "---------------------------------------------------------";
echo " "
echo "Enter the Song Name";
read songName;

# TO REPLACE SPACE BY '%20'
songNameURL=`echo $songName | sed 's/ /%20/g'`;


url="https://www.lyrics.com/lyrics/$songNameURL";

function dump_webpage() {
    echo "Searching For Song \"$songName\" :"
    curl -so $preSearchHtml $url;
    echo "Got Responce!!!"
}

function filter_webpage(){
    # find the line number of the line containing "best-matches"
    startIndex=`cat $preSearchHtml | grep -n "best-matches" | cut -f1 -d:`;

    # At max it has 83 line of content
    endIndex=`echo $startIndex + 83 | bc -l`

    # first Level Filter
    head -n $endIndex $preSearchHtml | tail -n+$startIndex > $level1Filter;

    # second Level Filter

    
    #################################################
    # EVERY MATCHED SONG WILL HAVE "bm-label" CLASS #
    # FIND THAT INDEX AND FILTER THE LAST INDEX AND #
    # STARTING FROM $startIndex GO TO $lastBmLabel  #
    #################################################
    lastBmLabel=`cat $level1Filter | grep -n "bm-label" | cut -f1 -d: | sed 's/ /\n/g' | tail -n 1`

    cat $level1Filter | head -n `echo $lastBmLabel + 5 | bc -l` > $level2Filter
}

function get_related_artists(){
    cat $level2Filter | grep "href=\"/lyric/"  | sed -n 's/.*href="\([^"]*\).*/\1/p' | sed 's/\/lyric/https:\/\/www.lyrics.com\/lyric/g' | uniq > links.txt;
    cat $level2Filter | grep "href=\"artist/" | uniq | sed -n 's/.*">\([^<]*\).*/\1/p' > artist.txt;
}

function ask_for_artist(){
    echo " "
    echo " "
    echo " "
    echo "For the song \"$songName\", Found Artists:"
    cat -b artist.txt;
    echo " "
    echo "Choose the Artist of whome Lyrics to be found";
    read artistNumber;
    
    maxArtistNumber=`wc -l links.txt | awk '{ print $1 }'`;
    re='^[0-9]+$'

    while [ $artistNumber -gt $maxArtistNumber ]
    do
        echo " Enter the valid number: "
        read artistNumber;
    done

    LyricsURL=`head -n $artistNumber links.txt | tail -n+$artistNumber`;
    curl -so $lyricPageHtml $LyricsURL;
}

function filter_lyric_page(){
    startIndex=`cat $lyricPageHtml | grep -n "id=\"lyric-body-text" | cut -f1 -d:`;
    endIndex=`cat $lyricPageHtml | grep -n "pre>" | cut -f1 -d:`
    head -n $endIndex $lyricPageHtml | tail -n+$startIndex > $lyricPageFiltered;
    cat $lyricPageFiltered | sed 's/<[^>]*>//g' > $LYRICS_FILE
}


dump_webpage;
filter_webpage;
get_related_artists;
ask_for_artist;
filter_lyric_page;