# This -*- perl -*- script makes the Makefile
# $Id: Makefile.PL,v 1.1.1.1 2003-05-30 02:17:26 cvs Exp $

#--- Distribution section ---

$DISTNAME = 'TimeDate';
$VERSION  = "1.14";

#--- Write the Makefile

BEGIN { require 5.004 }

use ExtUtils::MakeMaker;

WriteMakefile(
	VERSION   => $VERSION,
	NAME      => $DISTNAME,
);


