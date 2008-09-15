BEGIN {print "1..5\n";}
END {print "not ok 1\n" unless $loaded;}
use XML::Parser;
$loaded = 1;
print "ok 1\n";

################################################################
# Check default external entity handler


my $txt = '';

sub txt {
  my ($xp, $data) = @_;

  $txt .= $data;
}

my $docstring =<<'End_of_XML;';
<!DOCTYPE foo [
  <!ENTITY a SYSTEM "a.ent">
  <!ENTITY b SYSTEM "b.ent">
  <!ENTITY c SYSTEM "c.ent">
]>
<foo>
a = "&a;"
b = "&b;"


And here they are again in reverse order:
b = "&b;"
a = "&a;"

</foo>
End_of_XML;

open(ENT, '>a.ent') or die "Couldn't open a.ent for writing";
print ENT "This ('&c;') is a quote of c";
close(ENT);

open(ENT, '>b.ent') or die "Couldn't open b.ent for writing";
print ENT "Hello, I'm B";
close(ENT);

open(ENT, '>c.ent') or die "Couldn't open c.ent for writing";
print ENT "Hurrah for C";
close(ENT);

my $p = new XML::Parser(Handlers => {Char => \&txt});

$p->parse($docstring);

my %check = (a => "This ('Hurrah for C') is a quote of c",
	     b => "Hello, I'm B");

my $tstcnt = 2;

while ($txt =~ /([ab]) = "(.*)"/g) {
  my ($k, $v) = ($1, $2);

  unless ($check{$k} eq $v) {
    print "not ";
  }
  print "ok $tstcnt\n";
  $tstcnt++;
}

unlink('a.ent');
unlink('b.ent');
unlink('c.ent');
