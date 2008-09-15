#!/bin/sh

# quick shell script to make our life easier in rhn400 until brisbane and US docs team converts their tool chain 
# to an xml based system. in other words...the goal is to replace this as soon as we can. many dirs are hard coded
# so they need to be changed if someone else needs to run this (mmccune?) but wanted to stick this in svn just in case
# we run into that situation. 
#
# essentially this script will download the latest translated html docs for sat/ref
# and preps them for our svn repository. note the english docs must be done separately
#
# rsync will copy the translated html files from brisbane. i keep the dir around in my home
# dir so only the updated files are rsynched....this drastically improves download times
# over ride your location with the tmp arg option
#
# HISTORY:
# 7/20/2005 added pdf extraction support shughes

usage() {
    echo "Usage: $0 [--help] [--top svn-top] [--tmp tmp stage dir]"
}


# assuming directories where I stick files unless you over ride with arg options; shughes
TOP=$HOME/trunk/rhn-svn #top of svn dir
I18NDIR=$HOME/i18n #where we stick the brisbane raw html/pdf
RELEASE=rhn400 # {rhn370 | rhn400}
TMPDIR=/tmp/rhn-docs

while [ ${#} -ne 0 ]; do
    ARG=$1
    shift
    case "$ARG" in
        --help )
            usage
            exit 0
            ;;
        --top )
            TOP=$1
            shift
            ;;
        --tmp )
            I18NDIR=$1
            shift
            ;;
        * )
            echo "Don't know what to do with $ARG" >&2
            exit 1
            ;;
    esac
done

[ -d "$I18NDIR" ] || {
    echo "directory $I18NDIR does not exist"
    usage
    exit 1
}

HELPDIR=$TOP/eng/docs/guides #svn base dir for help docs

declare -a all_lang
declare -a all_enc

#all languages we support
all_lang=(de es fr it ja ko pt_br zh_cn zh_tw) #rhn400 support

# mapping of language encodings for all_lang arr
all_enc=(ISO-8859-1 ISO-8859-1 ISO-8859-1 ISO-8859-1 EUC-JP EUC-KR ISO-8859-1 GB18030 BIG5);

# guides we are supporting 
all_guides=(satellite reference);

echo "o Cleaning $TPDIR"

rm -rf $TMPDIR
mkdir $TMPDIR
cd $TMPDIR

[ -d "$I18NDIR/html" ] || {
    echo "creating $I18NDIR/html "
    mkdir $I18NDIR/html
}

[ -d "$I18NDIR/pdf" ] || {
    echo "creating $I18NDIR/pdf "
    mkdir $I18NDIR/pdf
}

echo "o rsyncing translated i18n html docs"
# separate dir so we can use archive rsync option...reduces wait time for out of sync docs
rsync -av -e ssh bob.brisbane.redhat.com:/mnt/redhat/docs/eng/rhn/4.0/FINAL-20050811/HTML/ $I18NDIR/html
echo "o copying i18n docs to $TMPDIR"
rsync -av -e ssh bob.brisbane.redhat.com:/mnt/redhat/docs/eng/rhn/4.0/FINAL-20050811/PDF/ $I18NDIR/pdf
echo "o copying i18n pdfs to $TMPDIR"
cp -r $I18NDIR/html $TMPDIR 
cp -r $I18NDIR/pdf $TMPDIR 

e_count=${#all_lang[@]}
g_count=${#all_guides[@]}

#process all supported languages
for (( i = 0; i < $e_count; i++ )) ; do
 for ((g = 0; g < $g_count; g++))  ; do 
  pushd $TMPDIR/html/RHN-${all_guides[$g]}-${all_lang[$i]}
  LIST=`find . -name '*.html'`

  for j in $LIST ; do 
    #add page content directive to jsps
    echo "<%@ page contentType=\"text/html; charset=UTF-8\"%>" | cat - $j > $j.new
    mv $j.new $j;
    #convert all internal links to jsp
    perl -i -pe 's/\.html/\.jsp/' $j
    #force the encoding to UTF-8 if needed
    if [[ "${all_enc[$i]}" != 'UTF-8' ]]; then
      iconv -f ${all_enc[$i]} -t UTF-8 $j -o $j.utf8;
      mv $j.utf8 $j;
      # change charset to UTF-8 inside content
      #perl -i -pe "s/${all_enc[$i]}/UTF-8/i" $j
    fi
  done
  
  #rename all html to jsp files
  echo "o moving ${all_lang[$i]} files to jsp"
  rename .html .jsp $LIST
  popd
 done

  # stage the reference files to svn working dir
  if [[ -d $TMPDIR/html/RHN-reference-${all_lang[$i]} ]]; then
    pushd $TMPDIR/html/RHN-reference-${all_lang[$i]}
    echo "o staging ${all_lang[$i]} reference files to $HELPDIR/reference/$RELEASE/${all_lang[$i]}"
    cp -r * $HELPDIR/reference/$RELEASE/${all_lang[$i]}/
    popd
  fi

  # stage the satellite files to svn working dir
  if [[ -d $TMPDIR/html/RHN-satellite-${all_lang[$i]} ]]; then
    pushd $TMPDIR/html/RHN-satellite-${all_lang[$i]}
    echo "o staging ${all_lang[$i]} satellite files to $HELPDIR/satellite/$RELEASE/${all_lang[$i]}"
    cp -r * $HELPDIR/satellite/$RELEASE/${all_lang[$i]}/
    popd
  fi

  # stage the pdf files to svn working dir and add release number
  cp $TMPDIR/pdf/RHN-satellite-${all_lang[$i]}.pdf $HELPDIR/satellite/$RELEASE/${all_lang[$i]}/RHN-satellite-${RELEASE:(-3)}-${all_lang[$i]}.pdf
  cp $TMPDIR/pdf/RHN-reference-${all_lang[$i]}.pdf $HELPDIR/reference/$RELEASE/${all_lang[$i]}/RHN-reference-${RELEASE:(-3)}-${all_lang[$i]}.pdf
done
