package Test::Unit::Setup;
use strict;

use base qw(Test::Unit::Decorator);

sub run {
    my $self    = shift();
    my($result) = @_;
    my $protectable = sub {
        $self->set_up();
        $self->basic_run($result);
        $self->tear_down();
    };
    $result->run_protected($self, $protectable);
}

# Sets up the fixture. Override to set up additional fixture
# state.

sub set_up {
    print "Suite setup\n";
}

# Tears down the fixture. Override to tear down the additional
# fixture state.
 
sub tear_down {
    print "Suite teardown\n";
}

1;
__END__


=head1 NAME

Test::Unit::Setup - unit testing framework helper class

=head1 SYNOPSIS

    # A Decorator to set up and tear down additional fixture state.
    # Subclass Setup and insert it into your tests when you want
    # to set up additional state once before the tests are run.

=head1 DESCRIPTION

A Decorator to set up and tear down additional fixture state.
Subclass Setup and insert it into your tests when you want
to set up additional state once before the tests are run.

=head1 AUTHOR

Copyright (c) 2001 Kevin Connor <kconnor@interwoven.com>

All rights reserved. This program is free software; you can
redistribute it and/or modify it under the same terms as
Perl itself.

=head1 SEE ALSO

L<Test::Unit::TestCase>, L<Test::Unit::Exception>

=cut
