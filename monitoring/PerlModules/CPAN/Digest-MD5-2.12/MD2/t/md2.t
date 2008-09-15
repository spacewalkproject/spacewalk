print "1..7\n";
use strict;

use Digest::MD2 qw(md2 md2_hex);
my $testno = 0;

# From RFC 1319
my $TESTS = <<'EOT';
MD2 ("") = 8350e5a3e24c153df2275c9f80692773
MD2 ("a") = 32ec01ec4a6dac72c0ab96fb34c0b5d1
MD2 ("abc") = da853b0d3f88d99b30283a69e6ded6bb
MD2 ("message digest") = ab4f496bfb2a530b219ff33031fe06b0
MD2 ("abcdefghijklmnopqrstuvwxyz") = 4e8ddff3650292ab5a4108c3aa47940b
MD2 ("ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789") = da33def2a42df13975352846c30338cd
MD2 ("12345678901234567890123456789012345678901234567890123456789012345678901234567890") = d5976f79d83d3a0dc9806c3c66f3efd8
EOT

for (split(/^/, $TESTS)) {
    die unless /^MD2\s*\(\"([^\"]*)\"\)\s*=\s*(.*)/;
    my $message = $1;
    my $hexdigest = $2;
    my $bindigest = pack("H*", $hexdigest);

    my $failed;
    $failed++ unless md2($message) eq $bindigest;
    $failed++ unless md2_hex($message) eq $hexdigest;

    # Test OO interface
    $failed++ unless Digest::MD2->new->add($message)->digest eq $bindigest;
    $failed++ unless Digest::MD2->new->add($message)->hexdigest eq $hexdigest;

    print "not " if $failed;
    print "ok ", ++$testno, "\n";
}
