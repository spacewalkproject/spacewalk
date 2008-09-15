#!./perl -w

# ID: %I%, %G%   

use strict ;

BEGIN {
    unless(grep /blib/, @INC) {
        chdir 't' if -d 't';
        @INC = '../lib' if -d '../lib';
    }
}

use BerkeleyDB; 
use t::util ;

if ($BerkeleyDB::db_ver < 2.005002)
{
    print "1..0 # Skip: join needs Berkeley DB 2.5.2 or later\n" ;
    exit 0 ;
}


print "1..41\n";

my $Dfile1 = "dbhash1.tmp";
my $Dfile2 = "dbhash2.tmp";
my $Dfile3 = "dbhash3.tmp";
unlink $Dfile1, $Dfile2, $Dfile3 ;

umask(0) ;

{
    # error cases
    my $lex = new LexFile $Dfile1, $Dfile2, $Dfile3 ;
    my %hash1 ;
    my $value ;
    my $status ;
    my $cursor ;

    ok 1, my $db1 = tie %hash1, 'BerkeleyDB::Hash', 
				-Filename => $Dfile1,
                               	-Flags     => DB_CREATE,
                                -DupCompare   => sub { $_[0] lt $_[1] },
                                -Property  => DB_DUP|DB_DUPSORT ;

    # no cursors supplied
    eval '$cursor = $db1->db_join() ;' ;
    ok 2, $@ =~ /Usage: \$db->BerkeleyDB::db_join\Q([cursors], flags=0)/;

    # empty list
    eval '$cursor = $db1->db_join([]) ;' ;
    ok 3, $@ =~ /db_join: No cursors in parameter list/;

    # cursor list, isn not a []
    eval '$cursor = $db1->db_join({}) ;' ;
    ok 4, $@ =~ /db_join: first parameter is not an array reference/;

    eval '$cursor = $db1->db_join(\1) ;' ;
    ok 5, $@ =~ /db_join: first parameter is not an array reference/;

    my ($a, $b) = ("a", "b");
    $a = bless [], "fred";
    $b = bless [], "fred";
    eval '$cursor = $db1->db_join($a, $b) ;' ;
    ok 6, $@ =~ /db_join: first parameter is not an array reference/;

}

{
    # test a 2-way & 3-way join

    my $lex = new LexFile $Dfile1, $Dfile2, $Dfile3 ;
    my %hash1 ;
    my %hash2 ;
    my %hash3 ;
    my $value ;
    my $status ;

    my $home = "./fred" ;
    ok 7, my $lexD = new LexDir($home);
    ok 8, my $env = new BerkeleyDB::Env -Home => $home,
				     -Flags => DB_CREATE|DB_INIT_TXN
					  	|DB_INIT_MPOOL;
					  	#|DB_INIT_MPOOL| DB_INIT_LOCK;
    ok 9, my $txn = $env->txn_begin() ;
    ok 10, my $db1 = tie %hash1, 'BerkeleyDB::Hash', 
				-Filename => $Dfile1,
                               	-Flags     => DB_CREATE,
                                -DupCompare   => sub { $_[0] cmp $_[1] },
                                -Property  => DB_DUP|DB_DUPSORT,
			       	-Env 	   => $env,
			    	-Txn	   => $txn  ;
				;

    ok 11, my $db2 = tie %hash2, 'BerkeleyDB::Hash', 
				-Filename => $Dfile2,
                               	-Flags     => DB_CREATE,
                                -DupCompare   => sub { $_[0] cmp $_[1] },
                                -Property  => DB_DUP|DB_DUPSORT,
			       	-Env 	   => $env,
			    	-Txn	   => $txn  ;

    ok 12, my $db3 = tie %hash3, 'BerkeleyDB::Btree', 
				-Filename => $Dfile3,
                               	-Flags     => DB_CREATE,
                                -DupCompare   => sub { $_[0] cmp $_[1] },
                                -Property  => DB_DUP|DB_DUPSORT,
			       	-Env 	   => $env,
			    	-Txn	   => $txn  ;

    
    ok 13, addData($db1, qw( 	apple		Convenience
    				peach		Shopway
				pear		Farmer
				raspberry	Shopway
				strawberry	Shopway
				gooseberry	Farmer
				blueberry	Farmer
    			));

    ok 14, addData($db2, qw( 	red	apple
    				red	raspberry
    				red	strawberry
				yellow	peach
				yellow	pear
				green	gooseberry
				blue	blueberry)) ;

    ok 15, addData($db3, qw( 	expensive	apple
    				reasonable	raspberry
    				expensive	strawberry
				reasonable	peach
				reasonable	pear
				expensive	gooseberry
				reasonable	blueberry)) ;

    ok 16, my $cursor2 = $db2->db_cursor() ;
    my $k = "red" ;
    my $v = "" ;
    ok 17, $cursor2->c_get($k, $v, DB_SET) == 0 ;

    # Two way Join
    ok 18, my $cursor1 = $db1->db_join([$cursor2]) ;

    my %expected = qw( apple Convenience
			raspberry Shopway
			strawberry Shopway
		) ;

    # sequence forwards
    while ($cursor1->c_get($k, $v) == 0) {
	delete $expected{$k} 
	    if defined $expected{$k} && $expected{$k} eq $v ;
	#print "[$k] [$v]\n" ;
    }
    ok 19, keys %expected == 0 ;
    ok 20, $cursor1->status() == DB_NOTFOUND ;

    # Three way Join
    ok 21, $cursor2 = $db2->db_cursor() ;
    $k = "red" ;
    $v = "" ;
    ok 22, $cursor2->c_get($k, $v, DB_SET) == 0 ;

    ok 23, my $cursor3 = $db3->db_cursor() ;
    $k = "expensive" ;
    $v = "" ;
    ok 24, $cursor3->c_get($k, $v, DB_SET) == 0 ;
    ok 25, $cursor1 = $db1->db_join([$cursor2, $cursor3]) ;

    %expected = qw( apple Convenience
			strawberry Shopway
		) ;

    # sequence forwards
    while ($cursor1->c_get($k, $v) == 0) {
	delete $expected{$k} 
	    if defined $expected{$k} && $expected{$k} eq $v ;
	#print "[$k] [$v]\n" ;
    }
    ok 26, keys %expected == 0 ;
    ok 27, $cursor1->status() == DB_NOTFOUND ;

    # test DB_JOIN_ITEM
    # #################
    ok 28, $cursor2 = $db2->db_cursor() ;
    $k = "red" ;
    $v = "" ;
    ok 29, $cursor2->c_get($k, $v, DB_SET) == 0 ;
 
    ok 30, $cursor3 = $db3->db_cursor() ;
    $k = "expensive" ;
    $v = "" ;
    ok 31, $cursor3->c_get($k, $v, DB_SET) == 0 ;
    ok 32, $cursor1 = $db1->db_join([$cursor2, $cursor3]) ;
 
    %expected = qw( apple 1
                        strawberry 1
                ) ;
 
    # sequence forwards
    $k = "" ;
    $v = "" ;
    while ($cursor1->c_get($k, $v, DB_JOIN_ITEM) == 0) {
        delete $expected{$k}
            if defined $expected{$k} ;
        #print "[$k]\n" ;
    }
    ok 33, keys %expected == 0 ;
    ok 34, $cursor1->status() == DB_NOTFOUND ;

    ok 35, $cursor1->c_close() == 0 ;
    ok 36, $cursor2->c_close() == 0 ;
    ok 37, $cursor3->c_close() == 0 ;

    ok 38, ($status = $txn->txn_commit) == 0;

    undef $txn ;

    ok 39, my $cursor1a = $db1->db_cursor() ;
    eval { $cursor1 = $db1->db_join([$cursor1a]) };
    ok 40, $@ =~ /BerkeleyDB Aborting: attempted to do a self-join at/;
    eval { $cursor1 = $db1->db_join([$cursor1]) } ;
    ok 41, $@ =~ /BerkeleyDB Aborting: attempted to do a self-join at/;

    undef $cursor1a;
    #undef $cursor1;
    #undef $cursor2;
    #undef $cursor3;
    undef $db1 ;
    undef $db2 ;
    undef $db3 ;
    undef $env ;
    untie %hash1 ;
    untie %hash2 ;
    untie %hash3 ;
}

print "# at the end\n";
