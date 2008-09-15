#
# a MakeMaker script for IO::Socket::SSL (aspa@hip.fi).
#
# $Id: Makefile.PL,v 1.1.1.1 2002-02-23 00:31:09 dfaraldo Exp $.
#

use 5.00503; # prior versions have problems with self-ties.
use ExtUtils::MakeMaker;
use English;

# See lib/ExtUtils/MakeMaker.pm for details of how to influence
# the contents of the Makefile that is written.
WriteMakefile(
  'NAME'	=> 'IO::Socket::SSL',
  'VERSION_FROM' => 'lib/IO/Socket/SSL.pm',
  'DISTNAME' => 'IO-Socket-SSL',
  'PREREQ_PM' => { 'Net::SSLeay' => 1.03 },
  'dist' => { COMPRESS => 'gzip', SUFFIX => 'gz', },
);
