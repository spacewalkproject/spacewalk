#!/local/bin/perl -w

open(E, "ISOlat1.sgml") || die;

while (<E>) {
    if (/^\s*<!ENTITY\s+(\w+)\s+CDATA\s+\"&\#(\d+);\"\s*--\s*(.*?)\s*-->/) {
        print " $1\t=> '", chr($2), "',  # $3\n";
    } else {
	print STDERR $_;
    }
}
