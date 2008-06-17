use strict;
use Apache::test;
my $i = 0;
my $r = shift;
$r->send_http_header("text/plain");

eval {
    require Apache::Log;
};
if($@) {
    print "$@\n";
    print "1..0\n";
    return;
}

my $rlog = $r->log;
my $slog = $r->server->log;
my @methods = qw{
emerg
alert
crit
error
warn
notice
info
debug
};
my $tests = @methods * 2;
$tests += 2;

print "1..$tests\n";
for my $method (@methods)
{
    if(defined $ENV{USER} and $ENV{USER} eq "dougm") {
	$rlog->$method("Apache->method $method ", "OK");
	$slog->$method("Apache::Server->method $method ", "OK");
    }
    print "method $method OK\n";
    test ++$i, $rlog->can($method);
    test ++$i, $slog->can($method);
}

my $x = 0;
$r->log->warn(sub { ++$x; "log __ANON__ OK" });
test ++$i, $x;

my $zero = 0;
$r->log->debug(sub { ++$zero; "NOT OK" }); #LogLevel not set this high w/ 'make test'
test ++$i, $zero == 0;
