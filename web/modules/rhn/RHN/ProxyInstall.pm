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

package RHN::ProxyInstall;

use strict;
use English;

use RHN::AppInstall::Session;
use RHN::SatCluster;
use RHN::SatInstall;
use RHN::ConfigChannel;
use RHN::ConfigRevision;
use RHN::DataSource::Simple;
use RHN::CryptoKey;
use RHN::Utils;

use RHN::Exception;
use Params::Validate qw/:all/;
Params::Validate::validation_options(strip_leading => "-");

use Archive::Tar;
use File::Temp qw/tempfile/;
use File::Spec;

use constant DEFAULT_ORG_TRUSTED_SSL_CERT =>
  'RHN-ORG-TRUSTED-SSL-CERT';

sub create_sat_cluster_record {
  my $class = shift;
  my %params = validate(@_, { session => 1,
			      customer_id => 1,
			      description => 1,
			      last_update_user => 0,
			    });

  my $session = $params{session};
  my $hostname = $session->param('hostname');
  my $vip = RHN::Utils::find_ip_address($hostname);

  my $sc = new RHN::SatCluster(customer_id => $params{customer_id},
			       description => $params{description},
			       last_update_user => $params{last_update_user} || 'installer',
			       server_id => $params{session}->get_server->id,
			       vip => $vip,
			      );
  $sc->create_new();

  my $key = RHN::SatCluster->fetch_key($sc->recid);
  $params{session}->param(scout_shared_key => $key);

  return 0;
}

sub generate_ssl_cert {
  my $class = shift;
  my %params = validate(@_, { session => 1,
			      hostname => 1,
			      ca_cert_password => 1,
			      org => 1,
			      org_unit => 1,
			      email => 1,
			      city => 1,
			      state => 1,
			      country => 1,
			      cert_expiration => 1,
			      target_config_channel => 0,
			    });

  my %ssl_cert_opts;

  # yuck-o - the parameter naming sucks - need to convert some
  foreach my $key (qw/org org_unit email city state country hostname/) {
    my $val = $params{$key};
    my $new_key = $key;
    $new_key =~ s/_/-/g;
    $new_key = "-set-${new_key}";

    $ssl_cert_opts{$new_key} = $val;
  }

  $ssl_cert_opts{-dir} = '/root/ssl-build';
  $ssl_cert_opts{'-cert-expiration'} = $params{cert_expiration};
  $ssl_cert_opts{-password} = $params{ca_cert_password};

  foreach my $attr (values %ssl_cert_opts) {
    PXT::Utils->untaint(\$attr);
  }

  my $ret = RHN::SatInstall->generate_server_cert(%ssl_cert_opts);
  $ret = $ret >> 8; # output of system(), to get real return code we need to shift by 8 bits
  my %RET_CODES = (
        22 => "22: Web server's SSL certificate generation/signing failed. Did you mistype your CA password?",
  );
  return ($RET_CODES{$ret} or $ret) if ($ret > 0);

  if ($params{target_config_channel}) {
    my @opts = ("--ssl-dir=" . $ssl_cert_opts{-dir},
		"--hostname=" . $ssl_cert_opts{"-set-hostname"},
		"--channel=" . $params{target_config_channel},
		"--org-id=" . $params{session}->user->org_id,
	       );

    foreach my $opt (@opts) {
      PXT::Utils->untaint(\$opt);
    }

    my $command = '/usr/bin/rhn-sudo-load-ssl-cert ' . join(' ', @opts);

    my ($ca_chain, $ca_rpm) = `$command`;

    if ($ca_chain) {
      chomp($ca_chain);
      chomp($ca_rpm);
      $params{session}->param(ca_chain => $ca_chain);
      $params{session}->param(org_ssl_cert => 1);
      $params{session}->param(ca_rpm => $ca_rpm);
    }
    else {
      throw "(appinstall:could_not_load_cert) Internal error: could not load the SSL cert generated for this proxy";
    }
  }

  return;
}

sub import_ssl_cert {
  my $class = shift;
  my %params = validate(@_, { session => 1,
			      target_config_channel => 1,
			      cert_tar => 1,
			    });

  my $hosted_is_parent = 0;
  my $hosted_url = PXT::Config->get('kickstart_host') || PXT::Config->get('base_domain');

  if ($hosted_url eq $params{session}->param('rhn_parent')) {
    $hosted_is_parent = 1;
  }

  my $tardata = $params{session}->param('ssl_key_tar');

  if (ref $tardata eq 'ARRAY') {
    $tardata = $tardata->[-1];
  }

  my ($ca_chain, $ca_rpm);

  eval {
    ($ca_chain, $ca_rpm) = $class->extract_ssl_cert(-target_config_channel => $params{target_config_channel},
						    -tardata => $tardata,
						    -org_id => $params{session}->user->org_id,
						    -hosted_is_parent => $hosted_is_parent,
						   );
  };
  if ($@) {
    my $E = $@;

    if ($E->is_rhn_exception('not_enough_quota')) {
      throw "(appinstall:not_enough_quota) Storing the needed configuration files would exceed your configuration quota.";
    }

    throw $E;
  }

  if ($ca_chain) {
    $params{session}->param(ca_chain => $ca_chain);
    $params{session}->param(org_ssl_cert => 1);
  }
  if ($ca_rpm) {
    $params{session}->param(ca_rpm => $ca_rpm);
  }

  return;
}

sub extract_ssl_cert {
  my $class = shift;
  my %params = validate(@_, { target_config_channel => 1,
			      tardata => 1,
			      org_id => 1,
			      hosted_is_parent => { default => 0 },
			    });

  # must be a better way...for now, write .tar file to /tmp and hand
  # off to Archive::Tar.

  my ($wr, $tmpfile) = tempfile(DIR => "/tmp");

  $wr->print($params{tardata});

  close $wr;

  my $tar = new Archive::Tar($tmpfile);
  my $cc = RHN::ConfigChannel->lookup(-org_id => $params{org_id},
				      -label => $params{target_config_channel});

  my $transaction = RHN::DB->connect();
  $transaction->nest_transactions();

  my $server_pem;
  my $ca_cert;
  my ($ca_chain, $ca_rpm);

  my @required_files = qw/server.crt server.csr server.key/;
  push @required_files, DEFAULT_ORG_TRUSTED_SSL_CERT;
  my @optional_files;

  my $ca_cert_rpm_filename = find_ca_cert_rpm_in_tar($tar);

  if ($ca_cert_rpm_filename) {
    push @required_files, $ca_cert_rpm_filename;
  }
  # order matters here, so we populate server_pem properly.
  foreach my $filename (@required_files, @optional_files) {
    my $tar_path = find_file_in_tar($tar, $filename);
    my $content;

    if ($tar_path) {
      $content = $tar->get_content($tar_path);
    }

    # Some files may be optional
    if (not $content and not grep { $filename eq $_ } @optional_files) {
      $transaction->nested_rollback();
      throw "(appinstall:invalid_cert) The cert file provided did not contain '$filename'";
    }
    elsif (not $content) {
      next;
    }

    my %file_opts = (-path => '',
		     -content => $content,
		     -config_channel => $cc,
		     -username => 'root',
		     -groupname => 'root',
		     -mode => '644',
		     -binary => 0,
		    );

    my $binary = 0;
    if ($filename eq 'server.crt') {
      $server_pem = $content;
      $file_opts{-path} = '/etc/httpd/conf/ssl.crt/server.crt';
    }
    elsif ($filename eq 'server.csr') {
      $file_opts{-mode} = '600';
      $file_opts{-path} = '/etc/httpd/conf/ssl.csr/server.csr';
    }
    elsif ($filename eq 'server.key') {
      $server_pem .= $content;
      $file_opts{-mode} = '600';
      $file_opts{-path} = '/etc/httpd/conf/ssl.key/server.key';
    }
    elsif ($filename eq DEFAULT_ORG_TRUSTED_SSL_CERT) {
      $ca_cert = $content;

      if ($params{hosted_is_parent}) {
	next;
      }

      $file_opts{-path} = '/usr/share/rhn/' . DEFAULT_ORG_TRUSTED_SSL_CERT;
      $ca_chain = $file_opts{-path};
    }
    elsif ($filename eq $ca_cert_rpm_filename) {
      $file_opts{-path} = '/var/www/html/pub/' . $filename;
      $ca_rpm = $file_opts{-path};
      $file_opts{-binary} = 1;
    }
    else {
      throw "(appinstall:unhandled_file) The file '$filename' isn't properly handled";
    }

    eval {
      import_file(%file_opts);
    };
    if ($@) {
      my $E = $@;

      $transaction->nested_rollback;
      throw $E;
    }
  }

# special cases...
  eval {
    # server_pem - for jabberd
    import_file(-path => '/etc/jabberd/server.pem',
		-content => $server_pem,
		-config_channel => $cc,
		-username => 'jabberd',
		-groupname => 'jabberd',
		-mode => '600');

    if ($ca_cert) {
      # Public version of CA cert.
      import_file(-path => '/var/www/html/pub/' . DEFAULT_ORG_TRUSTED_SSL_CERT,
		  -content => $ca_cert,
		  -config_channel => $cc,
		  -username => 'apache',
		  -groupname => 'apache',
		  -mode => '644',
		 );
    }
  };
  if ($@) {
    my $E = $@;

    $transaction->nested_rollback;
    throw $E;
  }

  import_ssl_cert_for_kickstarts($ca_cert, $params{org_id});

  $transaction->nested_commit;

  return ($ca_chain, $ca_rpm);
}

sub find_file_in_tar {
  my $tar = shift;
  my $target_filename = shift;

  my @files_in_tar = $tar->list_files;

  foreach my $filename (@files_in_tar) {
    my ($vol, $dir, $base) = File::Spec->splitpath($filename);

    if ($base eq $target_filename) {
      return $filename;
    }
  }

  return;
}

sub find_ca_cert_rpm_in_tar {
  my $tar = shift;

  my @files_in_tar = $tar->get_files;

  foreach my $file (@files_in_tar) {
    my ($vol, $dir, $base) = File::Spec->splitpath($file->name);

    if ($base =~ /rhn-org-trusted.*noarch\.rpm/) {
      return $base;
    }
  }

  return;
}

sub import_file {
  my %params = validate(@_, { path => 1,
			      content => 1,
			      config_channel => 1,
			      binary => { default => 0 },
			      username => { default => 'root' },
			      groupname => { default => 'root' },
			      mode => { default => 770 },
			      selinux_ctx => { default => '' },
			    });

  my $cc = $params{config_channel};
  my $path = $params{path};

  my $cfid = $cc->vivify_file_existence($path);

  my $new_revision = new RHN::ConfigRevision;
  $new_revision->config_file_id($cfid);
  $new_revision->path($path);

  if ($params{binary}) {
    $new_revision->is_binary(1);
  }
  else {
    $new_revision->is_binary(0);
  }

  $new_revision->delim_start(PXT::Config->get('config_delim_start'));
  $new_revision->delim_end(PXT::Config->get('config_delim_end'));
  $new_revision->username($params{username});
  $new_revision->groupname($params{groupname});
  $new_revision->filemode($params{mode});
  $new_revision->contents($params{content});
  $new_revision->selinux_ctx($params{selinux_ctx});

  $new_revision->commit;

  return 0;
}

sub activate_proxy {
  my $class = shift;
  my %params = validate(@_, { session => 1,
			      version => 1,
			    });

  my $transaction = RHN::DB->connect;
  $transaction->nest_transactions;

  eval {
    $params{session}->get_server->activate_proxy(-version => $params{version});
  };

  if ($@) {
    my $E = $@;
    $transaction->nested_rollback;

    die $E unless (ref $E eq 'RHN::Exception');

    if ($E->is_rhn_exception('proxy_no_proxy_child_channel')) {
      return "Could not look up RHN Proxy child channel for your current base channel.";
    }
    elsif ($E->is_rhn_exception('channel_family_no_subscriptions')) {
      return "You have no available subscriptions to the RHN Proxy channels.";
    }
    else {
      throw $E;
    }
  }
  else {
    $transaction->nested_commit;
  }

  return 0;
}

sub deactivate_proxy {
  my $class = shift;
  my %params = validate(@_, { session => 1,
			    });

  my $server = $params{session}->get_server;

  unless ($server->is_proxy) {
    throw "(appinstall:not_a_proxy) This system is not an RHN Proxy";
  }

  $server->deactivate_proxy();

  return 0;
}

sub load_configfile_into_session {
  my $class = shift;
  my %params = validate(@_, { session => 1,
			      target_config_file => 1,
			      target_config_channel => 1,
			    });

  my $rev;

  eval {
    $rev = find_latest_config_revision(-org_id => $params{session}->user->org_id,
				       -path => $params{target_config_file},
				       -channel_label => $params{target_config_channel});
  };
  if ($@) {
    my $E = $@;

    if (ref $E and $E->is_rhn_exception('appinstall:file_does_not_exist')) {
      return;
    }

    throw $E;
  }

  my @lines = split(/\n/, $rev->contents);

  foreach my $line (@lines) {
    next if ($line =~ /^\s*#/);
    next unless ($line =~ /(\S+)\s*=\s*(.*)/);

    $params{session}->param($1, $2);
  }

  return;
}

sub update_configfile_from_session {
  my $class = shift;
  my %params = validate(@_, { session => 1,
			      target_config_file => 1,
			      target_config_channel => 1,
			    });

  my $rev = find_latest_config_revision(-org_id => $params{session}->user->org_id,
					-path => $params{target_config_file},
					-channel_label => $params{target_config_channel});

  my @lines = split(/\n/, $rev->contents);

  foreach my $line (@lines) {
    next if ($line =~ /^\s*#/);

    $line =~ s/(\S+)(\s*=\s*)(.*)/"${1}${2}" . ($params{session}->param($1) || '')/e;
  }

  my $new_contents = join("\n", @lines);

  my $new_revision = $rev->copy_revision;
  $new_revision->set_contents($new_contents); #creates a new revision
  $new_revision->commit;

  return;
}

sub find_latest_config_revision {
  my %params = validate(@_, {org_id => 1,
			     channel_label => 1,
			     path => 1,
			    });
  my $cc;

  eval {
    $cc = RHN::ConfigChannel->lookup(-org_id => $params{org_id},
				     -label => $params{channel_label});
  };
  if ($@) {
    my $E = $@;
    if ($E =~ /no config_channel/) {
      throw "(appinstall:config_channel_does_not_exist) A Config Channel with label '$params{channel_label}' does not exist.";
    }
    else {
      throw $E;
    }
  }

  my $rev = RHN::ConfigChannel->lookup_latest_in_channel(-channel_id => $cc->id,
							 -file_path => $params{path});

  unless ($rev) {
    throw "(appinstall:file_does_not_exist) Configfile '$params{path}' does not exist in config channel '$params{channel_label}'";
  }

  return $rev;
}

sub load_ip_address {
  my $class = shift;
  my %params = validate(@_, { session => 1,
			    });

  my $session = $params{session};

  my $hostname = $session->param('rhn_parent');

  return unless $hostname;

  my $ip_addr = RHN::Utils::find_ip_address($hostname);

  return unless $ip_addr;

  $session->param(rhn_parent_ip => $ip_addr);

  return;
}

# test if machine have installed package(s)
# accept one or more name of package and
# set have_package_foo to true for each installed
# package.
# you can optionally pass alias for list of packages
# in that case is set have_package_any_of_alias and
# have_package_all_of_alias
sub have_package {
  my $class = shift;
  my %params = validate(@_, { session => 1,
                              package => 1,
                              alias   => 0,
                            });

  my $session = $params{session};
  my @packages = (ref $params{'package'} eq 'ARRAY') ?
        @{$params{'package'}} :
        ($params{'package'});

  # any - does any package from the list is installed
  # all - does all of the packages are installed;
  my ($all, @package_list);
  foreach my $package (@packages) {
    if (my $version = $params{session}->get_server->version_of_package_installed($package)) {
      push @package_list, $package;
      $package =~ tr/-/_/;
      $session->param("have_package_$package" => join('.', $version->{'VERSION'}, $version->{'RELEASE'}));
    } else {
      $all = 0;
    }
  }
  my $any = @package_list;
  $session->param("packages_list_$params{'alias'}" => join(' ', @package_list)); 

  # set alias so we do not test whole list of package all the time
  if ($params{'alias'}) {
    $session->param("have_package_any_of_$params{'alias'}" => $any);
    $session->param("have_package_all_of_$params{'alias'}" => $all);
  }
  return;
}


sub import_ssl_cert_for_kickstarts {
  my $ca_cert = shift;
  my $org_id = shift;

  my $ds = new RHN::DataSource::Simple(-querybase => 'General_queries',
				       -mode => 'crypto_keys_for_org');
  my $org_keys = $ds->execute_query(-org_id => $org_id);

  $ca_cert =~ s/^\s*(.*)\s*$/$1/s;
  my $cert_description = DEFAULT_ORG_TRUSTED_SSL_CERT;


  foreach my $key (@{$org_keys}) {
    $key->{KEY} =~ s/^\s*(.*)\s*$/$1/s;

    return if $key->{KEY} eq $ca_cert;
  }

  my $postfix = 0;

  if (grep { $_->{DESCRIPTION} eq $cert_description } @{$org_keys}) {
    $postfix = 1;
  }

  while (grep { $_->{DESCRIPTION} eq $cert_description . "-$postfix" } @{$org_keys}) {
    $postfix++;
  }

  if ($postfix) {
    $cert_description = $cert_description . "-$postfix";
  }

  my $ck = new RHN::CryptoKey;
  $ck->org_id($org_id);
  $ck->description($cert_description);
  $ck->set_type('SSL');
  $ck->key($ca_cert);
  $ck->commit;

  return 1;
}

1;
