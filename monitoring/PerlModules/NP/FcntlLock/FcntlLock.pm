package FcntlLock;

use 5.008;
use strict;
use warnings;

require Exporter;

our @ISA = qw(Exporter);

# Items to export into callers namespace by default. Note: do not export
# names by default without a very good reason. Use EXPORT_OK instead.
# Do not simply export all your public functions/methods/constants.

# This allows declaration	use FcntlLock ':all';
# If you do not need this, moving things directly into @EXPORT or @EXPORT_OK
# will save memory.
our %EXPORT_TAGS = ( 
  'all' => [ qw(
    lock_ex lock_sh lock_un
  )],
);

our @EXPORT_OK = ( @{ $EXPORT_TAGS{'all'} } );

our @EXPORT = qw(
);

our $VERSION = '0.01';

require XSLoader;
XSLoader::load('FcntlLock', $VERSION);

# Preloaded methods go here.

1;
__END__
=head1 NAME

FcntlLock - Perl extension for using fcntl(2) locks

=head1 SYNOPSIS

  use FcntlLock ':all';

  # Create a shared lock on a file:
  open(SLOCK, "<lockfile") or die;
  my $rv = lock_sh(\*SLOCK);

  # Create an exclusive lock on a file (must be opened for writing):
  open(XLOCK, ">lockfile") or die;
  my $rv = lock_ex(\*XLOCK);

  # Release a lock on a file:
  my $rv = lock_un(\*LOCK);

  # ... or
  close(LOCK);



=head1 ABSTRACT

FcntlLock provides a simple interface to fcntl(2) file
locking.

=head1 DESCRIPTION

FcntlLock allows the caller to create a shared or exclusive lock on
an entire file.  The locks should work on an NFS-mounted volume or a
local filesystem.  All calls return 0 on success, -1 on failure with
$! set to the specific error.

=over 4

=item B<lock_ex>

Create an exclusive lock on a file.  Only one process may hold an
exclusive lock on a file at any given time.

=item B<lock_sh>

Create a shared lock on a file.  Multiple processes may hold shared
locks on the same file.

=item B<lock_un>

Release the lock on a file.

=back


=head1 EXPORT

None by default.

B<:all> to get lock_ex, lock_sh, and lock_un imported into your 
namespace.


=head1 SEE ALSO

fcntl(2)

=head1 AUTHOR

Dave Faraldo, E<lt>dfaraldo@redhat.comE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright 2004 by Red Hat, Inc.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself. 

=cut
