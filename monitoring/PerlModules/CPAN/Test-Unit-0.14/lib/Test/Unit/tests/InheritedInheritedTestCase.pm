package Test::Unit::tests::InheritedInheritedTestCase;

# Test class used in SuiteTest

use base qw(Test::Unit::tests::InheritedTestCase);

sub new {
    shift()->SUPER::new(@_);
}

sub test3 {
}

1;
