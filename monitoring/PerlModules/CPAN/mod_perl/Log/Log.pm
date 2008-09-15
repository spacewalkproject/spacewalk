package Apache::Log;

use mod_perl ();

$VERSION = '1.01';
__PACKAGE__->mod_perl::boot($VERSION);

1;
__END__

=head1 NAME

Apache::Log - Interface to Apache logging

=head1 SYNOPSIS

  use Apache::Log ();
  my $rlog = $r->log;
  $rlog->debug("You only see this if `LogLevel' is set to `debug'");

  my $slog = $r->server->log;

=head1 DESCRIPTION

The Apache::Log module provides an interface to Apache's I<ap_log_error>
and I<ap_log_rerror> routines.

=over 4

=item emerg

=item alert

=item crit

=item error

=item warn

=item notice

=item info

=item debug

=back

=head1 AUTHOR

Doug MacEachern

=head1 SEE ALSO

mod_perl(3), Apache(3).

=cut
