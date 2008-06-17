package Test::Unit::Debug;

=head1 NAME

Test::Unit::Debug - framework debugging control

=head1 SYNOPSIS

    package MyRunner;

    use Test::Unit::Debug qw(debug_to_file debug_pkg);

    debug_to_file('foo.log');
    debug_pkg('Test::Unit::TestCase');

=cut

use strict;

use base 'Exporter';
use vars qw(@EXPORT_OK);
@EXPORT_OK = qw(debug debug_to_file
                debug_pkg no_debug_pkg debug_pkgs no_debug_pkgs debugged);

my %DEBUG = ();
my $out = \*STDERR;

=head1 ROUTINES

=head2 debug_to_file($file)

Switch debugging to C<$file>.

=cut

sub debug_to_file {
    my ($file) = @_;
    open(DEBUG, ">$file") or die "Couldn't open $file for writing";
    $out = \*DEBUG;
}

=head2 debug_to_stderr()

Switch debugging to STDERR (this is the default).

=cut

sub debug_to_stderr {
    $out = \*STDERR;
}

sub debug {
    my ($package, $filename, $line) = caller();
    print $out @_ if $DEBUG{$package};
}

=head2 debug_pkg($pkg)

Enable debugging in package C<$pkg>.

=cut

sub debug_pkg {
    $DEBUG{$_[0]} = 1;
}

=head2 debug_pkgs(@pkgs)

Enable debugging in the packages C<@pkgs>.

=cut

sub debug_pkgs {
    $DEBUG{$_} = 1 foreach @_;
}

=head2 debug_pkg($pkg)

Enable debugging in package C<$pkg>.

=cut

sub no_debug_pkg {
    $DEBUG{$_[0]} = 0;
}

=head2 debug_pkgs(@pkgs)

Disable debugging in the packages C<@pkgs>.

=cut

sub no_debug_pkgs {
    $DEBUG{$_} = 0 foreach @_;
}

sub debugged {
    my ($package, $filename, $line) = caller();
    return $DEBUG{$_[0] || $package};
}

=head1 SEE ALSO

L<Test::Unit>

=cut

1;
