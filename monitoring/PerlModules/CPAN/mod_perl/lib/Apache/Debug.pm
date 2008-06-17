package Apache::Debug;
use Cwd 'fastcwd';

use vars qw($VERSION);
$VERSION = "1.61";

sub import {
    local $^W = 0;
    shift;

    my(%args) = @_;
    return unless exists $args{level};

    print STDERR "Apache::Debug: [@_]\n";
    $Apache::Registry::Debug = $args{level};

    $^M = 'a' x (1<<16);

    require Carp;
    $SIG{__DIE__} = \&Carp::confess;
}

#from HTTP::Status

my %StatusCode = (
    100 => 'Continue',
    101 => 'Switching Protocols',
    200 => 'OK',
    201 => 'Created',
    202 => 'Accepted',
    203 => 'Non-Authoritative Information',
    204 => 'No Content',
    205 => 'Reset Content',
    206 => 'Partial Content',
    300 => 'Multiple Choices',
    301 => 'Moved Permanently',
    302 => 'Moved Temporarily',
    303 => 'See Other',
    304 => 'Not Modified',
    305 => 'Use Proxy',
    400 => 'Bad Request',
    401 => 'Unauthorized',
    402 => 'Payment Required',
    403 => 'Forbidden',
    404 => 'Not Found',
    405 => 'Method Not Allowed',
    406 => 'Not Acceptable',
    407 => 'Proxy Authentication Required',
    408 => 'Request Timeout',
    409 => 'Conflict',
    410 => 'Gone',
    411 => 'Length Required',
    412 => 'Precondition Failed',
    413 => 'Request Entity Too Large',
    414 => 'Request-URI Too Large',
    415 => 'Unsupported Media Type',
    500 => 'Internal Server Error',
    501 => 'Not Implemented',
    502 => 'Bad Gateway',
    503 => 'Service Unavailable',
    504 => 'Gateway Timeout',
    505 => 'HTTP Version Not Supported',
);

sub dump {
    my($r, $status) = (shift,shift);
    my $srv  = $r->server;
    my $conn = $r->connection;
    my %headers = $r->headers_in;
    my $host = $r->get_remote_host;
    my $cwd = fastcwd;
    $r->status($status);
    $r->content_type("text/html");
    $r->content_language("en");
    $r->no_cache(1);
    $r->header_out("X-Debug-Version" => q$Id: Debug.pm,v 1.1.1.1 2000-11-15 19:38:33 kboomsli Exp $);
    $r->send_http_header;
    
    return 0 if $r->header_only;   # should not generate a body

    my $title = "$status $StatusCode{$status}";
    $r->write_client(join("\n", "<html>",
			  "<head><title>$title</title></head>",
                          "<body>", "<h3>$title</h3>", @_, 
			  "<pre>", ($@ ? "$@\n" : ""), "cwd=$cwd\n"));

    for (
	 qw(
	    method uri protocol path_info filename
            allow_options
	    )
	 )
    {
	$r->print(sprintf "<b>\$r->%-17s</b> : %s\n", $_, $r->$_() );
    }

    for (
	 qw(
	    server_admin 
	    server_hostname
            port
	    )
	 ) 
    {
	$r->print(sprintf "<b>\$s->%-17s</b> : %s\n", $_, $srv->$_() );
    }

    for (
	 qw(
	    remote_host
            remote_ip
            remote_logname
            user
            auth_type
	    )
	 )
    {
	$r->print(sprintf "<b>\$c->%-17s</b> : %s\n", $_, $conn->$_() );
    }

    my $args = $r->args;
    my %args = $r->args;
    my %in   = $r->content;
    $r->print(
		     "\n<b>scalar \$r->args       :</b> $args\n",
			 
		     "\n<b>\$r->args:</b>\n",
		     (map { "   $_ = $args{$_}\n" } sort keys %args),

		     "\n<b>\$r->content:</b>\n",
		     (map { "   $_ = $in{$_}\n" } sort keys %in),
			 
		     "\n<b>\$r->headers_in:</b>\n",		     
		     (map { sprintf "   %-12s = %s\n", $_, $headers{$_} } sort keys %headers),
		     );
    $r->print("</pre>\n</body></html>\n");
    return 0; #need to give a return status
}

1;

__END__

=head1 NAME

Apache::Debug - Utilities for debugging embedded perl code

=head1 SYNOPSIS

    use Apache::Debug ();

    Apache::Debug::dump($r, SERVER_ERROR, "Uh Oh!");

=head1 DESCRIPTION

This module sends what may be helpful debugging info to the client
rather that the error log.

