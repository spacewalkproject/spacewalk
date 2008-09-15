package NOCpulse::Probe::Config::UnixOS;

use strict;

use Exporter();
use vars qw(@EXPORT_OK @ISA %EXPORT_TAGS);
@EXPORT_OK   = qw(os_matches os_is_irix os_is_aix os_configured_to_uname os_uname_to_configured
                  UNAME_TO_CONFIGURED_OS CONFIGURED_TO_UNAME_OS
                  LINUX SOLARIS IRIX IRIX64 BSD HPUX AIX
                  PROBE_LINUX PROBE_SATELLITE PROBE_SOLARIS PROBE_IRIX PROBE_BSD PROBE_HPUX PROBE_AIX);
%EXPORT_TAGS = (constants => \@EXPORT_OK);

@ISA = qw(Exporter);

use NOCpulse::Probe::Error;

use constant PROBE_LINUX     => 'Linux System';
use constant PROBE_SATELLITE => 'Spacewalk';
use constant PROBE_SOLARIS   => 'Solaris System';
use constant PROBE_IRIX      => 'Irix System';
use constant PROBE_BSD       => 'BSD System';
use constant PROBE_HPUX      => 'HP-UX System';
use constant PROBE_AIX       => 'AIX System';

use constant LINUX   => 'Linux';
use constant SOLARIS => 'SunOS';
use constant IRIX    => 'IRIX';
use constant IRIX64  => 'IRIX64';
use constant BSD     => 'FreeBSD';
use constant HPUX    => 'HP-UX';
use constant AIX     => 'AIX';

use constant CONFIGURED_TO_UNAME_OS =>
  {
   PROBE_LINUX()     => LINUX(),
   PROBE_SATELLITE() => LINUX(),
   PROBE_SOLARIS()   => SOLARIS(),
   PROBE_IRIX()      => IRIX(),
   PROBE_BSD()       => BSD(),
   PROBE_HPUX()      => HPUX(),
   PROBE_AIX()       => AIX(),
  };

use constant UNAME_TO_CONFIGURED_OS =>
  {
   LINUX()   => PROBE_LINUX(),
   SOLARIS() => PROBE_SOLARIS(),
   IRIX()    => PROBE_IRIX(),
   IRIX64()  => PROBE_IRIX(),
   BSD()     => PROBE_BSD(),
   HPUX()    => PROBE_HPUX(),
   AIX()     => PROBE_AIX(),
  };

sub os_configured_to_uname {
    my $os = shift;
    return CONFIGURED_TO_UNAME_OS->{$os};
}

sub os_uname_to_configured {
    my $os = shift;
    return UNAME_TO_CONFIGURED_OS->{$os};
}

# Returns true value if the given OS is IRIX or IRIX64.
sub os_is_irix {
    my $os = shift;
    return $os eq IRIX || $os eq IRIX64;
}

# Returns true value if the given OS is AIX.
sub os_is_aix {
    my $os = shift;
    return $os eq AIX;
}

# Returns true value if the configured OS and the real one
# returned by uname match, false otherwise.
sub os_matches {
    my ($uname_os, $configured_os) = @_;
    return os_uname_to_configured($uname_os) eq $configured_os
      || $uname_os eq LINUX && $configured_os eq PROBE_SATELLITE;
}

1;
