package TestAssertionCodeRef;
use strict;

use base qw(Test::Unit::TestCase);

sub test_case_to_string { my $self = shift; $self->assert(sub { my
$self = shift; $self->to_string eq shift; }, $self,
"test_noy_to_string(" . ref($self) . ")"); }

sub test_with_a_regex {
    my $self = shift;
    $self->assert(qr/foo/, 'foo');
    $self->assert(qr/bar/, 'foo');
}
1;
