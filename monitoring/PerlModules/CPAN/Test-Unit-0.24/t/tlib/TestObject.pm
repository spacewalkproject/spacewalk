package TestObject;

use strict;

sub new {
    my $class = shift;
    bless [@_], $class;
}

1;
