
use Apache::test;

skip_test unless have_module "Data::Dumper";
skip_test unless have_module "Devel::Symdump";

%Apache::ReadConfig:: = ();

$^W=0;

my $i = 0;

print "1..2\n";

require Apache::httpd_conf;

require Apache::PerlSections;

use IO::File ();

my $file = "perlsections.pl";
my $fh = IO::File->new(">$file") or die "can't open $file $!\n";

$fh->print(Apache::PerlSections->dump);

$fh->close;

my $in = IO::File->new($file) or die "can't open $file $!\n";

eval join '', <$in>;

$in->close;

test ++$i, not $@;

die $@ if $@;

test ++$i, -s $file;




