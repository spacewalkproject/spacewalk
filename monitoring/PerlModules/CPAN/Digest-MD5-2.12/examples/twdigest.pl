#!/usr/local/bin/perl

use MD5;

#
# twdigest -- format MD5 digest like TripWire does
#
# This converts the md5->digest binary string to
# 64-radix ascii, given the base-vector:
# 0 - 9, A - Z, a - z, :, .
#

sub twdigest {
    my($digest) = @_;
    my(@chunks, $bits);

    # Convert to ASCII bit-string
    $bits = unpack("B*", $digest);

    # Round up length to multiple of 6 by prepending zeros
    $bits = ("0" x ((6 - (length($bits) % 6)) % 6)) . $bits;

    # Split into 6-bit chunks
    @chunks = grep {$_ ne ''} (split(/(.{6})/, $bits, -1));

    # Convert each 6-bit value to a single character
    foreach (@chunks)
    {
	$_ = pack("B8", "00" . $_);
	tr/\000-\011\012-\043\044-\075\076\077/0-9A-Za-z:./;
    }

    # Join all of the chunks into one string
    join('', @chunks);
}
