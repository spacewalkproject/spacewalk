my $r = shift;
$r->send_http_header('text/plain');
my $module = $r->args;

if (Apache->module($module)) {
    print "OK\n";
} 
