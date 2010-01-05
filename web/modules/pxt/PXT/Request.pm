#
# Copyright (c) 2008 Red Hat, Inc.
#
# This software is licensed to you under the GNU General Public License,
# version 2 (GPLv2). There is NO WARRANTY for this software, express or
# implied, including the implied warranties of MERCHANTABILITY or FITNESS
# FOR A PARTICULAR PURPOSE. You should have received a copy of GPLv2
# along with this software; if not, see
# http://www.gnu.org/licenses/old-licenses/gpl-2.0.txt.
# 
# Red Hat trademarks are not licensed under GPLv2. No permission is
# granted to use or replicate Red Hat trademarks that are incorporated
# in this software or its documentation. 
#

package PXT::Request;

use strict;

use RHN::Session;
use RHN::User;
use RHN::Access;
use RHN::Exception qw/throw/;
use RHN::StoredMessage;
use PXT::Trace;
use PXT::XmlrpcRequest;
use PXT::SoapRequest;

use Carp qw/cluck confess/;
use Data::Dumper;
use URI::URL;
use Cache::FileCache;
use Params::Validate qw/validate/;
use APR::URI ();
use Apache2::RequestIO ();
use Apache2::Connection ();
use Apache2::SubRequest ();

sub new {
  my $class = shift;
  my $apache = shift;
  my $apache_request = shift;
  my $cookies = shift;
  my $session = shift;

  my $self = bless { apache => $apache,
		     apr => $apache_request,
		     cookies => $cookies,
		     session => $session,
		     rpc => 0,
		     stage => "",
		     context => { },
                     no_cache => 1,
		     cleansed_params => { },
		     failed_params => { },
		     use_sessions => 1,
		   }, $class;

  return $self;
}

sub apr {
  my $self = shift;

  if (@_) {
    $self->{apr} = shift;
  }

  return $self->{apr};
}

# passthrough to Apache::Request->upload
sub upload {
  my $self = shift;

  if ($self->{apr}) {
    my $upload = $self->{apr}->upload(@_);
    # get names of uploads
    my @uploads = $self->{apr}->upload(@_);

    # treat uploads more like how we deal w/ formvars...
    # $upload is reference to object unless it completly fail
    return $upload if ($upload and @uploads and @$upload->size != 0);
  }

  return;
}

my @valid_message_queues = qw/site_info local_alert local_info/;

sub push_message {
  my $self = shift;
  my $queue = shift;
  my $msg_text = shift;

  throw "Message text and queue name required - got ($msg_text, $queue)" unless ($msg_text && $queue);
  throw "Invalid queue '$queue', valid queues: " . join (", ", @valid_message_queues) unless grep { $queue eq $_ } @valid_message_queues;

  my $msg = RHN::StoredMessage->new($msg_text);

  my $messages = $self->session->get("rhn_message_" . $queue) || [ ];
  push @{$messages}, $msg;

  $self->session->set("rhn_message_" . $queue => $messages);
}

sub messages {
  my $self = shift;
  my $queue = shift;

  throw "Message queue name required" unless ($queue);
  throw "Invalid queue '$queue'" unless grep { $queue eq $_ } @valid_message_queues;

  my $messages = $self->session->get("rhn_message_" . $queue) || [];
  $self->session->unset("rhn_message_" . $queue);

  return @{$messages};
}

sub message_tag_handler {
  my $pxt = shift;
  my %params = @_;
  my $block = $params{__block__};

  my $queue = $params{queue};

  throw "Message queue name required" unless ($queue);
  throw "Invalid queue '$queue'" unless grep { $queue eq $_ } @valid_message_queues;

  my @messages;

  foreach my $msg ($pxt->messages($queue)) {
    next unless $msg->is_valid;

    push @messages, $msg->render;
  }

  return unless @messages;

  my $output = join("", map { "$_<br />\n" } @messages);
  $block =~ s/\{messages\}/$output/;
  return $block

}

# this little bit is a function maker so we can pass some methods
# straight through to the main Apache request object

my @passthrough = (qw/uri method the_request filename path_info hostname/,
		   qw/headers_in headers_out main/,
		   qw/get_remote_host connection dir_config no_cache/,
		   qw/content_type server_root_relative document_root/,
		   qw/is_initial_req print parsed_uri args/,
		   qw/sendfile log_error status internal_redirect protocol/,
		  );

foreach my $pt (@passthrough) {
  no strict "subs";
  no strict "refs";

  *{"PXT::Request::$pt"} = eval qq{
    sub {
      my \$self = shift;
      \$self->{apache}->$pt(\@_);
    }
  };

  use strict "refs";
  use strict "subs";
#  warn "passthrough $pt created";
}

sub header_in {
  my ($self, $name) = (shift, shift);
  if (@_) {
    $self->{apache}->headers_in->{$name} = $_[0];
  } else {
    return $self->{apache}->headers_in->{$name};
  }
}
sub header_out {
  my ($self, $name) = (shift, shift);
  if (@_) {
    $self->{apache}->headers_out->{$name} = $_[0];
  } else {
    return $self->{apache}->headers_out->{$name};
  }
}
sub send_http_header {
  # noop
}

sub ssl_available {
  my $self = shift;

  return PXT::Config->get('ssl_available');
}

sub ssl_request {
  my $self = shift;

  return 1 if $self->header_in('X-ENV-HTTPS') or $self->{apache}->subprocess_env('HTTPS');

  return 0;
}

sub pnotes {
  my $self = shift;
  my $key = shift;

  if (@_) {
    $self->{apache}->pnotes($key, @_);
  }

  if (defined $self->{apache}->pnotes($key)) {
    return $self->{apache}->pnotes($key);
  }
  elsif (exists $self->{context}->{$key}) {
    return $self->{context}->{$key};
  }

  return;
}

sub notes {
  my $self = shift;
  my $key = shift;

  if (@_) {
    $self->{apache}->notes($key, @_);
  }

  return $self->{apache}->notes($key);
}

sub context {
  my $self = shift;
  return $self->pnotes(@_);
}

sub cleanse_param {
  my $self = shift;

  if (@_ == 0) {
    return keys %{$self->{cleanse_params}};
  }
  else {
    $self->{cleansed_params}->{$_} = 1 foreach @_;
  }
}

sub cleanse_params {
  my $self = shift;
  my $apr = $self->{apr};
  my @formvars = $apr->param;

  my @cleansers = split /,\s*/, PXT::Config->get('param_cleansers');
  if (not @cleansers) {
    warn "Error: no param cleansers defined; proceding in insecure mode";
  }

  foreach my $cleanser (@cleansers) {
    my ($class, $method) = split /->/, $cleanser, 2;
    if (not $class or not $method) {
      die "cleanser '$cleanser' not parseable";
    }
    PXT::Utils->untaint(\$class);

    eval "use $class";
    die $@ if $@;

    $class->$method($self);
  }
}

sub fail_param {
  my $self = shift;

  if (@_ == 0) {
    return keys %{$self->{failed_params}};
  }
  else {
    my ($param, $error) = @_;
    $self->{failed_params}->{$param} = $error;
  }
}

sub param {
  my $self = shift;

  if (@_ == 0) { # get param list
    return grep { not exists $self->{modified_params}{$_} or defined $self->{modified_params}{$_} } $self->{apr}->param();
  }
  elsif (@_ == 1) { # get param
    my $var = shift;

    if (exists $self->{modified_params}{$var}) {
      return $self->{modified_params}{$var};
    }
 
    if (defined $self->{apr}->param($var) and not exists $self->{cleansed_params}->{$var}) {

      if (exists $self->{failed_params}->{$var}) {
	cluck "Formvar '$var' failed permissions check - " . $self->{failed_params}->{$var};
	$self->redirect('/errors/permission.pxt');
      }
      else {
	warn "Access to formvar '$var' not allowed: formvar not cleansed - ", join(", ", caller);
	$PXT::ApacheHandler::make_vile = "#ffff00";
      }
    }

    return $self->{apr}->param($var);
  }
  elsif (@_ == 2) { # set param
    # mark the parameter changed or deleted
    $self->{modified_params}{$_[0]} = $_[1];
  }
}

# just like param, except we don't care if it has been cleansed or not
sub dirty_param {
  my $self = shift;
  my $var = shift;

  if (RHN::Cleansers->securable_param($var)) {
    confess "Formvar '$var' cleansable but used with dirty_param; security issue";
  }

  # getter or setter?
  if (@_ == 0) {
    if (exists $self->{modified_params}{$var}) {
      return $self->{modified_params}{$var};
    }
    return $self->{apr}->param($var);
  }
  else {
    return $self->param($var, @_);
  }
}

# always a getter.  check for cleansing, and handle appropriately.
# use sparingly.
sub passthrough_param {
  my $self = shift;
  my $formvar = shift;

  if (grep { $formvar eq $_ } RHN::Cleansers->secure_params) {
    return $self->param($formvar);
  }
  else {
    return $self->dirty_param($formvar);
  }
}

sub prefill_form_values {
  my $self = shift;
  my $block = shift;

  return '' unless $block;

  $block =~ s(\[formvar:(.*?)\])(PXT::Utils->escapeHTML($self->passthrough_param($1) || ''))egsmi;
  $block =~ s(\{formvar:(.*?)\})(PXT::Utils->escapeHTML($self->passthrough_param($1) || ''))egsmi; # )

  return $block;
}

sub redirect {
  my $self = shift;
  my $dest = shift;
  my @params = @_;

  if (@params) {
    if (not $dest =~ /\?/) {
      $dest .= '?';
    }

    my @result;
    while (my ($k, $v) = splice @params, 0, 2) {
      my $param = '';
      $param .= PXT::Utils->escapeURI($k);
      $param .= "=";
      $param .= PXT::Utils->escapeURI($v);
      push @result, $param;
    }

    $dest .= join("&", @result);
  }

  die bless { dest => $dest }, "PXT::Redirect";
}

sub cookie {
  my $self = shift;
  return $self->{cookies}->{+shift};
}

sub session_cookie_name {
  my $self = shift;

  return "pxt-session-cookie";

  my $personality = $self->pnotes('hostname_personality');

  if ($personality) {
    return "$personality-pxt-session-cookie";
  }
  else {
    return "pxt-session-cookie";
  }
}

sub cookie_jar {
  my $self = shift;

  my @secure;
  @secure = (-secure => 1)
    if $self->ssl_available;

  my $timeout = PXT::Config->get("session_database_lifetime");

  my @expire;
  @expire = (-expires => $timeout)
    if $timeout;

  my @ret;

  if ($self->session->can_persist) {
    PXT::Debug->log(2, sprintf("Generating session cookie for user: '%s', " .
			       "session name: '%s', value: '%s', expire: '%s'.",
			       $self->user ? $self->user->id() : 'none',
			       $self->session_cookie_name,
			       $self->session->key,
			       $timeout || 'never'));

    my $session_cookie = new Apache2::Cookie $self->{apr},
      -name => $self->session_cookie_name,
	-value => $self->session->key,
	  #-domain => PXT::Config->get("base_domain"),
	  # Don't set the cookie's domain, as it will cause issues since we aren't setting it in the java stack
	    @expire,
	      @secure,
		-path => "/";

    push @ret, $session_cookie;
  }

  return @ret;
}

sub manual_content {
  my $self = shift;

  if (@_) {
    $self->{manual_content} = shift;
  }
  return $self->{manual_content};
}

sub pxt_no_cache {
  my $self = shift;

  if (@_) {
    $self->{no_cache} = shift;
  }
  return $self->{no_cache};
}

sub xml_request {
  my $self = shift;

  if (@_) {
    $self->{rpc} = shift;
  }
  return $self->{rpc};
}

sub xml_return_raw {
  my $self = shift;

  if (@_) {
    $self->{xml_raw} = shift;
  }
  return $self->{xml_raw};
}

sub gzip_output {
  my $self = shift;

  if (@_) {
    $self->{gzip_output} = shift;
  }
  return $self->{gzip_output};
}

sub xml_body {
  my $self = shift;

  return $self->{xml_body} if exists $self->{xml_body};
  return unless $self->xml_request;

  my $length = $self->header_in('Content-length');
  return unless $length;

  my $buf;
  my $bytes_read = $self->{apache}->read($buf, $length);

  if ($bytes_read != $length) {
    throw "Tried to read $length bytes from rpc request, but only could read $bytes_read";
  }

  $self->{xml_body} = $buf;

  return $buf;
}

sub rpc_params {
  my $self = shift;

  return @{$self->{rpc_params}} if $self->{rpc_params};

  $self->{rpc_params} = $self->xml_request->decode_rpc_params($self->xml_body);

  return @{$self->{rpc_params}};
}

sub encode_rpc_result {
  my $self = shift;

  return $self->xml_request->encode_rpc_result(@_);
}

my %fault_messages =
  ( unknown_error => 'Unknown internal error',
    server_security => 'No server perms/server does not exist',
    invalid_login => 'Invalid username/password',
    old_client => 'Your client does not support this version of PXT.  Contact rhn-feedback@redhat.com',
    invalid_certificate => 'Invalid server certificate',
    invalid_sat_certificate => 'Invalid entitlement certificate',
    satellite_already_activated => 'Satellite has already been activated',
    no_sat_chan_for_version => 'No Satellite channel exists for specified version',
    no_access_to_sat_channel => 'Account does not have access to any Satellite channels',
    insufficient_channel_entitlements => 'All entitlements to the required channel are currently in use.',
  );

sub touch_session {
  $_[0]->{session_touched} = 1;
}

sub session_touched {
  return $_[0]->{session_touched};
}

sub session {
  my $self = shift;

  if (@_) {
    $self->{session} = shift;
  }

  $self->touch_session;
  return $self->{session};
}

sub clear_user {
  my $self = shift;

  delete $self->{__user__};
}

sub clear_session {
  my $self = shift;

  PXT::Debug->log(2, sprintf("Clearing session for user: '%s', " .
			     "IP: '%s'.",
			     $self->user ? $self->user->id() : 'none',
			     $self->{apache}->connection->remote_ip));

  my $session = new RHN::Session $self->{apache}->hostname, $self->{apache}->connection->remote_ip;
  $session->serialize(-new => 1);
  $self->session($session);
}

sub log_user_in {
  my $self = shift;
  my $user = shift;
  my @sets_to_skip = @_;

  PXT::Debug->log(2, sprintf("Logging in user: '%s'.",
			     $user->id(),
			    ));

  $self->session->uid($user->id);
  $self->cleanse_params();
  $self->session->unset('last_nav_location');
  $user->clear_selections(@sets_to_skip);
  $user->mark_log_in;
#  $user->org->join_rhn;
}

sub user {
  my $self = shift;

  return unless $self->session and $self->session->uid;

  return $self->{__user__} if $self->{__user__};

  $self->{__user__} = RHN::User->lookup(-id => $self->session->uid);
  $self->{__user__}->cleanse_sets();

  return $self->{__user__};
}

sub form_builder_variables {
  my $self = shift;

  push @{$self->{form_builder_variables}}, @_;
}

sub parse {
  my $self = shift;
  my $str = shift;

  PXT::ApacheHandler->pxt_parse_data($self, \$str);

  return $str;
}

sub include {
  my $self = shift;
  my %params;

  Carp::croak "invalid params to PXT::Request->include()" if not defined $_[0];

  if ($_[0] =~ /^-/) {
    %params = @_;
  }
  else{
    $params{-path} = shift;
  }

  # allow -file to be a synonym for -path
  $params{-path} = $params{-file}
    if exists $params{-file};

  my $data = PXT::ApacheHandler->_read_file($params{-path}, $self->document_root);

  return $data if $params{-raw};

  return PXT::Utils->escapeHTML($data) if $params{-escape};

  my %contexts = map { (substr($_, 1) => $params{$_}) } keys %params;
  delete @contexts{qw/raw file path/};

#  local $self->{context};
  $self->context($_, $contexts{$_}) foreach keys %contexts;

  $data = PXT::Utils->perform_substitutions($data, "context:", \%contexts);

  PXT::ApacheHandler->pxt_parse_data($self, \$data);

  return $data;
}

sub derelative_path {
  my $pxt = shift;
  my $path = shift;

  if ($path !~ m(^https?:) and $path !~ m(^/)) {
    my $r = $pxt->{apache};
    my $current_base = $r->parsed_uri->path;
    $current_base =~s(/[^/]*$)();

    return "$current_base/$path";
  }

  return $path;
}

sub derelative_url {
  my $pxt = shift;
  my $url = shift;

  $url = $pxt->derelative_path($url);

  # URI::URL's constructor can construct from either strings or other
  # URI::URL objects
  $url = new URI::URL($url);

  my $forced_protocol = shift || '';

  if ($pxt->ssl_available) {
    $url->scheme('https');
  }
  else {
    $url->scheme('http');
  }

  $url->scheme($forced_protocol) if $forced_protocol;

  $url->host(PXT::Config->get('base_domain')) unless $url->host;

  # for base_port; ignore base_port in ssl mode for now, as it
  # probably wouldn't work
  $url->port(PXT::Config->get('base_port')) if PXT::Config->get('base_port') and not $url->scheme eq 'https';

  return $url;
}

sub route_marker {
  my $self = shift;
  my $href = shift;
  my $msg = shift;
  my $formvar = shift;

  if ($formvar) {
    $href .= "?$formvar=" . $self->param($formvar);
  }

  if ($href and $msg) {
    $self->session->set('route_marker' => [ $href, $msg ]);
  }

  return @{$self->session->get('route_marker') || [ ] };
}

# marks this page as one to be cached...
sub cache_document_contents {
  my $self = shift;
  my $cache_lifetime = shift;

  if ($cache_lifetime) {
    PXT::Debug->log(7, "caching page contents for $cache_lifetime");
    $self->pnotes(cache_page_lifetime => $cache_lifetime);
  }
  else {
    return $self->pnotes('cache_page_lifetime');
  }
}

# key used for searching the cache...
sub cache_key {
  my $self = shift;
  return $self->uri;
}

# definition of what makes complete document contents cachable:
# a) not logged in
# b) no formvars
sub is_cachable {
  my $self = shift;

  return (not $self->user and not keys %{$self->param()});
}

# returns the cached document contents if possible
sub cached_copy {
  my $self = shift;

  my $cache = new Cache::FileCache({namespace => 'pxt_page_cache'});

  # save the cache object for a rainy day...
  $self->{__cache__} = $cache;

  my $key = $self->cache_key;

  PXT::Debug->log(7, "looking for cache object with key:  $key");

  return $cache->get($key);
}

# actually takes the final document contents and shoves it in a cache...
sub write_document_contents_to_cache {
  my $self = shift;
  my $page_contents = shift;

  my $cache_lifetime = $self->cache_document_contents();

  if (not $self->is_cachable()) {

    PXT::Debug->log(2, "warning:  attempt to cache page w/ either logged-in state or formvars denied...");
    return;
  }

  my $key = $self->cache_key;

  PXT::Debug->log(7, "caching key:  $key");

  $self->{__cache__}->set($key, $page_contents, $cache_lifetime);
}

# for debugging purposes, add a header for cached requests
sub cached_contents_header {
  my $self = shift;

  my $cache_obj = $self->{__cache__}->get_object($self->uri);

  my $expires_at = localtime($cache_obj->get_expires_at());
  my $created_at = localtime($cache_obj->get_created_at());

  PXT::Debug->log(7, "created: $created_at, expires: $expires_at");

  return ('X-PXT-Contents-Cached' => "cached=$created_at; expires=$expires_at");
}

sub trace_request {
  my $self = shift;
  my %params = validate(@_, { -result => 1, -extra => 0, -contents => 0 });

  my $result_code = $params{-result};
  my @extras = $params{-extra};

  return unless PXT::Config->get("trace_session");
  return unless PXT::Trace::DB->active;

  # no, do not trace reqs into /dev/ since that would be weird for
  # saving traces
  if ($self->uri =~ m(^/dev/)) {
    return;
  }

  my $r = $self->{apache};
  my $apr = $r->pnotes('pxt_apr');

  my @formvars;
  for my $pname ($apr->param) {
    push @formvars, [ $pname, $_ ] for $apr->param($pname);
  }

  my $hit = new PXT::Trace::Hit;
  $hit->uri($r->parsed_uri->path);
  $hit->method($r->method);
  $hit->params(@formvars);
  $hit->result_code($result_code);
  $hit->duration($self->pnotes('page_render_time'));
  $hit->extra_data(@extras);

  if ($params{-contents}) {
    my $contents = ${$params{-contents}};
    $hit->content_length(length $contents);
    if ($contents =~ m(<title>(.*?)</title>)) {
      my $title = $1;
      $hit->push_seen_html(title => $title);
    }

    my @h1 = $contents =~ m(<h1>(.*?)</h1>);
    $hit->push_seen_html(h1 => $_) for @h1;

    if ($contents =~ m(<div class="local-alert">(.*?)</div>)ms) {
      $hit->alert($1);
    }
  }

  my $trace = PXT::Trace::DB->lookup($self->session->key);
  $trace = PXT::Trace->create($self->session->key) if not $trace;
  $trace->user($self->user->login) if $self->user;
  $trace->add_hit($hit);
  PXT::Trace::DB->commit($trace);
}

sub use_sessions {
  my $self = shift;
  my $use_sessions = shift;

  if (defined $use_sessions) {
    $self->{use_sessions} = $use_sessions;
    if (not $use_sessions) {
      PXT::Debug->log(2, sprintf("Disabling sessions for path: '%s', user: '%s'",
				 $self->uri,
				 $self->user ? $self->user->id() : 'none'));
    }
  }

  if (not $self->{use_sessions}) {
    PXT::Debug->log(2, sprintf("NOT using sessions for path '%s', user: '%s'",
				 $self->uri,
				 $self->user ? $self->user->id() : 'none'));
  }

  return $self->{use_sessions};
}

package PXT::Debug;

sub log {
  my $class = shift;
  my $level = shift;
  my @msg = @_;

  if ($level < PXT::Config->get('debug')) {
    my (undef, $file, $line) = caller;
    my @frame = caller(1);

    warn "$frame[3] ($file:$line): " . join(" ", @msg) . "\n";
  }
}

sub log_dump {
  my $class = shift;
  my $level = shift;
  my @structs = @_;

  if ($level < PXT::Config->get('debug')) {
    my (undef, $file, $line) = caller;
    my @frame = caller(1);

    warn sprintf("$frame[3] ($file:$line): %s\n", Data::Dumper->Dump(\@structs));
  }
}

1;
