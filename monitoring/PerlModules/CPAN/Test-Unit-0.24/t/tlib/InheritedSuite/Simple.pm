package InheritedSuite::Simple;

use strict;

use base qw(Test::Unit::TestSuite);

sub include_tests { 'Success'                }
sub name          { 'Simple inherited suite' }

1;
