# $Id: Makefile.PL,v 1.1.1.1 2002-02-09 00:37:00 dfaraldo Exp $
#
#  Copyright (c) 1995-2000, Raphael Manfredi
#  
#  You may redistribute only under the same terms as Perl 5, as specified
#  in the README file that comes with the distribution.
#
# $Log: not supported by cvs2svn $
# Revision 1.0.1.1  2001/01/03 09:38:39  ram
# patch7: removed spurious 'clean' entry
#
# Revision 1.0  2000/09/01 19:40:41  ram
# Baseline for first official release.
#

use ExtUtils::MakeMaker;
use Config;

WriteMakefile(
    'NAME'			=> 'Storable',
    'DISTNAME'		=> "Storable",
	'MAN3PODS'		=> {},
    'VERSION_FROM'	=> 'Storable.pm',
    'dist'			=> { SUFFIX => 'gz', COMPRESS => 'gzip -f' },
);

