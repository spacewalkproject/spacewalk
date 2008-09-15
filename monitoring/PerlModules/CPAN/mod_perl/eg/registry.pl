#see Apache::Registry

#just like test.pl, but using Apache->methods

my $r = Apache->request;
$r->content_type("text/html");
$r->send_http_header();
%ENV = $r->cgi_env;

$r->print(
  "<b>Date: ", scalar localtime, "</b><br>\n",

  "%ENV: <br>\n", map { "$_ = $ENV{$_} <br>\n" } keys %ENV,
);

