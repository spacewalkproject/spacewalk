#!/bin/sh
# Disclaimer and Terms: You may use these scripts for commercial or
# non-commercial use at your own risk, as long as you retain the
# copyright statements in the source code. These scripts are provided
# "AS IS" with no warranty whatsoever and are FREE for as long as you
# want to use them. You can edit and adapt them to your requirements
# without seeking permission from me. I only ask that you retain the
# credits where they are due. 
#
# Author: Vishal Goenka <vgoenka@hotmail.com>
# 
# Source Lines of Code and Comment Count 
# Version 1.0
#
# Counts lines of code, comments and prints their ratio. See Usage
# below for more information

usage()
{
cat <<EOF
-----------------------------------------------------------------------------
Prints the code/comment ratio for specified files. The output can be
changed to extract the code/comment itself by specifying options as indicated
below:

Usage: `basename $0` [-nopretty]
	     [-findopt "<options for find>"]
	     [-raw [-dest_dir <destination dir>]]
	     [-code|-comment|-copyright] 
	     [-summary]
	     [<files>|<directories>]
options:
    -nopretty  : ignore pretty code constructs, such as braces/brackets on 
		 separate lines, or empty lines in comment blocks. This option
		 can be combined with the -raw to see what lines are being 
		 ignored.

    -findopt   : options that will be passed directly to the find command.
		 This can be used to specify accurately the types of files
		 that `basename $0` will be run on. Since the version of 'find'
		 is likely to be different on various OS environments, this 
		 option allows you to take advantage of the features available
		 on the current OS, without trying to limit to a lowest common
		 denominator. The entire option must be quoted as in:
		    -findopt "-name *.java -o -name *.c -maxdepth 2"

    -raw       : print the raw code/comment/copyright instead of the line count
		 This shows just what is being counted and what is being 
		 ignored. When using this option on more than one files, the
		 output can be redirected to a destination directory.

    -dest_dir  : The destination directory where the output of -raw will be 
		 directed. The source directory structure is preserved.

    -code      : print the line count of the code only, or print just the code
		 if -raw is specified.

    -comment   : print the line count of the comment only, or print just the 
		 comments if -raw is specified.

    -copyright : print the line count of the copyright statements only, or 
		 print the copyright lines themselves if -raw is specified.

    -summary   : This option is only applicable for lines count (not the 
		 -raw option). It indicates that only package level summary
		 be printed instead of per-file statistics.
-----------------------------------------------------------------------------	    
EOF
}

SPACES="                                                                        "
WHITE_SPACES=" 	" 
IGNORE_CODE="$WHITE_SPACES"
IGNORE_COMMENTS="$WHITE_SPACES"
AWK="awk"

# The default awk on some Unix systems just doesn't cut it!
# You must reset AWK to the new awk if old awk doesn't work
resetAwk()
{
if [ "$OS" = "Windows_NT" ]
then
    AWK="awk"
else
    AWK="nawk"
fi
}

# Right justify argument ($1) in a field of n ($2)
# n must be less than length of $SPACES
rt_justify()
{
    echo "${SPACES}${1}" | sed 's/ *\(.\{'"${2}"',\}\)$/\1/'
}

xscc()
{
# Author: Vishal Goenka <vgoenka@hotmail.com>
# eXtract Source Code Comment
#
# Usage: xscc.awk [extract=code|comment|copyright] [prune=copyright]
#                 [blanklines=1] [language=<lang>] file ...
#
# Note:  If your shell environment does not have /usr/bin/awk available
#        you might have to run this command by typing:
# awk -f xscc.awk [extract=code|comment|copyright] [prune=copyright]
#                 [blanklines=1] [language=<lang>] file ...
# Certain old versions of awk may not support this script. If the awk
# on your system gives errors, consider using nawk or gawk.
#
# This AWK script extracts program source code, comments or copyright 
# statements. Copyright statements are defined as the comment lines that
# preceed the first line of code.
#
# The default behavior is to extract the source code, and filter the
# comments out. The optional arguments are described below:
#
#    extract=code      -- print the code, filter comments out. This mode
#                         is the default, unless overridden otherwise.
#    extract=comment   -- print the comments, and filter out the code. 
#    extract=copyright -- print the copyright statements only.
#
#    prune=copyright   -- in the default mode (extract=code), it prints
#                         all code and comments following the copyright 
#                         statements, which are filtered out. 
#                         In the 'extract=comment' mode, it prints all
#                         comments other than the copyright statements.
# 
#    blanklines=1      -- by default, blank lines are not printed, unless 
#                         specified using this option.
#    
#    language=<lang>   -- force a specific language as per the following
#                         table, rather than infer the language from the
#                         extension, which is the default behavior.
#
# This script supports the following programming languages, and infers the 
# language from the file extension (unless overridded using language=<lang>)
# as follows:
#
# Language         Extensions
# Java             java, idl
# C                c
# C++              C, cc, cpp, h, H
# JavaScript       js
# HTML             htm, html
# Shell            sh, ksh, bash, ksh
# Perl             pl, perl, pm
#
$AWK 'func i(b,c,e,d){y=0;z=(e=="copyright");A=z||(e=="comment");B=(!z&&(prune=="copyright"));C=D=E="";if(!b)b=d[split(c,d,".")];else c="";if(b==c)C="#";else if(b~/^(java|C|cc|h|H|cpp|idl|js)$/){C="//";D="/*";E="*/"}else if(b~/^(c)$/){D="/*";E="*/"}else if(b~/^htm|html$/){D="<!--";E="-->"}else C="#"}func f(g){gsub("\\*","\\*",g);return g}func h(a,j){if(z&&!j&&a)nextfile;else if(B&&a){if(A&&!j)B=0;else if(!A&&j){print a;y=1}}else if(j)F=F a}func k(l,t){if(l!~/[\x022\x027]/)return "";else{gsub(/\\.|[^\x022\x027]/,"",l);do{t=l;gsub(/^\x022\x027*\x022|^\x027\x022*\x027/,"",l)}while(t!=l);if(length(l))l=substr(l,0,1);return l}}func p(q,l,n){n=index(l,q);if(n<=1||(n>1&&substr(l,n-1,1)!="\x05c"))return n;else return n+p(q,substr(l,n+1))}func o(l,g,r,n){n=split(l,r,f(g));G=0;h(r[1] g,A);if(n>1)v(substr(l,length(r[1] g)+1))}func s(l,m,g,r,n,q,u){u=length(g)+1;n=split(l,r,f(g));q=k(r[1]);if(!length(q)){if(m){G=1;h(r[1],!A);h(g,A);if(n>1)v(substr(l,length(r[1])+u))}else{h(r[1],!A);h(substr(l,length(r[1])+1),A)}}else{if(n>1){n=p(q,substr(l,length(r[1])+u));if(n)n+=length(r[1])+u-1}if(n>1){h(substr(l,1,n),!A);if(n<length(l))v(substr(l,n+1))}else print l}}func v(l,w,x){if(D){if(G){if(index(l,E))o(l,E);else h(l,A)}else{w=index(l,D);if(C&&(x=index(l,C))&&(!w||x<w))s(l,0,C);else if(w)s(l,1,D);else h(l,!A)}}else{if(index(l,C))s(l,0,C);else h(l,!A)}}{if(FNR==1)i(language,FILENAME,extract);if(y)print;else{F="";v($0);if(blanklines||F~/[^ ]/)print F}}' $*
}

# ignore_pretty <language>
# set IGNORE_CODE and IGNORE_COMMENTS based on the given language
ignore_pretty()
{
    language=${1:-sh}
    case "$language" in
	java|C|c|cc|h|H|cpp|idl|js)  
		IGNORE_CODE="${WHITE_SPACES}{}();,";
		IGNORE_COMMENTS="${WHITE_SPACES}*\/";;
	*)
		IGNORE_CODE="${WHITE_SPACES}{}();,";
		IGNORE_COMMENTS="${WHITE_SPACES}#";;
    esac
}

# unformat <stdin>
# if nopretty = 0, simply delete blank lines, 
# if nopretty = 1, wrap lines with characters containing IGNORE 
# characters on next line to preserve the characters, while reducing 
# the spread on multiple lines
unformat()
{
    if [ ${nopretty:-0} -eq 1 ]
    then
	sed -n "{
	   s,^[ 	]*\(.*\)[ 	]*$,\1,
	   H
	   g
	   s,\n,,g
	   /[^$IGNORE]/ba
	   \$ba
	   d
	   :a
	   p
	   s,.*,,
	   h
       }" $*
    else
	sed "{
	    /^[$WHITE_SPACES]*$/d
	}" $*
    fi
}

# raw_code <file>
raw_code()
{
    IGNORE="$IGNORE_CODE"
    xscc $1 | unformat
}

# raw_comment <file> <language>
raw_comment()
{
    IGNORE="$IGNORE_COMMENTS"
    xscc extract=comment prune=copyright $1 | unformat 
}

# raw_copyright <file>
# Extract the raw copyright, no formatting changes to this one!
raw_copyright()
{
    xscc extract=copyright $1
}

checkerror()
{
if [ $1 -ne 0 ]
then
    echo $2 
    exit 1
fi
}

# raw_content <file>
raw_content()
{
    ext=`basename $1 | sed -n 's/.*[.]//p'`
    if [ ${nopretty:-0} -eq 1 ]
    then
	ignore_pretty $ext
    fi
    cmd="raw_${content:-code} $1 $ext"
    if [ ! -z "$dest_dir" ]
    then
	dir="$dest_dir/`dirname $1`"
	file="$dest_dir/$1"
	if [ ! -d "$dir" ]
	then
	    mkdir -p "$dir"
	    checkerror $? "ERROR creating sub-directory $dir" 
	fi
	`echo $cmd` > $file
     else
	`echo $cmd`
     fi
}

raw_header()
{
    echo
}

raw_footer()
{
    echo
}

count_header()
{
    if [ "${summary:-0}" -eq 0 ]
    then
	_h_="   "
    fi
    if [ ! -z "$content" ]
    then
	echo "$_h_     ${content:-Code}     File/Package" 
	echo "--------------------------------------------"
    else
	echo "$_h_    Total     Code   Comment   Copyright   Comment/Code   File/Package"
	echo "--------------------------------------------------------------------------"
    fi
}

count_footer()
{
    if [ ! -z "$content" ]
    then
	pkg_report "`rt_justify $pkgtotal 8`     $current_package"
	echo "--------------------------------------------"
	pkg_report "`rt_justify $TOTAL 8`     GRAND TOTAL"
    else
	ratio=`echo "$pkgcode $pkgcomment" | $AWK '{printf "%15.3f\n", $2/$1}'`
	pkg_report "`rt_justify $pkgtotal 8` `rt_justify $pkgcode 8` `rt_justify $pkgcomment 8` `rt_justify $pkgcopyright 8` $ratio      $current_package"
	ratio=`echo "$CODE $COMMENT" | $AWK '{printf "%15.3f\n", $2/$1}'`
	echo "--------------------------------------------------------------------------"
	pkg_report "`rt_justify $TOTAL 8` `rt_justify $CODE 8` `rt_justify $COMMENT 8` `rt_justify $COPYRIGHT 8` $ratio      GRAND TOTAL"
    fi
}


# selectcontent [<content-type>] <content-type>
selectcontent()
{
    if [ $# -gt 1 ]
    then
	echo "Usage error: -$1 and -$2 may not be specified together"
	exit 1
    fi
    content=$1
}

getfiles()
{
    args="$*"
    find ${args:-`pwd`} -type f $findopt | sed '/CVS/d'
}

pkg_report()
{
    if [ ${summary:-0} -eq 0 ]
    then
	echo ">> $*"
	echo
    else
	echo "$*"
    fi
}

count_content()
{
    package=`dirname $1`
    if [ -z "$current_package" ]
    then
	current_package="$package"
    fi
    # If content is set, count only for content
    if [ ! -z "$content" ]
    then
    	if [ "$package" != "$current_package" ]
	then
	    pkg_report "`rt_justify $pkgtotal 8`     $current_package"
	    pkgtotal=0
	    current_package="$package"
	fi

	total=`raw_content "$1" | wc -l`
	pkgtotal=`expr ${pkgtotal:-0} + $total`
	TOTAL=`expr ${TOTAL:-0} + $total`
	if [ ${summary:-0} -eq 0 ]
	then
	    echo "   `rt_justify $total 8`     $1"
	fi
    else
    	if [ "$package" != "$current_package" ]
	then
	    ratio=`echo "$pkgcode $pkgcomment" | $AWK '{printf "%15.3f\n", $2/$1}'`
	    pkg_report "`rt_justify $pkgtotal 8` `rt_justify $pkgcode 8` `rt_justify $pkgcomment 8` `rt_justify $pkgcopyright 8` $ratio      $current_package"
	    pkgcode=0
	    pkgcomment=0
	    pkgcopyright=0
	    pkgtotal=0
	    current_package="$package"
	fi

	content="code"
	code=`raw_content "$1" | wc -l`
	pkgcode=`expr ${pkgcode:-0} + $code`
	CODE=`expr ${CODE:-0} + $code`

	content="comment"
	comment=`raw_content "$1" | wc -l`
	pkgcomment=`expr ${pkgcomment:-0} + $comment`
	COMMENT=`expr ${COMMENT:-0} + $comment`	

	content="copyright"
	copyright=`raw_content "$1" | wc -l`
	pkgcopyright=`expr ${pkgcopyright:-0} + $copyright`
	COPYRIGHT=`expr ${COPYRIGHT:-0} + $copyright`

	total=`cat $1 | wc -l`
	pkgtotal=`expr ${pkgtotal:-0} + $total`
	TOTAL=`expr ${TOTAL:-0} + $total`

	if [ ${summary:-0} -eq 0 ]
	then
	    ratio=`echo "$code $comment" | $AWK '{printf "%15.3f\n", $2/$1}'`
	    echo "   `rt_justify $total 8` `rt_justify $code 8` `rt_justify $comment 8` `rt_justify $copyright 8` $ratio      $1"
	fi    
	content=""
    fi
}


# Do not enclose this is a function, or else the parameters passed to 
# -findopt in "quotes" are unquoted when the arguments are passed to 
# the function
#
# main()
# {
while [ 1 ]
do
    option=`echo "$1" | sed -n "s,^-\(.*\),\1,p"`
    if [ "$option" != "" ]
    then
	shift
	case "$option" in
	    -help|help|h)usage; break;;
	     nopretty)   nopretty=1;;
	     raw)        mode=raw;;
	     dest_dir)   dest_dir=`echo $1 | sed 's,/$,,'`; 
			 shift;
			 if [ ! -d "$dest_dir" ]; then echo "$dest_dir does not exist!"; exit 1; fi;;
	     code|comment|copyright) selectcontent $content $option;;
	     findopt)    findopt="$1"; shift;; 
	     summary)    summary=1;;
	      *)         usage; break;;
	esac;
    else 
	`echo "${mode:-count}_header"`
	for f in `getfiles $*`
	do 
	    if [ -f $f ]
	    then
		`echo "${mode:-count}_content $f"`
	    fi
	done
	`echo "${mode:-count}_footer"`
	break;
    fi
done
# }
# main $*


