BEGIN {print "1..3\n";}
END {print "not ok 1\n" unless $loaded;}
use XML::Parser;
$loaded = 1;
print "ok 1\n";

my $delim = '------------123453As23lkjlklz877';
my $file = 'samples/REC-xml-19980210.xml';
my $tmpfile = 'stream.tmp';

my $cnt = 0;


open(OUT, ">$tmpfile") or die "Couldn't open $tmpfile for output";
open(IN, $file) or die "Couldn't open $file for input";

while (<IN>) {
  print OUT;
}

close(IN);
print OUT "$delim\n";

open(IN, $file);
while (<IN>) {
  print OUT;
}

close(IN);
close(OUT);

my $parser = new XML::Parser(Stream_Delimiter => $delim,
			     Handlers => {Comment => sub {$cnt++;}});

open(FOO, $tmpfile);

$parser->parse(*FOO);

print "not " if ($cnt != 37);
print "ok 2\n";

$cnt = 0;

$parser->parse(*FOO);

print "not " if ($cnt != 37);
print "ok 3\n";

close(FOO);
unlink($tmpfile);
