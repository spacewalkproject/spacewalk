use lib "./t";

use MIME::Parser;

use strict;
config MIME::Tools DEBUGGING=>0;
use ExtUtils::TBone;


# Are on a machine where binmode matters?
my $txtmode = "./testout/textmode";
open TEXTMODE, ">$txtmode" or die "open textmode file!";
print TEXTMODE "abc\ndef\nghi\n";       
close TEXTMODE;
my $uses_crlf = ((-s $txtmode) == 12) ? 0 : 1; 

# Actual length of message:
my $MSGLEN   = 669;
my $MSGLINES = 20;
my $MSGLEN_text = $MSGLEN + ($uses_crlf * $MSGLINES);

# Checker:
my $T = typical ExtUtils::TBone;

# Gout...
sub gout {
    my ($h, $ent) = @_;
    my $test;
    my $pos1;
    my $pos2;

    no strict 'refs';
    my $sh = (ref($h) ? $h : \*$h);

    print $sh "\n", "=" x 30, " ", ($test = "ent->print"), "\n";
    $pos1 = tell($sh);
    eval { $ent->print($h) };
    $pos2 = tell($sh);
    $T->ok((!$@ and (($pos2 - $pos1) == $MSGLEN_text)), 
	   "$h, $test [$pos1-$pos2 == $MSGLEN_text]");

    print $sh "\n", "=" x 30, " ", ($test = "print ent->as_string"), "\n";
    $pos1 = tell($sh);
    eval { print $h $ent->as_string };
    $pos2 = tell($sh);
    $T->ok((!$@ and (($pos2 - $pos1) == $MSGLEN_text)), 
		"$h, $test [$pos1-$pos2]");

    print $sh "\n", "=" x 30, " ", ($test = "ent->print_header"), "\n";
    eval { $ent->print_header($h) };
    $T->ok(!$@, "$h, $test: $@");

    print $sh "\n", "=" x 30, " ", ($test = "ent->print_body"), "\n";
    eval { $ent->print_body($h) };
    $T->ok(!$@, "$h, $test: $@");

    print $sh "\n", "=" x 30, " ", ($test = "ent->bodyhandle->print"), "\n";
    eval { $ent->bodyhandle->print($h) };
    $T->ok(!$@, "$h, $test: $@");
    
    print $sh "\n", "=" x 30, " ",($test = "print ent->bodyhandle->data"),"\n";
    eval { print $h $ent->bodyhandle->data };
    $T->ok(!$@, "$h, $test: $@");
    1;
}


# Loops:
my @msgfiles = qw(simple.msg);
my @corelims = qw(ALL NONE 512);


# Create checker:
$T->begin(((6+1) * 3 * int(@corelims) * int(@msgfiles)));

# Create a parser:
my $parser = new MIME::Parser;
$parser->output_dir("./testout");

# For each message:
my $msgfile;
foreach $msgfile (@msgfiles) {

    my $corelim;
    foreach $corelim (@corelims) {
	
	# Set opt:
	$parser->output_to_core($corelim);
	
	# Parse:
	my $ent = $parser->parse_open("./testin/$msgfile");
	my $out = "./testout/gauntlet.out";
	my $outsize = 3201 + ($uses_crlf * 97);

	# Open output stream 1:
	open GOUT, ">$out" or die "$!";
	gout('::GOUT', $ent);
	close GOUT;
	my $s1 = -s $out;
	$T->ok($s1 == $outsize, "BARE FH:    size $out ($s1) == $outsize?");
	
	# Open output stream 2:
        open GOUT, ">$out" or die "$!";
	gout(\*GOUT, $ent);
	close GOUT;
	my $s2 = -s $out;
	$T->ok($s2 == $outsize, "GLOB ref:   size $out ($s2) == $outsize?");

	# Open output stream 3:
        my $GOUT = (new FileHandle ">$out") || die "$!";
	gout($GOUT, $ent);
	$GOUT->close;
	my $s3 = -s $out;
	$T->ok($s3 == $outsize, "FileHandle: size $out ($s3) == $outsize?");
    }
}


# Done!
exit(0);
1;

