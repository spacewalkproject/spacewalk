
package LWP::Protocol::handler;

use LWP::Protocol;
@ISA = qw(LWP::Protocol);

use strict;
use HTTP::Request;
use HTTP::Response;
use HTTP::Status;
use HTTP::Date;
use URI::Escape;
use NOCpulse::MockApacheRequest;

sub request
{
    my($self, $http_request, $proxy, $arg, $size) = @_;

    my $url = $http_request->url;

    my $scheme = $url->scheme;
    if ($scheme ne 'handler') {
	return HTTP::Response->new(&HTTP::Status::RC_INTERNAL_SERVER_ERROR,
				   "LWP::Protocol::handler::request called for '$scheme'");
    }
    
    my $uri = $http_request->uri;
    $uri =~ /^handler:\/\/([^\/]+)/;
    my $handler_class = $1;
    
    my $apache_request = NOCpulse::MockApacheRequest->new();
    $apache_request->query_string($http_request->content());
    
    my $status;
    {
	eval "use $handler_class;";
	no strict "refs";
	# need to eval {} this next line?
	$status = &{$handler_class.'::handler'}($apache_request);
    }
    
    my $response = HTTP::Response->new($status);

    my $content = $apache_request->output();
    
    $response->header('Content-Length', scalar($content));
    $response->is_success(1);
    $response->content($content);
    
    return $response;
}

1;
