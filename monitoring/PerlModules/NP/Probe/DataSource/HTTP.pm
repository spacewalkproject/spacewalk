package NOCpulse::Probe::DataSource::HTTP;

use strict;

use Error;
use NOCpulse::Log::Logger;
use NOCpulse::Probe::Error;
use LWP::UserAgent;
use HTTP::Cookies;
use URI::URL;


use base qw(NOCpulse::Probe::DataSource::AbstractDataSource);

use Class::MethodMaker
  get_set =>
  [qw(
      ip
      port
      urlpath
      useragent
      username
      password
      timeout
      complete_url
      protocol
     )],
  new_with_init => 'new',
  ;

$SIG{'PIPE'} = sub {die "Server closed connection"};
my $Log = NOCpulse::Log::Logger->new(__PACKAGE__);

sub init {

    my ($self, %in_args) = @_;
    my %out_args;

    $out_args{ip} = delete $in_args{ip};
    $out_args{port} = delete $in_args{port};
    $out_args{urlpath} = delete $in_args{urlpath};
    $out_args{useragent} = delete $in_args{useragent};
    $out_args{username} = delete $in_args{username};
    $out_args{password} = delete $in_args{password};
    $out_args{timeout} = delete $in_args{timeout};
    $out_args{protocol} = delete $in_args{protocol};

    $self->SUPER::init(%out_args);
}


sub connect {
}
#Both the connect and disconnect subs are required by AbstractDataSource, so they are included here,
#but are intentionally left empty as the HTTP datasource gets everything it needs in execute()
sub disconnect {
}


sub execute {
    my $self = shift;

    *LWP::UserAgent::get_basic_credentials = sub {
      my($me, $realm, $uri) = @_;
      my $netloc = $uri->host_port;
      my $user = $self->username;
      chomp($user);
      return (undef, undef) unless length $user;
      my $password = $self->password;
      chomp($password);
      return ($user, $password);
  };

    #BZ 164820: IP addresses with leading zeros in any octets need
    #to be fixed so http(s) request work correctly
    my $host = $self->ip;
    $host =~ s/ +//g;
    my @octets = split(/\./, $host);
    foreach my $octet (@octets) {
        $octet =~ s/^0*//;
        $octet = 0 unless $octet;
    }
    $host = join('.', @octets);

    my $uri = new URI::URL($self->urlpath);
    $uri->scheme($self->protocol);
    $uri->host($host);
    $uri->port($self->port);
    $self->complete_url($uri);

    # Include support for cookies
    my $jar = new HTTP::Cookies;
    my $ua = new LWP::UserAgent();
    $ua->agent($self->useragent);
    $ua->cookie_jar($jar);

    # Fetch, rover.
    $Log->log(2, 'Sending HTTP Request for '. "$uri \n");
    my $req = new HTTP::Request(GET => $uri);
    my $res = $ua->request($req);

    if ((!$res->is_success()) && ($res->code != '401')){
	$self->errors(join(' ', $res->code, $res->message));
	$Log->log(2, 'Request failed with ', $res->code, " error code\n");
	$Log->log(4, 'Errors found:  ', $self->errors, " \n");
    } elsif ($res->code == '401') {
	#need to handle a 401 authorization required code a little different than all other HTTP error codes
	$self->errors($res->code);
	$Log->log(2, 'Authorization is needed as a ', $res->code, " return code was found.\n");
    } else {
	$self->results($res->content);
    }
    return $self;

}


1;
