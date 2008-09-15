package TestTest;
use strict;

use base qw(Test::Unit::TestCase);

use TornDown;
use WasRun;
use Test::Unit::Error;
use Test::Unit::Failure;
use Class::Inner;
use Error qw/:try/;

sub verify_error {
    my $self = shift;
    my ($test) = @_;
    my $result = $test->run();
    $self->assert_num_equals(1, $result->run_count());
    $self->assert_num_equals(0, $result->failure_count());
    $self->assert_num_equals(1, $result->error_count());
    $self->assert(! $result->was_successful());
}

sub verify_failure {
    my $self = shift;
    my ($test) = @_;
    my $result = $test->run();
    $self->assert_num_equals(1, $result->run_count());
    $self->assert_num_equals(1, $result->failure_count());
    $self->assert_num_equals(0, $result->error_count());
    $self->assert(! $result->was_successful());
}

sub verify_success {
    my $self = shift;
    my ($test) = @_;
    my $result = $test->run();
    $self->assert_num_equals(1, $result->run_count());
    $self->assert_num_equals(0, $result->failure_count());
    $self->assert_num_equals(0, $result->error_count());
    $self->assert($result->was_successful());
}

# test subs

sub make_dummy_testcase {
    my $self = shift;
    my $sub  = pop;
    my $method_name = shift || 'run_test';
    my $test_name = (caller(1))[3] . '_inner';
    
    Class::Inner->new(parent  => 'Test::Unit::TestCase',
                      methods => { $method_name => $sub },
                      args    => [ $test_name ]);
}

sub test_case_to_string {
    my $self = shift;
    $self->assert(qr"test_case_to_string\(TestTest\)",
                  $self->to_string);
    $self->assert($self->to_string() eq "test_case_to_string(TestTest)");
}

sub test_error {
    my $self = shift;
    my $error = $self->make_dummy_testcase(
        sub { Test::Unit::Error->throw(-object => $self); }
    );
    $self->verify_error($error);
}

sub test_die {
    my $self = shift;
    my $fail = $self->make_dummy_testcase(sub { my $self = shift; die "died" });
    $self->verify_error($fail);
}

sub test_fail {
    my $self = shift;
    my $fail = $self->make_dummy_testcase(sub { my $self = shift; fail() });
    $self->verify_error($fail);
}

sub test_failure {
    my $self = shift;
    my $failure = $self->make_dummy_testcase(
        sub {
            my $self = shift;
            $self->assert(0);
        }
    );
    $self->verify_failure($failure);
}

sub test_failure_exception {
    my $self = shift;
    try {
        $self->fail;
    }
    catch Test::Unit::Failure with {
        1;
    }
    otherwise {
        $self->fail;
    }
}

sub test_run_and_tear_down_both_throw {
    my $self = shift;
    my $fails = Class::Inner->new(
        parent  => 'TornDown',
        methods => { 
            run_test => sub {
                throw Test::Unit::Error -object => $_[0];
            },
            tear_down => sub {
                my $self = shift;
                $self->SUPER;
                die "this tear_down dies";
            },
        },
        args    => [ 'test_run_and_tear_down_both_throw_inner' ],
    );
    $self->verify_error($fails);
    $self->assert($fails->torn_down());
}

sub test_run_and_tear_down_both_throw2 {
    my $self = shift;
    my $fails = Class::Inner->new(
        parent  => 'TornDown',
        methods => { 
            run_test => sub {
                die "this run_test dies";
            },
            tear_down => sub {
                my $self = shift;
                $self->SUPER;
                throw Test::Unit::Error -object => $_[0];
            },
        },
        args    => [ 'test_run_and_tear_down_both_throw2_inner' ],
    );
    $self->verify_error($fails);
    $self->assert($fails->torn_down());
}

sub test_runner_printing {
    my $self = shift;
    $self->assert("1.05" eq (1050 / 1000));
}

sub test_setup_fails {
    my $self = shift;
    my $fails = Class::Inner->new(
        parent  => 'Test::Unit::TestCase',
        methods => {
            set_up => sub {
                my $self = shift;
                throw Test::Unit::Error -object => $self;
            },
            run_test => sub {},
        },
        args    => [ 'test_setup_fails_inner' ],
    );
    $self->verify_error($fails);
}

sub test_success {
    my $self = shift;
    my $success = $self->make_dummy_testcase(sub {shift->assert(1)});
    $self->verify_success($success);
}

sub test_tear_down_after_error {
    my $self = shift;
    my $fails = Class::Inner->new(
        parent  => 'TornDown',
        methods => { dummy => sub {} },
        args    => [ 'test_tear_down_after_error_inner' ],
    );
    $self->verify_error($fails);
    $self->assert($fails->torn_down());
}

sub test_tear_down_dies {
    my $self = shift;
    my $fails = Class::Inner->new(
        parent  => 'Test::Unit::TestCase',
        methods => {
            tear_down => sub { die "this tear_down dies" },
            run_test  => {}
        },
        args    => [ 'test_tear_down_dies_inner' ],
    );
    $self->verify_error($fails);
}

sub test_tear_down_fails {
    my $self = shift;
    my $fails = Class::Inner->new(
        parent  => 'Test::Unit::TestCase',
        methods => {
            tear_down => sub {
                Test::Unit::Error->throw(
                    -text => "this tear_down throws an Error"
                );
            },
            run_test  => {}
        },
        args    => [ 'test_tear_down_fails_inner' ],
    );
    $self->verify_error($fails);
}

sub test_set_up_dies_no_tear_down {
    my $self = shift;
    my $fails = Class::Inner->new(
        parent  => 'TornDown',
        methods => { set_up => sub { die "this set_up dies" } },
        args    => [ 'test_set_up_dies_no_tear_down_inner' ],
    );
    $self->verify_error($fails);
    $self->assert(! $fails->torn_down());
}

sub test_set_up_throws_no_tear_down {
    my $self = shift;
    my $fails = Class::Inner->new(
        parent  => 'TornDown',
        methods => {
            set_up => sub {
                Test::Unit::Error->throw(
                    -text => "this set_up throws an Error"
                );
            }
        },
        args    => [ 'test_set_up_throws_no_tear_down_inner' ],
    );
    $self->verify_error($fails);
    $self->assert(! $fails->torn_down());
}

sub test_was_not_successful {
    my $self = shift;
    my $failure = $self->make_dummy_testcase(sub { shift->fail });
    $self->verify_failure($failure);
}

sub test_was_run {
    my $self = shift;
    my $test = WasRun->new("WasRun");
    $test->run();
    $self->assert($test->was_run());
}

sub test_was_successful {
    my $self = shift;
    my $success = $self->make_dummy_testcase(sub { shift->assert(1) });
    $self->verify_success($success);
}

sub test_assert_on_matching_regex {
    my $self = shift;
    my $matching_regex = $self->make_dummy_testcase
        (sub {
             my $self = shift;
             $self->assert(scalar('foo' =~ /foo/), 'foo matches foo (boolean)');
             $self->assert(qr/foo/, 'foo', 'foo matches foo (Assertion::Regex)');
         });
    $self->verify_success($matching_regex);
}

sub test_assert_on_failing_regex {
    my $self = shift;
    
    my $matching_regex = $self->make_dummy_testcase
        (sub {
             my $self = shift;
             $self->assert(scalar("foo" =~ /bar/), "Should not have matched!");
             $self->assert(qr/bar/, "foo");
         });
    $self->verify_failure($matching_regex);
}

sub test_assert_with_non_assertion_object {
    my $self = shift;
    my $obj = bless {}, 'NonExistentClass';
    $self->assert($obj, "Object should eval to true");
}
1;
