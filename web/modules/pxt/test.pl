# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl test.pl'

######################### We start with some black magic to print on failure.

# Change 1..1 below to 1..last_test_to_print .
# (It may become useful if the test is moved to ./t subdirectory.)

use strict;
use Test;
BEGIN { plan tests => 3 }

use PXT;
use PXT::Parser;
ok(1);

######################### End of black magic.

# Insert your test code below (better if it prints "ok 13"
# (correspondingly "not ok 13") depending on the success of chunk 13
# of the test code):

my $data = <<EOT;
<html>
<foo>
  <test:tag1 test1="1">
  <test:tag2>
    baz
  </test:tag2>
</foo>
EOT

my $p = new PXT::Parser;
$p->register_tag("test:tag1", sub { my %attr = @_; ok($attr{test1}, 1); return "tag1"} );
$p->register_tag("test:tag2", sub { my %attr = @_; ok($attr{__block__} =~ /baz/); return "tag2"} );
$p->expand_tags(\$data);
print $data;

