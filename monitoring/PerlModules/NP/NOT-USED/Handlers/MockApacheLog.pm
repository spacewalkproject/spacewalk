
use strict;


package NOCpulse::MockApacheLog;


sub new
{
    my $class = shift;
    my $self = {};
    bless $self, $class;

    return $self;
}

# The log() method is for internal use only.  Use one of the
# methods below instead.

sub log
{
    my $line = shift;
    my $level = shift || 'info';

    print '['.gmtime().'] ['.$level.'] [client 127.0.0.1] '.$line."\n";
    
}

# The various methods for logging.  The method name
# corresponds to the log level.

sub emerg
{
    my $self = shift;
    my $line = shift;

    $self->log($line, 'emerg');
}

sub alert
{
    my $self = shift;
    my $line = shift;

    $self->log($line, 'alert');
}

sub crit
{
    my $self = shift;
    my $line = shift;

    $self->log($line, 'crit');
}

sub error
{
    my $self = shift;
    my $line = shift;

    $self->log($line, 'error');
}

sub warn
{
    my $self = shift;
    my $line = shift;

    $self->log($line, 'warn');
}

sub notice
{
    my $self = shift;
    my $line = shift;

    $self->log($line, 'notice');
}

sub info
{
    my $self = shift;
    my $line = shift;

    $self->log($line, 'info');
}

sub debug
{
    my $self = shift;
    my $line = shift;

    $self->log($line, 'debug');
}

1;
