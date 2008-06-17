#!/usr/bin/perl -w
use strict;
use lib '/var/www/lib';

use CGI;
use RHN::SessionSwap;
use Digest::MD5;
use PXT::Config;
use POSIX ":sys_wait_h";


for my $sig (qw/PIPE IO HUP INT TERM/) {
  $SIG{$sig} = sub { kill $::pid; sleep 1; kill -9, $::pid; cleanup_dirs(); exit; };
}

$SIG{CHLD} = sub { waitpid($::pid, WNOHANG) };

my $q = new CGI;
my ($timestamp, $md5) = RHN::SessionSwap->extract_data($q->param('token'));

die "Token " . $q->param('token') . " expired before use." if time() - $timestamp > 1800;

my @files = sort $q->param('filename');

#warn "file list from pxt request object:\n" . join("\n", @files);

my %all_files = map { $_ => 1 } $q->param('filename_full');

if (not defined $q->param('filename_full') and @files == 1) {
  %all_files = ($files[0], 1);
}

my $computed_md5 = Digest::MD5::md5_hex(join(":", sort keys %all_files));
die "Invalid checksum match ($timestamp, $md5, $computed_md5)" unless $md5 eq $computed_md5;

foreach my $file (@files) {
  die "File in list but not in full_list"
    unless exists $all_files{$file};
}

@files = grep { -e $_ } @files;

#warn "file list post grep statement:\n" . join("\n", @files);


# trying extra hard to be secure; however, since the data is md5
# csum'd with our secret, it should be okay.

foreach (@files) {
  die "Invalid file #1: $_"
    unless (m(^/pub/redhat) or m(^/pub/rhn)) and m(\.(rpm|iso)$);
  die "Invalid file #2: $_"
    if /[^-:A-Za-z0-9_.+\/@]/ or /\.\./;
}

if ($q->param('notar') and @files == 1) {
#  warn "single file, no tarring...";
  print $q->header(-type => 'application/octet-stream', -expires => "+0d");
  open FH, $files[0]
    or die "Can't open file $files[0]: $!";

  local $/ = \4096;
  while (<FH>) {
    print;
  }

  close FH;

  exit;
}

print $q->header(-type => 'application/x-tar', -expires => "+0d");

my $staging = "/tmp/download-staging-area";

if (not -d $staging) {
  mkdir $staging, 0700
    or die "Can't mkdir $staging: $!";
}

mkdir "$staging/stage-$$", 0700
  or die "Can't mkdir $staging/stage-$$: $!";
mkdir "$staging/stage-$$/rhn-packages", 0700
  or die "Can't mkdir $staging/stage-$$/rhn-packages: $!";
chdir "$staging/stage-$$/rhn-packages"
  or die "Can't chdir $staging/stage-$$/rhn-packages: $!";

my @base_files;
foreach my $file (@files) {
  my $base_file = (split m(/), $file)[-1];
  push @base_files, $base_file;
  symlink $file => $base_file;
}

#warn "base files:\n" . join("\n", @files);

chdir "$staging/stage-$$"
  or die "Can't chdir $staging/stage-$$: $!";

my $cmd = "/bin/tar hcf - " . join(" ", map { "rhn-packages/$_" } @base_files);

$::pid = open FH, "$cmd 2>/dev/null |"
  or die "Can't open $cmd: $!";

# block size for reading set to 4096 bytes
local $/ = \4096;
while (<FH>) {
  print;
}

close FH;

cleanup_dirs();

waitpid $::pid, WNOHANG;

sub cleanup_dirs {
  unlink "$staging/stage-$$/rhn-packages/$_" foreach @base_files;
  rmdir "$staging/stage-$$/rhn-packages";
  rmdir "$staging/stage-$$";
}
