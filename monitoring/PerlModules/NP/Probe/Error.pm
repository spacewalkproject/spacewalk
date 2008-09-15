package NOCpulse::Probe::Error;

use strict;

use Error;

use base qw(NOCpulse::Utils::Error);

sub new {
    my $class = shift;
    my $message = "" . shift;
    my $value = shift;

    # Try the message and value as a message catalog section and key.
    my $lookup = NOCpulse::Probe::MessageCatalog->instance->message($message, $value);
    $message = $lookup if $lookup;

    return $class->SUPER::new($message, $value);
}

# Error subclasses

# Quasi-internal errors -- users should see them, but they should gritch
@NOCpulse::Probe::DataSource::CommandFailedError::ISA  = 'NOCpulse::Probe::Error';
@NOCpulse::Probe::WindowsUpdateError::ISA              = 'NOCpulse::Probe::Error';

# User-visible errors
@NOCpulse::Probe::UserVisibleError::ISA                = 'NOCpulse::Probe::Error';
@NOCpulse::Probe::ConfigError::ISA                     = 'NOCpulse::Probe::UserVisibleError';
@NOCpulse::Probe::Shell::ConnectError::ISA             = 'NOCpulse::Probe::UserVisibleError';
@NOCpulse::Probe::Shell::ExecFailedError::ISA          = 'NOCpulse::Probe::UserVisibleError';
@NOCpulse::Probe::Shell::LostConnectionError::ISA      = 'NOCpulse::Probe::UserVisibleError';
@NOCpulse::Probe::Shell::TimedOutError::ISA            = 'NOCpulse::Probe::UserVisibleError';
@NOCpulse::Probe::Shell::WindowsService::SSLError::ISA = 'NOCpulse::Probe::UserVisibleError';
@NOCpulse::Probe::DataSource::ConfigError::ISA         = 'NOCpulse::Probe::UserVisibleError';
@NOCpulse::Probe::DataSource::ConnectError::ISA        = 'NOCpulse::Probe::UserVisibleError';
@NOCpulse::Probe::DataSource::OSMismatchError::ISA     = 'NOCpulse::Probe::UserVisibleError';
@NOCpulse::Probe::DataSource::UnsupportedOSError::ISA  = 'NOCpulse::Probe::UserVisibleError';
@NOCpulse::Probe::DataSource::ExecuteError::ISA        = 'NOCpulse::Probe::UserVisibleError';
@NOCpulse::Probe::DataSource::TimedOutError::ISA       = 'NOCpulse::Probe::UserVisibleError';
@NOCpulse::Probe::DataSource::MissingProgramError::ISA = 'NOCpulse::Probe::UserVisibleError';
@NOCpulse::Probe::WindowsServiceVersionError::ISA      = 'NOCpulse::Probe::UserVisibleError';

@NOCpulse::Probe::DataSource::PerfDataObjectError::ISA   = 'NOCpulse::Probe::UserVisibleError';
@NOCpulse::Probe::DataSource::PerfDataCounterError::ISA  = 'NOCpulse::Probe::UserVisibleError';
@NOCpulse::Probe::DataSource::PerfDataInstanceError::ISA = 'NOCpulse::Probe::UserVisibleError';
@NOCpulse::Probe::DataSource::MalformedEventError::ISA = 'NOCpulse::Probe::UserVisibleError';

@NOCpulse::Probe::DataSource::WmiNotSupportedError::ISA = 'NOCpulse::Probe::UserVisibleError';

@NOCpulse::Probe::DbConnectError::ISA       = 'NOCpulse::Probe::DataSource::ConnectError';
@NOCpulse::Probe::DbLoginError::ISA         = 'NOCpulse::Probe::DbConnectError';
@NOCpulse::Probe::DbInstanceError::ISA      = 'NOCpulse::Probe::DbConnectError';
@NOCpulse::Probe::DbHostError::ISA          = 'NOCpulse::Probe::DbConnectError';
@NOCpulse::Probe::DbPortError::ISA          = 'NOCpulse::Probe::DbConnectError';
@NOCpulse::Probe::DbTimedOutError::ISA      = 'NOCpulse::Probe::DbConnectError';
@NOCpulse::Probe::DbTableNotFoundError::ISA = 'NOCpulse::Probe::UserVisibleError';

# Internal coding errors -- their messages will be logged and gritched,
# but will not be visible to customers.
@NOCpulse::Probe::InternalError::ISA               = 'NOCpulse::Probe::Error';
@NOCpulse::Probe::ClassNotFoundError::ISA          = 'NOCpulse::Probe::InternalError';
@NOCpulse::Probe::PriorState::FileCorrupted::ISA   = 'NOCpulse::Probe::InternalError';
@NOCpulse::Probe::PriorState::WrongFileFormat::ISA = 'NOCpulse::Probe::InternalError';
@NOCpulse::Probe::DataSource::NotConnected::ISA    = 'NOCpulse::Probe::InternalError';
@NOCpulse::Probe::Shell::NotConnectedError::ISA    = 'NOCpulse::Probe::InternalError';
@NOCpulse::Probe::StderrRedirError::ISA            = 'NOCpulse::Probe::InternalError';

1;

__END__
