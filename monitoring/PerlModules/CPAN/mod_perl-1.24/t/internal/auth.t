use Apache::test;

my $ua = Apache::UserAgent->new;
my $url = URI::URL->new("http://$net::httpserver/auth/.htaccess");
my $i;
my $request = HTTP::Request->new(GET => $url); 

unless($net::callback_hooks{PERL_AUTHEN}) {
    print "1..1\nok 1\n";
    exit(0);
}

print "1..2\n";

my $response = $ua->request($request, undef, undef);

test ++$i, $response->is_success;
#print $response->as_string;
$ua->creds(qw(bad one));

$response = $ua->request($request, undef, undef);

test ++$i, $response->is_error;

BEGIN {
package Apache::UserAgent;
@ISA = qw(LWP::UserAgent);
@creds = qw(dougm mod_perl);  

sub get_basic_credentials { shift->creds }

sub creds {
    shift;
    @creds = @_ if @_;
    @creds;
}

}
