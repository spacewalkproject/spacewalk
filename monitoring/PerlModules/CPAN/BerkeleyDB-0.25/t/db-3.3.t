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

BEGIN
{
    if ($BerkeleyDB::db_version < 3.3) {
        print "1..0 # Skip: this needs Berkeley DB 3.3.x or better\n" ;
        exit 0 ;
    }
}     

umask(0);

print "1..44\n";        

{
    # db->truncate

    my $Dfile;
    my $lex = new LexFile $Dfile ;
    my %hash ;
    my ($k, $v) ;
    ok 1, my $db = new BerkeleyDB::Hash -Filename => $Dfile, 
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
    ok 2, $ret == 0 ;

    # check there are three records
    ok 3, countRecords($db) == 3 ;

    # now truncate the database
    my $count = 0;
    ok 4, $db->truncate($count) == 0 ;

    ok 5, $count == 3 ;
    ok 6, countRecords($db) == 0 ;

}

{
    # db->associate -- secondary keys

    sub sec_key
    {
        #print "in sec_key\n";
        my $pkey = shift ;
        my $pdata = shift ;

       $_[0] = $pdata ;
        return 0;
    }

    my ($Dfile1, $Dfile2);
    my $lex = new LexFile $Dfile1, $Dfile2 ;
    my %hash ;
    my $status;
    my ($k, $v, $pk) = ('','','');

    # create primary database
    ok 7, my $primary = new BerkeleyDB::Hash -Filename => $Dfile1, 
				     -Flags    => DB_CREATE ;

    # create secondary database
    ok 8, my $secondary = new BerkeleyDB::Hash -Filename => $Dfile2, 
				     -Flags    => DB_CREATE ;

    # associate primary with secondary
    ok 9, $primary->associate($secondary, \&sec_key) == 0;

    # add data to the primary
    my %data =  (
		"red"	=> "flag",
		"green"	=> "house",
		"blue"	=> "sea",
		) ;

    my $ret = 0 ;
    while (($k, $v) = each %data) {
        my $r = $primary->db_put($k, $v) ;
	#print "put $r $BerkeleyDB::Error\n";
        $ret += $r;
    }
    ok 10, $ret == 0 ;

    # check the records in the secondary
    ok 11, countRecords($secondary) == 3 ;

    ok 12, $secondary->db_get("house", $v) == 0;
    ok 13, $v eq "house";

    ok 14, $secondary->db_get("sea", $v) == 0;
    ok 15, $v eq "sea";

    ok 16, $secondary->db_get("flag", $v) == 0;
    ok 17, $v eq "flag";

    # pget to primary database is illegal
    ok 18, $primary->db_pget('red', $pk, $v) != 0 ;

    # pget to secondary database is ok
    ok 19, $secondary->db_pget('house', $pk, $v) == 0 ;
    ok 20, $pk eq 'green';
    ok 21, $v  eq 'house';

    ok 22, my $p_cursor = $primary->db_cursor();
    ok 23, my $s_cursor = $secondary->db_cursor();

    # c_get from primary 
    $k = 1;
    ok 24, $p_cursor->c_get($k, $v, DB_FIRST) == 0;

    # c_get from secondary
    ok 25, $s_cursor->c_get($k, $v, DB_FIRST) == 0;

    # c_pget from primary database should fail
    $k = 1;
    ok 26, $p_cursor->c_pget($k, $pk, $v, DB_FIRST) != 0;

    # c_pget from secondary database 
    ok 27, $s_cursor->c_pget($k, $pk, $v, DB_FIRST) == 0;

    # check put to secondary is illegal
    ok 28, $secondary->db_put("tom", "dick") != 0;
    ok 29, countRecords($secondary) == 3 ;

    # delete from primary
    ok 30, $primary->db_del("green") == 0 ;
    ok 31, countRecords($primary) == 2 ;

    # check has been deleted in secondary
    ok 32, $secondary->db_get("house", $v) != 0;
    ok 33, countRecords($secondary) == 2 ;

    # delete from secondary
    ok 34, $secondary->db_del('flag') == 0 ;
    ok 35, countRecords($secondary) == 1 ;


    # check deleted from primary
    ok 36, $primary->db_get("red", $v) != 0;
    ok 37, countRecords($primary) == 1 ;

}


    # db->associate -- multiple secondary keys


    # db->associate -- same again but when DB_DUP is specified.


{
    # db->associate -- secondary keys, each with a user defined sort

    sub sec_key2
    {
        my $pkey = shift ;
        my $pdata = shift ;
        #print "in sec_key2 [$pkey][$pdata]\n";

        $_[0] = length $pdata ;
        return 0;
    }

    my ($Dfile1, $Dfile2);
    my $lex = new LexFile $Dfile1, $Dfile2 ;
    my %hash ;
    my $status;
    my ($k, $v, $pk) = ('','','');

    # create primary database
    ok 38, my $primary = new BerkeleyDB::Btree -Filename => $Dfile1, 
				     -Compare  => sub { return $_[0] cmp $_[1]},
				     -Flags    => DB_CREATE ;

    # create secondary database
    ok 39, my $secondary = new BerkeleyDB::Btree -Filename => $Dfile2, 
				     -Compare  => sub { return $_[0] <=> $_[1]},
				     -Property => DB_DUP,
				     -Flags    => DB_CREATE ;

    # associate primary with secondary
    ok 40, $primary->associate($secondary, \&sec_key2) == 0;

    # add data to the primary
    my %data =  (
		"red"	=> "flag",
		"orange"=> "custard",
		"green"	=> "house",
		"blue"	=> "sea",
		) ;

    my $ret = 0 ;
    while (($k, $v) = each %data) {
        my $r = $primary->db_put($k, $v) ;
	#print "put [$r] $BerkeleyDB::Error\n";
        $ret += $r;
    }
    ok 41, $ret == 0 ;
    #print "ret $ret\n";

    #print "Primary\n" ; dumpdb($primary) ;
    #print "Secondary\n" ; dumpdb($secondary) ;

    # check the records in the secondary
    ok 42, countRecords($secondary) == 4 ;

    my $p_data = joinkeys($primary, " ");
    #print "primary [$p_data]\n" ;
    ok 43, $p_data eq join " ", sort { $a cmp $b } keys %data ;
    my $s_data = joinkeys($secondary, " ");
    #print "secondary [$s_data]\n" ;
    ok 44, $s_data eq join " ", sort { $a <=> $b } map { length } values %data ;

}

