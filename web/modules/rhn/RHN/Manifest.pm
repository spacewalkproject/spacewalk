#
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

package RHN::Manifest;
use strict;
use RPM2;

use RHN::Exception qw/throw/;
use RHN::Package;

use Params::Validate;
Params::Validate::validation_options(strip_leading => "-");

my @valid_fields = qw/packages package_arch_map org_id/;


sub new {
  my $class = shift;
  my %attr = @_;

  my $self = bless { packages => [], package_arch_map => {}, package_blacklist => [], org_id => undef}, $class;

  foreach (@valid_fields) {
    if (exists $attr{$_}) {
      $self->$_($attr{$_});
    }
  }

  # set the package blacklist on the class
  my @bl = RHN::Package -> package_blacklist($self -> {org_id});
  $self -> set_package_blacklist(@bl);

  return $self;
}

sub packages {
  return @{(shift)->{packages}}
}

sub get_package_blacklist {
    return @{(shift)->{package_blacklist}};
}

sub set_package_blacklist {
  my $self = shift;
  my @blist = @_;

  $self->{package_blacklist} = \@blist;
  return;
}


sub add_package {
  my $self = shift;
  my ($pkg) = validate_pos(@_, { isa => "RHN::Manifest::Package" });

  #Now we check the blacklist array
  #to make sure that we don't 
  #add packages that are supposed to be hidden.
  my @bl = $self->get_package_blacklist();
  foreach my $blpackage (@bl){
    if ($blpackage eq $pkg->name){
	warn "Tried to add blacklisted package: " . $pkg->name . "\n";
	return;
    }
  }

  push @{$self->{packages}}, $pkg;
  push @{$self->{package_arch_map}->{$pkg->name_arch}}, $pkg;
}

sub packages_by_name_arch {
  my $self = shift;
  my $name_arch = shift;

  return (ref $self->{package_arch_map}->{$name_arch} eq 'ARRAY'
	  ? @{$self->{package_arch_map}->{$name_arch}}
	  : $self->{package_arch_map}->{$name_arch});
}

# multimethod!
sub compare_manifests {
  my ($s1, $s2, $diff_only) = validate_pos(@_, { isa => "RHN::Manifest" }, { isa => "RHN::Manifest" }, { default => 0 });
  my $ret = [];

  my %s1_names;
  my %s2_names;

  # need to remove packages that are in both lists... can confuse comparison
  my %nevras = map { $_->as_nvrae() => 1 } $s1->packages;

  foreach my $pkg ($s2->packages) {
    if (exists $nevras{$pkg->as_nvrae()}) {
      $nevras{$pkg->as_nvrae()}++;
    }
  }

  %nevras = map { $_ => 1 } grep { $nevras{$_} == 2 } keys %nevras;

  my @s1_pkgs = grep { not exists $nevras{$_->as_nvrae()} } $s1->packages;
  my @s2_pkgs = grep { not exists $nevras{$_->as_nvrae()} } $s2->packages;

  # ok, by now, duplicates should be filtered out, so we can do a sane comparison

  foreach my $pkg (@s1_pkgs) {
    $s1_names{$pkg->name_arch} = $pkg;
  }

  foreach my $pkg (@s2_pkgs) {
    $s2_names{$pkg->name_arch} = $pkg;
  }

  my @names;
  @names = keys %s1_names;

  foreach my $name_arch (keys %s2_names) {
    push @names, $name_arch
      unless exists $s1_names{$name_arch};
  }

  my @data = map { 
    ({ NAME => $s1_names{$_} ? $s1_names{$_}->name : $s2_names{$_}->name,
       S1 => $s1_names{$_},
       S2 => $s2_names{$_}
     }) } @names;

  foreach my $row (@data) {
    my $p1 = $row->{S1};
    my $p2 = $row->{S2};

    $row->{COMPARISON} = ($p1 <=> $p2)
      if $p1 and $p2;

    if (defined $row->{S1} and defined $row->{S2} and defined $row->{COMPARISON} and $row->{COMPARISON} == 0) {
      next if $diff_only;
    }

    push @$ret, $row;
  }

  return $ret;
}

sub datasource_result_into_manifest {
  my $self = shift;
  my $result = shift;

  my @required_fields = qw/NAME_ID NAME VERSION RELEASE EPOCH/;
  my $checked_fields = 0;

  for my $package (@$result) {
    if (not $checked_fields) {
      $checked_fields++;

      for my $field (@required_fields) {
	die "Datasource does not provide field $field" unless exists $package->{$field};
      }
    }

    my $manifest_package =
      RHN::Manifest::Package->new(-name => $package->{NAME},
				  -name_id => $package->{NAME_ID},
				  -version => $package->{VERSION},
				  -release => $package->{RELEASE},
				  -epoch => $package->{EPOCH},
				  -evr_id => $package->{EVR_ID},
				  -id => $package->{ID},
				  -arch => $package->{ARCH},
				  );

    $self->add_package($manifest_package);
  }

  return $self;
}

sub remove_packages {
  my $self = shift;
  my @packages = @_;

  foreach my $package (@packages) {
    $self->remove_package($package);
  }

  return;
}

sub remove_package {
  my $self = shift;
  my $package = shift;

  throw "Argument '$package' must be an RHN::Manifest::Package"
    unless (ref $package and $package->isa('RHN::Manifest::Package'));

  my $offset;
  my $current_packages = $self->{packages};

PKG:
  for(my $i = 0; $i <= scalar(@{$current_packages}); $i++) {
    my $target = $current_packages->[$i];

    if ($package == $target) {
      $offset = $i;
      last PKG;
    }
  }

  if (defined $offset) { # we found a match
    splice @{$self->{packages}}, $offset, 1;
    delete $self->{package_arch_map}->{$package->name_arch};
  }

  return (defined $offset ? 1 : 0);
}


package RHN::Manifest::Package;
use overload
  "<=>" => \&op_compare,
  "cmp" => \&op_compare,
  "==" => \&op_equals,
  "eq" => \&op_equals,
  '""' => \&op_string;

use Params::Validate;
Params::Validate::validation_options(strip_leading => "-");

sub new {
  my $class = shift;
  my %params = validate(@_, => { epoch => 1, name => 1, version => 1, release => 1,
			         evr_id => 0, name_id => 0, id => 0, arch => 0 });

  my $self = bless \%params, $class;
  $self->{__associated__} = {};

  return $self;
}

sub associate_data {
  my $self = shift;
  my $key = shift;

  if (@_) {
    $self->{__associated__}->{$key} = shift;
  }

  return $self->{__associated__}->{$key};
}

sub DESTROY { }

my %accessors = map { $_ => 1 } qw/name version release epoch name_id evr_id arch id/;
sub AUTOLOAD {
  my $self = shift;

  our $AUTOLOAD;
  my $method = $AUTOLOAD;
  $method =~ s/.*:://;

  if (exists $accessors{$method}) {
    if (@_) {
      $self->{$method} = shift;
    }

    return $self->{$method};
  }
  else {
    use Carp;
    croak "no such method $method for object $self";
  }
}

sub name_arch { # accessor to concat name-arch
  my $self = shift;
  my $narch = $self->name;

  if ($self->arch) {
    $narch .= '-' . $self->arch;
  }

  return $narch;
}

sub op_compare {
  my ($p1, $p2) = validate_pos(@_, { isa => "RHN::Manifest::Package" }, { isa => "RHN::Manifest::Package" }, 0);

  return
    RHN::Manifest::Package->vercmp($p1->epoch, $p1->version, $p1->release,
				   $p2->epoch, $p2->version, $p2->release);
}

sub op_equals {
  my ($p1, $p2) = validate_pos(@_, { isa => "RHN::Manifest::Package" }, { isa => "RHN::Manifest::Package" }, 0);

  my ($e1, $e2, $v1, $v2, $r1, $r2) = ($p1->epoch, $p2->epoch, $p1->version, $p2->version, $p1->release, $p2->release);

  $e1 ||= '0';
  $e2 ||= '0';

  return ( ($e1 eq $e2) and ($v1 eq $v2) and ($r1 eq $r2) );
}

sub op_string {
  my $self = shift;
  return $self->name . "-" . $self->as_vre;
}

sub as_vre {
  my $self = shift;

  my $epoch = "";
  $epoch = ":" . $self->epoch if defined $self->epoch and $self->epoch;

  return join("-", $self->version, $self->release) . $epoch;
}

sub as_nvre {
  my $self = shift;

  my $epoch = "";
  $epoch = ":" . $self->epoch if defined $self->epoch and $self->epoch;

  return join("-", $self->name, $self->version, $self->release) . $epoch;
}

sub as_nvrae {
  my $self = shift;

  return $self->as_nvre unless defined $self->arch;

  my $epoch = "";
  $epoch = ":" . $self->epoch if defined $self->epoch and $self->epoch;

  my $arch = '.' . $self->arch;

  return join("-", $self->name, $self->version, $self->release) . $arch . $epoch;
}

sub vercmp {
  my $class = shift;
  my ($e1, $v1, $r1, $e2, $v2, $r2) = @_;

  # XXX undef epoch is zero epoch... to us.
  $e1 ||= 0;
  $e2 ||= 0;

  return 1 if $e1 and not $e2;
  return -1 if not $e1 and $e2;

  if ($e1 != $e2) {
    $e1 = int $e1;
    $e2 = int $e2;

    return -1 if $e1 < $e2;
    return 1 if $e1 > $e2;
  }

  unless (defined $v1 and defined $v2) {
    die "v1($v1) or v2($v2) undefined";
  }

  my $c = RPM2::rpmvercmp($v1, $v2);

  return $c if $c;

  return RPM2::rpmvercmp($r1, $r2);
}

1;
