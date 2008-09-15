# -*- mode: perl -*- 
# ============================================================================

# $Id: using.t,v 1.1.1.1 2001-01-05 23:26:26 dparker Exp $
# $Source: /tmp/svnmove/cvs-orig/PerlModules/CPAN/Net-SNMP-3.6/t/using.t,v $

# Simple usage test for Perl module Net::SNMP.

# Copyright (c) 1999-2000 David M. Town <david.town@marconi.com>.
# All rights reserved.

# This program is free software; you may redistribute it and/or modify it
# under the same terms as Perl itself.

# ============================================================================

BEGIN { $|=1; $^W=1; }

use strict;
use Test;

BEGIN { plan tests => 7 };

my ($r, $e);

# Load the Net::SNMP module
eval { require Net::SNMP; };
ok($@, '', 'Unable to load Net::SNMP module');

# Create a session to 'localhost'
eval { ($r, $e) = Net::SNMP->session; };
ok($e, '', "Failed to create Net::SNMP object: $e");

# Validate the encoding/decoding of the INTEGER value 4294967295
eval { $r->_object_clear_buffer; };
eval { $r->_asn1_encode(&Net::SNMP::INTEGER, 4294967295); };
eval { $e = $r->_asn1_decode; };
ok($e, 4294967295, "Failed to properly handle INTEGER value 4294967295");

# Validate the encoding/decoding of the INTEGER value -128
eval { $r->_object_clear_buffer; };
eval { $r->_asn1_encode(&Net::SNMP::INTEGER, -128); };
eval { $e = $r->_asn1_decode; };
ok($e, -128, "Failed to properly handle INTEGER value -128");

# Change the SNMP version to SNMPv2c
eval { $e = $r->version('SNMPv2c'); };
ok($e, 0x01, "Failed to set SNMP version to SNMPv2c");
  
# Validate the encoding/decoding of the Counter64 value 18446744073709551615
{
   local $^W=0;  # Suppress warnings from Math::BigInt

   eval { $r->_object_clear_buffer; };
   eval { $r->_asn1_encode(&Net::SNMP::COUNTER64, '18446744073709551615'); };
   eval { $e = $r->_asn1_decode; };
   ok($e, '18446744073709551615', 
      "Failed to properly handle Counter64 value 18446744073709551615"
   );
}

# Close the session
eval { $r->close; };
ok($@, '', 'Net::SNMP object not created');

# ============================================================================
