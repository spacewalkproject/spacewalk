#!/bin/sh
##
##  prop.sh -- process indication though a propeller
##  Copyright (c) 1998 Ralf S. Engelschall, All Rights Reserved. 
##

line="$*"

perl=''
for dir in `echo $PATH | sed -e 's/:/ /g'` .; do
    if [ -f "$dir/perl" ]; then
        perl="$dir/perl"
        break
    fi
done
if [ ".$perl" != . ]; then
    #
    #   Perl is preferred because writing to STDERR in
    #   Perl really writes immediately as one would expect
    #
    $perl -e '
        @p = ("|","/","-","\\"); 
        $i = 0; 
        while (<STDIN>) { 
            printf(STDERR "\r%s...%s\b", $ARGV[0], $p[$i++]);
            $i = 0 if ($i > 3); 
        }
        printf(STDERR "\r%s    \n", $ARGV[0]);
    ' "$line"
else
    #
    #   But when Perl doesn't exists we use Awk even
    #   some Awk's buffer even the /dev/stderr writing :-(
    #
    awk '
        BEGIN { 
            split("|#/#-#\\", p, "#");
            i = 1; 
        } 
        { 
            printf("\r%s%c\b", line, p[i++]) > "/dev/stderr"; 
            if (i > 4) { i = 1; } 
        }
        END {
            printf("\r%s    \n", line) > "/dev/stderr";
        }
    ' "line=$line" 
fi

