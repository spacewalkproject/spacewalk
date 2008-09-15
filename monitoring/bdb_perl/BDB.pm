package NOCpulse::BDB;

use strict;
use BerkeleyDB;
use Fcntl;
use Symbol;
use FcntlLock ':all';

local $NOCpulse::BDB::Error = undef;

#################################################
# private utilities
#################################################

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

    die "NOCpulse::BDB is no longer used; this is a bug, please report.";

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

    my $open_ok = sysopen($fh, $lockfilename, O_RDWR, 0644);
    if( not $open_ok )
    {
	if( -e $lockfilename )
	{
	    $NOCpulse::BDB::Error = "Cannot open lock file $lockfilename: $!";
	    return undef;
	}
	
	# The database doesn't already exist

	my $retval = &make_db_dirs($filename, 0700);
	if ( not $retval )
	{
	    $NOCpulse::BDB::Error = "Cannot create directory for $filename: $!";
	    return undef;
	}
	
	my $open_again_ok = sysopen($fh, $lockfilename, O_RDWR|O_CREAT, 0644);
	if( not $open_again_ok )
	{
	    $NOCpulse::BDB::Error = "Cannot open lock file $lockfilename: $!";
	    return undef;
	}
    }

    my $rc = lock_file($fh, $write);
    if( not $rc )
    {
	close $fh;
	$NOCpulse::BDB::Error = "Cannot acquire lock on $lockfilename: $!";
	return undef;
    }

    $self->{filehandles}->{$filename} = $fh;

    my $db = new BerkeleyDB::Btree(-Filename => $filename,
				   -Flags    => DB_CREATE,
				   -Mode     => 0644
				   );

    if( not defined $db )
    {
	$NOCpulse::BDB::Error = "Cannot open database $filename: $BerkeleyDB::Error";
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
	$NOCpulse::BDB::Error = "Cannot release lock on $filename: $!";
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
	$NOCpulse::BDB2::Error = "Cannot insert into $filename: $status";
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
	$NOCpulse::BDB::Error = "Cannot insert list into $filename: $status";
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

    # print "fetch($filename, $start, $end, $get_initial)\n";

    my $ts;

    if(  ( $start < 1000000000 ) and ( $end >= 1000000000 ) )
    {
	$ts = $self->_fetch($filename, $start, 999999999);
	push @{$ts}, @{ $self->_fetch($filename, 1000000000, $end) };
    }
    else
    {
	$ts = $self->_fetch($filename, $start, $end, $get_initial);
    }

    if( $get_initial )
    {
	if( ( (scalar @$ts) == 0) or ($ts->[0] > $start) )
	{
	    # still need to get the initial point
	    my ($previous_t, $previous_v) = $self->previous($filename, $start);
	    if( defined $previous_t )
	    {
		$ts = [ $previous_t, $previous_v, @{$ts}];
	    }
	    elsif( $start >= 1000000000 )
	    {
		($previous_t, $previous_v) = $self->previous($filename, 999999999);
		if( defined $previous_t )
		{
		    $ts = [ $previous_t, $previous_v, @{$ts}];
		}
	    }

	}
    }

    return $ts;
}

sub _fetch
{
    my $self = shift;
    my $filename = shift;
    my $start = shift;
    my $end = shift;

    # print "_fetch($filename, $start, $end)\n";

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
	if( ( $x <= $end ) and ( $x >= $start ) )
	{
	    # print "B $x $v\n";
	    push @{$ts}, ($x, $v);

	    while( $cursor->c_get($t, $v, DB_NEXT) == 0 )
	    {
		last if ( $t >= $end );
		last if ( $t < $start ); # extra for lexical badness
		# print "C $t $v\n";
		push @{$ts}, ($t, $v);
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

    # this is a workaround for the lexical comparator problem:
    my ($z, $w) = (900000000, 0);
    $cursor->c_get($z, $w, DB_SET_RANGE);
    my $status;
    if ( ($status = $cursor->c_get($t, $v, DB_PREV)) != 0 )
    {
	# This is what it should be:
	$status = $cursor->c_get($t, $v, DB_LAST);
    }

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
	$NOCpulse::BDB::Error = "put error on $to_filename: $status";
	return undef;
    }

    return 1;

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


