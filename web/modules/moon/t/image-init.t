# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl test.pl'

#########################

# change 'tests => 1' to 'tests => last_test_to_print';

use Test;
BEGIN { plan tests => 7 };
use Moon::Image;
ok(1); # If we made it this far, we're ok.

#########################

# Insert your test code below, the Test module is use()ed here so read
# its man page ( perldoc Test ) for help writing this test script.

my $image;
eval {
  $image = Moon::Image->load_from_file("images/non-existant.png");
};

ok($@);

ok($image = Moon::Image->load_from_file("images/chart.png"));

ok($image = new Moon::Image(200, 200));

my $white = $image->add_color(0, 0, 0);
ok($white eq 0);

my $red_and_green = $image->add_color(255, 255, 0);
my $black = $image->add_color(255, 255, 255);

$image->set_transparent($red_and_green);
my $transparent = $image->get_transparent();
ok($red_and_green, $transparent);

$image->draw_pixel(10, 10, $black);
$image->draw_line(20, 0, 100, 145, $black);
$image->draw_rectangle(35, 35, 60, 80, $black);

ok($image->draw_filled_rectangle(140, 140, 120, 89));

ok(1);

