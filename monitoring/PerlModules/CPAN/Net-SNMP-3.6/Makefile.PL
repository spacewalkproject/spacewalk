# -*- mode: perl -*-
# ============================================================================

# $Id: Makefile.PL,v 1.1.1.1 2001-01-05 23:26:26 dparker Exp $
# $Source: /tmp/svnmove/cvs-orig/PerlModules/CPAN/Net-SNMP-3.6/Makefile.PL,v $

# Makefile for Perl module Net::SNMP.

# Copyright (c) 1998-2000 David M. Town <david.town@marconi.com>.
# All rights reserved.

# This program is free software; you may redistribute it and/or modify it
# under the same terms as Perl itself.

# ============================================================================

use ExtUtils::MakeMaker qw(WriteMakefile);

WriteMakefile(
   NAME          => 'Net::SNMP',
   DISTNAME      => 'Net-SNMP',
   VERSION_FROM  => 'lib/Net/SNMP.pm',
   dist          => { COMPRESS => 'gzip', SUFFIX => 'gz' },
   ($] ge '5.005') ? (
      'AUTHOR'   => 'David M. Town <david.town@marconi.com>',
      'ABSTRACT' => 'Object oriented interface to SNMP',
   ) : (),
);

exit 0;

# ============================================================================

