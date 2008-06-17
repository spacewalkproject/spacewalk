package NOCpulse::Utils::XML;

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
