#!/usr/bin/perl -w
use strict;
use lib '/var/www/lib';
use RHN::DB;

$0 = "stress.pl";

my $forks = shift || 10;

my $dbh = RHN::DB->connect("webdev");

print "Connected, now fetching server ids...\n";

my $sth = $dbh->prepare('SELECT id FROM rhnServer');
$sth->execute;
my @server_ids;
while (my ($sid) = $sth->fetchrow) {
  push @server_ids, $sid;
}

print "Servers loaded, $#server_ids found.\n";

for (1 .. $forks) {
  last if fork();
}
print "Forks complete, now connecting...\n";

$dbh = RHN::DB->connect("webdev_user");
$dbh->ping;

while (1) {
  my $server_id = @server_ids[int rand($#server_ids)];
  print "$$: $server_id\n";

  my $sth;

  for my $table (qw/rhnServerInfo rhnRam rhnCPU rhnServerLocation rhnServerPackage rhnServerDMI rhnServerNetwork rhnDevice/) {
    $sth = $dbh->prepare("SELECT * FROM $table WHERE server_id = ?");
    $sth->execute($server_id);
    my @foo = $sth->fullfetch;
  }
}
