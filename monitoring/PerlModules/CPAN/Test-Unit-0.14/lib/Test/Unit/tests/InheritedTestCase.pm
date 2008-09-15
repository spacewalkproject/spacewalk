package Test::Unit::tests::InheritedTestCase;

# Test class used in SuiteTest

use base qw(Test::Unit::tests::OneTestCase);

sub new {
    shift()->SUPER::new(@_);
}

sub test2 {
}

1;
