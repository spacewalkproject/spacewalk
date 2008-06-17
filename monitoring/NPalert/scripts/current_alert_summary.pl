#!/usr/bin/perl

# This ad-hoc report summaries the entries in the current alerts table
# by date and customer id, producing deltas from the previous day.

use strict;
use NOCpulse::Notif::NotificationDB;
use NOCpulse::Probe::DataSource::AbstractDatabase qw(:constants);
use NOCpulse::Config;

my $program="current_alert_summary";

# Set up the report filename
my $np_cfg = new NOCpulse::Config;
my $log_dir = $np_cfg->get('notification','log_dir');
my $filename = "$log_dir/$program.txt";

# Connect to the database to glean the report data.  Summarize current alert
# counts by customer and date
my $ndb = new NOCpulse::Notif::NotificationDB;
my $table = 'current_alerts';
my $sql = <<EOSQL;
  select (to_char(date_submitted,'YYYY-MM-DD') || ' ' ||  customer_id) as one, 
      count(*) as count
  from current_alerts
  group by (to_char(date_submitted,'YYYY-MM-DD')  || ' ' || customer_id)
EOSQL

my $ref = $ndb->execute($sql, $table, FETCH_ARRAYREF);


# Put the data in a multidimensional array for ease of use
my %dates;
my %cids;
my %customers;

foreach my $item (@$ref) {
  my $one=$item->{ONE};
  my $count = $item->{COUNT};
  next unless $one;
  my ($date,$cid)=split(/\s+/,$one);

  $dates{$date}++;
  $cids{$cid}++;
  $customers{$cid,$date}=$count;
} 

# Create the report file
my $subject="Current Alerts Summary: " . scalar(gmtime());
open(FILE ,"> $filename") || die "Unable to open $!";

my @dates=sort(keys(%dates));
shift(@dates);  # Get rid of first partial
pop(@dates);    # Get rid of last partial

# Report title
print FILE "$subject\n\n";
# Report headers
printf FILE "%10s ", "Customer";
my $count=0;

foreach  (@dates) {
  $count++;
  printf FILE "%10.10s ", "$_";
  next if $count == 1;
  printf FILE "(%7.7s) ","delta";
}
print FILE "\n";

# Report body
foreach my $cid (sort {$a <=> $b} keys(%cids)) {
  printf FILE "%10d ",$cid;
  $count=0;
  my ($prior,$current);
  foreach my $date (@dates) {
    $count++;
    $prior=$current; 
    $current=$customers{$cid,$date};
    printf FILE "%10d ",$current;
    next if $count == 1;
    my $delta=$current-$prior;
    printf FILE "(%7d) ",$delta;
  }
  print FILE "\n";
}

close(FILE ) || die "Unable to close";
