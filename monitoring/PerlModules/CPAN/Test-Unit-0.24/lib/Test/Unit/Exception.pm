package Test::Unit::Exception;

use strict;

use Carp;
use Error;

use base 'Error';

sub throw_new {
    my $self = shift;
    my $class = ref $self;
    $class->throw(%{$self || {}},@_);
}

sub stacktrace {
    my $self = shift;
    warn "Stacktrace is deprecated and no longer works"
}

sub get_message {
    my $self = shift;
    $self->text;
}

sub hide_backtrace {
    my $self = shift;
    $self->{_hide_backtrace} = 1;
}

sub stringify {
    my $self = shift;
    my $file = $self->file;
    my $line = $self->line;
    my $message = $self->text || 'Died';
    my $object = $self->object;

    my $str = "$file:$line";
    $str .= ' - ' . $object->to_string() if $object && $object->can('to_string');
    $str .= "\n" . $message;
    return $str;
}

sub to_string {
    my $self = shift;
    $self->stringify;
}

sub failed_test {
    carp "Test::Unit::Exception::failed_test called";
    return $_[0]->object;
}

sub thrown_exception {
    carp "Test::Unit::Exception::thrown_exception called";
    return $_[0]->object;
}

1;
__END__

=head1 NAME

Test::Unit::Exception - unit testing framework exception class

=head1 SYNOPSIS

This class is not intended to be used directly 

=head1 DESCRIPTION

This class is used by the framework to communicate the result of
assertions, which will throw an instance of a subclass of this class
in case of errors or failures.

=head1 AUTHOR

Copyright (c) 2000 Christian Lemburg, E<lt>lemburg@acm.orgE<gt>.

All rights reserved. This program is free software; you can
redistribute it and/or modify it under the same terms as
Perl itself.

Thanks go to the other PerlUnit framework people: 
Brian Ewins, Cayte Lindner, J.E. Fritz, Zhon Johansen.

Thanks for patches go to:
Matthew Astley.

=head1 SEE ALSO

=over 4

=item *

L<Test::Unit::Assert>

=item *

L<Test::Unit::Error>

=item *

L<Test::Unit::Failure>

=back

=cut
