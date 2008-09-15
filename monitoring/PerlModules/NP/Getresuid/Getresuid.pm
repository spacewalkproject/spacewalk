package Getresuid;

use 5.00503;
use strict;

require Exporter;
require DynaLoader;
use vars qw($VERSION @ISA @EXPORT @EXPORT_OK %EXPORT_TAGS);
@ISA = qw(Exporter DynaLoader);

# Items to export into callers namespace by default. Note: do not export
# names by default without a very good reason. Use EXPORT_OK instead.
# Do not simply export all your public functions/methods/constants.

# This allows declaration	use Getresuid ':all';
# If you do not need this, moving things directly into @EXPORT or @EXPORT_OK
# will save memory.
%EXPORT_TAGS = ( 'all' => [ qw(
	
) ] );

@EXPORT_OK = ( @{ $EXPORT_TAGS{'all'} } );

@EXPORT = qw(
  getresuid
  getresgid
  setresuid
  setresgid
);
$VERSION = '0.01';

bootstrap Getresuid $VERSION;

# Preloaded methods go here.

1;
__END__

=head1 NAME

Getresuid - Perl extension for getresuid/getresgid Linux system calls

=head1 SYNOPSIS

  use Getresuid;
  
  my($ruid, $euid, $suid) = getresuid();
  my $rv = setresuid($ruid, $euid, $suid);

  my($rgid, $egid, $sgid) = getresgid();
  my $rv = setresgid($rgid, $egid, $sgid);


=head1 DESCRIPTION

The Getresuid module imports the 'getresuid' and 'getresgid' Linux
system calls.

=head1 EXPORTS

getresuid() - get real, effective, and saved UID

setresuid() - set real, effective, and saved UID

getresgid() - get real, effective, and saved GID

setresgid() - set real, effective, and saved GID


=head1 AUTHOR

Dave Faraldo<lt>dfaraldo@redhat.com<gt>

=head1 DATE

Last modified: $Date: 2003-09-03 02:42:59 $

=head1 SEE ALSO

The 'getresuid' and 'getresgid' man pages.

=cut
