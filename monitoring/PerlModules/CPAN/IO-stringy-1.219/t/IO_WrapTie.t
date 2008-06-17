#!/usr/bin/perl -w         #-*-Perl-*-

use lib "./t";
use IO::Handle;
use IO::Scalar;
use ExtUtils::TBone;
use IO::WrapTie;

#--------------------
#
# TEST...
#
#--------------------

# Make a tester:
my $T = typical ExtUtils::TBone;

# Set the counter:
unless ($] >= 5.004) {
    $T->begin(1);
    $T->ok(1);
    $T->end;
    exit 0;
}
$T->begin(6);

my $hello = 'Hello, ';
my $world = "world!\n";

#### test
my $s = '';
my $SH = new IO::WrapTie 'IO::Scalar', \$s;
$T->ok(1, "Construction");

#### test
print $SH $hello, $world;
$T->ok($s eq "$hello$world",
       "print FH ARGS",
       S => $s);

#### test
$SH->print($hello, $world);
$T->ok($s eq "$hello$world$hello$world",
       "FH->print(ARGS)",
       S => $s);
      
#### test
$SH->seek(0,0);
$T->ok(1, "FH->seek(0,0)");

#### test
@x = <$SH>;
$T->ok((($x[0] eq "$hello$world") &&
	($x[1] eq "$hello$world") &&
	!$x[2]),
       "array = <FH>");

#### test
my $sref = $SH->sref;
$T->ok($sref eq \$s, "FH->sref");


# So we know everything went well...
$T->end;


