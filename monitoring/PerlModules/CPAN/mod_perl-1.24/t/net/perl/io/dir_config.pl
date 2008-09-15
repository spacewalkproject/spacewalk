use strict;
use Apache::test;
use Data::Dumper ();
use Apache::ModuleConfig ();

my $r = shift;
my $i = 0;
$r->send_http_header("text/plain");

my $cfg = Apache::ModuleConfig->get($r, "Apache::TestDirectives");

$r->print(Data::Dumper::Dumper($cfg));
test ++$i, "$cfg" =~ /HASH/;
test ++$i, keys(%$cfg) >= 3;
test ++$i, $cfg->{FromNew};
unless ($cfg->{SetFromScript}) {
    $cfg->{SetFromScript} = [$0,$$];
}

my $scfg = Apache::ModuleConfig->get($r->server, "Apache::TestDirectives");
$r->print(Data::Dumper::Dumper($scfg));
