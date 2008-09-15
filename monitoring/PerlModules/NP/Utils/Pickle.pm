package NOCpulse::Utils::Pickle;

use strict;

use XML::Dumper;

# This module serializes and unserialized an XML stream.

# Serialize
# turn an XML object into bits
sub pickle {
  my $class = shift;
  my $object = shift;

  my $dumper = XML::Dumper->new;

  return $dumper->pl2xml($object);
}

# Unserialize
# turn bits into an XML object
sub unpickle {
  my $class = shift;
  my $bits = shift;

  my $dumper = XML::Dumper->new;

  return $dumper->xml2pl($bits);
}

1;
