package Test::Unit::tests::OverrideTestCase;
use strict;

# Test class used in SuiteTest

use base qw(Test::Unit::tests::OneTestCase);

sub new {
    shift()->SUPER::new(@_);
}

sub test_case {
}

1;
