use lib "./t";

use MIME::Tools;
use MIME::Decoder;
config MIME::Tools QUIET=>1;

# config MIME::Tools DEBUGGING=>1;
use ExtUtils::TBone;

#------------------------------------------------------------
# BEGIN
#------------------------------------------------------------

# Is gzip available?  Quick and dirty test:
my $has_gzip;
foreach (split $^O eq "MSWin32" ? ';' : ':', $ENV{PATH}) {
    last if ($has_gzip = -x "$_/gzip");
}
if ($has_gzip) {
   require MIME::Decoder::Gzip64;
   install MIME::Decoder::Gzip64 'x-gzip64';
}

# Get list of encodings we think we provide:
my @encodings = ('base64',
		 'quoted-printable',
		 '7bit',
		 '8bit',
		 'binary',
		 ($has_gzip ? 'x-gzip64' : ()),
		 'x-uuencode');

# Create checker:
my $T = typical ExtUtils::TBone;
$T->begin(scalar(@encodings));

# Report what tests we may be skipping:
$T->msg($has_gzip 
	? "Using gzip: $has_gzip"
	: "No gzip: skipping x-gzip64 test");

# Test each encoding in turn:
my ($e, $eno) = (undef, 0);
foreach $e (@encodings) {
    ++$eno;
    my $decoder = new MIME::Decoder $e;
    $decoder or next;
 
    $T->msg("Encoding/decoding of $e");
    my $infile  = $T->catfile('.', 'testin', 'fun.txt');
    my $encfile = $T->catfile('.', 'testout', "fun.en$eno");
    my $decfile = $T->catfile('.', 'testout', "fun.de$eno");

    # Encode:
    open IN, "<$infile" or die "open $infile: $!";    
    open OUT, ">$encfile" or die "open $encfile: $!"; 
    binmode IN; binmode OUT;	 
    $decoder->encode(\*IN, \*OUT) or next;
    close OUT;
    close IN;

    # Decode:
    open IN, "<$encfile" or die "open $encfile: $!";
    open OUT, ">$decfile" or die "open $decfile: $!";
    binmode IN; binmode OUT;
    $decoder->decode(\*IN, \*OUT) or next;
    close OUT;
    close IN;

    # Can we compare?
    if ($e =~ /^(base64|quoted-printable|binary|x-gzip64|x-uuencode)$/i) {
	$T->ok(((-s $infile) == (-s $decfile)),
		  "size of $infile == size of $decfile");
    }
    else {
	$T->ok(1);
    }
}

# Done!
$T->end;
exit(0);
1;





