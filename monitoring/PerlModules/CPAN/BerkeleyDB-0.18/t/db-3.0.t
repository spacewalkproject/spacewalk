#!./perl -w

# ID: 1.2, 7/17/97

use strict ;

BEGIN {
    unless(grep /blib/, @INC) {
        chdir 't' if -d 't';
        @INC = '../lib' if -d '../lib';
    }
}

use BerkeleyDB; 
use t::util ;

BEGIN
{
    if ($BerkeleyDB::db_version < 3) {
        print "1..0 # Skipped - this needs Berkeley DB 3.x or better\n" ;
        exit 0 ;
    }
}        

print "1..14\n";


my $Dfile = "dbhash.tmp";

umask(0);

{
    # set_mutexlocks

    my $home = "./fred" ;
    ok 1, my $lexD = new LexDir($home) ;
    chdir "./fred" ;
    ok 2, my $env = new BerkeleyDB::Env -Flags => DB_CREATE ;
    ok 3, $env->set_mutexlocks(0) == 0 ;
    chdir ".." ;
    undef $env ;
}

{
    # c_dup


    my $lex = new LexFile $Dfile ;
    my %hash ;
    my ($k, $v) ;
    ok 4, my $db = new BerkeleyDB::Hash -Filename => $Dfile, 
				     -Flags    => DB_CREATE ;

    # create some data
    my %data =  (
		"red"	=> 2,
		"green"	=> "house",
		"blue"	=> "sea",
		) ;

    my $ret = 0 ;
    while (($k, $v) = each %data) {
        $ret += $db->db_put($k, $v) ;
    }
    ok 5, $ret == 0 ;

    # create a cursor
    ok 6, my $cursor = $db->db_cursor() ;

    # point to a specific k/v pair
    $k = "green" ;
    ok 7, $cursor->c_get($k, $v, DB_SET) == 0 ;
    ok 8, $v eq "house" ;

    # duplicate the cursor
    my $dup_cursor = $cursor->c_dup(DB_POSITION);
    ok 9, $dup_cursor ;

    # move original cursor off green/house
    $cursor->c_get($k, $v, DB_NEXT) ;
    ok 10, $k ne "green" ;
    ok 11, $v ne "house" ;

    # duplicate cursor should still be on green/house
    ok 12, $dup_cursor->c_get($k, $v, DB_CURRENT) == 0;
    ok 13, $k eq "green" ;
    ok 14, $v eq "house" ;
    
}
