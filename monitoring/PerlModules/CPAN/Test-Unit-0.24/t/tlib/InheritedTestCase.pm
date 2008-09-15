package InheritedTestCase;

# Test class used in SuiteTest

use base qw(OneTestCase);

sub new {
    shift()->SUPER::new(@_);
}

sub test2 {
}

1;
