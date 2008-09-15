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
    if ($BerkeleyDB::db_version < 3.1) {
        print "1..0 # Skip: this needs Berkeley DB 3.1.x or better\n" ;
        exit 0 ;
    }
}     

print "1..35\n";

my $Dfile = "dbhash.tmp";
my $Dfile2 = "dbhash2.tmp";
my $Dfile3 = "dbhash3.tmp";
unlink $Dfile;

umask(0) ;



{
    # c_count

    my $lex = new LexFile $Dfile ;
    my %hash ;
    ok 1, my $db = tie %hash, 'BerkeleyDB::Hash', -Filename => $Dfile,
				      -Property  => DB_DUP,
                                      -Flags    => DB_CREATE ;

    $hash{'Wall'} = 'Larry' ;
    $hash{'Wall'} = 'Stone' ;
    $hash{'Smith'} = 'John' ;
    $hash{'Wall'} = 'Brick' ;
    $hash{'Wall'} = 'Brick' ;
    $hash{'mouse'} = 'mickey' ;

    ok 2, keys %hash == 6 ;

    # create a cursor
    ok 3, my $cursor = $db->db_cursor() ;

    my $key = "Wall" ;
    my $value ;
    ok 4, $cursor->c_get($key, $value, DB_SET) == 0 ;
    ok 5, $key eq "Wall" && $value eq "Larry" ;

    my $count ;
    ok 6, $cursor->c_count($count) == 0 ;
    ok 7, $count == 4 ;

    $key = "Smith" ;
    ok 8, $cursor->c_get($key, $value, DB_SET) == 0 ;
    ok 9, $key eq "Smith" && $value eq "John" ;

    ok 10, $cursor->c_count($count) == 0 ;
    ok 11, $count == 1 ;


    undef $db ;
    undef $cursor ;
    untie %hash ;

}

{
    # db_key_range

    my $lex = new LexFile $Dfile ;
    my %hash ;
    ok 12, my $db = tie %hash, 'BerkeleyDB::Btree', -Filename => $Dfile,
				      -Property  => DB_DUP,
                                      -Flags    => DB_CREATE ;

    $hash{'Wall'} = 'Larry' ;
    $hash{'Wall'} = 'Stone' ;
    $hash{'Smith'} = 'John' ;
    $hash{'Wall'} = 'Brick' ;
    $hash{'Wall'} = 'Brick' ;
    $hash{'mouse'} = 'mickey' ;

    ok 13, keys %hash == 6 ;

    my $key = "Wall" ;
    my ($less, $equal, $greater) ;
    ok 14, $db->db_key_range($key, $less, $equal, $greater) == 0 ;

    ok 15, $less != 0 ;
    ok 16, $equal != 0 ;
    ok 17, $greater != 0 ;

    $key = "Smith" ;
    ok 18, $db->db_key_range($key, $less, $equal, $greater) == 0 ;

    ok 19, $less == 0 ;
    ok 20, $equal != 0 ;
    ok 21, $greater != 0 ;

    $key = "NotThere" ;
    ok 22, $db->db_key_range($key, $less, $equal, $greater) == 0 ;

    ok 23, $less == 0 ;
    ok 24, $equal == 0 ;
    ok 25, $greater == 1 ;

    undef $db ;
    untie %hash ;

}

{
    # rename

    my $lex = new LexFile $Dfile ;
  
    ok 26, my $db1 = new BerkeleyDB::Hash -Filename => $Dfile, 
				        -Subname  => "fred" ,
				        -Flags    => DB_CREATE ;

    ok 27, my $db2 = new BerkeleyDB::Btree -Filename => $Dfile, 
				        -Subname  => "joe" ,
				        -Flags    => DB_CREATE ;

    # Add a k/v pair
    my %data = qw(
    			red	sky
			blue	sea
			black	heart
			yellow	belley
			green	grass
    		) ;

    ok 28, addData($db1, %data) ;
    ok 29, addData($db2, %data) ;

    undef $db1 ;
    undef $db2 ;

    # now rename 
    ok 30, BerkeleyDB::db_rename(-Filename => $Dfile, 
                              -Subname => "fred",
                              -Newname => "harry") == 0;
  
    ok 31, my $db3 = new BerkeleyDB::Hash -Filename => $Dfile, 
				        -Subname  => "harry" ;

}

{
    # verify

    my $lex = new LexFile $Dfile, $Dfile2 ;
  
    ok 32, my $db1 = new BerkeleyDB::Hash -Filename => $Dfile, 
				        -Subname  => "fred" ,
				        -Flags    => DB_CREATE ;

    # Add a k/v pair
    my %data = qw(
    			red	sky
			blue	sea
			black	heart
			yellow	belley
			green	grass
    		) ;

    ok 33, addData($db1, %data) ;

    undef $db1 ;

    # now verify 
    ok 34, BerkeleyDB::db_verify(-Filename => $Dfile, 
                              -Subname => "fred",
                              ) == 0;

    # now verify & dump
    ok 35, BerkeleyDB::db_verify(-Filename => $Dfile, 
                              -Subname => "fred",
                              -Outfile => $Dfile2,
                              ) == 0;
  
}

# db_remove with env

