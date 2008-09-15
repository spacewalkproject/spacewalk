package Apache;

use strict;
use mod_perl 1.17_01;
use Exporter ();
use Apache::Constants qw(OK DECLINED);
use Apache::Connection ();
use Apache::Server ();

eval { require Apache::Table; };

@Apache::EXPORT_OK = qw(exit warn);

*import = \&Exporter::import;

if (caller eq "CGI::Apache") {
    #we must die here outside of httpd so CGI::Switch works
    die unless $ENV{MOD_PERL};
}

{
    no strict;
    $VERSION = "1.26";
    __PACKAGE__->mod_perl::boot($VERSION);
}

BEGIN {
    *Apache::ReadConfig:: = \%ApacheReadConfig::;
}

sub httpd_conf {
    shift;
    push @Apache::ReadConfig::PerlConfig,
      map "$_\n", @_;
}

sub parse_args {
    my($wantarray,$string) = @_;
    return unless defined $string and $string;
    if(defined $wantarray and $wantarray) {
	return map { Apache::unescape_url_info($_) } split /[=&;]/, $string, -1;
    }
    $string;
}

sub content {
    my($r) = @_;
    my $ct = $r->header_in("Content-type") || "";
    return unless $ct =~ m!^application/x-www-form-urlencoded!;
    my $buff;
    $r->read($buff, $r->header_in("Content-length"));
    parse_args(wantarray, $buff);
}

sub args {
    my($r, $val) = @_;
    parse_args(wantarray, 
	       $val ? $r->query_string($val) : $r->query_string);
}

*READ = \&read unless defined &READ;

sub read {
    my($r, $bufsiz) = @_[0,2];
    my($nrd, $buf, $total);
    $nrd = $total = 0;
    $buf = "";
    $_[1] ||= "";
    #$_[1] = " " x $bufsiz unless defined $_[1]; #XXX?

    $r->hard_timeout("Apache->read");

    while($bufsiz) {
	$nrd = $r->read_client_block($buf, $bufsiz) || 0;
	if(defined $nrd and $nrd > 0) {
	    $bufsiz -= $nrd;
	    $_[1] .= $buf;
 	    #substr($_[1], $total, $nrd) = $buf;
	    $total += $nrd;
	    next if $bufsiz;
	    last;
	}
	else {
	    $_[1] = undef;
	    last;
	}
    }
    $r->kill_timeout;
    return $total;
}

sub new_read {
    my($r, $bufsiz) = @_[0,2];
    my($nrd, $buf, $total);
    $nrd = $total = 0;
    $buf = "";
    $_[1] ||= "";

    if(my $rv = $r->setup_client_block) {
	$r->log_error("Apache->read: setup_client_block returned $rv");
	die $rv;
    }

    #XXX: must set r->read_length to 0 here,
    #since this read() method may be called in loop
    #in which case, the second time in, should_client_block() 
    #thinks we've already read the request body and returns 0
    $r->read_length(0); 

    unless($r->should_client_block) {
	my $rl = $r->read_length;
	$r->log_error("Apache->read: should_client_block returned 0 (rl=$rl)");
	return 0;
    }

    $r->hard_timeout("Apache->read");
    
    while($bufsiz) {
	$nrd = $r->get_client_block($buf, $bufsiz) || 0;
	if(defined $nrd and $nrd > 0) {
	    $bufsiz -= $nrd;
	    $_[1] .= $buf;
 	    #substr($_[1], $total, $nrd) = $buf;
	    $total += $nrd;
	    $r->reset_timeout;
	    next if $bufsiz;
	    last;
	}
	else {
	    $_[1] = undef;
	    last;
	}
    }
    $r->kill_timeout;
    return $total;
}

sub GETC { my $c; shift->READ($c,1); $c; }

#shouldn't use <STDIN> anyhow, but we'll be nice
sub READLINE { 
    my $r = shift;
    my $line; 
    $r->read($line, $r->header_in('Content-length'));
    $line;
}

sub PRINTF {
    my $r = shift;
    my $fmt = shift;
    $r->print(sprintf($fmt, @_));
}
*printf = \&PRINTF;

sub WRITE {
    my($r, $buff, $length, $offset) = @_;
    my $send = substr($buff, $offset, $length);
    $r->print($send);
}

sub send_cgi_header {
    my($r, $headers) = @_;
    my $dlm = "\015?\012"; #a bit borrowed from LWP::UserAgent
    my($key, $val);
    local $_;
    while(($_, $headers) = split /$dlm/, $headers, 2) {
	#warn "hunk=`$_'\n";
	#warn "rest=`$headers'\n";
	if ($_ && /^(\S+?):\s*(.*)$/) {
	    ($key, $val) = ($1, $2);
	    last unless $key;
	    $r->cgi_header_out($key, $val);
	}
	else {
	    #warn "mod_perl: found header terminator\n";
	    my $not_sent = 0;
	    if($Apache::__SendHeader) {
		$not_sent = not $r->sent_header;
	    }
	    else {
		$not_sent = 1;
	    }
	    $r->send_http_header if $not_sent;
	    $r->print($headers); #send rest of buffer, without stripping newlines!!!
	    last;
	}
    }
}

1;

__END__

=head1 NAME

Apache - Perl interface to the Apache server API

=head1 SYNOPSIS

   use Apache ();

=head1 DESCRIPTION

This module provides a Perl interface the Apache API.  It is here
mainly for B<mod_perl>, but may be used for other Apache modules that
wish to embed a Perl interpreter.  We suggest that you also consult
the description of the Apache C API at http://www.apache.org/docs/.

=head1 THE REQUEST OBJECT

The request object holds all the information that the server needs to
service a request.  Apache B<Perl*Handler>s will be given a reference to the
request object as parameter and may choose to update or use it in various
ways.  Most of the methods described below obtain information from or
update the request object.
The perl version of the request object will be blessed into the B<Apache> 
package, it is really a C<request_rec*> in disguise.

=over 4

=item Apache->request([$r])

The Apache->request method will return a reference to the request object.

B<Perl*Handler>s can obtain a reference to the request object when it
is passed to them via C<@_>.  However, scripts that run under 
B<Apache::Registry>, for example, need a way to access the request object.
B<Apache::Registry> will make a request object available to these scripts
by passing an object reference to C<Apache-E<gt>request($r)>.
If handlers use modules such as B<CGI::Apache> that need to access
C<Apache-E<gt>request>, they too should do this (e.g. B<Apache::Status>).

=item $r->as_string

Returns a string representation of the request object.  Mainly useful
for debugging.

=item $r->main

If the current request is a sub-request, this method returns a blessed
reference to the main request structure.  If the current request is
the main request, then this method returns C<undef>.

=item $r->prev

This method returns a blessed reference to the previous (internal) request
structure or C<undef> if there is no previous request.

=item $r->next

This method returns a blessed reference to the next (internal) request
structure or C<undef> if there is no next request.

=item $r->last

This method returns a blessed reference to the last (internal) request
structure.  Handy for logging modules.

=item $r->is_main

Returns true if the current request object is for the main request.
(Should give the same result as C<!$r-E<gt>main>, but will be more efficient.)

=item $r->is_initial_req

Returns true if the current request is the first internal request,
returns false if the request is a sub-request or internal redirect.

=back

=head1 SUB REQUESTS

Apache provides a sub-request mechanism to lookup a uri or filename,
performing all access checks, etc., without actually running the
response phase of the given request.  Notice, we have dropped the
C<sub_req_> prefix here.  The C<request_rec*> returned by the lookup
methods is blessed into the B<Apache::SubRequest> class.  This way,
C<destroy_sub_request()> is called automatically during
C<Apache::SubRequest-E<gt>DESTROY> when the object goes out of scope.  The
B<Apache::SubRequest> class inherits all the methods from the
B<Apache> class.

=over 4

=item $r->lookup_uri($uri)

   my $subr = $r->lookup_uri($uri);
   my $filename = $subr->filename;

   unless(-e $filename) {
       warn "can't stat $filename!\n";
   } 

=item $r->lookup_file($filename)

   my $subr = $r->lookup_file($filename);

=item $subr->run

   if($subr->run != OK) {
       $subr->log_error("something went wrong!");
   }

=back

=head1 CLIENT REQUEST PARAMETERS

In this section we will take a look at various methods that can be used to
retrieve the request parameters sent from the client.
In the following examples, B<$r> is a request object blessed into the 
B<Apache> class, obtained by the first parameter passed to a handler subroutine
or I<Apache-E<gt>request>

=over 4

=item $r->method( [$meth] )

The $r->method method will return the request method.  It will be a
string such as "GET", "HEAD" or "POST".
Passing an argument will set the method, mainly used for internal redirects.

=item $r->method_number( [$num] )

The $r->method_number method will return the request method number.
The method numbers are defined by the M_GET, M_POST,... constants
available from the B<Apache::Constants> module.  Passing an argument
will set the method_number, mainly used for internal redirects and
testing authorization restriction masks.

=item $r->bytes_sent

The number of bytes sent to the client, handy for logging, etc.

=item $r->the_request

The request line sent by the client, handy for logging, etc.

=item $r->proxyreq

Returns true if the request is proxy http.
Mainly used during the filename translation stage of the request, 
which may be handled by a C<PerlTransHandler>.

=item $r->header_only

Returns true if the client is asking for headers only, 
e.g. if the request method was B<HEAD>.

=item $r->protocol

The $r->protocol method will return a string identifying the protocol
that the client speaks.  Typical values will be "HTTP/1.0" or
"HTTP/1.1".

=item $r->hostname

Returns the server host name, as set by full URI or Host: header.

=item $r->request_time

Returns the time that the request was made.  The time is the local unix
time in seconds since the epoch.

=item $r->uri( [$uri] )

The $r->uri method will return the requested URI minus optional query
string, optionally changing it with the first argument.

=item $r->filename( [$filename] )

The $r->filename method will return the result of the I<URI --E<gt>
filename> translation, optionally changing it with the first argument
if you happen to be doing the translation.

=item $r->path_info( [$path_info] )

The $r->path_info method will return what is left in the path after the
I<URI --E<gt> filename> translation, optionally changing it with the first 
argument if you happen to be doing the translation.

=item $r->args( [$query_string] )

The $r->args method will return the contents of the URI I<query
string>.  When called in a scalar context, the entire string is
returned.  When called in a list context, a list of parsed I<key> =>
I<value> pairs are returned, i.e. it can be used like this:

   $query = $r->args;
   %in    = $r->args;

$r->args can also be used to set the I<query string>. This can be useful
when redirecting a POST request.

=item $r->headers_in

The $r->headers_in method will return a %hash of client request
headers.  This can be used to initialize a perl hash, or one could use
the $r->header_in() method (described below) to retrieve a specific
header value directly.

Will return a I<HASH> reference blessed into the I<Apache::Table>
class when called in a scalar context with no "key" argument. This
requires I<Apache::Table>.

=item $r->header_in( $header_name, [$value] )

Return the value of a client header.  Can be used like this:

   $ct = $r->header_in("Content-type");
   $r->header_in($key, $val); #set the value of header '$key'

=item $r->content

The $r->content method will return the entity body read from the
client, but only if the request content type is
C<application/x-www-form-urlencoded>.
When called in a scalar context, the entire string is
returned.  When called in a list context, a list of parsed I<key> =>
I<value> pairs are returned.  *NOTE*: you can only ask for this once,
as the entire body is read from the client.

=item $r->read($buf, $bytes_to_read)

This method is used to read data from the client, 
looping until it gets all of C<$bytes_to_read> or a timeout happens.

In addition, this method sets a timeout before reading with
C<$r-E<gt>hard_timeout>.

=item $r->get_remote_host

Lookup the client's DNS hostname. If the configuration directive
B<HostNameLookups> is set to off, this returns the dotted decimal
representation of the client's IP address instead. Might return
I<undef> if the hostname is not known.

=item $r->get_remote_logname

Lookup the remote user's system name.  Might return I<undef> if the
remote system is not running an RFC 1413 server or if the configuration
directive B<IdentityCheck> is not turned on.

=back

More information about the client can be obtained from the
B<Apache::Connection> object, as described below.

=over 4

=item $c = $r->connection

The $r->connection method will return a reference to the request
connection object (blessed into the B<Apache::Connection> package).
This is really a C<conn_rec*> in disguise.  The following methods can
be used on the connection object:

=over 4

=item $c->remote_host

If the configuration directive B<HostNameLookups> is set to on:  then
the first time C<$r-E<gt>get_remote_host> is called the server does a DNS
lookup to get the remote client's host name.  The result is cached in
C<$c-E<gt>remote_host> then returned. If the server was unable to resolve
the remote client's host name this will be set to "". Subsequent calls
to C<$r-E<gt>get_remote_host> return this cached value.

If the configuration directive B<HostNameLookups> is set to off: calls
to C<$r-E<gt>get_remote_host> return a string that contains the dotted
decimal representation of the remote client's IP address. However this
string is not cached, and C<$c-E<gt>remote_host> is undefined. So, it's
best to to call C<$r-E<gt>get_remote_host> instead of directly accessing
this variable.

=item $c->remote_ip

The dotted decimal representation of the remote client's IP address.
This is set by the server when the connection record is created so
is always defined.

You can also set this value by providing an argument to it. This is
helpful if your server is behind a squid accelerator proxy which adds
a X-Forwarded-For header.

=item $c->local_addr

A packed SOCKADDR_IN in the same format as returned by
L<Socket/pack_sockaddr_in>, containing the port and address on the
local host that the remote client is connected to.  This is set by
the server when the connection record is created so it is always
defined.

=item $c->remote_addr

A packed SOCKADDR_IN in the same format as returned by
L<Socket/pack_sockaddr_in>, containing the port and address on the
remote host that the server is connected to.  This is set by the
server when the connection record is created so it is always defined.

Among other things, this can be used, together with C<$c-E<gt>local_addr>, to
perform RFC1413 ident lookups on the remote client even when the
configuration directive B<IdentityCheck> is turned off.

Can be used like:

   use Net::Ident qw (lookupFromInAddr);
   ...
   my $remoteuser = lookupFromInAddr ($c->local_addr,
                                      $c->remote_addr, 2);

Note that the lookupFromInAddr interface does not currently exist in
the B<Net::Ident> module, but the author is planning on adding it
soon.

=item $c->remote_logname

If the configuration directive B<IdentityCheck> is set to on:  then the
first time C<$r-E<gt>get_remote_logname> is called the server does an RFC
1413 (ident) lookup to get the remote users system name. Generally for
UNI* systems this is their login. The result is cached in C<$c-E<gt>remote_logname>
then returned.  Subsequent calls to C<$r-E<gt>get_remote_host> return the
cached value.

If the configuration directive B<IdentityCheck> is set to off: then 
C<$r-E<gt>get_remote_logname> does nothing and C<$c-E<gt>remote_logname> is
always undefined.

=item $c->user( [$user] )

If an authentication check was successful, the authentication handler
caches the user name here. Sets the user name to the optional first
argument.

=item $c->auth_type

Returns the authentication scheme that successfully authenticate
C<$c-E<gt>user>, if any.

=item $c->aborted

Returns true if the client stopped talking to us.

=item $c->fileno( [$direction] )

Returns the client file descriptor. If $direction is 0, the input fd
is returned. If $direction is not null or ommitted, the output fd is
returned.

This can be used to detect client disconnect without doing any I/O,
e.g. using IO::Select.

=back

=back

=head1 SERVER CONFIGURATION INFORMATION

The following methods are used to obtain information from server
configuration and access control files.

=over 4

=item $r->dir_config( $key )

Returns the value of a per-directory variable specified by the 
C<PerlSetVar> directive.

   # <Location /foo/bar>
   # PerlSetVar  Key  Value
   # </Location>

   my $val = $r->dir_config('Key');

Keys are case-insensitive.

Will return a I<HASH> reference blessed into the
I<Apache::Table> class when called in a scalar context with no
"key" argument. See I<Apache::Table>.

=item $r->requires

Returns an array reference of hash references, containing information
related to the B<require> directive.  This is normally used for access
control, see L<Apache::AuthzAge> for an example.

=item $r->auth_type

Returns a reference to the current value of the per directory
configuration directive B<AuthType>. Normally this would be set to
C<Basic> to use the basic authentication scheme defined in RFC 1945,
I<Hypertext Transfer Protocol -- HTTP/1.0>. However, you could set to
something else and implement your own authentication scheme.

=item $r->auth_name

Returns a reference to the current value of the per directory
configuration directive B<AuthName>.  The AuthName directive creates
protection realm within the server document space. To quote RFC 1945
"These realms allow the protected resources on a server to be
partitioned into a set of protection spaces, each with its own
authentication scheme and/or authorization database." The client uses
the root URL of the server to determine which authentication
credentials to send with each HTTP request. These credentials are
tagged with the name of the authentication realm that created them.
Then during the authentication stage the server uses the current
authentication realm, from C<$r-E<gt>auth_name>, to determine which set of
credentials to authenticate.

=item $r->document_root

Returns a reference to the current value of the per server
configuration directive B<DocumentRoot>. To quote the Apache server
documentation, "Unless matched by a directive like Alias, the server
appends the path from the requested URL to the document root to make
the path to the document."  This same value is passed to CGI
scripts in the C<DOCUMENT_ROOT> environment variable.

=item $r->allow_options

The C<$r-E<gt>allow_options> method can be used for
checking if it is OK to run a perl script.  The B<Apache::Options>
module provides the constants to check against.

   if(!($r->allow_options & OPT_EXECCGI)) {
       $r->log_reason("Options ExecCGI is off in this directory", 
		      $filename);
   }

=item $r->get_server_port

Returns the port number on which the server is listening.

=item $s = $r->server

Return a reference to the server info object (blessed into the
B<Apache::Server> package).  This is really a C<server_rec*> in
disguise.  The following methods can be used on the server object:

=item $s = Apache->server

Same as above, but only available during server startup for use in
<Perl> sections, B<PerlScript> or B<PerlModule>.

=item $s->server_admin

Returns the mail address of the person responsible for this server.

=item $s->server_hostname

Returns the hostname used by this server.

=item $s->port

Returns the port that this servers listens too.

=item $s->is_virtual

Returns true if this is a virtual server.

=item $s->names

Returns the wild-carded names for ServerAlias servers. 

=item $s->dir_config( $key )

Alias for Apache::dir_config.

=item $s->warn

Alias for Apache::warn.

=item $s->log_error

Alias for Apache::log_error.

=item $s->uid

Returns the numeric user id under which the server answers requests.
This is the value of the User directive.

=item $s->gid

Returns the numeric group id under which the server answers requests.
This is the value of the Group directive.

=item $s->loglevel

Returns the value of the current LogLevel. This method is added by
the Apache::Log module, which needs to be pulled in.

    use Apache::Log;
    print "LogLevel = ", $s->loglevel;

If using Perl 5.005+, the following constants are defined (but not
exported):

    Apache::Log::EMERG
    Apache::Log::ALERT
    Apache::Log::CRIT
    Apache::Log::ERR
    Apache::Log::WARNING
    Apache::Log::NOTICE
    Apache::Log::INFO
    Apache::Log::DEBUG

=item $r->get_handlers( $hook )

Returns a reference to a list of handlers enabled for $hook. $hook is
a string representing the phase to handle. The returned list is a list
of references to the handler subroutines.

	$list = $r->get_handlers( 'PerlHandler' );

=item $r->set_handlers( $hook, [\&handler, ... ] )

Sets the list if handlers to be called for $hook. $hook is a string
representing the phase to handle. The list of handlers is an anonymous
array of code references to the handlers to install for this request
phase. The special list [ \&OK ] can be used to disable a particular
phase.

	$r->set_handlers( PerlLogHandler => [ \&myhandler1, \&myhandler2 ] );
	$r->set_handlers( PerlAuthenHandler => [ \&OK ] );

=item $r->push_handlers( $hook, \&handler )

Pushes a new handler to be called for $hook. $hook is a string
representing the phase to handle. The handler is a reference to a
subroutine to install for this request phase. This handler will be
called before any configured handlers.

	$r->push_handlers( PerlHandler => \&footer);

=back

=head1 SETTING UP THE RESPONSE

The following methods are used to set up and return the response back
to the client.  This typically involves setting up $r->status(), the
various content attributes and optionally some additional
$r->header_out() calls before calling $r->send_http_header() which will
actually send the headers to the client.  After this a typical
application will call the $r->print() method to send the response
content to the client.

=over 4

=item $r->send_http_header

Send the response line and all headers to the client.

This method will create headers from the $r->content_xxx() and
$r->no_cache() attributes (described below) and then append the
headers defined by $r->header_out (or $r->err_header_out if status
indicates an error).

=item $r->get_basic_auth_pw

If the current request is protected by Basic authentication, 
this method will return 0, otherwise -1.  
The second return value will be the decoded password sent by the client.

   ($ret, $sent_pw) = $r->get_basic_auth_pw;

=item $r->note_basic_auth_failure

Prior to requiring Basic authentication from the client, this method 
will set the outgoing HTTP headers asking the client to authenticate 
for the realm defined by the configuration directive C<AuthName>.

=item $r->handler( [$meth] )

Set the handler for a request.
Normally set by the configuration directive C<AddHandler>.

   $r->handler( "perl-script" );

=item $r->notes( $key, [$value] )

Return the value of a named entry in the Apache C<notes> table, or
optionally set the value of a named entry.  This table is used by Apache
modules to pass messages amongst themselves. Generally if you are
writing handlers in mod_perl you can use Perl variables for this.

   $r->notes("MY_HANDLER" => OK);
   $val = $r->notes("MY_HANDLER");

Will return a I<HASH> reference blessed into the I<Apache::Table>
class when called in a scalar context with no "key" argument. This
requires I<Apache::Table>.

=item $r->pnotes( $key, [$value] )

Like $r->notes, but takes any scalar as an value.

   $r->pnotes("MY_HANDLER" => [qw(one two)]);
   my $val = $r->pnotes("MY_HANDLER");
   print $val->[0];     # prints "one"

Advantage over just using a Perl variable is that $r->pnotes gets
cleaned up after every request.

=item $r->subprocess_env( $key, [$value] )

Return the value of a named entry in the Apache C<subprocess_env>
table, or optionally set the value of a named entry. This table is
used by mod_include.  By setting some custom variables inside
a perl handler it is possible to combine perl with mod_include nicely.
If you say, e.g. in a PerlHeaderParserHandler

   $r->subprocess_env(MyLanguage => "de");

you can then write in your .shtml document:

   <!--#if expr="$MyLanguage = en" -->
   English
   <!--#elif expr="$MyLanguage = de" -->
   Deutsch
   <!--#else -->
   Sorry
   <!--#endif -->

Will return a I<HASH> reference blessed into the I<Apache::Table>
class when called in a scalar context with no "key" argument. This
requires I<Apache::Table>.

=item $r->content_type( [$newval] )

Get or set the content type being sent to the client.  Content types
are strings like "text/plain", "text/html" or "image/gif".  This
corresponds to the "Content-Type" header in the HTTP protocol.  Example
of usage is:

   $previous_type = $r->content_type;
   $r->content_type("text/plain");

=item $r->content_encoding( [$newval] )

Get or set the content encoding.  Content encodings are string like
"gzip" or "compress".  This correspond to the "Content-Encoding"
header in the HTTP protocol.

=item $r->content_languages( [$array_ref] )

Get or set the content languages.  The content language corresponds to the
"Content-Language" HTTP header and is an array reference containing strings
such as "en" or "no".

=item $r->status( $integer )

Get or set the reply status for the client request.  The
B<Apache::Constants> module provide mnemonic names for the status codes.

=item $r->status_line( $string )

Get or set the response status line.  The status line is a string like
"200 Document follows" and it will take precedence over the value specified
using the $r->status() described above.


=item $r->headers_out

The $r->headers_out method will return a %hash of server response
headers.  This can be used to initialize a perl hash, or one could use
the $r->header_out() method (described below) to retrieve or set a specific
header value directly.

Will return a I<HASH> reference blessed into the I<Apache::Table>
class when called in a scalar context with no "key" argument. This
requires I<Apache::Table>.

=item $r->header_out( $header, $value )

Change the value of a response header, or create a new one.  You
should not define any "Content-XXX" headers by calling this method,
because these headers use their own specific methods.  Example of use:

   $r->header_out("WWW-Authenticate" => "Basic");
   $val = $r->header_out($key);

=item $r->err_headers_out

The $r->err_headers_out method will return a %hash of server response
headers.  This can be used to initialize a perl hash, or one could use
the $r->err_header_out() method (described below) to retrieve or set a specific
header value directly.

The difference between headers_out and err_headers_out is that the
latter are printed even on error, and persist across internal redirects
(so the headers printed for ErrorDocument handlers will have them).

Will return a I<HASH> reference blessed into the I<Apache::Table>
class when called in a scalar context with no "key" argument. This
requires I<Apache::Table>.

=item $r->err_header_out( $header, [$value] )

Change the value of an error response header, or create a new one.
These headers are used if the status indicates an error.

   $r->err_header_out("Warning" => "Bad luck");
   $val = $r->err_header_out($key);

=item $r->no_cache( $boolean )

This is a flag that indicates that the data being returned is volatile
and the client should be told not to cache it.

=item $r->print( @list )

This method sends data to the client with C<$r-E<gt>write_client>, but first
sets a timeout before sending with C<$r-E<gt>hard_timeout>. This method is
called instead of CORE::print when you use print() in your mod_perl programs.

This method treats scalar references specially. If an item in @list is a
scalar reference, it will be dereferenced before printing. This is a
performance optimization which prevents unneeded copying of large strings,
and it is subtly different from Perl's standard print() behavior.

Example:

   $foo = \"bar"; print($foo);

The result is "bar", not the "SCALAR(0xDEADBEEF)" you might have expected. If
you really want the reference to be printed out, force it into a scalar
context by using C<print(scalar($foo))>.

=item $r->send_fd( $filehandle )

Send the contents of a file to the client.  Can for instance be used
like this:

  open(FILE, $r->filename) || return 404;
  $r->send_fd(FILE);
  close(FILE);

=item $r->internal_redirect( $newplace )

Redirect to a location in the server namespace without 
telling the client. For instance:

   $r->internal_redirect("/home/sweet/home.html");

=item $r->internal_redirect_handler( $newplace )

Same as I<internal_redirect>, but the I<handler> from C<$r> is preserved.

=item $r->custom_response($code, $uri)

This method provides a hook into the B<ErrorDocument> mechanism,
allowing you to configure a custom response for a given response
code at request-time.

Example:

    use Apache::Constants ':common';

    sub handler {
        my($r) = @_;

        if($things_are_ok) {
	    return OK;
        }

        #<Location $r->uri>
        #ErrorDocument 401 /error.html
        #</Location>

        $r->custom_response(AUTH_REQUIRED, "/error.html");

        #can send a string too
        #<Location $r->uri>
        #ErrorDocument 401 "sorry, go away"
        #</Location>

        #$r->custom_response(AUTH_REQUIRED, "sorry, go away");

        return AUTH_REQUIRED;
    }

=back

=head1 SERVER CORE FUNCTIONS

=over 4

=item $r->soft_timeout($message)

=item $r->hard_timeout($message)

=item $r->kill_timeout

=item $r->reset_timeout

(Documentation borrowed from http_main.h)

There are two functions which modules can call to trigger a timeout
(with the per-virtual-server timeout duration); these are hard_timeout
and soft_timeout.

The difference between the two is what happens when the timeout
expires (or earlier than that, if the client connection aborts) ---
a soft_timeout just puts the connection to the client in an
"aborted" state, which will cause http_protocol.c to stop trying to
talk to the client, but otherwise allows the code to continue normally.
hard_timeout(), by contrast, logs the request, and then aborts it
completely --- longjmp()ing out to the accept() loop in http_main.
Any resources tied into the request resource pool will be cleaned up;
everything that is not will leak.

soft_timeout() is recommended as a general rule, because it gives your
code a chance to clean up.  However, hard_timeout() may be the most
convenient way of dealing with timeouts waiting for some external
resource other than the client, if you can live with the restrictions.

When a hard timeout is in scope, critical sections can be guarded
with block_alarms() and unblock_alarms() --- these are declared in
alloc.c because they are most often used in conjunction with
routines to allocate something or other, to make sure that the
cleanup does get registered before any alarm is allowed to happen
which might require it to be cleaned up; they * are, however,
implemented in http_main.c.

kill_timeout() will disarm either variety of timeout.

reset_timeout() resets the timeout in progress.

=item $r->post_connection($code_ref)

=item $r->register_cleanup($code_ref)

Register a cleanup function which is called just before $r->pool is
destroyed.

   $r->register_cleanup(sub {
       my $r = shift;
       warn "registered cleanup called for ", $r->uri, "\n";
   });

The I<post_connection> method is simply an alias for I<register_cleanup>, 
as this method may be used to run code after the client connection is closed,
which may not be a I<cleanup>.

=back

=head1 CGI SUPPORT

We also provide some methods that make it easier to support the CGI
type of interface.

=over 4

=item $r->send_cgi_header()

Take action on certain headers including I<Status:>, I<Location:> and
I<Content-type:> just as mod_cgi does, then calls
$r->send_http_header().  Example of use:

   $r->send_cgi_header(<<EOT);
   Location: /foo/bar
   Content-type: text/html

   EOT

=back

=head1 ERROR LOGGING

The following methods can be used to log errors. 

=over 4

=item $r->log_reason($message, $file)

The request failed, why??  Write a message to the server errorlog.

   $r->log_reason("Because I felt like it", $r->filename);

=item $r->log_error($message)

Uh, oh.  Write a message to the server errorlog.

   $r->log_error("Some text that goes in the error_log");

=item $r->warn($message)

For pre-1.3 versions of apache, this is just an alias for
C<log_error>.  With 1.3+ versions of apache, this message will only be
send to the error_log if B<LogLevel> is set to B<warn> or higher. 

=back

=head1 UTILITY FUNCTIONS

=over 4

=item Apache::unescape_url($string)

Handy function for unescapes.  Use this one for filenames/paths.
Use unescape_url_info for the result of submitted form data.

=item Apache::unescape_url_info($string)

Handy function for unescapes submitted form data.
In opposite to unescape_url it translates the plus sign to space.

=item Apache::perl_hook($hook)

Returns true if the specified callback hook is enabled:

   for (qw(Access Authen Authz ChildInit Cleanup Fixup
           HeaderParser Init Log Trans Type))
   {
       print "$_ hook enabled\n" if Apache::perl_hook($_);
   }  

=back

=head1 GLOBAL VARIABLES

=over 4

=item $Apache::Server::Starting

Set to true when the server is starting.

=item $Apache::Server::ReStarting

Set to true when the server is starting.

=item $Apache::Server::ConfigTestOnly

Set to true when the server is running in configuration test mode
(C<httpd -t>).

   <Perl>
    # don't continue if it's a config test!
    print("Skipping the <Perl> code!\n"),
    return if $Apache::Server::ConfigTestOnly;
   
    print "Running the <Perl> code!\n"
    # some code here
   
   </Perl>


=back

=head1 SEE ALSO

perl(1),
Apache::Constants(3),
Apache::Registry(3),
Apache::Debug(3),
Apache::Options(3),
CGI::Apache(3)

Apache C API notes at C<http://www.apache.org/docs/>

=head1 AUTHORS

Perl interface to the Apache C API written by Doug MacEachern
with contributions from Gisle Aas, Andreas Koenig, Eric Bartley, 
Rob Hartill, Gerald Richter, Salvador Ortiz and others. 

=cut

