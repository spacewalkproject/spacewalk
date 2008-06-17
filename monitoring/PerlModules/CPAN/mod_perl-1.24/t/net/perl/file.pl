use strict;
use Apache::test;

my $r = shift;
$r->send_http_header('text/plain');

unless(have_module "Apache::File") {
    print "1..0\n";
    return;
}

# untaint $ENV{PATH}
$ENV{'PATH'} = '/bin:/usr/bin';
require Apache::File;

print "1..6\n";
my $fh = Apache::File->new;
my $i = 0;
test ++$i, $fh;
test ++$i, $fh->open($r->filename);
test ++$i, !$fh->open($r->filename.".nochance");
test ++$i, !Apache::File->new($r->filename.".yeahright");
#my $tmp = Apache::File->tmp;
#test ++$i, $tmp;
#++$i;
#print $tmp "ok $i\n";
#seek $tmp, 0, 0;
#print scalar(<$tmp>);
test ++$i, Apache::File->tmpfile;

$r->update_mtime;
test ++$i, $r->mtime;
print scalar localtime $r->mtime;
