my $r = shift;

$r->send_http_header("text/plain");

print "ServerError:\n";

print $@{$r->prev->uri};

print "\n";
print 'dump of %@:', "\n";
print map { "$_ = $@{$_}\n" } keys %{'@'};

