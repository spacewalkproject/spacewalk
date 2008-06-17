package Test::Unit::TestSuite;
use strict;
use constant DEBUG => 0;
use base qw(Test::Unit::Test);

use Test::Unit::TestCase;
use Test::Unit::InnerClass;

use Carp;
# helper subroutines

# determine if a string is the name of a valid package. There is no
# valid way of finding out if a package is a class.

sub is_not_name_of_a_class {
    my $name = shift;
    # Check if the package exists already.
    {
        no strict 'refs';
        return if keys %{"$name\::"};
    }
    # No? Try 'require'ing it
    eval "require $name";
    warn $@, "\n" if DEBUG;
    return 1 if $@;
}

sub is_a_test_case_class {
    my $pkg = shift;
    return if is_not_name_of_a_class($pkg);
    return eval {$pkg->isa("Test::Unit::TestCase")};
}

sub new {
    my $class = shift;
    my $classname = shift || ''; # Avoid a warning
    
    my $self = {
	    _Tests => [],
	    _Name => $classname,
    };
    bless $self, $class;
    warn ref($self) . "::new($classname) called\n" if DEBUG;

    $self->build_suite($classname) if $classname;
    return $self;
}

sub build_suite {
    my $self = shift;
    my $classname = shift;
    
    is_not_name_of_a_class($classname) and die "Could not find class $classname";
    
    # it is a class, create a suite with its tests
    # ... and that of its ancestors, if they are Test::Unit::TestCase
    if (!is_a_test_case_class($classname)) {
        $self->add_warning("Class $classname is not a Test::Unit::TestCase");
        return $self;
    }

    foreach my $method ($classname->list_tests) {
        if ( my $a_class_instance = $classname->new($method) ) {
            push @{$self->tests}, $a_class_instance;
        }
        else {
            $self->add_warning("build_suite: Couldn't create a $classname object");
        }
    }

    $self->add_warning("No tests found in $classname")
        unless @{$self->tests};
    return $self;
}

sub empty_new {
    my $class = shift;
    my ($name) = @_;
    
    my $self = $class->new;
    $self->name($name);
    print ref($self), "::empty_new($name) called\n" if DEBUG;
    return $self;
}

sub name {
    my $self = shift;
    $self->{_Name} = shift if @_;
    return $self->{_Name};
}

sub names {
    my $self = shift;
    my @test_list = @{$self->tests};
    return [ map {$_->name} @test_list ] if @test_list;
}

sub add_test {
    my $self = shift;
    my ($test) = @_;
    push @{$self->tests}, $test;
}

sub count_test_cases {
    my $self = shift;
    my $count = 0;
    for my $e (@{$self->tests()}) {
        $count += $e->count_test_cases();
    }
    return $count;
}

sub run {
    my $self = shift;
    my ($result) = @_;
    for my $e (@{$self->tests()}) {
        last if $result->should_stop();
        $e->run($result);
    }
	return $result;
}
    
sub test_at {
    my $self = shift;
    my ($index) = @_;
    return $self->tests()->[$index];
}

sub test_count {
    my $self = shift;
    return scalar @{$self->tests()};
}

sub tests {
    my $self = shift;
    return $self->{_Tests};
}

sub to_string {
    my $self = shift;
    return $self->name();
}

sub add_warning {
    my $self = shift;
    $self->add_test($self->warning(join '', @_));
}

sub warning {
    my $self = shift;
    my ($message) = @_;
    Test::Unit::TestSuite::_warning->new($message);
}

package Test::Unit::TestSuite::_warning;

use strict;
use base 'Test::Unit::TestCase';

sub run_test {
    my $self = shift;
    $self->fail($self->{_message});
}

sub new {
    my $class = shift;
    my $self = $class->SUPER::new('warning');
    $self->{_message} = shift;
    return $self;
}

1;
__END__


=head1 NAME

Test::Unit::TestSuite - unit testing framework base class

=head1 SYNOPSIS

    use Test::Unit::TestSuite;

    # more code here ...

    sub suite {
	my $class = shift;

	# create an empty suite
	my $suite = Test::Unit::TestSuite->empty_new("A Test Suite");
	
	# get and add an existing suite
	$suite->add_test(Test::Unit::TestSuite->new("MyModule::Suite_1"));

	# extract suite by way of suite method and add
	$suite->add_test(MyModule::Suite_2->suite());
	
	# get and add another existing suite
	$suite->add_test(Test::Unit::TestSuite->new("MyModule::TestCase_2"));

	# return the suite built
	return $suite;
    }

=head1 DESCRIPTION

This class is normally not used directly, but it can be used for
creating your own custom built aggregate suites.

Normally, this class just provides the functionality of auto-building
a test suite by extracting methods with a name prefix of C<test> from
a given package to the test runners.

=head1 AUTHOR

Framework JUnit authored by Kent Beck and Erich Gamma.

Ported from Java to Perl by Christian Lemburg.

Copyright (c) 2000 Christian Lemburg, E<lt>lemburg@acm.orgE<gt>.

All rights reserved. This program is free software; you can
redistribute it and/or modify it under the same terms as Perl itself.

Thanks go to the other PerlUnit framework people: 
Brian Ewins, Cayte Lindner, J.E. Fritz, Zhon Johansen.

=head1 SEE ALSO

=over 4

=item *

L<Test::Unit::TestRunner>

=item *

L<Test::Unit::TkTestRunner>

=item *

For further examples, take a look at the framework self test
collection (Test::Unit::tests::AllTests).

=back

=cut
