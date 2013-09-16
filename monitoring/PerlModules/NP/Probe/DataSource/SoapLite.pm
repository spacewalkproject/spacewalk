package NOCpulse::Probe::DataSource::SoapLite;

use strict;

use Error;
use NOCpulse::Log::Logger;
use NOCpulse::Probe::Error;
use SOAP::Lite;

use base qw(NOCpulse::Probe::DataSource::AbstractDataSource);

use Class::MethodMaker
  get_set =>
  [qw(
      host
      port
      username
      password
      complete_url
      protocol
      path
      result
     )],
  new_with_init => 'new',
  ;

$SIG{'PIPE'} = sub {die "Server closed connection"};
my $Log = NOCpulse::Log::Logger->new(__PACKAGE__);

# User name and password to use for SOAP::Lite authentication
my $username;
my $password;

# Record the fault string from SOAPLite
my $faultstring = undef;

sub init {

    my ($self, %in_args) = @_;
    my %out_args;
   
    $out_args{host} = delete $in_args{host};
    $out_args{port} = delete $in_args{port};
    $out_args{username} = delete $in_args{username};
    $out_args{password} = delete $in_args{password};
    $out_args{protocol} = delete $in_args{protocol};
    $out_args{path} = delete $in_args{path};    


    $username = $out_args{username};
    $password = $out_args{password};

    $self->SUPER::init(%out_args);
}


sub connect {
}
#Both the connect and disconnect subs are required by AbstractDataSource, so they are included here,
#but are intentionally left empty as the SoapLite datasource gets everything it needs in execute()
sub disconnect {
}

sub on_fault{
	my ($service, $result) = @_;
        
        eval{ $faultstring = $result->faultstring };

        if ($@) {
              $faultstring = $result;
        }
}

sub SOAP::Transport::HTTP::Client::get_basic_credentials {
    $Log->log(1, "Received a request for basic credentials. Returning " . $username . "/" . $password ."\n");
    return $username => $password;
}

sub execute {
    my $self = shift;
    my ($command, @command_params) = @_; 
    
    my $url = $self->protocol . '://' . $self->username . ':' . $self->password . '@' . $self->host . ':' . $self->port  . '/' . $self->path;
    $self->complete_url($url);

    $Log->log(2, 'Sending SOAPLite Request for '. $self->complete_url() . "\n");
   
    my $service;
    eval{ $service = SOAP::Lite->service ($self->complete_url) };
    $Log->log(2, "Created the service in the eval statement...\n");
    
    if (!$@) { 
	   $Log->log(2, "Eval did not set an error code..\n");
	   $service->on_fault( \&on_fault );
	   $Log->log(2, "About to execute command " . $command . " with params: " . join(" - ", @command_params) . "\n");
	   my $tmp = $service->$command(@command_params);
	   $self->result($tmp);
	   # check to see if a fault occurred in SOAPLite
	   if(defined($faultstring)) {
	    	$self->errors($faultstring);
	   }
    } else {
	   $Log->log(2, 'Eval did set an error code..\n');
	   $self->errors($@);
    }; 
  
    return $self;

}
1;
