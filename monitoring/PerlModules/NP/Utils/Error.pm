package NOCpulse::Utils::Error;

use strict;
use Error;

use base qw(Error::Simple);

# Always get stack traces
$Error::Debug = 1;

sub new {
    my $class = shift;
    my $message = "" . shift;
    my $value = shift;

    # Treat the second value as the "object" field if it's a ref.
    my $object = $value if ref($value);

    my $i = $Error::Depth;
    my @stack = ();
    while (my ($package, $filename, $line, $subroutine) = caller($i++)) {
        push(@stack, "$filename line $line") unless ($package =~ '^Error')
    }
    my $text = "$class: $message at $stack[0]";

    my $self = $class->SUPER::new($text, $value);
    $self->{'-stacktrace'} = join("\n\tcalled from ", @stack);

    $self->{'-object'} = $object if $object;

    # Message is what was originally thrown, with no file or line info.
    $self->{'-message'} = $message;

    return $self;
}

sub stringify {
    my $self = shift;
    return $self->text . "\t" . $self->stacktrace() . "\n" if ($Error::Debug);
    return $self->SUPER::stringify();
}

sub message {
    my $self = shift;
    exists $self->{'-message'} ? $self->{'-message'} : undef;
}

1;
