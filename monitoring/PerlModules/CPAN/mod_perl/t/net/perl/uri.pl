use strict;
use Apache::test;
$|++;
my $i = 0;

my $r = shift;
$r->send_http_header('text/plain');

eval {
    require Apache::URI;
};
if($@) {
    print "$@\n";
    print "1..0\n";
    return;
}
     
my (@methods) = qw{
scheme
hostinfo
user
password
hostname
path
rpath
query
fragment
port
unparse
};     

my $tests = (@methods * 2) * 2; 
print "1..$tests\n";
my $test_uri = "http://perl.apache.org:80/dist/apache-modlist.html";

for (1,2) {
    for my $uri ($r->parsed_uri, Apache::URI->parse($r, $test_uri)) {
	print "URI=", $uri->unparse, "\n";
	for my $meth (@methods) {
	    my $val = $uri->$meth();
	    test ++$i, $val || 1;
	    $val ||= "";
	    print "$meth = `$val'\n"; 
	}
    }
}
