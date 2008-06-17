package Test::Unit::Exception;
use strict;
use constant DEBUG => 0;

sub new {
    my $pkg = shift;
    my $class = ref $pkg || $pkg;
    my ($message) = @_;
    
    $message = '' unless defined($message);
    $message = "$class:\n$message\n";

    my $i = 0;
    my $stacktrace = '';
    my ($pack, $file, $line, $subname, $hasargs, $wantarray);
    
    while (($pack, $file, $line, $subname, 
	    $hasargs, $wantarray) = caller(++$i)) {
	$stacktrace .= "Level $i: in package '$pack', file '$file', at line '$line', sub '$subname'\n";
    }
    
    bless { _message => $message, _stacktrace => $stacktrace }, $class;
}

sub stacktrace {
    my $self = shift;
    return $self->{_stacktrace};
}

sub get_message {
    my $self = shift;
    return $self->{_message};
}

sub hide_backtrace {
    my $self = shift;
    $self->{_hide_backtrace} = 1;
}

sub to_string {
    my $self = shift;
    return $self->get_message() if $self->{_hide_backtrace};
    return $self->get_message() . $self->stacktrace();
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

L<Test::Unit::ExceptionError>

=item *

L<Test::Unit::ExceptionFailure>

=back

=cut
