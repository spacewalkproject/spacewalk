#!/usr/bin/perl -w
use strict;
use lib '/var/www/lib';
$|++;

use RHN::DB;
use RHN::Channel;
use RHN::KSTree;

use File::Spec;
use Getopt::Long;
use POSIX qw/strftime/;

my $usage = "Usage: $0 [ --help ] [ --dsn DSN ] [ --list ] [ --clear ] --install_type (rhel_5|rhel_4|rhel_3|rhel_2.1) [ --tree_type (rhn-managed|externally-managed) ] --label LABEL --channel CHANNEL FILE [ FILE FILE ... ]\n";
my %opts;
GetOptions(\%opts, "dsn=s", "install_type=s", "label=s", "tree_type:s", "channel=s", "list", "clear", "help") or die $usage;

my $help =<<EOQ;
Add kickstart trees to the given environment.

  --dsn           Use the specified dsn instead of the default.
  --list          Show all existing trees and then exit.
  --clear         Clear the specified tree and repopulate.
  --install_type  What generation of RHEL is this tree for?
  --tree_type     rhn-managed is correct for all of our trees.
  --label         The tree's unique label.
  --channel       What base channel is this tree associated with?
EOQ

my @files = @ARGV;
die $usage . $help if $opts{help};
die $usage unless @files or $opts{list};
die $usage unless $opts{label} or $opts{list};
die $usage unless $opts{install_type};

RHN::DB->set_default_handle($opts{dsn}) if $opts{dsn};

if ($opts{list}) {
  my $ds = new RHN::DataSource::General(-mode => 'insecure_all_kstrees');
  my $results = $ds->execute_query;

  my $format = "%-40s %-30s\n";
  printf $format, "Label", "Channel";
  printf $format, "-" x 40, "-" x 30;
  for my $row (@$results) {
    printf $format, $row->{LABEL}, $row->{CHANNEL_LABEL};
  }

  exit 0;
}

my $cid = RHN::Channel->channel_id_by_label($opts{channel});
if (not $cid) {
  die "No channel with label '$opts{channel}'\n";
}

my $tree = RHN::KSTree->lookup(-label => $opts{label});

if ($opts{clear}) {
  RHN::KSTree->delete_tree($tree->id);
  undef $tree;
}

if (not $tree) {
  $tree = RHN::KSTree->create_tree(-label => $opts{label},
				   -path => File::Spec->catfile("rhn/kickstart", $opts{label}),
				   -channel_id => $cid,
				   -install_type_label => $opts{install_type},
				   -tree_type => $opts{tree_type});
}
else {
  warn "Tree '$opts{label}' already exists, adding files to it...\n";
}

my $mount_point = File::Spec->catfile(PXT::Config->get('kickstart_mount_point'), $tree->base_path);

for my $file (@files) {
  if (not $file =~ m(^$mount_point)) {
    warn "File '$file' is not prefixed with $mount_point, skipping.\n";
    next;
  }

  my $fullpath = $file;
  $file =~ s(^$mount_point/?)();

  if ($tree->has_file($file)) {
    print "Skipping $file, already present.\n";
  }
  else {
    print "Adding: $file... ";

    my ($size, $mtime) = (stat($fullpath))[7, 9];
    my $file_struct = { RELATIVE_FILENAME => $file, FILE_SIZE => $size,
			LAST_MODIFIED => strftime("%Y-%m-%d %H:%M:%S", localtime $mtime),
		      };

    $file_struct->{MD5SUM} = compute_md5sum($fullpath);

    $tree->add_file($file_struct);

    print "done.\n";
  }
}

$tree->commit;
$tree->commit_files;

# Need to update the channel timestamp after adding new kstrees,
# so that sat-syncs will get the latest trees

my $dbh = RHN::DB->connect;
$dbh->call_procedure('rhn_channel.update_channel', $cid);

sub compute_md5sum {
  my $file = shift;
  use Digest::MD5;

  my $ctx = new Digest::MD5;

  open FH, "<$file" or die "open $file: $!";
  $ctx->addfile(*FH);
  close FH;

  return $ctx->hexdigest;
}
