package OverrideTestCase;
use strict;

# Test class used in SuiteTest

use base qw(OneTestCase);

sub new {
    shift()->SUPER::new(@_);
}

sub test_case {
}

1;
