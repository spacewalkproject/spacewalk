#!./perl -w

use strict ;

BEGIN {
    unless(grep /blib/, @INC) {
        chdir 't' if -d 't';
        @INC = '../lib' if -d '../lib';
    }
}

use BerkeleyDB; 
use t::util ;

print "1..50\n";

my $Dfile = "dbhash.tmp";

umask(0);

{
    # error cases

    my $lex = new LexFile $Dfile ;
    my %hash ;
    my $value ;

    my $home = "./fred" ;
    ok 1, my $lexD = new LexDir($home);
    ok 2, my $env = new BerkeleyDB::Env -Home => $home,
				     -Flags => DB_CREATE| DB_INIT_MPOOL;
    eval { $env->txn_begin() ; } ;
    ok 3, $@ =~ /^BerkeleyDB Aborting: Transaction Manager not enabled at/ ;

    eval { my $txn_mgr = $env->TxnMgr() ; } ;
    ok 4, $@ =~ /^BerkeleyDB Aborting: Transaction Manager not enabled at/ ;
    undef $env ;

}

{
    # transaction - abort works

    my $lex = new LexFile $Dfile ;
    my %hash ;
    my $value ;

    my $home = "./fred" ;
    ok 5, my $lexD = new LexDir($home);
    ok 6, my $env = new BerkeleyDB::Env -Home => $home,
				     -Flags => DB_CREATE|DB_INIT_TXN|
					  	DB_INIT_MPOOL|DB_INIT_LOCK ;
    ok 7, my $txn = $env->txn_begin() ;
    ok 8, my $db1 = tie %hash, 'BerkeleyDB::Hash', -Filename => $Dfile,
                                      	       	-Flags     => DB_CREATE ,
					       	-Env 	   => $env,
					    	-Txn	   => $txn  ;

    
    # create some data
    my %data =  (
		"red"	=> "boat",
		"green"	=> "house",
		"blue"	=> "sea",
		) ;

    my $ret = 0 ;
    while (my ($k, $v) = each %data) {
        $ret += $db1->db_put($k, $v) ;
    }
    ok 9, $ret == 0 ;

    # should be able to see all the records

    ok 10, my $cursor = $db1->db_cursor() ;
    my ($k, $v) = ("", "") ;
    my $count = 0 ;
    # sequence forwards
    while ($cursor->c_get($k, $v, DB_NEXT) == 0) {
        ++ $count ;
    }
    ok 11, $count == 3 ;
    undef $cursor ;

    # now abort the transaction
    ok 12, $txn->txn_abort() == 0 ;

    # there shouldn't be any records in the database
    $count = 0 ;
    # sequence forwards
    ok 13, $cursor = $db1->db_cursor() ;
    while ($cursor->c_get($k, $v, DB_NEXT) == 0) {
        ++ $count ;
    }
    ok 14, $count == 0 ;

    my $stat = $env->txn_stat() ;
    ok 15, $stat->{'st_naborts'} == 1 ;

    undef $txn ;
    undef $cursor ;
    undef $db1 ;
    undef $env ;
    untie %hash ;
}

{
    # transaction - abort works via txnmgr

    my $lex = new LexFile $Dfile ;
    my %hash ;
    my $value ;

    my $home = "./fred" ;
    ok 16, my $lexD = new LexDir($home);
    ok 17, my $env = new BerkeleyDB::Env -Home => $home,
				     -Flags => DB_CREATE|DB_INIT_TXN|
					  	DB_INIT_MPOOL|DB_INIT_LOCK ;
    ok 18, my $txn_mgr = $env->TxnMgr() ;
    ok 19, my $txn = $txn_mgr->txn_begin() ;
    ok 20, my $db1 = tie %hash, 'BerkeleyDB::Hash', -Filename => $Dfile,
                                      	       	-Flags     => DB_CREATE ,
					       	-Env 	   => $env,
					    	-Txn	   => $txn  ;

    
    # create some data
    my %data =  (
		"red"	=> "boat",
		"green"	=> "house",
		"blue"	=> "sea",
		) ;

    my $ret = 0 ;
    while (my ($k, $v) = each %data) {
        $ret += $db1->db_put($k, $v) ;
    }
    ok 21, $ret == 0 ;

    # should be able to see all the records

    ok 22, my $cursor = $db1->db_cursor() ;
    my ($k, $v) = ("", "") ;
    my $count = 0 ;
    # sequence forwards
    while ($cursor->c_get($k, $v, DB_NEXT) == 0) {
        ++ $count ;
    }
    ok 23, $count == 3 ;
    undef $cursor ;

    # now abort the transaction
    ok 24, $txn->txn_abort() == 0 ;

    # there shouldn't be any records in the database
    $count = 0 ;
    # sequence forwards
    ok 25, $cursor = $db1->db_cursor() ;
    while ($cursor->c_get($k, $v, DB_NEXT) == 0) {
        ++ $count ;
    }
    ok 26, $count == 0 ;

    my $stat = $txn_mgr->txn_stat() ;
    ok 27, $stat->{'st_naborts'} == 1 ;

    undef $txn ;
    undef $cursor ;
    undef $db1 ;
    undef $txn_mgr ;
    undef $env ;
    untie %hash ;
}

{
    # transaction - commit works

    my $lex = new LexFile $Dfile ;
    my %hash ;
    my $value ;

    my $home = "./fred" ;
    ok 28, my $lexD = new LexDir($home);
    ok 29, my $env = new BerkeleyDB::Env -Home => $home,
				     -Flags => DB_CREATE|DB_INIT_TXN|
					  	DB_INIT_MPOOL|DB_INIT_LOCK ;
    ok 30, my $txn = $env->txn_begin() ;
    ok 31, my $db1 = tie %hash, 'BerkeleyDB::Hash', -Filename => $Dfile,
                                      	       	-Flags     => DB_CREATE ,
					       	-Env 	   => $env,
					    	-Txn	   => $txn  ;

    
    # create some data
    my %data =  (
		"red"	=> "boat",
		"green"	=> "house",
		"blue"	=> "sea",
		) ;

    my $ret = 0 ;
    while (my ($k, $v) = each %data) {
        $ret += $db1->db_put($k, $v) ;
    }
    ok 32, $ret == 0 ;

    # should be able to see all the records

    ok 33, my $cursor = $db1->db_cursor() ;
    my ($k, $v) = ("", "") ;
    my $count = 0 ;
    # sequence forwards
    while ($cursor->c_get($k, $v, DB_NEXT) == 0) {
        ++ $count ;
    }
    ok 34, $count == 3 ;
    undef $cursor ;

    # now commit the transaction
    ok 35, $txn->txn_commit() == 0 ;

    $count = 0 ;
    # sequence forwards
    ok 36, $cursor = $db1->db_cursor() ;
    while ($cursor->c_get($k, $v, DB_NEXT) == 0) {
        ++ $count ;
    }
    ok 37, $count == 3 ;

    my $stat = $env->txn_stat() ;
    ok 38, $stat->{'st_naborts'} == 0 ;

    undef $txn ;
    undef $cursor ;
    undef $db1 ;
    undef $env ;
    untie %hash ;
}

{
    # transaction - commit works via txnmgr

    my $lex = new LexFile $Dfile ;
    my %hash ;
    my $value ;

    my $home = "./fred" ;
    ok 39, my $lexD = new LexDir($home);
    ok 40, my $env = new BerkeleyDB::Env -Home => $home,
				     -Flags => DB_CREATE|DB_INIT_TXN|
					  	DB_INIT_MPOOL|DB_INIT_LOCK ;
    ok 41, my $txn_mgr = $env->TxnMgr() ;
    ok 42, my $txn = $txn_mgr->txn_begin() ;
    ok 43, my $db1 = tie %hash, 'BerkeleyDB::Hash', -Filename => $Dfile,
                                      	       	-Flags     => DB_CREATE ,
					       	-Env 	   => $env,
					    	-Txn	   => $txn  ;

    
    # create some data
    my %data =  (
		"red"	=> "boat",
		"green"	=> "house",
		"blue"	=> "sea",
		) ;

    my $ret = 0 ;
    while (my ($k, $v) = each %data) {
        $ret += $db1->db_put($k, $v) ;
    }
    ok 44, $ret == 0 ;

    # should be able to see all the records

    ok 45, my $cursor = $db1->db_cursor() ;
    my ($k, $v) = ("", "") ;
    my $count = 0 ;
    # sequence forwards
    while ($cursor->c_get($k, $v, DB_NEXT) == 0) {
        ++ $count ;
    }
    ok 46, $count == 3 ;
    undef $cursor ;

    # now commit the transaction
    ok 47, $txn->txn_commit() == 0 ;

    $count = 0 ;
    # sequence forwards
    ok 48, $cursor = $db1->db_cursor() ;
    while ($cursor->c_get($k, $v, DB_NEXT) == 0) {
        ++ $count ;
    }
    ok 49, $count == 3 ;

    my $stat = $txn_mgr->txn_stat() ;
    ok 50, $stat->{'st_naborts'} == 0 ;

    undef $txn ;
    undef $cursor ;
    undef $db1 ;
    undef $txn_mgr ;
    undef $env ;
    untie %hash ;
}

