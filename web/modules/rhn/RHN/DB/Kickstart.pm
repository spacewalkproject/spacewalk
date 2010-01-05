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

use strict;

package RHN::DB::Kickstart;

use Params::Validate qw/:all/;
Params::Validate::validation_options(strip_leading => "-");

use RHN::SimpleStruct;
our @ISA = qw/RHN::SimpleStruct/;

use RHN::Kickstart::Commands;
use RHN::Kickstart::Packages;
use RHN::Kickstart::Post;
use RHN::Kickstart::Pre;
use RHN::Kickstart::IPRange;

use RHN::DataSource::General;
use RHN::DataSource::Simple;

use RHN::DB;
use RHN::Exception qw/throw/;

use URI::URL;
use RHN::TinyURL;

use PXT::Utils;

my %valid = (id => { default => 0 },
	     org_id => { optional => 1 },
	     is_org_default => { default => 'N' },
	     name => { optional => 0 },
	     label => { optional => 0 },
	     commands => { optional => 1 },
	     static_device => { optional => 1 },
	     kernel_params => { optional => 1 },
	     packages => { optional => 1 },
	     package_options => { type => ARRAYREF,
				  default => [ qw/resolvedeps/ ] },
	     pre => { optional => 1 },
	     post => { optional => 1 },
	     nochroot_post => { optional => 1 },
	     interpreter_post_script => { optional => 1 },
	     interpreter_pre_script => { optional => 1 },
	     interpreter_post_val => { optional => 1 },
	     interpreter_pre_val => { optional => 1 },
	     comments => { optional => 1 },
	     active => { default => 'Y' },
	     ip_ranges => { type => ARRAYREF,
			    optional => 1 },
	     file_list => { type => ARRAYREF,
			    optional => 1 },
	     default_kstree_id => { optional => 1 },
	     default_server_profile_id => { optional => 1 },
	     default_cfg_management_flag => { default => 'Y' },
	     default_remote_command_flag => { default => 'N' },
	    );

our @simple_struct_fields = keys %valid;

sub new {
  my $class = shift;
  my $self = RHN::SimpleStruct::new($class);

  my %params = Params::Validate::validate(@_, \%valid);

  foreach my $param (keys %params) {
    $self->$param($params{$param});
  }

  return $self;
}

sub clone {
  my $self = shift;

  $self->id(0);

  return $self;
}

sub commit {
  my $self = shift;
  my $dbh = shift || RHN::DB->connect;

  my $mode = 'update';

  if (not $self->id) {
    my $sth = $dbh->prepare("SELECT rhn_ks_id_seq.nextval FROM DUAL");
    $sth->execute;
    my ($id) = $sth->fetchrow;
    die "No new id from seq rhn_ks_id_seq (possible error: " . $sth->errstr . ")" unless $id;
    $sth->finish;

    $self->id($id);
    $mode = 'insert';
  }

  die "$self->commit called without valid id" unless $self->id and $self->id > 0;

  if ($self->is_org_default eq 'Y') {
    my $query = q|UPDATE rhnKSData SET is_org_default = 'N' WHERE org_id = :org_id|;
    my $sth = $dbh->prepare($query);

    $sth->execute_h(org_id => $self->org_id);
  }

  my $query;

  if ($mode eq 'update') {
    $query =<<EOQ;
UPDATE rhnKSData
   SET org_id = :org_id,
       is_org_default = :is_org_default,
       label = :label,
       name = :name,
       comments = :comments,
       active = :active,
       pre = :pre,
       post = :post,
       nochroot_post = :nochroot_post,
       static_device = :static_device,
       kernel_params = :kernel_params
 WHERE id = :id
EOQ

  }
  else {
    $query =<<EOQ;
INSERT
  INTO rhnKSData
       (id, org_id, is_org_default, label, name, comments, active, pre, post, nochroot_post, static_device, kernel_params)
VALUES (:id, :org_id, :is_org_default, :label, :name, :comments, :active, :pre, :post, :nochroot_post, :static_device, :kernel_params)
EOQ
  }

  my $sth = $dbh->prepare($query);

  $sth->execute_h(org_id => $self->org_id, is_org_default => $self->is_org_default,
		  label => $self->label, name => $self->name, comments => $self->comments,
		  active => $self->active, id => $self->id, pre => $dbh->encode_blob($self->pre, "pre"),
		  post => $dbh->encode_blob($self->post, "post"),
		  nochroot_post => $dbh->encode_blob($self->nochroot_post, "nochroot_post"),
		  static_device => $self->static_device, kernel_params => $self->kernel_params);

# defaults:

  $self->commit_defaults($dbh);

  #commit interpreter pre/post scripts if interpreter script and interpreter cli supplied
  $self->commit_int_script('pre', $dbh)  if ( $self->interpreter_pre_script && $self->interpreter_pre_val ); 
  $self->commit_int_script('post', $dbh) if ( $self->interpreter_post_script && $self->interpreter_post_val ); 

# commands and packages:

  if ($mode eq 'update') {
    $query =<<EOQ;
DELETE
  FROM rhnKickstartCommand
 WHERE kickstart_id = :id
EOQ

    $sth = $dbh->prepare($query);
    $sth->execute_h(id => $self->id);

    $query =<<EOQ;
DELETE
  FROM rhnKickstartPackage
 WHERE kickstart_id = :id
EOQ

    $sth = $dbh->prepare($query);
    $sth->execute_h(id => $self->id);

    $query =<<EOQ;
DELETE
  FROM rhnKickstartIPRange
 WHERE kickstart_id = :id
EOQ

    $sth = $dbh->prepare($query);
    $sth->execute_h(id => $self->id);

    $query =<<EOQ;
DELETE
  FROM rhnKickstartPreserveFileList
 WHERE kickstart_id = :id
EOQ

    $sth = $dbh->prepare($query);
    $sth->execute_h(id => $self->id);
  }

  $query =<<EOQ;
INSERT
  INTO rhnKickstartCommand
       (kickstart_id, ks_command_name_id, arguments)
VALUES (:ks_id, lookup_ks_command_name(:command_name), :arguments)
EOQ

  $sth = $dbh->prepare($query);

  if ($self->commands) {
    foreach my $command ($self->commands->export) {
      $sth->execute_h(ks_id => $self->id, command_name => $command->[0], arguments => $command->[1]);
    }
  }

# now packages...

  $query =<<EOQ;
INSERT
  INTO rhnKickstartPackage
       (kickstart_id, package_name_id)
VALUES (:ks_id, lookup_package_name(:package_name))
EOQ

  $sth = $dbh->prepare($query);

  if ($self->packages) {
    foreach my $package (@{$self->packages}) {
      $sth->execute_h(ks_id => $self->id, package_name => $package);
    }
  }

# now ip address ranges...
  $query =<<EOQ;
INSERT
  INTO rhnKickstartIPRange
       (kickstart_id, org_id, min, max)
VALUES (:ks_id, :org_id, :min, :max)
EOQ

  $sth = $dbh->prepare($query);

  if ($self->ip_ranges) {
    foreach my $ip_range (@{$self->ip_ranges}) {
      $sth->execute_h(ks_id => $self->id, org_id => $self->org_id, min => $ip_range->min->export, max => $ip_range->max->export);
    }
  }

# now file preservation lists...
  $query =<<EOQ;
INSERT
  INTO rhnKickstartPreserveFileList
       (kickstart_id, file_list_id)
VALUES (:ks_id, :flid)
EOQ

  $sth = $dbh->prepare($query);

  if ($self->file_list) {
    foreach my $flid (@{$self->file_list}) {
      $sth->execute_h(ks_id => $self->id, flid => $flid);
    }
  }

  $dbh->commit;

  return;
}

sub commit_defaults {
  my $self = shift;
  my $dbh = shift; # caller must commit transaction

  my $sth = $dbh->prepare(<<EOQ);
SELECT 1 FROM rhnKickstartDefaults WHERE kickstart_id = :id
EOQ

  $sth->execute_h(id => $self->id);
  my ($existing) = $sth->fetchrow;
  $sth->finish;

  if ($existing) {
    $sth = $dbh->prepare(<<EOQ);
UPDATE rhnKickstartDefaults
   SET kstree_id = :kstree_id,
       server_profile_id = :server_profile_id,
       cfg_management_flag = :cfg_management_flag,
       remote_command_flag = :remote_command_flag
 WHERE kickstart_id = :id
EOQ

    $sth->execute_h(id => $self->id, kstree_id => $self->default_kstree_id,
		    server_profile_id => $self->default_server_profile_id,
		    cfg_management_flag => $self->default_cfg_management_flag,
                    remote_command_flag => $self->default_remote_command_flag);
  }
  else {
    $sth = $dbh->prepare(<<EOQ);
INSERT
  INTO rhnKickstartDefaults
       (kickstart_id, kstree_id, server_profile_id, 
        cfg_management_flag, remote_command_flag)
VALUES (:id, :kstree_id, :server_profile_id, :cfg_management_flag,
        :remote_command_flag)
EOQ

    $sth->execute_h(id => $self->id, kstree_id => $self->default_kstree_id,
		    cfg_management_flag => $self->default_cfg_management_flag,
		    remote_command_flag => $self->default_remote_command_flag,
		    server_profile_id => $self->default_server_profile_id);
  }

  return;
}

# commit the interpreter pre/post script...caller validates args
sub commit_int_script {
  my $self  = shift;
  my $stype = shift;  # pre/post script type
  my $dbh = shift || RHN::DB->connect;

  my $sth;

  my $interpreter_value = $stype eq 'pre' ? $self->interpreter_pre_val : $self->interpreter_post_val;
  my $interpreter_script = $stype eq 'pre' ? $self->interpreter_pre_script : $self->interpreter_post_script;
  my $position_order = $stype eq 'pre' ? 1 : 2;

  my $existing;  # update/insert mode

  $sth = $dbh->prepare(<<EOQ);
SELECT 1 
  FROM   rhnKickstartScript 
  WHERE  1=1
  AND    kickstart_id = :ksid
  AND    script_type = :stype 
EOQ

  $sth->execute_h(ksid => $self->id
                  , stype => $stype);
  $existing = $sth->fetchrow;
  $sth->finish;

  if ($existing) { #update record, already existing
    $sth = $dbh->prepare(<<EOQ);
UPDATE rhnKickstartScript
   SET interpreter = :interpreter 
       , data = :script_data 
       , modified = sysdate
   WHERE 1=1
   AND   kickstart_id = :ksid
   AND   script_type = :stype
EOQ
    $sth->execute_h(interpreter   => $interpreter_value
					, script_data => $dbh->encode_blob($interpreter_script, 'data')
                    , ksid        => $self->id
                    , stype       => $stype );

  }
  else { #insert new record
    $sth = $dbh->prepare(<<EOQ);
INSERT
  INTO rhnKickstartScript
       (id
        , kickstart_id
        , position
        , script_type
        , interpreter
		, data)
  VALUES (rhn_ksscript_id_seq.nextval
          , :ksid
          , :position
          , :stype
          , :interpreter
          , :script_data)
EOQ

    $sth->execute_h(ksid => $self->id
		    		, position    => $position_order 
                    , stype       => $stype
                    , interpreter => $interpreter_value 
                    , script_data  => $dbh->encode_blob($interpreter_script, 'data') );

  } # end of insert

  $dbh->commit;

}   # end of sub 

sub lookup {
  my $class = shift;
  my %params = validate(@_, { id => 0, org_id => 0, label => 0, name => 0 });

  my $dbh = RHN::DB->connect;
  my $where;

  my %query_params;

  if (exists $params{id}) {
    $where = 'id = :id';
  }
  elsif (exists $params{label} and exists $params{org_id}) {
    $where = 'label = :label AND org_id = :org_id';
  }
  elsif (exists $params{name} and exists $params{org_id}) {
    $where = 'name = :name AND org_id = :org_id';
  }
  else {
    throw "need id or (label or name) and org_id";
  }

  my $query = <<EOQ;
SELECT id, org_id, is_org_default, label, name, comments, active, pre, post, nochroot_post, static_device, kernel_params
  FROM rhnKSData
 WHERE $where
EOQ

  my $sth = $dbh->prepare($query);
  $sth->execute_h(%params);

  my $row = $sth->fetchrow_hashref;
  $sth->finish;

  return undef unless ($row);

  $query = <<EOQ;
SELECT kstree_id, server_profile_id, cfg_management_flag, remote_command_flag
  FROM rhnKickstartDefaults
 WHERE kickstart_id = :id
EOQ
  $sth = $dbh->prepare($query);
  $sth->execute_h(id => $row->{ID});

  my $defaults = $sth->fetchrow_hashref;
  $sth->finish;

  $row->{"DEFAULT_${_}"} = $defaults->{$_} foreach (keys %{$defaults});

  my $ks = new RHN::Kickstart(map { ("-" . lc($_), $row->{$_}) } keys %{$row});

  my %commands;

  $query = <<EOQ;
SELECT KCN.name, KC.arguments
  FROM rhnKickstartCommandName KCN, rhnKickstartCommand KC
 WHERE KC.kickstart_id = :id
   AND KCN.id = KC.ks_command_name_id
EOQ

  $sth = $dbh->prepare($query);
  $sth->execute_h(id => $ks->id);

  my (@partitions, @raids, @volgroups, @logvols, @include);

  while (my ($name, $args) = $sth->fetchrow) {
    $args ||= '';
    my @args = split(/\s+/, $args);

    if ($name eq 'partitions') {
      push @partitions, \@args;
    }
    elsif ($name eq 'raids') {
      push @raids, \@args;
    }
    elsif ($name eq 'volgroups') {
      push @volgroups, \@args;
    }
    elsif ($name eq 'logvols') {
      push @logvols, \@args;
    }
    elsif ($name eq 'include') {
      push @include, \@args;
    }
    elsif (@args) {
      $commands{$name} = \@args;
    }
    else {
      $commands{$name} = '';
    }
  }

  if (%commands) {
    $commands{partitions} = new RHN::Kickstart::Partitions(@partitions);
    $commands{raids} = new RHN::Kickstart::Raids(@raids);
    $commands{volgroups} = new RHN::Kickstart::Volgroups(@volgroups);
    $commands{logvols} = new RHN::Kickstart::Logvols(@logvols);
    $commands{include} = new RHN::Kickstart::Include(@include);

    if ($commands{rootpw}) {
      $commands{rootpw} = new RHN::Kickstart::Password($commands{rootpw}->[0]);
    }
    else {
      $commands{rootpw} = new RHN::Kickstart::Password('');
    }

    $ks->commands(%commands);
  }

  my @packages;

  $query = <<EOQ;
SELECT PN.name
  FROM rhnKickstartPackage KP, rhnPackageName PN
 WHERE KP.kickstart_id = :id
   AND KP.package_name_id = PN.id
EOQ

  $sth = $dbh->prepare($query);
  $sth->execute_h(id => $ks->id);

  while (my ($name) = $sth->fetchrow) {
    push @packages, $name;
  }

  $ks->packages(new RHN::Kickstart::Packages(@packages));

  my @ip_ranges;

  $query =<<EOQ;
SELECT KSIPR.min, KSIPR.max
  FROM rhnKickstartIPRange KSIPR
 WHERE KSIPR.kickstart_id = :id
ORDER BY KSIPR.min
EOQ

  $sth = $dbh->prepare($query);
  $sth->execute_h(id => $ks->id);

  while (my ($min, $max) = $sth->fetchrow) {
    push @ip_ranges, new RHN::Kickstart::IPRange(-min => $min, -max => $max);
  }

  $ks->ip_ranges(\@ip_ranges);

  my @file_lists;

  $query =<<EOQ;
SELECT KSFL.file_list_id
  FROM rhnKickstartPreserveFileList KSFL
 WHERE KSFL.kickstart_id = :id
EOQ

  $sth = $dbh->prepare($query);
  $sth->execute_h(id => $ks->id);

  while (my ($row) = $sth->fetchrow) {
      push @file_lists, $row;
  }
  $ks->file_list(\@file_lists);

  $query =<<EOQ;
SELECT script_type
       , interpreter
       , data 
FROM   rhnKickstartScript
WHERE  1=1 
AND    kickstart_id = :id
EOQ
  
  $sth = $dbh->prepare($query);
  $sth->execute_h(id => $ks->id);  

  while (my ($type, $inter, $inter_data) = $sth->fetchrow) {
    if ($type eq 'pre') {
	  $ks->interpreter_pre_script($inter_data);
      $ks->interpreter_pre_val($inter);
    }
    elsif ($type eq 'post') {
	  $ks->interpreter_post_script($inter_data);
      $ks->interpreter_post_val($inter);
    }
  } 

  return $ks;
}

# set or get commands for this kickstart
# set with a hashref, array, or RHN::Kickstart::Commands object
sub commands {
  my $self = shift;
  my @commands = @_;

  return $self->SUPER::commands() unless exists $commands[0];

  my $cmnds; #the RHN::Kickstart::Commands object we are setting our commands to

  if (ref $commands[0]) {
    if (ref $commands[0] eq 'HASH') {
      $cmnds = new RHN::Kickstart::Commands(%{$commands[0]});
    }
    elsif (ref $commands[0] eq 'RHN::Kickstart::Commands') {
      $cmnds = $commands[0];
    }
    else {
      die "unhandled ref type '" . (ref $commands[0]) . "' setting commands for kickstart";
    }
  }
  elsif (@commands) {
    $cmnds = new RHN::Kickstart::Commands(@commands);
  }

  return $self->SUPER::commands($cmnds);
}

# set or get packages
# set with arrayref, array, or RHN::Kickstart::Packages object
sub packages {
  my $self = shift;
  my @packages = @_;

  return $self->SUPER::packages() unless exists $packages[0];

  my $pkgs; #the RHN::Kickstart::Packages object we are setting our packages to

  if (ref $packages[0]) {
    if (ref $packages[0] eq 'ARRAY') {
      $pkgs = new RHN::Kickstart::Packages(@{$packages[0]});
    }
    elsif (ref $packages[0] eq 'RHN::Kickstart::Packages') {
      $pkgs = $packages[0];
    }
    else {
      die "unhandled ref type '" . (ref $packages[0]) . "' setting packages for kickstart";
    }
  }
  else {
    $pkgs = new RHN::Kickstart::Packages(@packages);
  }

  return $self->SUPER::packages($pkgs);
}

sub active {
  my $self = shift;
  my $val = shift;

  return $self->SUPER::active() unless defined $val;

  $val = (uc($val) eq 'N' or not $val) ? 'N' : 'Y';

  return $self->SUPER::active($val);
}

sub default_cfg_management_flag {
  my $self = shift;
  my $val = shift;

  return $self->SUPER::default_cfg_management_flag() unless defined $val;

  $val = (uc($val) eq 'N' or not $val) ? 'N' : 'Y';

  return $self->SUPER::default_cfg_management_flag($val);
}

sub default_remote_command_flag {
  my $self = shift;
  my $val = shift;

  return $self->SUPER::default_remote_command_flag() unless defined $val;

  $val = (uc($val) eq 'N' or not $val) ? 'N' : 'Y';

  return $self->SUPER::default_remote_command_flag($val);
}

sub is_org_default {
  my $self = shift;
  my $val = shift;

  return $self->SUPER::is_org_default() unless defined $val;

  $val = (uc($val) eq 'N' or not $val) ? 'N' : 'Y';

  return $self->SUPER::is_org_default($val);
}

sub pre {
  my $self = shift;
  my $val = shift;

  if (defined $val) {
    if (not ref $val) {
      $self->SUPER::pre(new RHN::Kickstart::Pre($val));
    }
    elsif (ref $val eq 'RHN::Kickstart::Pre') {
      $self->SUPER::pre($val);
    }
    else {
      die "Invalid type for pre: '$val'";
    }
  }

  my $pre = $self->SUPER::pre;

  return ($pre ? $pre->as_string : '');
}

sub post {
  my $self = shift;
  my $val = shift;

  if (defined $val) {
    if (not ref $val) {
      $self->SUPER::post(new RHN::Kickstart::Post($val));
    }
    elsif (ref $val eq 'RHN::Kickstart::Post') {
      $self->SUPER::post($val);
    }
    else {
      die "Invalid type for post: '$val'";
    }
  }

  my $post = $self->SUPER::post;

  return ($post ? $post->as_string : '');
}

sub nochroot_post {
  my $self = shift;
  my $val = shift;

  if (defined $val) {
    if (not ref $val) {
      $self->SUPER::nochroot_post(new RHN::Kickstart::Post($val));
    }
    elsif (ref $val eq 'RHN::Kickstart::Post') {
      $self->SUPER::nochroot_post($val);
    }
    else {
      die "Invalid type for nochroot_post: '$val'";
    }
  }

  my $post = $self->SUPER::nochroot_post;

  return ($post ? $post->as_string : '');
}

sub delete_kickstart {
  my $class = shift;
  my $id = shift;
  my $transaction = shift;

  die "delete_kickstart requires an id" unless $id;

  my $dbh = $transaction || RHN::DB->connect;

  my $query =<<EOQ;
DELETE
  FROM rhnKickstartCommand
 WHERE kickstart_id = :id
EOQ

  my $sth = $dbh->prepare($query);
  $sth->execute_h(id => $id);

  $query =<<EOQ;
DELETE
  FROM rhnKickstartPackage
 WHERE kickstart_id = :id
EOQ

  $sth = $dbh->prepare($query);
  $sth->execute_h(id => $id);

  $query =<<EOQ;
DELETE
  FROM rhnKSData
 WHERE id = :id
EOQ

  $sth = $dbh->prepare($query);
  $sth->execute_h(id => $id);

  $dbh->commit unless $transaction;

  return;
}

sub remove_packages_by_name_id {
  my $class = shift;
  my $ksid = shift;
  my @pnids = @_;

  die "No ksid" unless $ksid;
  die "No pnids" unless @pnids;

  my $dbh = RHN::DB->connect;
  my $query =<<EOQ;
DELETE
  FROM rhnKickstartPackage KP
 WHERE KP.kickstart_id = :ksid
   AND KP.package_name_id = :pnid
EOQ

  my $sth = $dbh->prepare($query);

  foreach my $pnid (@pnids) {
    $sth->execute_h(ksid => $ksid, pnid => $pnid);
  }

  $dbh->commit;

  return;
}

sub kickstarts_for_org {
  my $class = shift;
  my $org_id = shift;

  die "No org_id" unless $org_id;

  my $ds = new RHN::DataSource::General (-mode => 'kickstarts_for_org');
  my $data = $ds->execute_query(-org_id => $org_id);

  return @{$data};
}

sub dist {
  my $self = shift;

  return unless $self->commands and $self->commands->url;

  my @url_data = @{$self->commands->url};
  my $dist = '';

  foreach my $arg (@url_data) {

    if ($arg =~ m|dist/(.*)/?|) {
      $dist = $1;
    }
  }

  return $dist;
}

# The host with the files needed by Anaconda
sub host {
  my $self = shift;

  return unless $self->commands and $self->commands->url;

  my @url_data = @{$self->commands->url};
  my $host = '';

  foreach my $arg (@url_data) {

    if ($arg =~ m|https?://([^/]*)|) {
      $host = $1;
    }
  }

  return $host;
}

sub crypto_keys {
  my $self = shift;
  my @keys = @_;

  if (@keys) {
    my $dbh = RHN::DB->connect;
    my $sth = $dbh->prepare(<<EOQ);
DELETE
  FROM rhnCryptoKeyKickstart
 WHERE ksdata_id = :ksid
EOQ

    $sth->execute_h(ksid => $self->id);

    $sth = $dbh->prepare(<<EOQ);
INSERT
  INTO rhnCryptoKeyKickstart
       (crypto_key_id, ksdata_id)
VALUES (:ckid, :ksid)
EOQ

    foreach my $id (@keys) {
      $sth->execute_h(ckid => $id, ksid => $self->id);
    }

    $sth->finish;
    $dbh->commit;
  }

  my $ds = new RHN::DataSource::Simple(-querybase => 'General_queries', -mode => 'crypto_keys_for_ks_profile');
  my $data = $ds->execute_query(-ksid => $self->id);

  return @{$data};
}


sub org_ks_ip_ranges {
  my $class = shift;
  my $org_id = shift;

  die "No org_id" unless $org_id;

  my $ds = new RHN::DataSource::General(-mode => 'org_ks_ip_ranges');
  my $data = $ds->execute_query(-org_id => $org_id);

  return @{$data};
}

sub get_url {
  my $self = shift;
  my $url = generate_url(@_, label => $self->label);

  return $url->as_string;
}

sub generate_url {
  my %params = validate(@_, { org_id => 0, kstree => 0, label => 0, mode => 1, scheme => 0 });

  my %url_data;

  if ($params{org_id}) {
    $url_data{org} = RHN::SessionSwap->encode_data($params{org_id});
  }

  if ($params{mode} eq 'view_label') {
    $url_data{view_label} = $params{label};
  }
  elsif ($params{mode} eq 'label') {
    $url_data{label} = $params{label};
  }
  elsif ($params{mode} eq 'ip_range') {
    $url_data{mode} = 'ip_range';
  }
  else {
    die "Invalid mode: '" . $params{mode} . "'\n";
  }

  my $scheme = $params{scheme} || 'http';
  unless ($scheme eq 'http' or $scheme eq 'https') {
    throw "(invalid_parameter) The 'scheme' parameter was '$scheme', but should be 'http' or 'https'";
  }

  my $url = new URI::URL;
  $url->scheme($scheme);
  $url->host(PXT::Config->get('base_domain'));
  $url->path('/kickstart/ks/' . join('/', %url_data));

  return $url;
}

1;

