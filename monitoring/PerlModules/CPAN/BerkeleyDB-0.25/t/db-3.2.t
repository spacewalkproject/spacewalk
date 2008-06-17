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
    if ($BerkeleyDB::db_version < 3.2) {
        print "1..0 # Skip: this needs Berkeley DB 3.2.x or better\n" ;
        exit 0 ;
    }
}     

print "1..6\n";


my $Dfile = "dbhash.tmp";
my $Dfile2 = "dbhash2.tmp";
my $Dfile3 = "dbhash3.tmp";
unlink $Dfile;

umask(0) ;



{
    # set_q_extentsize

    ok 1, 1 ;
}

{
    # env->set_flags

    my $home = "./fred" ;
    ok 2, my $lexD = new LexDir($home) ;
    ok 3, my $env = new BerkeleyDB::Env -Home => $home,
                                         -Flags => DB_CREATE ,
                                         -SetFlags => DB_NOMMAP ;
 
    undef $env ;                      
}

{
    # env->set_flags

    my $home = "./fred" ;
    ok 4, my $lexD = new LexDir($home) ;
    ok 5, my $env = new BerkeleyDB::Env -Home => $home,
                                         -Flags => DB_CREATE ;
    ok 6, ! $env->set_flags(DB_NOMMAP, 1);
 
    undef $env ;                      
}
