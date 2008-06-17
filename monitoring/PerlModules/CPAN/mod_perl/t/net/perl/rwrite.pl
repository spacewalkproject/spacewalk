my $r = shift;
$r->send_http_header("text/plain");

use strict;
my $string = "";

for ('A'..'Z') { 
    $string .= $_ x 1000;
}

print $string;

print "\nlength=", length($string) if $r->args;

