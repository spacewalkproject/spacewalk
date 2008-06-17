my $r = shift;

$r->custom_response(500, "/perl/server_error.pl");

my $qs = $r->args;

die "$qs\n";

