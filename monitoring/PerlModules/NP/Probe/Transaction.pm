package NOCpulse::Probe::Transaction;

use strict;

use Carp;
use Error;
use NOCpulse::Config;
use NOCpulse::Notification;
use NOCpulse::NotificationQueue;
use NOCpulse::StateChange;
use NOCpulse::StateChangeQueue;
use NOCpulse::TimeSeriesDatapoint;
use NOCpulse::TimeSeriesQueue;
use NOCpulse::Log::LogManager;
use NOCpulse::Log::Logger;
use NOCpulse::Probe::Error;
use NOCpulse::Probe::Result;

use Class::MethodMaker
  get_set => 
  [qw(
      queue_time
      notification
      notification_queue
      state_change
      state_change_queue
      time_series_queue
     )],
  list =>
  [qw(
      time_series
     )],
  hash =>
  [qw(
      contact_group
      _queue_init_args
     )],
  new_with_init => 'new',
  new_hash_init => 'hash_init',
  ;

my $Log = NOCpulse::Log::Logger->new(__PACKAGE__);


sub init {
    my ($self, %args) = @_;
    $args{queue_time} = time() unless defined($args{queue_time});
    $self->hash_init(%args);

    my $config   = NOCpulse::Config->new();
    my $debug    = NOCpulse::Log::LogManager->instance->output_handler;
    my $gritcher = NOCpulse::Gritch->new($config->get('queues', 'gritchdb'));

    $self->_queue_init_args(Debug    => $debug,
                            Config   => $config,
                            Gritcher => $gritcher);
}

sub prepare_notification {
    my ($self, $result) = @_;

    $result or throw NOCpulse::Probe::InternalError("No result provided");

    $self->notification_queue(NOCpulse::NotificationQueue->new($self->_queue_init_args));

    my $notif = NOCpulse::Notification->newInitialized();
    $self->notification($notif);

    my $probe_rec = $result->probe_record;

    $notif->time($self->queue_time);
    $notif->state($result->overall_status);
    $notif->customerId($probe_rec->customer_id);
    $notif->checkCommand($probe_rec->command_id);
    $notif->commandLongName($probe_rec->command_long_name);

    # Convert contact group parallel arrays into a hash.
    my $group_ids = $probe_rec->contact_groups;
    my $group_names = $probe_rec->contact_group_names;
    for (my $i = 0; $i < scalar(@$group_ids); ++$i) {
        $self->contact_group($group_names->[$i], $group_ids->[$i]);
    }

    my ($id, $desc) = $self->_cluster_info();
    $notif->clusterId($id);
    $notif->clusterDesc($desc);

    if ($probe_rec->probe_type eq 'ServiceProbe') {
	$notif->type('service');
	$notif->message($result->notification_text);
	$notif->hostAddress($self->_trim_whitespace($probe_rec->host_ip));
	$notif->hostName($probe_rec->host_name);
	$notif->hostProbeId($probe_rec->host_id);
	$notif->osName($probe_rec->os_name);
	$notif->physicalLocationName($probe_rec->physical_location_name);
	$notif->probeDescription($probe_rec->description);
	$notif->probeGroupName($probe_rec->command_group_name);
	$notif->probeId($probe_rec->recid);
	$notif->probeType($probe_rec->probe_type);

    } elsif ($probe_rec->probe_type eq 'LongLegs') {
	$notif->type('longlegs');
	$notif->message($result->notification_text);
	$notif->probeDescription($probe_rec->description);
	$notif->probeId($probe_rec->recid);
	$notif->probeType($probe_rec->probe_type);

    } elsif ($probe_rec->probe_type eq 'HostProbe') {
	$notif->type('host');
	$notif->state($result->translated_host_status());
	$notif->hostAddress($self->_trim_whitespace($probe_rec->host_ip));
	$notif->hostName($probe_rec->host_name);
	$notif->hostProbeId($probe_rec->host_id);
	$notif->osName($probe_rec->os_name);
	$notif->physicalLocationName($probe_rec->physical_location_name);
	$notif->probeType($probe_rec->probe_type);
	$notif->probeGroupName($probe_rec->command_group_name);
	$notif->probeDescription($probe_rec->description);
	my $state = $notif->state;
	my $host = $notif->hostName;
	$notif->message("Host $host is $state");
    } else {
        throw NOCpulse::Probe::Error("Unrecognized probe type for probe ".
                                     $probe_rec->recid.": '".$probe_rec->probe_type."'");
    }
}

sub prepare_state_change {
    my ($self, $result) = @_;

    $result or throw NOCpulse::Probe::InternalError("No result provided");

    $self->state_change_queue(NOCpulse::StateChangeQueue->new($self->_queue_init_args));

    my $state_change = NOCpulse::StateChange->newInitialized();
    $self->state_change($state_change);

    $state_change->desc($result->detail_text);
    $state_change->t($self->queue_time);
    $state_change->state($result->translated_host_status());

    if ($result->probe_record->probe_type eq 'LongLegs') {
        my ($cluster_id, $desc) = $self->_cluster_info();
	$state_change->oid($result->probe_record->recid.'-'.$cluster_id);
    } else {
	$state_change->oid($result->probe_record->recid);
    }
}

sub prepare_time_series {
    my ($self, $result) = @_;

    $result or throw NOCpulse::Probe::InternalError("No result provided");

    $self->time_series_queue(NOCpulse::TimeSeriesQueue->new($self->_queue_init_args));

    foreach my $item ($result->item_named_values) {
        next unless $item->is_metric;
        my $point = NOCpulse::TimeSeriesDatapoint->newInitialized();
        my @oid_parts = ($result->probe_record->customer_id,
                         $result->probe_record->recid,
                         $item->name);
        $point->oid(join('-', @oid_parts));
        $point->t($self->queue_time);
        $point->v($item->value);
        $self->time_series_push($point);
        $Log->log(4, "metric ", $item->name, ' = ', $item->value, ' at ',
                  $self->_timestamp($self->queue_time), "\n");
    }
}

sub commit {
    my $self = shift;

    $self->commit_notification();
    $self->commit_state_change();
    $self->commit_time_series();
}

sub commit_notification {
    my $self = shift;

    my $queue = $self->notification_queue;
    my $notif = $self->notification;

    return unless $queue and $notif;

    # Queue up the notification for each contact group.
    foreach my $group_name ($self->contact_group_keys) {
	$notif->groupName($group_name);
	$notif->groupId($self->contact_group($group_name));
        $Log->dump(4, "Enqueue ", $notif, "\n");
	$queue->enqueue($notif);
    }

}

sub commit_state_change {
    my $self = shift;

    my $queue = $self->state_change_queue;
    my $state_change = $self->state_change;

    return unless $queue and $state_change;

    $queue->enqueue($state_change);
}

sub commit_time_series {
    my $self = shift;

    my $queue = $self->time_series_queue;

    return unless $queue and $self->time_series_count > 0;

    $queue->enqueue($self->time_series);
}

# Returns a list with sat cluster id and description.
sub _cluster_info {
    my $self = shift;
    my $config = NOCpulse::Config->new();
    my $sat_cluster_file = $config->get('netsaint', 'configDir').'/SatCluster.ini';
    my $sat_config = NOCpulse::Config->new($sat_cluster_file);
    return ($sat_config->get('Cluster', 'id'), $sat_config->get('Cluster', 'description'));
}

sub _timestamp {
  my ($self, $time) = @_;

  my ($sec, $min, $hour, $mday, $mon, $year, $wday, $yday, $isdst) = localtime($time);
  return sprintf("%02d/%02d/%4d %02d:%02d:%02d", 
                 $mon+1, $mday, $year + 1900, $hour, $min, $sec);
}

sub _trim_whitespace {
  my ($self, $string) = @_;

  $string =~ s/^\s*(.*?)\s*$/$1/;
  return $string
}

1;

__END__
