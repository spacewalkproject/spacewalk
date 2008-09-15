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

package RHN::Kickstart::Post;

# The 'Post' section - this package is really to hold 'helper' methods.

use PXT::Utils;
use RHN::Package;
use RHN::TokenGen::Local;

use Params::Validate qw/:all/;
Params::Validate::validation_options(strip_leading => "-");

sub new {
  my $class = shift;
  my $val = shift;

  die "'$val' is a ref." if (ref $val);

  $val =~ s/\r\n/\n/g; # wash textbox input
  $val =~ s/\r/\n/g;

  my $self = bless \$val, $class;

  return $self;
}

sub as_string {
  my $self = shift;

  return $$self;
}

# Helpers

sub get_rhn_packages {
  my $self = shift;
  my $on_off = shift;
  my $attr = shift;

  my @packages = @{$attr->{packages}};
  my $ssl_available = $attr->{ssl_available};

  my $expires = time + 43200; # 12 hours
  my @urls;

  foreach my $pkg_id (@packages) {
    my $pkg = RHN::Package->lookup(-id => $pkg_id);

    push @urls, RHN::TokenGen::Local->generate_url(0, 0, $pkg->path, "/download", "local", $expires, $ssl_available);

  }

  my $urls = join(" ", @urls);

  return unless $urls;

  $self->choose_action($attr->{style}, $on_off, { urls => $urls });
}

sub update_rhn_packages {
  my $self = shift;
  my $on_off = shift;
  my $attr = shift;

  my @packages = @{$attr->{package_names}};

  # crude hack
  my $dir = '/tmp/rhn_rpms/optional';
  my $packages = join(" ", map { "$dir/$_*" } @{$attr->{package_names}});
  $self->choose_action('update_rhn_package', $on_off, { packages => $packages });
}


sub add_gpg_keys {
  my $self = shift;
  my $on_off = shift;
  my $attr = shift;

  my @key_data = @{$attr->{key_data}};

  return unless @key_data;

  my $dist = $attr->{dist};

  for (my $i = $#key_data; $i >= 0; $i--) { # What's this?!  A 'for' loop in perl?  Madness!
    $self->choose_action("import_gpg_keys_${dist}" , $on_off, { index => $i + 1 });
    $self->choose_action('write_key_to_file', $on_off, { key => $key_data[$i], index => $i + 1, type => 'gpg' });
  }
}

sub add_ssl_keys {
  my $self = shift;
  my $on_off = shift;
  my $attr = shift;

  my @key_data = @{$attr->{key_data}};

  return unless @key_data;

  $self->choose_action('use_custom_ssl_keys', $on_off);
  $self->choose_action("import_ssl_keys" , $on_off);

  for (my $i = $#key_data; $i >= 0; $i--) {
    $self->choose_action('write_key_to_file', $on_off, { key => $key_data[$i], index => $i + 1, type => 'ssl' });
  }
}

sub choose_action {
  my $self = shift;
  my $mode = shift;
  my $toggle = shift;
  my $args = shift;

  if (not defined $toggle) { # is it on already?
    return $self->check_for_line($mode);
  }
  elsif ($toggle) { # turn it on...
    return $self->insert_line($mode, $args);
  }
  else { # ...or off
    return $self->remove_line($mode);
  }
}

my %helpers = (
	       enable_cfg_management => {
			       regexp => qr|^mkdir -p /etc/sysconfig/rhn/allowed-actions/configfiles\n
                                             touch /etc/sysconfig/rhn/allowed-actions/configfiles/all|xm,
			       string =>    "mkdir -p /etc/sysconfig/rhn/allowed-actions/configfiles\n"
					  . "touch /etc/sysconfig/rhn/allowed-actions/configfiles/all",
			       position => 1,
  			      },
	       enable_remote_command => {
			       regexp => qr|^mkdir -p /etc/sysconfig/rhn/allowed-actions/script\n
                                             touch /etc/sysconfig/rhn/allowed-actions/script/all|xm,
			       string =>    "mkdir -p /etc/sysconfig/rhn/allowed-actions/script\n"
					  . "touch /etc/sysconfig/rhn/allowed-actions/script/all",
			       position => 1,
  			      },
	       import_rhn_gpg_key_rhel3 => {
			       regexp => qr|^rpm --import /usr/share/rhn/RPM-GPG-KEY|m,
			       string =>   "rpm --import /usr/share/rhn/RPM-GPG-KEY",
			       position => 1,
			      },
	       import_rhn_gpg_key_rhel2_1 => {
			       regexp => qr|^gpg $(up2date --gpg-flags) --batch --import /usr/share/rhn/RPM-GPG-KEY\n
                                             gpg $(up2date --gpg-flags) --batch --import /usr/share/rhn/RPM-GPG-KEY|xm,
			       string =>   "gpg \$(up2date --gpg-flags) --batch --import /usr/share/rhn/RPM-GPG-KEY\n"
					 . "gpg \$(up2date --gpg-flags) --batch --import /usr/share/rhn/RPM-GPG-KEY",
			       position => 1,
			      },
	       rhnreg_ks_with_profile_name => {
			     regexp => qr|^rhnreg_ks --activationkey=(\S+)|m,
			     string =>   "rhnreg_ks --activationkey={key} --profilename=\"{profile_name}\"",
			     position => 1,
			    },
	       rhnreg_ks => {
			     regexp => qr|^rhnreg_ks --activationkey=(\S+)|m,
			     string =>   "rhnreg_ks --activationkey={key}",
			     position => 1,
			    },
	       up2date_conf_www => {
			regexp => qr|^perl -npe \'s/www.rhns.redhat.com/.*/\' -i /etc/sysconfig/rhn/up2date|m,
			string =>   "perl -npe 's/www.rhns.redhat.com/{kickstart_host}/' -i /etc/sysconfig/rhn/up2date",
			position => 1,
				       },
	       up2date_conf_xmlrpc => {
			regexp => qr|^perl -npe \'s/xmlrpc.rhn.redhat.com/.*/\' -i /etc/sysconfig/rhn/up2date|m,
			string =>   "perl -npe 's/xmlrpc.rhn.redhat.com/{kickstart_host}/' -i /etc/sysconfig/rhn/up2date",
			position => 1,
				       },
	       rhn_register_conf_www => {
			regexp => qr|^perl -npe \'s/www.rhns.redhat.com/.*/\' -i /etc/sysconfig/rhn/rhn_register|m,
			string =>   "perl -npe 's/www.rhns.redhat.com/{kickstart_host}/' -i /etc/sysconfig/rhn/rhn_register",
			position => 1,
				       },
	       rhn_register_conf_xmlrpc => {
			regexp => qr|^perl -npe \'s/xmlrpc.rhn.redhat.com/.*/\' -i /etc/sysconfig/rhn/rhn_register|m,
			string =>   q(perl -npe 's/xmlrpc.rhn.redhat.com/{kickstart_host}/' -i /etc/sysconfig/rhn/rhn_register),
			position => 1,
				       },
	       make_rhn_packages_dir => {
				       regexp => qr|^mkdir -p /tmp/rhn_rpms/optional|m,
				       string =>   "mkdir -p /tmp/rhn_rpms/optional",
				       position => 1,
				      },
	       download_rhn_packages => {
				       regexp => qr|^wget -P /tmp/rhn_rpms [^\n]*|m,
				       string =>   "wget -P /tmp/rhn_rpms {urls}",
				       position => 1,
				      },
	       download_optional_rhn_packages => {
				       regexp => qr|^wget -P /tmp/rhn_rpms/optional [^\n]*|m,
				       string =>   "wget -P /tmp/rhn_rpms/optional {urls}",
				       position => 1,
				      },
	       freshen_rhn_packages => {
				       regexp => qr|^rpm -Fvh /tmp/rhn_rpms/\*rpm|m,
				       string =>   "rpm -Fvh /tmp/rhn_rpms/*rpm",
				       position => 1,
				      },
	       update_rhn_package => {
				       regexp => qr|^rpm -Uvh --replacepkgs --replacefiles (/tmp/rhn_rpms/optional/.*?\*)+|m,
				       string =>   "rpm -Uvh --replacepkgs --replacefiles {packages}",
				       position => 1,
				      },
	       rhn_check => {
			     regexp => qr|^rhn_check$|m,
			     string =>    "rhn_check",
			     position => 1,
			    },
	       copy_out => {
			     string =>    "\n# now copy from the ks-tree we saved in the non-chroot checkout\n" .
			                  "cp -fav /tmp/ks-tree-copy/* /\n" .
			                  "rm -Rf /tmp/ks-tree-copy",
			     position => 2,
			    },
               write_key_to_file => {
                                     regexp => qr!cat > /tmp/({type})-key-({index}) <<'EOF'.*EOF\n# \1-key-\2!sm,
                                     string => "cat > /tmp/{type}-key-{index} <<'EOF'\n{key}\nEOF\n# {type}-key-{index}",
                                     position => 1,
                                    },
               import_gpg_keys_rhel3 => {
                                     regexp => qr|rpm --import /tmp/gpg-key-({index})|m,
                                     string => 'rpm --import /tmp/gpg-key-{index}',
				     position => 1,
				    },
               import_gpg_keys_rhel2_1 => {
                                     regexp => qr|^gpg $(up2date --gpg-flags) --batch --import /tmp/gpg-key-({index})\n
                                                   gpg $(up2date --gpg-flags) --batch --import /tmp/gpg-key-\1|xm,
                                     string => "gpg \$(up2date --gpg-flags) --batch --import /tmp/gpg-key-{index}\n"
                                             . "gpg \$(up2date --gpg-flags) --batch --import /tmp/gpg-key-{index}",
                                     position => 1,
                                     },
               import_ssl_keys => {
                                   regexp => qr|cat /tmp/ssl-key-\* > /usr/share/rhn/RHN-ORG-TRUSTED-SSL-CERT|m,
                                   string => 'cat /tmp/ssl-key-* > /usr/share/rhn/RHN-ORG-TRUSTED-SSL-CERT',
				   position => 1,
				   },
               use_custom_ssl_keys => {
                                       regexp => qr|^perl -npe \'s/RHNS-CA-CERT/RHN-ORG-TRUSTED-SSL-CERT/g\' -i /etc/sysconfig/rhn/*|m,
                                       string =>  q(perl -npe 's/RHNS-CA-CERT/RHN-ORG-TRUSTED-SSL-CERT/g' -i /etc/sysconfig/rhn/*),
                                       position => 1,
                                      },
	       start_log => {
			     regexp => qr|^\( # Log \%post errors$|m,
			     string => '( # Log %post errors',
			     position => 0,
			    },
	       end_log => {
			   regexp => qr|^\) > /root/ks-post\.log 2>&1$|m,
			   string => ') > /root/ks-post.log 2>&1',
			  },
	       add_comment => {
			       regexp => qr|^#always add new comments|,
			       string => qq(\n# {comment}\n),
			       position => 1,
			      },
	       set_resolv_conf => {
			       regexp => qr|^cp /etc/resolv\.conf /mnt/sysimage/etc/resolv\.conf|,
			       string => qq(cp /etc/resolv.conf /mnt/sysimage/etc/resolv.conf),
			       position => 0,
			      },
	       # we use oldtmp below because, in rhel3, /oldtmp is
	       # what we made on the initrd; /tmp is a ramfs copy (and
	       # an imperffect copy that skips some files and doesn't
	       # preserve directory permissions).
	       copy_preserved_files => {
			       string =>  "mkdir /mnt/sysimage/tmp/ks-tree-copy\n"
					. "if [ -d /oldtmp/ks-tree-shadow ]; then\n"
                                        . "    cp -fa /oldtmp/ks-tree-shadow/* /mnt/sysimage/tmp/ks-tree-copy\n"
					. "elif [ -d /tmp/ks-tree-shadow ]; then\n"
                                        . "    cp -fa /tmp/ks-tree-shadow/* /mnt/sysimage/tmp/ks-tree-copy\n"
					. "fi",
			       position => 0,
			      },
	       );

sub valid_helpers {
  return (keys %helpers);
}

sub check_for_line {
  my $self = shift;
  my $mode = shift;

  my $check = $self->as_string =~ $helpers{$mode}->{regexp};
  return $1 ? $1 : $check;
}

sub insert_line {
  my $self = shift;
  my $mode = shift;
  my $subst = shift;

  my $options = $helpers{$mode};

  if ($options->{regexp} && $self->as_string =~ $options->{regexp}) {
    my $regexp = $options->{regexp};
    $regexp = PXT::Utils->perform_substitutions($regexp, $subst);
    $$self =~ s/$regexp/PXT::Utils->perform_substitutions($options->{string}, $subst)/egsm;
  }
  else {
    my @lines = split(/\n/, $self->as_string);

    push @lines, (''); # make sure we append when position is '-1'

    if (defined $options->{position}) {
      splice(@lines, $options->{position}, 0, PXT::Utils->perform_substitutions($options->{string}, $subst));
    }
    else {
      push @lines, PXT::Utils->perform_substitutions($options->{string}, $subst);
    }

    $$self = join("\n", @lines);
  }

  return 1;
}

sub remove_line {
  my $self = shift;
  my $mode = shift;

  my ($index, $found);
  my @lines = split(/\n/, $self->as_string);

  for ($index = 0; $index <= $#lines; $index++) {
    if ($lines[$index] =~ $helpers{$mode}->{regexp}) {
      $found = 1;
      last;
    }
  }

  splice(@lines, $index, 1);

  $$self = join("\n", @lines);
  return 1;
}

1;
