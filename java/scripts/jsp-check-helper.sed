s/<%\@\s\+\(taglib\|page\) \([^%]\|%[^>]\)*%>//g
s/<%\([^%]\|%[^>]\)*%>/aaa/g
s/<bean:message [^>]*\/>/bean text/g
s/<decorator:getProperty [^>]*\/>/something/g
s/<c:out [^>]*\/>/out something/g
s/<\(\/\?[^:> ]*\):/<\1_/g
s/^/<xml>/
s/$/<\/xml>/
s/<!DOCTYPE [^>]*>//
