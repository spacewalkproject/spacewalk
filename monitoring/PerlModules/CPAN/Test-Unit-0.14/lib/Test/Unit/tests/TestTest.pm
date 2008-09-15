package Test::Unit::tests::TestTest;
use strict;

use base qw(Test::Unit::TestCase);

use Test::Unit::tests::TornDown;
use Test::Unit::tests::WasRun;
use Test::Unit::InnerClass;

sub verify_error {
    my $self = shift;
    my ($test) = @_;
    my $result = $test->run();
    $self->assert($result->run_count() == 1);
    $self->assert($result->failure_count() == 0);
    $self->assert($result->error_count() == 1);
    $self->assert(! $result->was_successful());
}

sub verify_failure {
    my $self = shift;
    my ($test) = @_;
    my $result = $test->run();
    $self->assert($result->run_count() == 1);
    $self->assert($result->failure_count() == 1);
    $self->assert($result->error_count() == 0);
    $self->assert(! $result->was_successful());
}

sub verify_success {
    my $self = shift;
    my ($test) = @_;
    my $result = $test->run();
    $self->assert($result->run_count() == 1);
    $self->assert($result->failure_count() == 0);
    $self->assert($result->error_count() == 0);
    $self->assert($result->was_successful());
}

# test subs

sub test_case_to_string {
    my $self = shift;
    $self->assert(qr"test_case_to_string\(Test::Unit::tests::TestTest\)",
                  $self->to_string);
    $self->assert($self->to_string() eq "test_case_to_string(Test::Unit::tests::TestTest)");
}

sub test_error {
    my $self = shift;
    my $error = Test::Unit::InnerClass::make_inner_class("Test::Unit::TestCase", <<'EOIC', "error"); 
sub run_test {
    my $self = shift;
    my $e = Test::Unit::ExceptionError->new();
    die $e;
}
EOIC
    $self->verify_error($error);
}

sub test_fail {
    my $self = shift;
    my $fail = Test::Unit::InnerClass::make_inner_class("Test::Unit::TestCase", <<'EOIC', "fail"); 
sub run_test {
    my $self = shift;
    fail();
}
EOIC
    $self->verify_error($fail);
}

sub test_failure {
    my $self = shift;
    my $failure = Test::Unit::InnerClass::make_inner_class("Test::Unit::TestCase", <<'EOIC', "failure"); 
sub run_test {
    my $self = shift;
    $self->assert(0);
}
EOIC
    $self->verify_failure($failure);
}
    
sub test_failure_exception {
    my $self = shift;
    eval {
	$self->fail();
    };
    my $exception = $@;
    if ($exception->isa("Test::Unit::ExceptionFailure")) {
	return;
    }
    $self->fail();
}

sub test_run_and_tear_down_fails {
    my $self = shift;
    my $fails = Test::Unit::InnerClass::make_inner_class("TornDown", <<'EOIC', "fails");
sub tear_down {
    my $self = shift;
    $self->SUPER::tear_down();
    my $e = Test::Unit::ExceptionError->new();
    die $e;
}
sub run_test {
    my $e = Test::Unit::ExceptionError->new();
    die $e;
}
EOIC
    $self->verify_error($fails);
    $self->assert($fails->torn_down());
}

sub test_runner_printing {
    my $self = shift;
    $self->assert("1.05" eq (1050 / 1000));
}

sub test_setup_fails {
    my $self = shift;
    my $fails = Test::Unit::InnerClass::make_inner_class("Test::Unit::TestCase", <<'EOIC', "fails"); 
sub set_up {
    my $e = Test::Unit::ExceptionError->new();
    die $e;
}
sub run_test {
}
EOIC
    $self->verify_error($fails);
}

sub test_success {
    my $self = shift;
    my $success = Test::Unit::InnerClass::make_inner_class("Test::Unit::TestCase", <<'EOIC', "success"); 
sub run_test {
    my $self = shift;
    $self->assert(1);
}
EOIC
    $self->verify_success($success);
}

sub test_tear_down_after_error {
    my $self = shift;
    my $fails = Test::Unit::InnerClass::make_inner_class("TornDown", "", "fails");
    $self->verify_error($fails);
    $self->assert($fails->torn_down());
}

sub test_tear_down_fails {
    my $self = shift;
    my $fails = Test::Unit::InnerClass::make_inner_class("Test::Unit::TestCase", <<'EOIC', "fails"); 
sub tear_down {
    my $e = Test::Unit::ExceptionError->new();
    die $e;
}
sub run_test {
}
EOIC
    $self->verify_error($fails);
}

sub test_tear_down_setup_fails {
    my $self = shift;
    my $fails = Test::Unit::InnerClass::make_inner_class("TornDown", <<'EOIC', "fails");
sub set_up {
    my $self = shift;
    my $e = Test::Unit::ExceptionError->new();
    die $e;
}
EOIC
    $self->verify_error($fails);
    $self->assert(not $fails->torn_down());
}

sub test_was_not_successful {
    my $self = shift;
    my $failure = Test::Unit::InnerClass::make_inner_class("Test::Unit::TestCase", <<'EOIC', "fail"); 
sub run_test {
    my $self = shift;
    $self->fail();
}
EOIC
    $self->verify_failure($failure);
}

sub test_was_run {
    my $self = shift;
    my $test = WasRun->new("");
    $test->run();
    $self->assert($test->was_run());
}

sub test_was_successful {
    my $self = shift;
    my $success = Test::Unit::InnerClass::make_inner_class("Test::Unit::TestCase", <<'EOIC', "success"); 
sub run_test {
    my $self = shift;
    $self->assert(1);
}
EOIC
    $self->verify_success($success);
}

sub test_assert_on_matching_regex {
    my $self = shift;
    my $matching_regex = Test::Unit::InnerClass::make_inner_class("Test::Unit::TestCase", <<'EOIC', "matching_regex"); 
sub run_test {
    my $self = shift;
    $self->assert("foo" =~ /foo/, "Should have matched!");
    $self->assert(qr/foo/, "foo");
}
EOIC
    $self->verify_success($matching_regex);
}

sub test_assert_on_failing_regex {
    my $self = shift;
    my $matching_regex = Test::Unit::InnerClass::make_inner_class("Test::Unit::TestCase", <<'EOIC', "failing_regex"); 
sub run_test {
    my $self = shift;
    $self->assert(scalar("foo" =~ /bar/), "Should not have matched!");
    $self->assert(qr/bar/, "foo");
}
EOIC
    $self->verify_failure($matching_regex);
}

sub test_assert_with_non_assertion_object {
    my $self = shift;
    my $obj = bless {}, 'NonExistentClass';
    $self->assert($obj, "Object should eval to true");
}
1;
