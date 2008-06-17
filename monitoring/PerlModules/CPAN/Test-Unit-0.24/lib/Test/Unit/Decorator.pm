package Test::Unit::Decorator;
use strict;

use base qw(Test::Unit::Test);

sub new {
    my $class = shift;
    my ($fTest) = @_;
    return bless { _fTest => $fTest }, $class;
}

sub basic_run {
    my $self = shift;
    my ($result) = @_;
    $self->{_fTest}->run($result);
}

sub count_test_cases() {
    my $self = shift;
    return $self->{_fTest}->count_test_cases();
}
sub run {
    my $self = shift;
    my ($result) = @_;
    $self->{_fTest}->basic_run($result);
}

sub to_string {
    my $self = shift;
    "$self->{_fTest}";
}

sub get_test {
    my $self = shift;
    return $self->{_fTest};
}

1;
__END__


=head1 NAME

Test::Unit::Decorator - unit testing framework helper class

=head1 SYNOPSIS

    # A Decorator for Tests. Use TestDecorator as the base class
    # for defining new test decorators. Test decorator subclasses
    # can be introduced to add behaviour before or after a test
    # is run.

=head1 DESCRIPTION

A Decorator for Tests. Use TestDecorator as the base class
for defining new test decorators. Test decorator subclasses
can be introduced to add behaviour before or after a test
is run.

=head1 AUTHOR

Copyright (c) 2001 Kevin Connor <kconnor@interwoven.com>

All rights reserved. This program is free software; you can
redistribute it and/or modify it under the same terms as
Perl itself.

=head1 SEE ALSO

L<Test::Unit::TestCase>

=cut
