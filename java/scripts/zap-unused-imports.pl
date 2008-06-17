#!/usr/bin/perl -w
use strict;

use File::Temp qw/tempfile/;
use File::Basename;

while (<>) {
  chomp;
  if (/\[checkstyle\] (\S+) Unused import - (\S+)/) {
    my ($file, $import) = ($1, $2);
    $file =~ s/:\d+:\d+:$//;
    $import =~ s/\.$//;

    remove_import($file, $import);
  }
}

sub remove_import {
  my ($file, $import) = @_;

  open IN, "<$file" or die "open $file: $!";
  my ($out, $backup) = tempfile("renameXXXXXX", DIR => dirname $file);

  while (<IN>) {
    unless (/^import\s+$import;/) {
      print $out $_;
    }
  }

  close IN;
  close $out;

  rename $backup => $file;
}
