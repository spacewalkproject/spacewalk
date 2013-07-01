#
# Copyright (c) 2008--2011 Red Hat, Inc.
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

package PXT::Config;

use strict;
use Carp qw/carp/;
use Params::Validate;

# bretm--these can be set in your httpd.conf file, where you have:
#
# <Files *.pxt>
#   SetHandler perl-script
#   PerlHandler PXT::ApacheHandler
#
#   PerlSetVar foo 1
#
# </Files>
#
# might not be exactly the right place for 'em, but it works :)

our $default_config;

sub new {
  my $class = shift;
  my $domain = shift;

  die "no domain specified in constructor" unless defined $domain;

  my $self = bless { domain => $domain,
		     config_defaults => {},
		     config_trees => {},
		     overrides => {},
		     config_mtimes => {},
		     last_local_configs => undef,
		   }, $class;

  $self->load_configs;

  return $self;
}

sub default_config {
  my $class = shift;

  if (not $default_config) {
    $default_config = $class->new('web');
  }

  return $default_config;
}

sub load_file {
  my $class = shift;
  my $self = ref $class ? $class : $class->default_config();
  my %params = validate(@_, { -filename => 1, -mode => 1 });

  local * FH;
  open FH, '<', $params{-filename}
    or die "Can't open config file '$params{-filename}': $!";

  while(<FH>) {
    # Skip empty and comment-only lines
    next if /^\s*(#|$)/;

    my $line = $_;
    my $regex = qr/\\\s*$/;
    while ($line =~ s/$regex//) {
      my $next_line = <FH>;
      $next_line =~ s/^\s*//;
      $line .= $next_line;
    }

    my ($var, $val) = split /\s*=\s*/, $line, 2;
    $var =~ s/^\s+//;
    $val =~ s/\s+$//;

    my $domain;
    my @components = split /\./, $var;
    if (@components > 1) {
      ($domain, $var) = (join(".", @components[0 .. $#components - 1]), $components[-1]);
    }
    else {
      $domain = $self->{domain};
    }

    if ($params{-mode} eq 'default') {
      # logic: if we're setting defaults, save it to the default tree...
      $self->{config_defaults}->{$domain}->{$var} = $val;
    }
    else {
      # logic: if we're overriding defaults, and we're seeing a tree
      # we've seen, but a value we have not seen, then warn out.  this
      # lets trees we've not seen not cause trouble, but still warn
      # for trees we care about

      if (exists $self->{config_defaults}->{$domain} and not exists $self->{config_defaults}->{$domain}->{$var}) {
	# alas, this warning has to go.  I wish we could be more rigid
	# in namespacing configs, but we cannot.  so we silently
	# ignore this error that we once reported.  a tear, I shed.

	# carp "config $domain.$var not in master config list in PXT::Config";
      }
      $self->{config_trees}->{$domain}->{$var} = $val;
    }
  }

  close FH;
}

sub get {
  my $class = shift;
  my $self = ref $class ? $class : $class->default_config();

  my ($domain, $variable);

  if (@_ > 1) {
    $domain = shift;
    $variable = shift;
  }
  else {
    $domain = $self->{domain};
    $variable = shift;
  }

  if (exists $self->{overrides}->{$variable}) {
    return $self->{overrides}->{$variable};
  }

  my $r;
  eval {
    $r = Apache->request;
  };
  $r = undef if $@;
  undef $@;

  if ($r) {
    if (defined $r->dir_config($variable)) {
      return $r->dir_config($variable)
    }
  }

  my @domains = ($self->{domain});
  unshift @domains, $domain if $domain ne $self->{domain};

  if (not exists $self->{config_defaults}->{$domain} or not exists $self->{config_defaults}->{$domain}->{$variable}) {
    warn "config $domain.$variable not in master config list in PXT::Config";
  }

  foreach my $domain (@domains) {
    if (exists $self->{config_trees}->{$domain} and exists $self->{config_trees}->{$domain}->{$variable}) {
      return $self->{config_trees}->{$domain}->{$variable};
    }
  }

  return $self->{config_defaults}->{$domain}->{$variable};
}

sub set {
  my $class = shift;
  my $self = ref $class ? $class : $class->default_config();

  my ($domain, $variable);

  if (@_ > 2) {
    $domain = shift;
    $variable = shift;
  }
  else {
    $domain = $self->{domain};
    $variable = shift;
  }

  die "Invalid config directive: $variable" unless exists $self->{config_defaults}->{$domain}->{$variable};

  $self->{overrides}->{$variable} = shift;
}

sub reset_default {
  my $class = shift;
  my $self = ref $class ? $class : $class->default_config();

  my ($domain, $variable);

  if (@_ > 2) {
    $domain = shift;
    $variable = shift;
  }
  else {
    $domain = $self->{domain};
    $variable = shift;
  }

  die "Invalid config directive: $variable" unless exists $self->{config_defaults}->{$domain}->{$variable};

  delete $self->{overrides}->{$variable};
}

sub master_configs {
  my $self = shift;

  return ("/usr/share/rhn/config-defaults/rhn_$self->{domain}.conf", "/usr/share/rhn/config-defaults/rhn.conf");
}

sub local_configs {
  my $self = shift;

  return "/etc/rhn/rhn.conf";
}

sub load_configs {
  my $class = shift;
  my $self = ref $class ? $class : $class->default_config();

  my @master_configs = $self->master_configs;
  my @local_configs = $self->local_configs;

  push @local_configs, @_;

  # okay.  we have to keep track of WHICH config files contributed to
  # the current cached values.  if the files changed (either new ones
  # or old ones removed), invalidate the entire cache

  my $current_local_configs = join("|", sort @local_configs);
  if ($self->{last_local_configs} and $self->{last_local_configs} ne $current_local_configs) {
    $self->{config_mtimes} = {};
  }
  $self->{last_local_configs} = join("|", sort @local_configs);

  my $modified = 0;
  for my $file (@master_configs, @local_configs) {
    my $last_mtime = $self->{config_mtimes}->{$file} || 0;
    my $current_mtime = (stat $file)[9] || -1;

    if ($last_mtime != $current_mtime) {
      $self->{config_mtimes}->{$file} = $current_mtime;
      $modified = 1;
    }
  }

  return unless $modified;

  $self->{$_} = {} for qw/config_defaults config_trees overrides/;

  $self->load_file(-filename => $_, -mode => 'default') foreach @master_configs;
  $self->load_file(-filename => $_, -mode => 'local') foreach @local_configs;
}

1;
