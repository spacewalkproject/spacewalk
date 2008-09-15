

use Apache::Include ();
print "Content-type: text/plain\n\n";

print "1..4\n";
print "ok 1\n";
#Apache::Include->virtual("/perl/cgi.pl?PARAM=2");
Apache::Include->virtual("/cgi-bin/cgi.pl?PARAM=2");
print "ok 3\n";
Apache::Include->virtual("/cgi-bin/cgi.pl?PARAM=4");
