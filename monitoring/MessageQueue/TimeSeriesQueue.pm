
use strict;

package TimeSeriesQueue;

use NOCpulse::SMONQueue;
use NOCpulse::TimeSeriesDatapoint;
use URI::Escape;
use BerkeleyDB;

@TimeSeriesQueue::ISA = qw ( SMONQueue );

# Keep in synch with tsdb/TSDB.pm
my $PROTOCOL_VERSION = '1.0';


#######################
# class methods
#######################

sub new
{
    my $class = shift;
    my %args = @_;

    my $self = SMONQueue->new(%args);
    bless $self, $class;

    $self->directory($self->config()->get('queues', 'queuedir').'/'.$self->id());
    $self->maxsize($self->config()->get('queues', $self->id().'_maxsize'));
    $self->batch_size($self->config()->get('queues', $self->id().'_batch_size'));
    $self->protocol_version($PROTOCOL_VERSION);

    return $self;
}

sub batch_size
{
    my $self = shift;
    my $bs = shift;

    if( defined $bs )
    {
	$self->{'batch_size'} = $bs;
    }
    else
    {
	return $self->{'batch_size'};
    }
}

sub id
{
    return "ts_db";
}

sub name
{
    return "Time Series";
}

sub dequeue
{
    my $self = shift;
    my $smon = shift;


    my $batch_size = $self->batch_size();
    my $this_batch_size = ( $self->dqlimit > $batch_size ) ? $batch_size : $self->dqlimit;

    my $total_sent = 0;

    while( $total_sent < $self->dqlimit )
    {
	my ($entries, $entry_keys) = $self->entries($this_batch_size);
	if( not defined $entries )
	{
	    return;
	}
	
	my $num_found = scalar @$entries;
	if( $num_found == 0 )
	{
	    $self->dprint(2, "no timseries to send\n");
	    return;
	}
	
	my $keys_by_oid_and_time = {};
	my $data = "";
	
	my $i = 0;
	while ( $i < ( scalar @$entries ) )
	{
	    my $entry = $entries->[$i];
	    my $key = $entry_keys->[$i];
	    $data .= $entry->oid() . "\t" . $entry->t() . "\t" . $entry->v() . "\n";
	    $keys_by_oid_and_time->{$entry->oid(), $entry->t()} = $key;
	    $i++;
	}
	
	$data = uri_escape($data, $QueueEntry::badchars);
	
	my ($rc, $results) = $self->send_batch($smon, $data);
	
	$smon->heartbeat();
	
	if( $rc )
	{
	    my @deletable_keys;

	    my @result_lines = split("\n", $results);
	    my $result_line;
	    foreach $result_line (@result_lines)
	    {
		my ($oid, $t, $status) = split /\s+/, $result_line;
		if( $status eq 'retry' )
		{
		    # do not add this key to deletable
		    # so that we can resend this data item later
		}
		else
		{
		    push @deletable_keys, $keys_by_oid_and_time->{$oid, $t};
		}
	    }

	    $self->commit($self->filename(), @deletable_keys) 
                if (@deletable_keys);
	}
	else
	{
	    $self->dprint(1, "error sending batch to tsdb\n");
	    return;
	}

	$self->dprint(2, "sent $num_found entries\n");

	$total_sent += $num_found;
    }

    $self->dprint(3, "done with TimeSeriesQueue::dequeue\n");

}

sub send_batch
{
    my $self = shift;
    my $smon = shift;
    my $data = shift;

    $self->dprint(3, "constructing url\n");
    my $encoded_entry =
      'queuename='.$self->id().
      '&version='.$self->protocol_version().
      '&mac='.$self->mac().
      '&satcluster='.$self->cluster_id().
      '&fn=batch_insert&data='.$data;

    $self->dprint(1, "sending entry: $encoded_entry\n");

    my($code, $msg, $body) = $smon->connection()->ssl_post($smon->url_path(), $encoded_entry);

    if ($code == 200)
    {
        $self->dprint(1, "\t\tSuccess\n");
        return (1, $body);
    }
    elsif ($code == 202)
    {
        my $subject = $self->id()." queue send warning";
        my $message = "Server accepted datapoint with reservations:\n$body\n";
        $self->dprint(1, "\t\tServer accepted datapoint with reservations\n");
        $self->dprint(1, "\t\tWarning: $body\n");
        $self->gritcher()->gritch($subject, $message);
        return (1, $body);
    }
    else
    {
        my $subject = $self->id()." queue send error";
        my $message = "Couldn't send: ";
        if (defined($code))
        {
            $message .= "$code $msg\n";
            $message .= "Content: $body\n" if (length($body));
        }
        else
        {
            $message .= "$@\n";
        }
        $self->dprint(1, "\t\tFailed:  $subject: $message");
        $self->gritcher()->gritch($subject, $message) unless $code == 500; #bug 4247
        return (0, undef);
    }

}


# TimeSeriesQueue overrides db_read() in order implement a LIFO
# instead of the default FIFO

sub db_read
{
    my $self = shift;
    my $db = shift;
    my $max = shift;

    my $result_values = [];
    my $result_keys = [];

    my $status = 0;
    
    my $cursor = $db->db_cursor(); 
    
    my ($k, $v) = (0, 0);

    my $total = 0;
    $status = $cursor->c_get($k, $v, DB_LAST);

    while( ( ($max == 0) or ($total <= $max) ) and ($status == 0) )
    {
	$self->dprint(6, "db_read found $k -> $v\n");
	push @$result_keys, $k;
	push @$result_values, $v;
	$total++;
	$status = $cursor->c_get($k, $v, DB_PREV);
    }

    $cursor->c_close();
    undef $cursor;

    $self->dprint(2, "db_read is about to return ".scalar(@$result_values)." values\n");

    return ($result_values, $result_keys);
}

sub hydrate_entry
{
    my $self = shift;
    my $data = shift;

    return TimeSeriesDatapoint->hydrate($data);
}

1;
