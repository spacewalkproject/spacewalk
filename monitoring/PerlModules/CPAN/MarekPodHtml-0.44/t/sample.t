# -*- perl -*-
# Testing of Pod::HTML
# Author: Marek Rouchal <marekr@cpan.org>

$| = 1;

use Test;
use vars qw($TEST_MODE);

BEGIN { plan tests => 2 }

# syntax-check
# instead of calling system() with a non-portable
# output redirection, we "source" the code and
# let it execute something simple to verify that
# the syntax is correct
if(-d 'html' || mkdir('html')) {
  ok(1);
} else {
  ok(0);
}
@ARGV = qw(-dir html t/sample.pod);
$TEST_MODE = 1; # do not exit
eval "require 'blib/script/mpod2html';";
if($@) {
  ok(0);
  print "$@\n";
} else {
  ok(1);
}

