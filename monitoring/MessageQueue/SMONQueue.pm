# This is an abstract class
package NOCpulse::SMONQueue;

use strict;
use NOCpulse::Debuggable;
use BerkeleyDB;
use Fcntl;
use Symbol;
use URI::Escape;
use NOCpulse::SatCluster;
use Time::HiRes qw(gettimeofday);

@NOCpulse::SMONQueue::ISA = qw ( NOCpulse::Debuggable  );

sub new
{
    my $class = shift;
    my %args = @_;

    my $self = {};
    bless $self, $class;

    my $debug = $args{'Debug'};
    my $gritcher = $args{'Gritcher'};
    my $cfg = $args{'Config'};
    
    my($login,$pw,$uid,$gid) = getpwnam($cfg->get('queues', 'queueuser'));


    my $cluster = NOCpulse::SatCluster->newInitialized($cfg);

    $self->config($cfg);
    $self->debugobject($debug);
    $self->gritcher($gritcher);
    $self->uid($uid);
    $self->gid($gid);

    my $cluster_id = $cluster->get_id();
    $self->cluster_id($cluster_id);

    $self->calculate_mac();

    return $self;
}

sub dqlimit
{
   my $self = shift;

   if( not defined $self->{'dqlimit'} )
   {
       $self->{'dqlimit'} =
	   $self->config()->get('queues', $self->id().'_dequeueLimit') || 0;
   }

   return $self->{'dqlimit'};
}

sub calculate_mac
{
    my $self = shift;

    my $mac = `/sbin/ifconfig eth0`;
    $mac =~ s/.*HWaddr (\S*).*/$1/s;
    my @nodes = split(/:/, $mac);
    $mac = sprintf("%02X:%02X:%02X:%02X:%02X:%02X",
		   hex($nodes[0]), hex($nodes[1]), hex($nodes[2]),
		   hex($nodes[3]), hex($nodes[4]), hex($nodes[5]));

    $self->mac($mac);
}

sub mac
{
    my $self = shift;
    my $mac = shift;

    if( defined $mac ) 
    {
	$self->{'mac'} = $mac;
    }
    else
    {
	return $self->{'mac'};
    }
}

sub cluster_id
{
   my $self = shift;
   my $cluster_id = shift;

   if( defined $cluster_id )
   {
      $self->{'cluster_id'} = $cluster_id;
   }
   else
   {
      return $self->{'cluster_id'};
   }
}

sub directory
{
    my $self = shift;
    my $d = shift;
    
    if( defined $d )
    {
	$self->{'directory'} = $d;
    }
    else
    {
	return $self->{'directory'};
    }
}

sub filename
{
    my $self = shift;
    
    return $self->directory()."/entries.btree";
}

sub gritcher
{
    my $self = shift;
    my $g = shift;
    
    if( defined $g )
    {
	$self->{'gritcher'} = $g;
    }
    else
    {
	return $self->{'gritcher'};
    }
}

sub config
{
    my $self = shift;
    my $cfg = shift;
    
    if( defined $cfg )
    {
	$self->{'config'} = $cfg;
    }
    else
    {
	return $self->{'config'};
    }
}

sub uid
{
    my $self = shift;
    my $uid = shift;

    if( defined $uid )
    {
	$self->{'uid'} = $uid;
    }
    else
    {
	return $self->{'uid'};
    }
}

sub gid
{
    my $self = shift;
    my $gid = shift;

    if( defined $gid )
    {
	$self->{'gid'} = $gid;
    }
    else
    {
	return $self->{'gid'};
    }
}


sub maxsize
{
    my $self = shift;
    my $g = shift;
    
    if( defined $g )
    {
	$self->{'maxsize'} = $g;
    }
    else
    {
	return $self->{'maxsize'};
    }
}

sub protocol_version
{
    my $self = shift;
    my $v = shift;
    
    if( defined $v )
    {
	$self->{'protocol_version'} = $v;
    }
    else
    {
	return $self->{'protocol_version'};
    }
}


sub dequeue
{
    my $self = shift;
    my $smon = shift;

    my ($entries, $entry_keys) = $self->entries($self->dqlimit());

    if( not defined $entries )
    {
	$self->dprint(1, "got nothing from entries\n");
	return;
    }
    
    my $i = 0;
    while( $i < (scalar @$entries) )
    {
	my $entry = $entries->[$i];
	my $k = $entry_keys->[$i];
	my $rc = $self->send($smon, $entry);
	if( not $rc )
	{
	    $self->dprint(2, "error sending\n");
	    $smon->heartbeat();
	    return;
	}
	$self->commit($self->filename(), $k);
	$i++;
    }

}

sub hydrate_entry
{
    die "subclass must override";
}

sub send
{
    my $self = shift;
    my $smon = shift;
    my $entry = shift;

    $self->dprint(3, "constructing url\n");
    my $encoded_entry =
      'queuename='.$self->id().
      '&version='.$self->protocol_version().
      '&mac='.$self->mac().
      '&satcluster='.$self->cluster_id().
      '&'.$entry->as_url_query();

    $self->dprint(1, "sending entry: $encoded_entry\n");

    my($code, $msg, $body) = $smon->connection()->ssl_post($smon->url_path(), $encoded_entry);

    if ($code == 200)
    {
	$self->dprint(1, "\t\tSuccess\n");
	return 1;
    }
    elsif ($code == 202)
    {
	# Mitigated success -- there were errors, but the server accepted
	# our upload.  Delete the data point locally.
	my $subject = $self->id()." queue send warning";
	my $message = "Server accepted datapoint with reservations:\n$body\n";
	$self->dprint(1, "\t\tServer accepted datapoint with reservations\n");
	$self->dprint(1, "\t\tWarning: $body\n");
	$self->gritcher()->gritch($subject, $message);
	return 1;
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
	$self->gritcher()->gritch($subject, $message) unless $code == 500;
	return 0;
    }
}

sub show
{
    my $self = shift;

    my $filename = $self->filename();

    $self->dprint(2, "about to acquire_db($filename)\n");

    my ($db, $lock_fh) = $self->acquire_db($filename, 1);
    if( not defined $db )
    {
       return undef;
    }

    my ($dehydrated, $dehydrated_keys) = $self->db_read($db);

    my $i = 0;
    while( $i < (scalar @$dehydrated) )
    {
	my $parched = $dehydrated->[$i];
	my $k = $dehydrated_keys->[$i];
	$self->dprint(1, "-------------------\n");
	$self->dprint(1, "btree key: $k\n");
	$self->dprint(1, $parched."\n");
	$i++;
    }

    $self->release_db($filename, $db, $lock_fh);
}

sub commit
{
    my $self = shift;
    my $filename = shift;
    my @deletable = @_;

    my ($db, $lock_fh) = $self->acquire_db($filename, 1);
    if( not defined $db )
    {
       return undef;
    }

    $self->db_delete($db, @deletable);

    $self->release_db($filename, $db, $lock_fh);
}

sub btree_info
{
    my $self = shift;

    my ($db, $lock_fh) = $self->acquire_db($self->filename(), 0);
    if( not defined $db )
    {
	return undef;
    }
    
    my $info = $db->db_stat();
    
    $self->release_db($self->filename(), $db, $lock_fh);
    
    return $info
}

sub enqueue
{
    my $self = shift;
    my @entries = @_;

    my $filename = $self->filename();
    
    my ($db, $lock_fh) = $self->acquire_db($filename, 1);
    if( not defined $db )
    {
	return 0;
    }

    my $dehydrated = {};
    my $entry;
    foreach $entry (@entries)
    {
	$dehydrated->{gettimeofday()} = $entry->dehydrate();
    }

    $self->db_insert($db, $dehydrated);
    
    $self->release_db($filename, $db, $lock_fh);
    
    return 1;
    
}

sub overload_warning
{
    my $self = shift;
    my $num_entries = shift;

    my $subject = $self->name()." queue too large";
    my $message = $self->name()." queue growing too large ($num_entries entries)\n";
    $self->dprint(1, "$subject: $message\n");
    
    $self->gritcher()->gritch($subject, $message);    
}

sub entries
{
    my $self = shift;
    my $max = shift;
    
    my $filename = $self->filename();

    $self->dprint(2, "about to tie $filename\n");

    my ($db, $lock_fh) = $self->acquire_db($filename, 1);
    if( not defined $db )
    {
       return undef;
    }

    $self->dprint(2, "the tie is done for $filename\n");
    
    my $stats = $db->db_stat();
    if( not defined $stats )
    {
        $self->dprint(1, "error doing a stat on ".$self->name()."\n");
        $self->release_db($filename, $db, $lock_fh);
        return 0;
    }

    my $num_entries = $stats->{'bt_ndata'};

    $self->dprint(2, "Found $num_entries entries in ".$self->name()."\n");
    
    if ( $num_entries > $self->maxsize() ) {
	$self->overload_warning($num_entries);
    }

    my ($dehydrated, $dehydrated_keys) = $self->db_read($db, $max);
    $self->release_db($filename, $db, $lock_fh);
    $self->dprint(2, "released $filename\n");
    
    my $hydrated = [];
    
    if( defined $dehydrated )
    {
	my $i = 0;
	while( $i < (scalar @$dehydrated) )
	{
	    push @$hydrated, $self->hydrate_entry($dehydrated->[$i]);
	    $i++;
	}
	
	return ($hydrated, $dehydrated_keys);
    }
    else
    {
	return undef;
    }
    
}


sub name
{
    die "subclass must override";
}

#############################
# low-level BDB/file methods
#############################

sub compare_keys
{
    my ($a, $b) = @_;

    return( $a <=> $b );
};


sub acquire_db
{
    my $self = shift;
    my $filename = shift;
    my $write = shift;

    my $lock_fh = Symbol::gensym();
    my $lockfile = $filename.'.lock';
    
    my $open_ok = sysopen($lock_fh, $lockfile, O_RDWR|O_CREAT, 0644);
    if( not $open_ok )
    {
	$self->dprint(1, "error opening $lockfile: $!\n");
        return;
    }
    
    my $rc = lock_file($lock_fh, $write);
    if( not $rc )
    {
	close $lock_fh;
	$self->dprint(1, "Could not acquire lock on $lockfile: $!\n");
        return;
    }
    
    my $db = new BerkeleyDB::Btree(-Filename => $filename,
				   -Flags    => DB_CREATE,
				   -Mode     => 0644,
				   -Compare  => \&compare_keys,
				   );
    if( not defined $db )
    {
	$self->dprint(1, "Could not db_open database $filename: $BerkeleyDB::Error\n");
        return;
    }

    # Make sure file is owned by right owner if I'm root
    # This is a bit of a race, since between the creation time of the files
    # and the chowning, other enqueueing processes may attempt to acquire
    # handles and lock these files

    if( not $> )
    {
	my $rc1 = chown($self->uid(), $self->gid(), $self->filename());
	if( not $rc1 )
	{
	    $self->dprint(1, "ERROR: Unable to chown ".$self->filename()."\n");
	}
	
	my $rc2 = chown($self->uid(), $self->gid(), $self->filename().'.lock');
	if( not $rc2 )
	{
	    $self->dprint(1, "ERROR: Unable to chown ".$self->filename().".lock\n");
	}
    }

    return ($db, $lock_fh);

}

sub release_db
{
    my $self = shift;
    my $filename = shift;
    my $db = shift;
    my $lock_fh = shift;

    $db->db_close();

    my $rc = unlock_file($lock_fh);
    if( not $rc )
    {
	close $lock_fh;
	$self->dprint(1, "Could not release lock for $filename: $!\n");
        return;
    }

    close $lock_fh;
    
}    

sub db_insert
{
    my $self = shift;
    my $db = shift;
    my $elements = shift;

    $self->dprint(1, "db_insert ".$self->id()." beginning with ".scalar(keys %$elements)." elements\n");

    my $status = 0;

    my ($k, $v) = (0, 0);

    # we do this sort since it may help db_put be more efficient
    # If we anticipate inserts of multiple datapoints,
    # we should probably just use cursors

    my @key_list = sort compare_keys keys %$elements;

    while( ( scalar @key_list ) and ( $status == 0 ) )
    {
	my $k = pop @key_list;
	my $v = $elements->{$k};
	$status = $db->db_put($k, $v);
    }

    if( $status != 0 )
    {
	$self->dprint(1, "error during db_put\n");
	return 0;
    }

    return 1;
}

sub db_delete
{
    my $self = shift;
    my $db = shift;
    my @goners = @_;

    $self->dprint(2, "db_delete " . $self->id() . " " . scalar(@goners) . " entries\n");

    my $status = 0;

    while( ( scalar @goners ) and ( $status == 0 ) ) 
    {
	my $k = pop @goners;
	$status = $db->db_del($k);
        if( $status != 0 ) {
            $self->dprint(1, "Cannot delete entry $k from ", $self->id(), ": $status\n");
        }
    }
}

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
    $status = $cursor->c_get($k, $v, DB_FIRST);

    while( ( ($max == 0) or ($total <= $max) ) and ($status == 0) )
    {
	$self->dprint(6, "db_read found $k -> $v\n");
	push @$result_keys, $k;
	push @$result_values, $v;
	$total++;
	$status = $cursor->c_get($k, $v, DB_NEXT);
    }

    $cursor->c_close();
    undef $cursor;

    $self->dprint(2, "db_read is about to return ".scalar(@$result_values)." values\n");

    return ($result_values, $result_keys);
}

sub lock_file
{
    my $fh = shift;
    my $write = shift;

    my $flock_flags = $write ? &F_WRLCK : &F_RDLCK;

    my $flock_struct =
          pack('sslli',
               &F_WRLCK, # type
               0,        # whence
               0,        # start
               0,        # len
               0);       # pid

    return fcntl($fh, &F_SETLKW, $flock_struct);
}

sub unlock_file
{
    my $fh = shift;

    my $flock_struct =
          pack('sslli',
               &F_UNLCK, # type
               0,        # whence
               0,        # start
               0,        # len
               0);       # pid

    return fcntl($fh, &F_SETLK, $flock_struct);
}

1;

