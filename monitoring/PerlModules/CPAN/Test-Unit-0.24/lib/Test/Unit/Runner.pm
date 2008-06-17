package Test::Unit::Runner;
use strict;

use Test::Unit::Result;

use base qw(Test::Unit::Listener);

sub create_test_result {
  my $self = shift;
  return $self->{_result} = Test::Unit::Result->new();
}

sub result { shift->{_result} }

sub start_suite {
    my $self = shift;
    my ($suite) = @_;
    push @{ $self->{_suites_running} }, $suite;
} 

sub end_suite {
    my $self = shift;
    my ($suite) = @_;
    pop @{ $self->{_suites_running} };
}

sub suites_running {
    my $self = shift;
    return @{ $self->{_suites_running} || [] };
}

sub filter {
    my $self = shift;
    my (@filter) = @_;

    $self->{_filter} = [ @filter ] if @filter;

    return @{ $self->{_filter} || [] };
}

1;
__END__


=head1 NAME

    Test::Unit::Runner - abstract base class for test runners

=head1 SYNOPSIS

    # this class is not intended to be used directly 

=head1 DESCRIPTION

    This class is a parent class of all test runners, and represents
    state (e.g. run-time options) available to all runner classes.

=head1 AUTHOR

    Copyright (c) 2000 Brian Ewins, Christian Lemburg, <lemburg@acm.org>.

    All rights reserved. This program is free software; you can
    redistribute it and/or modify it under the same terms as
    Perl itself.

    Thanks go to the other PerlUnit framework people: 
    Cayte Lindner, J.E. Fritz, Zhon Johansen.

=head1 SEE ALSO

    - Test::Unit::HarnessUnit
    - Test::Unit::TestRunner
    - Test::Unit::TkTestRunner

=cut
