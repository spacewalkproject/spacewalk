print "1..5\n";

use Digest::SHA1 qw(sha1 sha1_hex sha1_base64);

print "not " unless Digest::SHA1->new->add("abc")->hexdigest eq "a9993e364706816aba3e25717850c26c9cd0d89d";
print "ok 1\n";

print "not " unless sha1("abc") eq pack("H*", "a9993e364706816aba3e25717850c26c9cd0d89d");
print "ok 2\n";

print "not " unless sha1_hex("abc") eq "a9993e364706816aba3e25717850c26c9cd0d89d";
print "ok 3\n";

print "not " unless sha1_base64("abc") eq "qZk+NkcGgWq6PiVxeFDCbJzQ2J0";
print "ok 4\n";

# Test file checking from too...
open(FILE, ">stest$$.txt") || die;
binmode(FILE);
for (1..512) {
    print FILE "This is line $_\n";
}
close(FILE);

open(FILE, "stest$$.txt") || die;
$digest = Digest::SHA1->new->addfile(*FILE)->b64digest;
print "$digest\nnot " unless $digest eq "1ZuIK/sQeBwqh+dIACqpnoRQUE4";
print "ok 5\n";

unlink("stest$$.txt");
