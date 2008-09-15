package ActiveTestTest;

use strict;

use Test::Unit::TestCase ();
use base 'Test::Unit::TestCase';
use Test::Unit::Result;
use Test::Unit::TestSuite ();
use Success;

sub testActiveTest {
    my $self = shift;
    my $test = $self->create_active_test_suite;
    my $result = Test::Unit::Result->new;
    $test->run($result);
    $self->assert_equals(100, $result->run_count);
    $self->assert_equals(0, $result->failure_count);
    $self->assert_equals(0, $result->error_count);
}

#  sub test_active_repeated_test {
#      my $self = shift;
#      my $test = Test::Unit::RepeatedTest($self->create_active_test_suite, 5);
#      my $result = Result->new;
#      $test->run($result);
#      $self->assert_equals(500, $result->run_count);
#      $self->assert_equals(0, $result->failure_count);
#      $self->assert_equals(0, $result->error_count);
#  }

#  sub test_active_repeated_test0 {
#      my $self = shift;
#      my $test = Test::Unit::RepeatedTest($self->create_active_test_suite, 0);
#      my $result = Result->new;
#      $test->run($result);
#      $self->assert_equals(0, $result->run_count);
#      $self->assert_equals(0, $result->failure_count);
#      $self->assert_equals(0, $result->error_count);
#  }

#  sub test_active_repeated_test1 {
#      my $self = shift;
#      my $test = Test::Unit::RepeatedTest($self->create_active_test_suite, 1);
#      my $result = Result->new;
#      $test->run($result);
#      $self->assert_equals(100, $result->run_count);
#      $self->assert_equals(0, $result->failure_count);
#      $self->assert_equals(0, $result->error_count);
#  }

sub create_active_test_suite () {
    my $self = shift;
    my $suite = Test::Unit::TestSuite->new;
    for (1 .. 100) {
        $suite->add_test(Success->new("test_success"));
    }
    return $suite;
}

1;
