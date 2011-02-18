# Copyright (c) 2008 Red Hat, Inc.
#
# This software is licensed to you under the GNU General Public License,
# version 2 (GPLv2). There is NO WARRANTY for this software, express or
# implied, including the implied warranties of MERCHANTABILITY or FITNESS
# FOR A PARTICULAR PURPOSE. You should have received a copy of GPLv2
# along with this software; if not, see
# http://www.gnu.org/licenses/old-licenses/gpl-2.0.txt.
#
# Red Hat trademarks are not licensed under GPLv2. No permission is
# granted to use or replicate Red Hat trademarks that are incorporated
# in this software or its documentation.
#

package Satcon;

use strict;
use File::Copy;
use File::Temp;

sub new {
  my $class = shift;
  my $open = quotemeta(shift || '@@');
  my $close = quotemeta(shift || '@@');

  my $self = bless { open_str => $open, close_str => $close }, $class;

  return $self;
}

sub load_conf_file {
  my $self = shift;
  my $patfile = shift;

  local * IF;
  open IF, '<', $patfile
    or die "Cannot open $patfile: $!";

  my %pats;
  my @lines;

  while (<IF>) {
    chomp;
    $lines[$.] = $_;
    next if /^\s*(#.*)?$/;

    if (/^(\w+)(\[\w+\])?\s*=\s*(.*)$/) {
      $pats{$1}->{$2 || '__value__'} = $3;
      $lines[$.] = [ $1, $2, $3 ];
    }
    else {
      die "$patfile, like $.: invalid pattern";
    }
  }

  close IF;

  $self->{patterns} = \%pats;
  $self->{pattern_file} = $patfile;
  $self->{lines} = \@lines;
}

sub save_conf_file {
  my $self = shift;
  my $outfile = shift || $self->{pattern_file};

  local * OF;
  open OF, '>', $outfile
    or die "Cannot create $outfile: $!";

  foreach my $line (@{$self->{lines}}) {
    if (ref $line) {
      if ($line->[1]) {
	print "$line->[0]=$line->[2]\n";
      }
      else {
	print "$line->[0]\[$line->[1]\]=$line->[2]\n";
      }
    }
    else {
      print "$line\n";
    }
  }

  close OF;
}

sub perform_substitutions {
  my $self = shift;
  my $str = shift;

  my $op = $self->{open_str};
  my $cl = $self->{close_str};

  if ($str =~ /$op/) {
    if (not exists $self->{replacement_pattern}) {
      my $patterns = join("|", map { quotemeta $_ } keys %{$self->{patterns}});
      my $pattern = qr/$op($patterns)$cl/;

      $self->{replacement_pattern} = $pattern;
    }

    my $pattern = $self->{replacement_pattern};
    $str =~ s,$pattern,$self->{patterns}->{$1}->{__value__},g;

    while ($str =~ /\G.*?$op(\w+)$cl/g) {
      $self->{unsubstituted_tags}->{$1}++;
    }
  }

  return $str;
}

sub unsubstituted_tags {
  my $self = shift;

  return keys %{$self->{unsubstituted_tags}};
}

1;
