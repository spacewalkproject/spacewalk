
my $r = Apache->request;
$r->content_type("text/plain");
$r->send_http_header;

$r->print("OK ", $r->path_info);
