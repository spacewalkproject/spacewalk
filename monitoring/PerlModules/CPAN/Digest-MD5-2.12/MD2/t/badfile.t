# Digest::MD5 2.07 and older used to trigger a core dump when
# passed an illegal file handle that failed to open.

print "1..2\n";

use Digest::MD2 ();

$md5 = Digest::MD2->new;

eval {
   use vars qw(*FOO);
   $md5->addfile(*FOO);
};
print "not " unless $@ =~ /^Bad filehandle: FOO/;
print "ok 1\n";

open(BAR, "none-existing-file.$$");
$md5->addfile(*BAR);

print "not " unless $md5->hexdigest eq Digest::MD2->new->hexdigest;
print "ok 2\n";
