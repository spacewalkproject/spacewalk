# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl test.pl'

#########################

# change 'tests => 1' to 'tests => last_test_to_print';
use strict;
use Test;
BEGIN { plan tests => 4 };
use Moon::Chart;
ok(1); # If we made it this far, we're ok.

#########################

# Insert your test code below, the Test module is use()ed here so read
# its man page ( perldoc Test ) for help writing this test script.


my @data = ( [6, -2], [0, 0], [2, -1.75], [2.5, -2], [3, 3], [4, 2.5], [1.02, 8] );
my $dataset = new Moon::Dataset::Coordinate();
$dataset->coords(\@data);

my $chart;

ok($chart  = new Moon::Chart(300, 300));


$chart->add_dataset("random data", $dataset);
ok(1);

my $time = time();
ok($chart->render_to_file("images/$time.png") and -e "images/$time.png");

