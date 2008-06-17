package SuiteTest;

use strict;

use base qw(Test::Unit::TestCase);

use Test::Unit::Result;
use Test::Unit::TestSuite;
use TornDown;
use WasRun;
require Test::Unit::Assertion::CodeRef;

my %method_hash = (runs => 'run_count',
                   failures => 'failure_count',
                   success  => 'was_successful',
                   errors   => 'error_count',);
sub new {
    my $self = shift()->SUPER::new(@_);
    $self->{_my_result} = undef;
    $self->{__default_assertion} =
        Test::Unit::Assertion::CodeRef->new(sub {
            my $arg_hash = shift;
            for (qw/runs failures errors/) {
                next unless exists $arg_hash->{$_};
                my $method = $method_hash{$_};
                my $expected = $arg_hash->{$_};
                my $got      = $self->result->$method();
                $expected == $got or
                    die "Expected $expected $_, got $got\n";
            }
            if (exists $arg_hash->{'success'}) {
                my $method = $method_hash{'success'};
                my $expected = $arg_hash->{'success'};
                my $got = $self->result->$method();
                $expected && $got || !$expected && !$got or
                    die "Expected ", $expected ? 'success,' : 'failure,',
                        ' got ', $got ? 'success.' : 'failure.', "\n";
            }
            1;
        });
    return $self;
}

sub basic_assertion {
    my $self = shift;
    $self->{__default_assertion}->do_assertion(ref($_[0]) ? shift : {@_});
}

sub result {
    my $self = shift;
    return $self->{_my_result};
}
    
sub set_up {
    my $self = shift;
    $self->{_my_result} = Test::Unit::Result->new();
}

sub suite {
    my $class = shift;
    my $suite = Test::Unit::TestSuite->empty_new("Suite Tests");
    $suite->add_test(SuiteTest->new("test_no_test_case_class"));
    $suite->add_test(SuiteTest->new("test_no_test_cases"));
    $suite->add_test(SuiteTest->new("test_one_test_case"));
    $suite->add_test(SuiteTest->new("test_not_existing_test_case"));
    $suite->add_test(SuiteTest->new("test_inherited_tests"));
    $suite->add_test(SuiteTest->new("test_inherited_inherited_tests"));
    $suite->add_test(SuiteTest->new("test_shadowed_tests"));
    $suite->add_test(SuiteTest->new("test_complex_inheritance"));
    return $suite;
}

# test subs

sub test_inherited_tests {
    my $self = shift;
    my $suite = Test::Unit::TestSuite->new("InheritedTestCase");
    $suite->run($self->result());
    $self->basic_assertion({success => 1, runs => 2});
    $self->assert($self->result()->was_successful());
    $self->assert(2 == $self->result->run_count);
}

sub test_complex_inheritance {
    my $self = shift;
    eval q{
        package _SuperClass;
        use base qw(Test::Unit::TestCase);
        sub test_case {
            my $self = shift;
            $self->assert($self->override_this_method );
        }
        sub override_this_method { 0 ; }
        
        package _SubClass;
        use base qw(_SuperClass);
        sub override_this_method { 1 ; }
    };
    die $@ if $@;
    my $suite = Test::Unit::TestSuite->new("_SubClass");
    my $result = $self->result;
    $suite->run($result);
    
    $self->assert($result->was_successful());
    $self->assert(1 == $self->result->run_count);
}

sub test_inherited_inherited_tests {
    my $self = shift;
    my $suite = Test::Unit::TestSuite->new("InheritedInheritedTestCase");
    $suite->run($self->result());
    $self->basic_assertion(success => 1, runs => 3);
    $self->assert($self->result()->was_successful());
    $self->assert(3 == $self->result()->run_count());
}

sub test_no_test_case_class {
    my $self = shift;
    eval {
      my $suite = Test::Unit::TestSuite->new("NoTestCaseClass");
    };
    $self->assert_str_equals("Class NoTestCaseClass was not a test case or test suite.\n", "$@");
}

sub test_no_test_cases {
    my $self = shift;
    my $t = Test::Unit::TestSuite->new("NoTestCases");
    $t->run($self->result());
    $self->basic_assertion(runs => 1, failures => 1, success => 0);
    $self->assert(1 == $self->result()->run_count()); # warning test
    $self->assert(1 == $self->result()->failure_count());
    $self->assert(not $self->result()->was_successful());
}

sub test_not_existing_test_case {
    my $self = shift;
    my $t = SuiteTest->new("not_existing_method");
    $t->run($self->result());
    $self->basic_assertion(runs => 1, failures => 1, errors => 0);
    $self->assert(1 == $self->result()->run_count());
    $self->assert(1 == $self->result()->failure_count());
    $self->assert(0 == $self->result()->error_count());
}

sub test_one_test_case {
    my $self = shift;
    my $t = Test::Unit::TestSuite->new("OneTestCase");
    $t->run($self->result());
    $self->basic_assertion(runs => 1, failures => 0, errors => 0, success => 1);
    $self->assert(1 == $self->result()->run_count());
    $self->assert(0 == $self->result()->failure_count());
    $self->assert(0 == $self->result()->error_count());
    $self->assert($self->result()->was_successful());
}

sub test_shadowed_tests {
    my $self = shift;
    my $t = Test::Unit::TestSuite->new("OverrideTestCase");
    $t->run($self->result());
    $self->basic_assertion(runs => 1);
    $self->assert(1 == $self->result()->run_count());
}



1;

