# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl test.pl'

######################### We start with some black magic to print on failure.

BEGIN {
    require Time::HiRes;
    unless (defined &Time::HiRes::gettimeofday
	    && defined &Time::HiRes::ualarm
	    && defined &Time::HiRes::usleep) {
    	print "1..0\n";
	exit;
    }
}

# Change 1..1 below to 1..last_test_to_print .
# (It may become useful if the test is moved to ./t subdirectory.)

BEGIN { $| = 1; print "1..4\n"; }
END {print "not ok 1\n" unless $loaded;}

$Exporter::Verbose=1;
use Time::HiRes qw (time alarm sleep);
$loaded = 1;
print "ok 1\n";

######################### End of black magic.

# Insert your test code below (better if it prints "ok 13"
# (correspondingly "not ok 13") depending on the success of chunk 13
# of the test code):

print "time...";
$f = time; 
print "$f\nok 2\n";

print "sleep...";
$r = [Time::HiRes::gettimeofday];
sleep (0.5);
print Time::HiRes::tv_interval($r), "\nok 3\n";

$r = [Time::HiRes::gettimeofday];
$i = 5;
$SIG{ALRM} = "tick";
while ($i)
 {
  alarm(2.5);
  select (undef, undef, undef, 10);
  print "Select returned! ", Time::HiRes::tv_interval ($r), "\n";
 }

sub tick
 {
  print "Tick! ", Time::HiRes::tv_interval ($r), "\n";
  $i--;
 }
$SIG{ALRM} = 'DEFAULT';
print "ok 4\n";
