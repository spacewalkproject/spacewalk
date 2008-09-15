use lib "./t";

use strict;
use ExtUtils::TBone;

use MIME::QuotedPrint qw(decode_qp);
use MIME::Words qw(decode_mimewords);

#------------------------------------------------------------
# BEGIN
#------------------------------------------------------------

# Create checker:
my $T = typical ExtUtils::TBone;
$T->begin(10);

{
    local($/) = '';
    open WORDS, "<testin/words.txt" or die "open: $!";
    while (<WORDS>) {
	s{\A\s+|\s+\Z}{}g;    # trim

	my ($isgood, $expect, $enc) = split /\n/, $_, 3;
	$isgood = (uc($isgood) eq 'GOOD');
	$expect = eval $expect;

	my $dec = decode_mimewords($enc);
	$T->ok( ((($isgood && !$@) or (!$isgood && $@)) and
		 ($isgood ? ($dec eq $expect) : 1)),
	       'Is it good?',
	       IsGood  => $isgood,
	       Error   => $@,
	       Encoded => $enc,
	       Decoded => $dec,
	       Expectd => $expect);
    }
    close WORDS;
}    

# Done!
$T->end;
exit(0);
1;

