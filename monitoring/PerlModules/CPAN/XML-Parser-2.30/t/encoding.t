BEGIN {print "1..4\n";}
END {print "not ok 1\n" unless $loaded;}
use XML::Parser;
$loaded = 1;
print "ok 1\n";

################################################################
# Check encoding

my $xmldec = "<?xml version='1.0' encoding='x-sjis-unicode' ?>\n";

my $docstring=<<"End_of_doc;";
<\x8e\x83>\x90\x46\x81\x41\x98\x61\x81\x41\x99\x44
</\x8e\x83>
End_of_doc;

my $doc = $xmldec . $docstring;

my @bytes;
my $lastel;

sub text {
  my ($xp, $data) = @_;

  push(@bytes, unpack('C*', $data));
}

sub start {
  my ($xp, $el) = @_;

  $lastel = $el;
}

my $p = new XML::Parser(Handlers => {Start => \&start, Char => \&text});

$p->parse($doc);

my $exptag = "\xe7\xa5\x89";		# U+7949 blessings 0x8e83

my @expected = (0xe8, 0x89, 0xb2,	# U+8272 beauty    0x9046
		0xe3, 0x80, 0x81,	# U+3001 comma     0x8141
		0xe5, 0x92, 0x8c,	# U+548C peace     0x9861
		0xe3, 0x80, 0x81,	# U+3001 comma     0x8141
		0xe5, 0x83, 0x96,	# U+50D6 joy       0x9944
		0x0a);

if ($lastel eq $exptag) {
  print "ok 2\n";
}
else {
  print "not ok 2\n";
}

if (@bytes != @expected) {
  print "not ok 3\n";
}
else {
  my $i;
  for ($i = 0; $i < @expected; $i++) {
    if ($bytes[$i] != $expected[$i]) {
      print "not ok 3\n";
      exit;
    }
  }
  print "ok 3\n";
}

$lastel = '';

$p->parse($docstring, ProtocolEncoding => 'X-SJIS-UNICODE');

if ($lastel eq $exptag) {
  print "ok 4\n";
}
else {
  print "not ok 4\n";
}

