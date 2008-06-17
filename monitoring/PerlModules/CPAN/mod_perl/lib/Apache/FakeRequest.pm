package Apache::FakeRequest;

$Apache::FakeRequest::VERSION = "1.00";

sub new {
    my $class = shift;
    bless {@_}, $class;
}

sub print { shift; CORE::print(@_) }

#dummy method stubs
my @methods = qw{
  allow_options
  as_string auth_name auth_type
  basic_http_header bootstrap bytes_sent
  can_stack_handlers cgi_env cgi_header_out
  cgi_var clear_rgy_endav connection
  content content_encoding content_language
  content_type dir_config document_root
  err_header_out err_headers_out exit
  filename get_basic_auth_pw get_remote_host
  get_remote_logname handler hard_timeout
  header_in header_only header_out
  headers_in headers_out hostname import
  internal_redirect_handler is_initial_req is_main
  kill_timeout log_error log_reason
  lookup_file lookup_uri main
  max_requests_per_child method method_number
  module next no_cache
  note_basic_auth_failure notes
  path_info perl_hook post_connection prev
  protocol proxyreq push_handlers
  query_string read read_client_block
  read_length register_cleanup request
  requires reset_timeout rflush
  send_cgi_header send_fd send_http_header
  sent_header seqno server
  server_root_relative soft_timeout status
  status_line subprocess_env taint
  the_request translate_name unescape_url
  unescape_url_info untaint uri warn
  write_client 
};

sub elem {
    my($self, $key, $val) = @_;
    $self->{$key} = $val if $val;
    $self->{$key};
}

sub parse_args {
    my($wantarray,$string) = @_;
    return unless defined $string and $string;
    if(defined $wantarray and $wantarray) {
        return map { 
	    s/%([0-9a-fA-F]{2})/pack("c",hex($1))/ge;
	    $_;
	} split /[=&;]/, $string, -1;
    }
    $string;
}

sub args {
    my($r,$val) = @_;
    $r->{args} = $val if $val;
    parse_args(wantarray, $r->{args});
}


{
    my @code;
    for my $meth (@methods) {
	push @code, "sub $meth { shift->elem('$meth', \@_) };";
    }
    eval "@code";
    die $@ if $@;
}


package Apache::Constants;

sub OK          		{  0 }
sub DECLINED    		{ -1 }
sub DONE        		{ -2 }

sub CONTINUE                    { 100 }
sub DOCUMENT_FOLLOWS            { 200 }
sub NOT_AUTHORITATIVE           { 203 }
sub HTTP_NO_CONTENT             { 204 }
sub MOVED                       { 301 }
sub REDIRECT                    { 302 }
sub USE_LOCAL_COPY              { 304 }
sub HTTP_NOT_MODIFIED           { 304 }
sub BAD_REQUEST                 { 400 }
sub AUTH_REQUIRED               { 401 }
sub FORBIDDEN                   { 403 }
sub NOT_FOUND                   { 404 }
sub HTTP_METHOD_NOT_ALLOWED     { 405 }
sub HTTP_NOT_ACCEPTABLE         { 406 }
sub HTTP_LENGTH_REQUIRED        { 411 }
sub HTTP_PRECONDITION_FAILED    { 412 }
sub SERVER_ERROR                { 500 }
sub NOT_IMPLEMENTED             { 501 }
sub BAD_GATEWAY                 { 502 }
sub HTTP_SERVICE_UNAVAILABLE    { 503 }
sub HTTP_VARIANT_ALSO_VARIES    { 506 }

# methods

sub M_GET       { 0 }
sub M_PUT       { 1 }
sub M_POST      { 2 }
sub M_DELETE    { 3 }
sub M_CONNECT   { 4 }
sub M_OPTIONS   { 5 }
sub M_TRACE     { 6 }
sub M_INVALID   { 7 }

# options

sub OPT_NONE      {   0 }
sub OPT_INDEXES   {   1 }
sub OPT_INCLUDES  {   2 }
sub OPT_SYM_LINKS {   4 }
sub OPT_EXECCGI   {   8 }
sub OPT_UNSET     {  16 }
sub OPT_INCNOEXEC {  32 }
sub OPT_SYM_OWNER {  64 }
sub OPT_MULTI     { 128 }
sub OPT_ALL       {  15 }

# satisfy

sub SATISFY_ALL    { 0 }
sub SATISFY_ANY    { 1 }
sub SATISFY_NOSPEC { 2 }

# remotehost

sub REMOTE_HOST       { 0 }
sub REMOTE_NAME       { 1 }
sub REMOTE_NOLOOKUP   { 2 }
sub REMOTE_DOUBLE_REV { 3 }



sub MODULE_MAGIC_NUMBER { "The answer is 42" }
sub SERVER_VERSION      { "1.x" }
sub SERVER_BUILT        { "199908" }


1;

__END__

=head1 NAME

Apache::FakeRequest - fake request object for debugging

=head1 SYNOPSIS

    use Apache::FakeRequest;
    my $request = Apache::FakeRequest->new(method_name => 'value', ...);


=head1 DESCRIPTION

B<Apache::FakeRequest> is used to set up an empty Apache request
object that can be used for debugging.  The B<Apache::FakeRequest>
methods just set internal variables of the same name as the method and
return the value of the internal variables.  Initial values for
methods can be specified when the object is created.  The I<print>
method prints to STDOUT.

Subroutines for Apache constants are also defined so that using
B<Apache::Constants> while debugging works, although the values of the
constants are hard-coded rather than extracted from the Apache source
code.

    #!/usr/bin/perl

    use Apache::FakeRequest ();
    use mymodule ();

    my $request = Apache::FakeRequest->new('get_remote_host'=>'foobar.com');
    mymodule::handler($request);

=head1 AUTHORS

Doug MacEachern, with contributions from Andrew Ford <A.Ford@ford-mason.co.uk>.

