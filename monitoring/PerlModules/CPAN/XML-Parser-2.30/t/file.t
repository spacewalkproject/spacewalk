BEGIN {print "1..2\n";}
END {print "not ok 1\n" unless $loaded;}
use XML::Parser;
$loaded = 1;
print "ok 1\n";

my $count = 0;

$parser = new XML::Parser(ErrorContext => 2);
$parser->setHandlers(Comment => sub {$count++;});

$parser->parsefile('samples/REC-xml-19980210.xml');

print "not " unless $count == 37;
print "ok 2\n";
