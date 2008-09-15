#!/usr/bin/perl -w
use strict;
use lib '/var/www/lib';
use Getopt::Long;

use RHN::Channel;
use RHN::Package;
use RHN::DB;

use File::Find;

##
# This function determines whether a package is anywhere in a channel tree.
#
sub package_by_filename_in_tree {
  my $channel = shift;
  my $filename = shift;

  die "Invalid filename: contains naughty bits" if $filename =~ m(/);

  my $dbh = RHN::DB->connect;
  my $sth = $dbh->prepare(<<EOQ);
SELECT P.id
  FROM rhnPackage P,
       rhnChannelPackage CP,
       rhnChannel C
 WHERE (C.id = :cid OR C.parent_channel = :cid)
   AND CP.channel_id = C.id
   AND CP.package_id = P.id
   AND P.path LIKE :pathlike
EOQ

  $sth->execute_h(cid => $channel->id, pathlike => "%/$filename");
  my ($pid) = $sth->fetchrow;

  $sth->finish();

  return $pid;
}

my $usage = "Usage: $0 [ --dsn DSN ] [ --lookaside PATH ] --verbose --channel channel-label filename [ filename ... ]\n";

my $channel_label;
my $dsn;
my $verbose;
my $lookaside;

GetOptions("channel=s" => \$channel_label, "dsn=s" => \$dsn, verbose => \$verbose, "lookaside=s" => \$lookaside) or die $usage;

RHN::DB->set_default_handle($dsn) if $dsn;

die $usage if (not $channel_label or not @ARGV);

my $cid = RHN::Channel->channel_id_by_label($channel_label);

if (not $cid) {
  print "Channel not found: $channel_label\n";
  exit 1;
}

my $channel = RHN::Channel->lookup(-id => $cid);

for my $path (@ARGV) {
  my $filename = (split m(/), $path)[-1];
  my $package_id = package_by_filename_in_tree($channel, $filename);

  if ($package_id) {
    my $package = RHN::Package->lookup(-id => $package_id);
    my $disk_path = File::Spec->catfile(PXT::Config->get('mount_point'), $package->path);
    printf "Found: %s (package id %d)\n", $disk_path, $package_id
      if $verbose;
  }
  else {
    if ($lookaside) {
      my $found_in_lookaside = 0;
      find(sub {$_ eq $filename and $found_in_lookaside = 1; }, $lookaside);

      if ($found_in_lookaside) {
	printf "Found: %s (lookaside %s)\n", $File::Find::name, $lookaside
	  if $verbose;
      }
      else {
	print "Not found: $path\n";
      }
    }
    else {
      print "Not found: $path\n";
    }
  }
}
