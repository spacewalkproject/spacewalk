package NOCpulse::Utils::XML;
#
# Copyright (c) 2008 Red Hat, Inc.
#
# This software is licensed to you under the GNU General Public License,
# version 2 (GPLv2). There is NO WARRANTY for this software, express or
# implied, including the implied warranties of MERCHANTABILITY or FITNESS
# FOR A PARTICULAR PURPOSE. You should have received a copy of GPLv2
# along with this software; if not, see
# http://www.gnu.org/licenses/old-licenses/gpl-2.0.txt.
#
# Red Hat trademarks are not licensed under GPLv2. No permission is
# granted to use or replicate Red Hat trademarks that are incorporated
# in this software or its documentation.
#
use strict;

use MIME::Base64;
use Storable qw/nfreeze thaw/;

# This module serializes and unserialized an XML stream.

# Serialize
# turn an XML object into bits
sub serialize {
  my $class = shift;
  my $object = shift;

  return encode_base64(nfreeze($object));
}

# Unserialize
# turn bits into an XML object
sub unserialize {
  my $class = shift;
  my $bits = shift;

  return thaw(decode_base64($bits));
}

1;
