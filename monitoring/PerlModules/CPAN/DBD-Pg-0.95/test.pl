#!/usr/local/bin/perl -w

# $Id: test.pl,v 1.1.1.1 2001-01-12 20:41:07 dparker Exp $

# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl test.pl'

######################### not tested explicitly
#
# AutoCommit
# commit
# rollback
# Active
# Statement
# attributes
# err
# pg_auto_escape
# quote
# type_info_all
#
######################### We start with some black magic to print on failure.

BEGIN { $| = 1; }
END {print "test failed\n" unless $loaded;}
use DBI;
$loaded = 1;
use Config;
use strict;

######################### End of black magic.

my $os = $^O;
print "OS: $os\n";

my $dbmain = "template1";
my $dbtest = "pgperltest";

# optionally add ";host=$remotehost;port=$remoteport"
# or set the environment variable PGHOST
my $dsn_main = "dbi:Pg:dbname=$dbmain";
my $dsn_test = "dbi:Pg:dbname=$dbtest";

my ($dbh0, $dbh, $sth);

#DBI->trace(3); # make your choice


######################### drop, create and connect to test database

if ($os eq "MSWin32") {
    print "DBI->data_sources .......... skipped on $os\n"
} else {
    my $data_sources = join(" ", DBI->data_sources('Pg'));
    ( $data_sources =~ "$dsn_main" )
        and print "DBI->data_sources .......... ok\n"
        or  print "DBI->data_sources .......... not ok: $data_sources\n";
}

( $dbh0 = DBI->connect("$dsn_main", "", "", { AutoCommit => 1 }) )
    and print "DBI->connect ............... ok\n"
    or  die   "DBI->connect ............... not ok: ", $DBI::errstr;

my $Name = $dbh0->{Name};
( "$dbmain" eq $Name )
    and print "\$dbh->{Name} ............... ok\n"
    or  print "\$dbh->{Name} ............... not ok: $Name\n";

( 1 == $dbh0->ping )
    and print "\$dbh->ping ................. ok\n"
    or  die   "\$dbh->ping ................. not ok: ", $DBI::errstr;

$dbh0->{PrintError} = 0; # do not complain when dropping $dbtest
$dbh0->do("DROP DATABASE $dbtest");

( $dbh0->do("CREATE DATABASE $dbtest") )
    and print "\$dbh->do ................... ok\n"
    or  die   "\$dbh->do ................... not ok: ", $DBI::errstr;

$dbh = DBI->connect("$dsn_test", "", "", { AutoCommit => 1 }) or die $DBI::errstr;

$dbh->do("Set DateStyle = 'ISO'");


######################### create table

$dbh->do("CREATE TABLE builtin ( 
  bool_      bool,
  char_      char,
  char12_    char(12),
  char16_    char(16),
  varchar12_ varchar(12),
  text_      text,
  date_      date,
  int4_      int4,
  int4a_     int4[],
  float8_    float8,
  point_     point,
  lseg_      lseg,
  box_       box
  )");

$sth = $dbh->table_info;
my @infos = $sth->fetchrow_array;
$sth->finish;
( join(" ", @infos[2,3]) eq q{builtin TABLE} ) 
    and print "\$dbh->table_info ........... ok\n"
    or  print "\$dbh->table_info ........... not ok: ", join(" ", @infos), "\n";

my @names = $dbh->tables;
( join(" ", @names) eq q{builtin} ) 
    and print "\$dbh->tables ............... ok\n"
    or  print "\$dbh->tables ............... not ok: ", join(" ", @names), "\n";

my $attrs = $dbh->func('builtin', 'table_attributes');
( $$attrs[0]{NAME} eq q{varchar12_} ) 
    and print "\$dbh->pg_table_attributes .. ok\n"
    or  print "\$dbh->pg_table_attributes .. not ok: ", $$attrs[0]{NAME}, "\n";
#for (my $i=0; $i<=$#$attrs; $i++) {
#   print $$attrs[$i]{NAME},        "\t",
#         $$attrs[$i]{TYPE},        "\t",
#         $$attrs[$i]{SIZE},        "\t",
#         $$attrs[$i]{NOTNULL},     "\t",
#         $$attrs[$i]{DEFAULT},     "\t",
#         $$attrs[$i]{CONSTRAINT},  "\t",
#         $$attrs[$i]{PRIMARY_KEY}, "\n";
#}

######################### test various insert methods

# insert into table with $dbh->do($stmt)
 # PGPORT_1:NO Change #
$dbh->do("INSERT INTO builtin VALUES(
  't',
  'a',
  'Edmund Mergl',
  'quote \\\\ \'\' this',
  'Edmund Mergl',
  'Edmund Mergl',
  '1997-03-08',
  1234,
  '{1,2,3}',
  1.234,
  '(1.0,2.0)',
  '((1.0,2.0),(3.0,4.0))',
  '((1.0,2.0),(3.0,4.0))'
  )") or die $DBI::errstr;

# insert into table with $dbh->prepare() with placeholders and $dbh->execute(@bind_values)
 # PGPORT_1:NO Change #
( $sth = $dbh->prepare( "INSERT INTO builtin 
  ( bool_, char_, char12_, char16_, varchar12_, text_, date_, int4_, int4a_, float8_, point_, lseg_, box_ )
  VALUES ( ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ? )
  " ) )
    and print "\$dbh->prepare .............. ok\n"
    or  die   "\$dbh->prepare .............. not ok: ", $DBI::errstr;

( $sth->execute (
  'f',
  'b',
  'Halli  Hallo',
  'but  not  \164\150\151\163',
  'Halli  Hallo',
  'Halli  Hallo',
  '1995-01-06',
  5678,
  '{5,6,7}',
  5.678,
  '(4.0,5.0)',
  '((4.0,5.0),(6.0,7.0))',
  '((4.0,5.0),(6.0,7.0))'
  ) )
    and print "\$dbh->execute .............. ok\n"
    or  die   "\$dbh->execute .............. not ok: ", $DBI::errstr;

$sth->execute (
  'f',
  'c',
  'Potz   Blitz',
  'Potz   Blitz',
  'Potz   Blitz',
  'Potz   Blitz',
  '1957-10-05',
  1357,
  '{1,3,5}',
  1.357,
  '(2.0,7.0)',
  '((2.0,7.0),(8.0,3.0))',
  '((2.0,7.0),(8.0,3.0))'
   ) or die $DBI::errstr;

# insert into table with $dbh->do($stmt, @bind_values)
 # PGPORT_1:NO Change #
$dbh->do( "INSERT INTO builtin 
  VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ? )",
   {},
   'y',
   'z',
   'Ene Mene  Mu',
   'Ene Mene  Mu',
   'Ene Mene  Mu',
   'Ene Mene  Mu',
   '1957-10-14',
   5432,
   '{6,7,8}',
   6.789,
   '(5.0,6.0)',
   '((5.0,6.0),(7.0,8.0))',
   '((5.0,6.0),(7.0,8.0))'
   ) or die $DBI::errstr;

my $pg_oid_status = $sth->{pg_oid_status};
( $pg_oid_status ne '' )
    and print "\$sth->{pg_oid_status} ...... ok\n"
    or  print "\$sth->{pg_oid_status} ...... not ok: $pg_oid_status\n";

my $pg_cmd_status = $sth->{pg_cmd_status};
( $pg_cmd_status =~ /^INSERT/ )
    and print "\$sth->{pg_cmd_status} ...... ok\n"
    or  print "\$sth->{pg_cmd_status} ...... not ok: $pg_cmd_status\n";

( $sth->finish )
    and print "\$sth->finish ............... ok\n"
    or  die   "\$sth->finish ............... not ok: ", $DBI::errstr;

######################### test various select methods

# select from table using input parameters and and various fetchrow methods
 # PGPORT_1:NO Change #
$sth = $dbh->prepare("SELECT * FROM builtin where int4_ < ? + ?") or die $DBI::errstr;

( $sth->bind_param(1, '4000', DBI::SQL_INTEGER) )
    and print "\$sth->bind_param ........... ok\n"
    or  die   "\$sth->bind_param ........... not ok: ", $DBI::errstr;
$sth->bind_param(2, '6000', DBI::SQL_INTEGER);

$sth->execute or die $DBI::errstr;

my @row_ary = $sth->fetchrow_array;
( join(" ", @row_ary) eq q{1 a Edmund Mergl quote \ ' this   Edmund Mergl Edmund Mergl 1997-03-08 1234 {1,2,3} 1.234 (1,2) [(1,2),(3,4)] (3,4),(1,2)} ) 
    and print "\$sth->fetchrow_array ....... ok\n"
    or  print "\$sth->fetchrow_array ....... not ok: ", join(" ", @row_ary), "\n";

my $ary_ref = $sth->fetchrow_arrayref;
( join(" ", @$ary_ref) eq q{0 b Halli  Hallo but  not  this   Halli  Hallo Halli  Hallo 1995-01-06 5678 {5,6,7} 5.678 (4,5) [(4,5),(6,7)] (6,7),(4,5)} )
    and print "\$sth->fetchrow_arrayref .... ok\n"
    or  print "\$sth->fetchrow_arrayref .... not ok: ", join(" ", @$ary_ref), "\n";

my ($key, $val);
my $hash_ref = $sth->fetchrow_hashref;
foreach $key (sort (keys %$hash_ref)) {
    $val .= " $$hash_ref{$key}";
}
($val eq q{ 0 (8,7),(2,3) Potz   Blitz Potz   Blitz     c 1957-10-05 1.357 1357 {1,3,5} [(2,7),(8,3)] (2,7) Potz   Blitz Potz   Blitz} )
    and print "\$sth->fetchrow_hashref ..... ok\n"
    or  print "\$sth->fetchrow_hashref ..... not ok:  key = $key, val = $val\n";

# test various attributes

my @name = @{$sth->{NAME}};
( join(" ", @name) eq q{bool_ char_ char12_ char16_ varchar12_ text_ date_ int4_ int4a_ float8_ point_ lseg_ box_} )
    and print "\$sth->{NAME} ............... ok\n"
    or  print "\$sth->{NAME} ............... not ok: ", join(" ", @name), "\n";

my @type = @{$sth->{TYPE}};
( join(" ", @type) eq q{16 1042 1042 1042 1043 25 1082 23 1007 701 600 601 603} )
    and print "\$sth->{TYPE} ............... ok\n"
    or  print "\$sth->{TYPE} ............... not ok: ", join(" ", @type), "\n";

my @pg_size = @{$sth->{pg_size}};
( join(" ", @pg_size) eq q{1 -1 -1 -1 -1 -1 4 4 -1 8 16 32 32} )
    and print "\$sth->{pg_size} ............ ok\n"
    or  print "\$sth->{pg_size} ............ not ok: ", join(" ", @pg_size), "\n";

my @pg_type = @{$sth->{pg_type}};
( join(" ", @pg_type) eq q{bool bpchar bpchar bpchar varchar text date int4 _int4 float8 point lseg box} )
    and print "\$sth->{pg_type} ............ ok\n"
    or  print "\$sth->{pg_type} ............ not ok: ", join(" ", @pg_type), "\n";

# test binding of output columns

$sth->execute or die $DBI::errstr;

my ($bool, $char, $char12, $char16, $vchar12, $text, $date, $int4, $int4a, $float8, $point, $lseg, $box);
( $sth->bind_columns(undef, \$bool, \$char, \$char12, \$char16, \$vchar12, \$text, \$date, \$int4, \$int4a, \$float8, \$point, \$lseg, \$box) )
    and print "\$sth->bind_columns ......... ok\n"
    or  print "\$sth->bind_columns ......... not ok: ", $DBI::errstr;

$sth->fetch or die $DBI::errstr;
( "$bool, $char, $char12, $char16, $vchar12, $text, $date, $int4, $int4a, $float8, $point, $lseg, $box" eq 
  q{1, a, Edmund Mergl, quote \ ' this  , Edmund Mergl, Edmund Mergl, 1997-03-08, 1234, {1,2,3}, 1.234, (1,2), [(1,2),(3,4)], (3,4),(1,2)} )
    and print "\$sth->fetch ................ ok\n"
    or  print "\$sth->fetch ................ not ok:  $bool, $char, $char12, $char16, $vchar12, $text, $date, $int4, $int4a, $float8, $point, $lseg, $box\n";

my $gaga;
( $sth->bind_col(5, \$gaga) )
    and print "\$sth->bind_col ............. ok\n"
    or  print "\$sth->bind_col ............. not ok: ", $DBI::errstr;

$sth->fetch or die $DBI::errstr;
( $gaga eq q{Halli  Hallo} )
    and print "\$sth->fetch ................ ok\n"
    or  print "\$sth->fetch ................ not ok: $gaga\n";

$sth->finish or die $DBI::errstr;

# select from table using input parameters
 # PGPORT_1:NO Change #
$sth = $dbh->prepare( "SELECT * FROM builtin where char16_ = ?" ) or die $DBI::errstr;

my $string = q{quote \ ' this};
$sth->bind_param(1, $string) or die $DBI::errstr;

# $dbh->{pg_auto_escape} = 1;
# is needed for $string above and is on by default
$sth->execute or die $DBI::errstr;

$sth->{ChopBlanks} = 1;
@row_ary = $sth->fetchrow_array;
( join(" ", @row_ary) eq q{1 a Edmund Mergl quote \ ' this Edmund Mergl Edmund Mergl 1997-03-08 1234 {1,2,3} 1.234 (1,2) [(1,2),(3,4)] (3,4),(1,2)} ) 
    and print "\$sth->{ChopBlanks} ......... ok\n"
    or  print "\$sth->{ChopBlanks} .......... not ok: ", join(" ", @row_ary), "\n";

my $rows = $sth->rows;
( 1 == $rows )
    and print "\$sth->rows ................. ok\n"
    or  print "\$sth->rows ................. not ok: $rows\n";

$sth->finish or die $DBI::errstr;

######################### test copy to/from stdout/stdin
 # PGPORT_1:NO Change #
$dbh->do( "DELETE FROM builtin" ) or die $DBI::errstr;
 # PGPORT_1:NO Change #
$dbh->do( "COPY builtin FROM STDIN" ) or die $DBI::errstr;

my $ret;
for (1..3) {
    # watch the tabs and do not forget the newlines
    $ret = $dbh->func("t	a	Edmund Mergl	Edmund Mergl	Edmund Mergl	Edmund Mergl	1997-03-08	1234	{1,2,3}	1.234	(1.0,2.0)	((1.0,2.0),(3.0,4.0))	((1.0,2.0),(3.0,4.0))\n", 'putline');
}
$dbh->func("\\.\n", 'putline');
$dbh->func('endcopy');

( 1 == $ret )
    and print "\$dbh->func(putline) ........ ok\n"
    or  print "\$dbh->func(putline) ........ not ok: ", $ret, "\n";
 # PGPORT_1:NO Change #
$dbh->do( "COPY builtin TO STDOUT" ) or die $DBI::errstr;
my $buf = '';
$ret = 0;
$rows = 0;
while ($dbh->func($buf, 256, 'getline')) {
    #print "$buf\n";
    $rows++;
}
$dbh->func('endcopy');

( 3 == $rows )
    and print "\$dbh->func(getline) ........ ok\n"
    or  print "\$dbh->func(getline) ........ not ok: ", $rows, "\n";


######################### test large objects

# create large object from binary file

my ($ascii, $pgin);
foreach $ascii (0..255) {
    $pgin .= chr($ascii);
};

my $PGIN = '/tmp/pgin';
open(PGIN, ">$PGIN") or die "can not open $PGIN";
print PGIN $pgin;
close PGIN;

# begin transaction
$dbh->{AutoCommit} = 0;

my $lobjId;
( $lobjId = $dbh->func($PGIN, 'lo_import') )
    and print "\$dbh->func(lo_import) ...... ok\n"
    or  print "\$dbh->func(lo_import) ...... not ok\n";

# end transaction
$dbh->{AutoCommit} = 1;

unlink $PGIN;


# blob_read

# begin transaction
$dbh->{AutoCommit} = 0;

$sth = $dbh->prepare( "" ) or die $DBI::errstr;

my $blob;
( $blob = $sth->blob_read($lobjId, 0, 0) )
    and print "\$sth->blob_read ............ ok\n"
    or  print "\$sth->blob_read ............ not ok\n";

$sth->finish or die $DBI::errstr;

# end transaction
$dbh->{AutoCommit} = 1;


# read large object using lo-functions

# begin transaction
$dbh->{AutoCommit} = 0;

my $lobj_fd; # may be 0
( defined($lobj_fd = $dbh->func($lobjId, $dbh->{pg_INV_READ}, 'lo_open')) )
    and print "\$dbh->func(lo_open) ........ ok\n"
    or  print "\$dbh->func(lo_open) ........ not ok\n";

( 0 == $dbh->func($lobj_fd, 0, 0, 'lo_lseek') )
    and print "\$dbh->func(lo_lseek) ....... ok\n"
    or  print "\$dbh->func(lo_lseek) ....... not ok\n";

$buf = '';
( 256 == $dbh->func($lobj_fd, $buf, 256, 'lo_read') )
    and print "\$dbh->func(lo_read) ........ ok\n"
    or  print "\$dbh->func(lo_read) ........ not ok\n";

( 256 == $dbh->func($lobj_fd, 'lo_tell') )
    and print "\$dbh->func(lo_tell) ........ ok\n"
    or  print "\$dbh->func(lo_tell) ........ not ok\n";

( $dbh->func($lobj_fd, 'lo_close') )
    and print "\$dbh->func(lo_close) ....... ok\n"
    or  print "\$dbh->func(lo_close) ....... not ok\n";

# end transaction
$dbh->{AutoCommit} = 1;

( $dbh->func($lobjId, 'lo_unlink') )
    and print "\$dbh->func(lo_unlink) ...... ok\n"
    or  print "\$dbh->func(lo_unlink) ...... not ok\n";

# compare large objects

( $pgin cmp $buf and $pgin cmp $blob )
    and print "compare blobs .............. not ok\n"
    or  print "compare blobs .............. ok\n";

######################### disconnect and drop test database

# disconnect

( $dbh->disconnect )
    and print "\$dbh->disconnect ........... ok\n"
    or  die   "\$dbh->disconnect ........... not ok: ", $DBI::errstr;

$dbh0->do("DROP DATABASE $dbtest");
$dbh0->disconnect;

print "test sequence finished.\n";

######################### EOF
