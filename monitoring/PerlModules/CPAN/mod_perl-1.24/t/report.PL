
use ExtUtils::MakeMaker;
use Mail::Send ();
use Config;

use ExtUtils::testlib;
use lib qw(../blib/lib ../blib/arch);
use Apache::src;

my $src = Apache::src->new;
my $ap_v = $src->httpd_version;
my $ap_mmn = $src->module_magic_number;

my $mp_version = MM->parse_version(-e "lib/mod_perl.pm" ? 
	"lib/mod_perl.pm" : "../lib/mod_perl.pm");

my $msg = Mail::Send->new(
	To => 'modperl-cvs@apache.org',
	Subject => 'mod_perl test report');

my $fh = $msg->open;
$fh->print("mod_perl VERSION: $mp_version\n",
	   "Apache version: $ap_v\n",
	   "Apache MMN: $ap_mmn\n\n",
	join('', <>), "\n", Config::myconfig());
$fh->close;
