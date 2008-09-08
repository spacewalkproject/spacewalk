package NOCpulse::Utils::Error;
#
# Copyright (c) 2008 Red Hat, Inc.
#
# This software is licensed to you under the GNU General Public License,
# version 2 (GPLv2). There is NO WARRANTY for this software, express or
# implied, including the implied warranties of MERCHANTABILITY or FITNESS
# FOR A PARTICULAR PURPOSE. You should have received a copy of GPLv2
# along with this software; if not, see
# http://www.gnu.org/licenses/old-licenses/gpl-2.0.txt.
#
# Red Hat trademarks are not licensed under GPLv2. No permission is
# granted to use or replicate Red Hat trademarks that are incorporated
# in this software or its documentation.
#
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
