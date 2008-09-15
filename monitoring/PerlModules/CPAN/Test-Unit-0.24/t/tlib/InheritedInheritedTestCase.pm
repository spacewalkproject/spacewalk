package InheritedInheritedTestCase;

# Test class used in SuiteTest

use base qw(InheritedTestCase);

sub new {
    shift()->SUPER::new(@_);
}

sub test3 {
}

1;
