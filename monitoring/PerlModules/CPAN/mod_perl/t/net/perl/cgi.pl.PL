
use CGI ();
use strict;

my $r = CGI->new;

#warn "Running cgi.pl with $CGI::VERSION";

my($param) = $r->param('PARAM');
my($httpupload) = $r->param('HTTPUPLOAD');

$r->print( $r->header(-type => "text/plain",
		      "-X-Perl-Script" => "cgi.pl") );
$r->print( "ok $param\n" ) if $param;

my($content);
if ($httpupload) {
    no strict;
    local $/;
    $content = <$httpupload>;
    $r->print( "ok $content\n" );
}
