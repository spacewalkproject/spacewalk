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
        print "1..0 # Skipping test, this needs Berkeley DB 3.2.x or better\n" ;
        exit 0 ;
    }
}     

print "1..1\n";


my $Dfile = "dbhash.tmp";
my $Dfile2 = "dbhash2.tmp";
my $Dfile3 = "dbhash3.tmp";
unlink $Dfile;

umask(0) ;



{
    # set_q_extentsize

    ok 1, 1 ;
}

