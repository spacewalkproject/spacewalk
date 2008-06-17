
package NOCpulse::test::TestBDB2;

use strict;

use NOCpulse::BDB2;

sub list_eq
{
    my $l1 = shift;
    my $l2 = shift;

    if( ( scalar @$l1 ) != ( scalar @$l2 ) )
    {
	return 0;
    }

    my $i;
    while( $i < ( scalar @$l1 ) )
    {
	if( $l1->[$i] != $l2->[$i] )
	{
	    return 0;
	}
	$i++;
    }

    return 1;
}

sub test_tsdb
{
    my $self = shift;

    my $filename = "/tmp/test_bdb2.db";
    
    unlink($filename);
    
    my $db = NOCpulse::BDB2->new();
    
    $db->insert($filename,  999999000, 1);
    $db->insert($filename,  999999100, 2);
    $db->insert($filename, 1000000000, 6);
    $db->insert($filename, 1000000100, 7);
    
    my ($last_t, $last_v) = $db->last($filename);

    $self->assert($last_t == 1000000100 && $last_v == 7, "last");
    
    my $ts;
    
    $ts = $db->fetch($filename,
		       999990000,
		       999999900, 1);
    
    $self->assert(list_eq($ts, [999999000, 1, 999999100, 2]), "test1");
    
    $ts = $db->fetch($filename,
		       999990000,
		       1000001000, 1);
    
    $self->assert(list_eq($ts, [999999000, 1, 999999100, 2, 1000000000, 6, 1000000100, 7]), "test2");
    
    $ts = $db->fetch($filename,
		       999999999,
		       1000001000, 1);
    
    $self->assert(list_eq($ts, [999999100, 2, 1000000000, 6, 1000000100, 7]), "test3");
    
    $ts = $db->fetch($filename,
		       1000000000,
		       1000001000, 1);
    
    
    $self->assert(list_eq($ts, [1000000000, 6, 1000000100, 7]), "test4");
    
    $ts = $db->fetch($filename,
		       1900000000,
		       1900001000, 1);
    
    $self->assert(list_eq($ts, [1000000100, 7]), "test5");
    
    $ts = $db->fetch($filename,
		       1000000050,
		       1000001000, 1);
    
    $self->assert(list_eq($ts, [1000000000, 6, 1000000100, 7]), "test6");
    
    $db->delete($filename, 1000000000);
    
    $ts = $db->fetch($filename,
		       1000000050,
		       1000001000, 1);
    
    $self->assert(list_eq($ts, [999999100, 2, 1000000100, 7]), "deletion");
    
    unlink($filename);
    unlink($filename.".lock");
    
}
