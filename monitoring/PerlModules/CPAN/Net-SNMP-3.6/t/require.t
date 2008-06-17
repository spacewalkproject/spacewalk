# -*- mode: perl -*-
# ============================================================================

# $Id: require.t,v 1.1.1.1 2001-01-05 23:26:26 dparker Exp $
# $Source: /tmp/svnmove/cvs-orig/PerlModules/CPAN/Net-SNMP-3.6/t/require.t,v $

# Required module test for Perl module Net::SNMP.

# Copyright (c) 1999-2000 David M. Town <david.town@marconi.com>.
# All rights reserved.

# This program is free software; you may redistribute it and/or modify it
# under the same terms as Perl itself.

# ============================================================================

BEGIN { $|=1; $^W=1; }

use strict;
use Test;

BEGIN { plan tests => 5 };

# Exporter.pm
eval { require Exporter; };
ok($@, '', 'Required module Exporter missing');

# Socket.pm
eval { require Socket; };
ok($@, '', 'Required module Socket missing');

# Symbol.pm
eval { require Symbol; };
ok($@, '', 'Required module Symbol missing');

# Sys::Hostname.pm
eval { require Sys::Hostname; };
ok($@, '', 'Required module Sys::Hostname missing');

# Math::BigInt.pm
eval { require Math::BigInt; };
ok($@, '', 'Required module Math::BigInt missing');

# ============================================================================
