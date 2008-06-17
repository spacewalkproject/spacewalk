package NOCpulse::BDB2;

use strict;
use BerkeleyDB;
use Fcntl;
use Symbol;
use FcntlLock ':all';

local $NOCpulse::BDB2::Error = undef;

#################################################
# private utilities
#################################################

sub compare_keys
{
    my ($a, $b) = @_;

    return( $a <=> $b );
};

sub lock_file
{
    my $fh = shift;
    my $write = shift;
    my $rv;

    if ($write) {
      $rv = lock_ex($fh);
    } else {
      $rv = lock_sh($fh);
    }

    if ($rv == -1) {
      return 0;
    } else {
      return 1;
    }

}

sub unlock_file
{
    my $fh = shift;

    my $rv = lock_un($fh);

    if ($rv == -1) {
      return 0;
    } else {
      return 1;
    }

}

sub make_db_dirs
{
    my $path = shift;
    my $mode = shift;
    
    my $curpath = '';
    
    $path = "./$path" unless ($path =~ /^\//);
    
    my @pathname_components = split("/", $path);

    my $leaf = pop @pathname_components;
    
    while (@pathname_components)
    {
	$curpath .= shift(@pathname_components) . "/";
	if (! -d $curpath)
	{
	    my $rc = mkdir($curpath, $mode);
	    if( not $rc and not ( $! =~ /File exists/ ) ) 
	    {
		return 0;
	    }
	}
    }
    return 1;
}

#################################################
# public class methods
#################################################

sub new
{
    my $class = shift;

    die "NOCpulse::BDB2 is no longer used; this is a bug, please report.";

    my $self = {};
    bless $self, $class;

    $self->{filehandles} = {};

    return $self;
}

#################################################
# private object methods
#################################################

# All code in this class should use acquire_db/release_db to handle
# all access to BDB objects.

sub acquire_db
{
    my $self = shift;
    my $filename = shift;
    my $write = shift;

    my $fh = Symbol::gensym();

    my $lockfilename = $filename.'.lock';
    my ($lockfilename) = $lockfilename =~ /(.*)/;
    my $open_ok = sysopen($fh, $lockfilename, O_RDWR, 0644);
    if( not $open_ok )
    {
	if( -e $lockfilename )
	{
	    $NOCpulse::BDB2::Error = "error opening $lockfilename: $!";
	    return undef;
	}

	# The database doesn't already exist

	my $retval = &make_db_dirs($filename, 0700);
	if ( not $retval )
	{
	    $NOCpulse::BDB2::Error = "make_db_dirs status: $!";
	    return undef;
	}
	
	my $open_again_ok = sysopen($fh, $lockfilename, O_RDWR|O_CREAT, 0644);
	if( not $open_again_ok )
	{
	    $NOCpulse::BDB2::Error = "error opening $lockfilename: $!";
	    return undef;
	}
    }
    
    my $rc = lock_file($fh, $write);
    if( not $rc )
    {
	close $fh;
	$NOCpulse::BDB2::Error = "Could not acquire lock on $lockfilename: $!";
	return undef;
    }
    
    $self->{filehandles}->{$filename} = $fh;
    
    my $db = new BerkeleyDB::Btree(-Filename => $filename,
				   -Flags    => DB_CREATE,
				   -Mode     => 0644,
				   -Compare  => \&compare_keys
				   );

    if( not defined $db )
    {
	$NOCpulse::BDB2::Error = "Could not db_open database $filename: $BerkeleyDB::Error";
	return undef;
    }

    return $db;

}

sub release_db
{
    my $self = shift;
    my $filename = shift;
    my $db = shift;

    $db->db_close();

    my $fh = $self->{filehandles}->{$filename};

    my $rc = unlock_file($fh);
    if( not $rc )
    {
	close $fh;
	$NOCpulse::BDB2::Error = "Could not release lock on $filename: $!";
	return undef;
    }

    close $fh;
    
    delete $self->{filehandles}->{$filename};

    return 1;
}    

#################################################
# public object methods
#################################################

sub insert
{
    my $self = shift;
    my $filename = shift;
    my $t = shift;
    my $v = shift;

    # print "insert($filename, $t, $v)\n";

    my $db = $self->acquire_db($filename, 1);
    if( not defined $db )
    {
	return undef;
    }
    
    my $status = $db->db_put($t, $v);
    
    $self->release_db($filename, $db);
    undef $db;

    if( $status != 0 )
    {
	$NOCpulse::BDB2::Error = "put error on $filename: $status";
	return undef;
    }
    
    return 1;
}


sub insert_list
{
    my $self = shift;
    my $filename = shift;
    my $list = shift;

    my $db = $self->acquire_db($filename, 1);
    if( not defined $db )
    {
	return undef;
    }

    my $status = 0;
    
    while( ( ( scalar @{$list}) > 1 ) and
	   ( $status == 0 ) )
    {
	my $t = shift @{$list};
	my $v = shift @{$list};
	
	$status = $db->db_put($t, $v);
    }
    
    $self->release_db($filename, $db);
    undef $db;
    
    if( $status != 0 )
    {
	$NOCpulse::BDB2::Error = "put error on $filename: $status";
	return undef;
    }
    
    return 1;
}


sub fetch
{
    my $self = shift;
    my $filename = shift;
    my $start = shift;
    my $end = shift;
    my $get_initial = shift;

    my $ts = [];
    
    my $db = $self->acquire_db($filename, 0);
    if( not defined $db )
    {
	return undef;
    }
    
    my $cursor = $db->db_cursor(); 
    
    my ($t, $v) = (0, 0);
    my $x = $start;
    
    if( $cursor->c_get($x, $v, DB_SET_RANGE) == 0 )
    {
        if( $get_initial and ( $x > $start) )
        {
            # step back another position
            $cursor->c_get($x, $v, DB_PREV);
        }
	if( $x <= $end )
	{
	    push @{$ts}, ($x, $v);
	    while( $cursor->c_get($t, $v, DB_NEXT) == 0 )
	    {
		last if ( $t >= $end );
		push @{$ts}, ($t, $v);
	    }
	}
    }
    else
    {
	if( $get_initial )
	{
	    # couldn't find timestamp >= $start
	    # but we still need to calculate initial state
	    if( $cursor->c_get($x, $v, DB_LAST) == 0 )
            {
                push @{$ts}, ($x, $v);
            }
        }
    }
    
    $cursor->c_close();
    undef $cursor;

    $self->release_db($filename, $db);
    undef $db;

    return $ts;
}


sub last
{
    my $self = shift;
    my $filename = shift;
    
    my $db = $self->acquire_db($filename, 0);
    if( not defined $db )
    {
	return undef;
    }

    my $cursor = $db->db_cursor();
    
    my ($t, $v) = (0, 0);

    my $status = $cursor->c_get($t, $v, DB_LAST);

    $cursor->c_close();
    undef $cursor;

    $self->release_db($filename, $db);
    undef $db;
    
    if( $status == 0 )
    {
	return ($t, $v);
    }
    else
    {
	return undef;
    }
}

sub previous
{
    my $self = shift;
    my $filename = shift;
    my $t = shift;
    
    # print "previous($filename, $t)\n";

    my $db = $self->acquire_db($filename, 0);
    if( not defined $db )
    {
	return undef;
    }

    my $cursor = $db->db_cursor();
    
    my ($x, $v) = ($t, 0);

    my $s1 = $cursor->c_get($x, $v, DB_SET_RANGE);
    my $s2 = $cursor->c_get($x, $v, DB_PREV);
    
    $cursor->c_close();
    undef $cursor;

    $self->release_db($filename, $db);
    undef $db;
    
    if( ($x != 0) and ($x < $t) )
    {
	return ($x, $v);
    }
    else
    {
	return undef;
    }
}

sub delete
{
    my $self = shift;
    my $filename = shift;
    my $t = shift;
    
    my $db = $self->acquire_db($filename, 1);
    if( not defined $db )
    {
	return undef;
    }
   
    $db->db_del($t);
    
    $self->release_db($filename, $db);
    undef $db;
    
    return 0;
}

sub copy
{
    my $self = shift;
    my $from_filename = shift;
    my $to_filename = shift;
    my $start = shift;
    my $end = shift;
    
    # these are two separate loops because if we would create
    # the potential for deadlock if we needed both files open at the same time
    
    my %data; # would be more efficient as an array -awp
    
    my $from_db = $self->acquire_db($from_filename, 0);
    if( not defined $from_db )
    {
	return undef;
    }

    my $from_cursor = $from_db->db_cursor();
    
    my ($t, $v) = (0, 0);
    my $x = $start;
    
    if( $from_cursor->c_get($x, $v, DB_SET_RANGE) == 0 )
    {
	$data{$x} = $v;
	while( $from_cursor->c_get($t, $v, DB_NEXT) == 0 )
	{
	    last if ( $t >= $end );
	    $data{$t} = $v;
	}
    }
    
    $from_cursor->c_close();
    undef $from_cursor;

    $self->release_db($from_filename, $from_db);
    undef $from_db;
    
    my $to_db = $self->acquire_db($to_filename, 1);
    if( not defined $to_db )
    {
	return undef;
    }
    
    my @ks = keys %data;
    my $status = 0;
    my $i = 0;
    my $N = scalar @ks;
    
    while( ( $status == 0 ) and ( $i < $N ) )
    {
	my $k = $ks[$i];
	$status = $to_db->db_put($k, $data{$k});
	$i++;
    }
    
    $self->release_db($to_filename, $to_db);
    undef $to_db;
    
    if( $status != 0 )
    {
	$NOCpulse::BDB2::Error = "put error on $to_filename : $status";
	return undef;
    }
    
    return 0;
    
}

sub size
{
    my $self = shift;
    my $filename = shift;

    my $db = $self->acquire_db($filename, 0);
    if( not defined $db )
    {
	return undef;
    }
    
    my $stats = $db->db_stat();
    
    $self->release_db($filename, $db);
    undef $db;
    
    return $stats->{'bt_nkeys'};
}

sub stat
{
    my $self = shift;
    my $filename = shift;

    my $db = $self->acquire_db($filename, 0);
    if( not defined $db )
    {
	return undef;
    }
    
    my $stats = $db->db_stat();
    
    $self->release_db($filename, $db);
    undef $db;
    
    return $stats;
}


sub DESTROY
{
    my $self = shift;

    my $fh;
    foreach $fh ( values %{$self->{filehandles}} )
    {
	unlock_file($fh);
	close $fh;
    }
}

1;


