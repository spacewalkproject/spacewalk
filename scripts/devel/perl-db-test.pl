#!/usr/bin/perl;

use strict;
use RHN::DB;
use RHN::Exception;



sub dbtest() {

  my $dbh = RHN::DB->connect;

  my $query;
  my $sth;
  my @row;
  my $retval;

  $query = <<EOQ;
SELECT COUNT(*)
FROM web_contact where ID <> ? 
EOQ

  $sth = $dbh->prepare($query);
  $sth->execute(9999);
  @row = $sth->fetchrow_array();
  $retval = $row[0];
  $sth->finish;
  return $retval;
}

my $count = dbtest();

print "DB TEST: " . $count . "\n";



