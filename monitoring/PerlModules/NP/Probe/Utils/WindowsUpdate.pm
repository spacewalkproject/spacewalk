package NOCpulse::Probe::Utils::WindowsUpdate;

use strict;

use LWP::UserAgent;
use NOCpulse::Config;
use NOCpulse::Probe::Error;
use NOCpulse::Log::Logger;
use NOCpulse::Probe::MessageCatalog;

use Class::MethodMaker
  get_set =>
  [qw(
      windows_command
      auto_update
      installed_version
      user_agent
      not_upgraded_reason
      _message_catalog
     )],
  new_hash_init => 'hash_init',
  new_with_init => 'new',
  ;

my $Log = NOCpulse::Log::Logger->new(__PACKAGE__);

my $config = NOCpulse::Config->new();
my $LATEST_VERSION = $config->get('satellite', 'latestWindowsServiceVersion');

#use constant LATEST_VERSION => '3.15.1';
use constant NO_AUTO_UPDATE => 'Not upgrading because auto-update is disabled';
use constant TOO_OLD        => 'Not upgrading because installed version is too old';

sub init {
    my ($self, %args) = @_;

    $args{windows_command}
      or throw NOCpulse::Probe::InternalError("No windows command provided");

    $args{auto_update} = $args{windows_command}->auto_update unless exists $args{auto_update};

    $self->hash_init(%args);

    # Use the service shell's version unless it's already set
    $self->installed_version 
      or $self->installed_version($self->windows_command->shell->host_service_version);

    $self->_message_catalog(NOCpulse::Probe::MessageCatalog->instance());
}

sub update_if_needed {
    my $self = shift;
    if ($self->update_needed()) {
        $self->update_package();
    }
}

sub update_needed { 
    my $self = shift;
    my $cmp = $self->compare_versions($LATEST_VERSION, $self->installed_version);
    $Log->log(2, "compare latest version $LATEST_VERSION to installed ",
              $self->installed_version, ", result $cmp\n");
    return $cmp > 0;
}

# < 0  => version 1 < version 2
# == 0 => version 1 == version 2
# > 0  => version 1 > version 2
sub compare_versions {
    my ($class, $version_1, $version_2) = @_;

    my @v1_components = split(/\./, $version_1);
    my @v2_components = split(/\./, $version_2);

    # Compare each of the dot components.
    for (my $i = 0; $i < @v1_components || $i < @v2_components; ++$i) {
        my $v1 = (($i < @v1_components)? $v1_components[$i] : 0);
        my $v2 = (($i < @v2_components)? $v2_components[$i] : 0);
        if (my $cmp = $v1 <=> $v2) {
            return $cmp;
        }
    }
    return 0;
}

sub update_package {
  my $self = shift;

  unless ($self->auto_update) {
      $self->not_upgraded_reason(NO_AUTO_UPDATE);
      $Log->log(1, NO_AUTO_UPDATE, "\n");
      return;
  }

  my $filename = "NOCpulse_$LATEST_VERSION.msi";
  
  my $msi_url = $config->get('satellite', 'depotUrl') . "nocpulsed/" . $filename;

  # Auto-update was first enabled in version 2.2.1
  if ($self->compare_versions($self->installed_version, 2.2) <= 0) {
      $self->not_upgraded_reason(TOO_OLD);
      $Log->log(1, TOO_OLD, ": ", $self->installed_version, "\n");
      return;
  }

  # Set up the the user agent to retrieve the update file from depotUrl
  my $ua = $self->user_agent || LWP::UserAgent->new();
  $ua->agent("AgentName/0.1 " . $ua->agent);

  # Request the header information to verify file exists and get content-length.
  $Log->log(1, "Requesting header information for $msi_url\n");
  my $req = HTTP::Request->new(HEAD => $msi_url);
  my $ua_response = $ua->request($req);

  # Check the outcome of the response
  if (!$ua_response->is_success) {
      my $msg = sprintf($self->_message_catalog->windows_update('fetch_failed'),
                        $ua_response->status_line);
      throw NOCpulse::Probe::WindowsUpdateError($msg);
  }  

  my $file_size = $ua_response->content_length();

  # Get the service ready to receive the file.
  my $stdout = $self->windows_command->install($filename, $file_size, $LATEST_VERSION);

  unless ($stdout) {
      my $msg;
      if ($self->stderr) {
          $msg = sprintf($self->_message_catalog->windows_update('prepare_failed_stderr'),
                         $self->stderr);
      } else {
          $self->_message_catalog->windows_update('prepare_failed');
      }
      throw NOCpulse::Probe::WindowsUpdateError($msg);
  }

  if ($stdout !~ /ACCEPT/) {
      my $msg = sprintf($self->_message_catalog->windows_update('upgrade_denied'), $stdout);
      throw NOCpulse::Probe::WindowsUpdateError($msg);
  }

  # Transfer the upgrade file.
  my $bytes_received;
  my $bytes_sent;
  
  $ua_response = $ua->request(HTTP::Request->new(GET => $msi_url),
                              sub {
                                  my ($chunk, $response) = @_;
                                  my $chunk_size = length($chunk);
                                  $bytes_received += $chunk_size;
                                  $self->windows_command->shell->write_command($chunk);
                                  $bytes_sent += $chunk_size;
                              },
                              4096);
  if (($bytes_sent != $bytes_received) || ($bytes_sent != $file_size)) {
      my $msg = $self->_message_catalog->windows_update('upgrade_write_failed');
      throw NOCpulse::Probe::WindowsUpdateError($msg);
  }

  $Log->log(1, "Upgrade completed: ", $self->windows_command->results, "\n");

  return $self->windows_command->results;
}


1;

__END__
