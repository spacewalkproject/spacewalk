#
# a MakeMaker script for IO::Socket::SSL (aspa@hip.fi).
#
# $Id: Makefile.PL,v 1.1.1.1 2003-08-22 19:58:45 cvs Exp $.
#

use 5.00503; # prior versions have problems with self-ties.
use ExtUtils::MakeMaker;
use English;


# See lib/ExtUtils/MakeMaker.pm for details of how to influence
# the contents of the Makefile that is written.
WriteMakefile(
  'NAME'	=> 'IO::Socket::SSL',
  'VERSION_FROM' => 'SSL.pm',
  'DISTNAME' => 'IO-Socket-SSL',
  'PREREQ_PM' => { 'Net::SSLeay' => 1.08 },
  'dist' => { COMPRESS => 'gzip', SUFFIX => 'gz', },
);
