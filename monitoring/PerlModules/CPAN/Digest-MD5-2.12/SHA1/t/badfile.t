# Digest::MD5 2.07 and older used to trigger a core dump when
# passed an illegal file handle that failed to open.

print "1..2\n";

use Digest::SHA1 ();

$sha = Digest::SHA1->new;

eval {
   use vars qw(*FOO);
   $sha->addfile(*FOO);
};
print "not " unless $@ =~ /^Bad filehandle: FOO/;
print "ok 1\n";

open(BAR, "none-existing-file.$$");
$sha->addfile(*BAR);

print "not " unless $sha->hexdigest eq Digest::SHA1->new->hexdigest;
print "ok 2\n";
