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

package Sniglets::SatInstall;

use English;

use RHN::Exception qw/throw/;
use RHN::SatInstall;
use RHN::SatCluster;

use RHN::Form;
use RHN::Form::ParsedForm;
use RHN::Form::Widget::Text;
use RHN::Utils;

use Sys::Hostname;

use PXT::HTML;
use PXT::Utils;

use Sniglets::Forms;

sub register_tags {
  my $class = shift;
  my $pxt = shift;

  $pxt->register_tag("rhn-satinstall-form", \&satinstall_form);
  $pxt->register_tag("rhn-satinstall-configure", \&satinstall_config_form);
  $pxt->register_tag("rhn-satinstall-confirm-restart", \&satinstall_confirm_restart);

  $pxt->register_tag("rhn-satinstall-progressmeter", \&satinstall_progressmeter);

  $pxt->register_tag("rhn-satinstall-restart", \&satinstall_restart);
}

sub register_callbacks {
  my $class = shift;
  my $pxt = shift;

  $pxt->register_callback("rhn:satinstall_form_cb" => \&satinstall_form_cb);
  $pxt->register_callback("rhn:satinstall_configure_cb" => \&satinstall_config_cb);
  $pxt->register_callback("rhn:satinstall_restart_cb" => \&satinstall_restart_cb);
}

sub satinstall_form {
  my $pxt = shift;
  my %params = @_;

  unless (PXT::Config->get('satellite_install')) {
    $pxt->redirect("/index.pxt");
  }

  if (RHN::SatInstall->db_population_in_progress()
      and not $params{form_name} eq 'populate_db') {
    $pxt->push_message(local_alert => 'Database population in progress');
    $pxt->redirect('/install/populate_in_progress.pxt');
  }

  my $pform = build_form($pxt, %params);
  my $rform = $pform->realize;
  undef $pform;

  my $style = new Sniglets::Forms::Style;
  my $html = $rform->render($style);

  return $html;
}

my %form_map = (admin_email => { tag => \&build_admin_email_form,
				 cb => \&admin_email_form_cb },
	        db_config => { tag => \&build_db_config_form,
			       cb => \&db_config_cb },
	        populate_db => { tag => \&build_populate_db_form,
				 cb => \&populate_db_cb },
	        configure_rhn => { tag => \&build_configure_rhn_form,
				   cb => \&configure_rhn_cb },
	        configure_monitoring => { tag => \&build_configure_monitoring_form,
					  cb => \&configure_monitoring_cb },
	        rhn_register => { tag => \&build_rhn_register_form,
				  cb => \&rhn_register_cb },
	        satellite_cert => { tag => \&build_satellite_cert_form,
				    cb => \&satellite_cert_cb },
	        satellite_sync => { tag => \&build_satellite_sync_form,
				    cb => \&satellite_sync_cb },
	        gen_sat_cert => { tag => \&build_gen_sat_cert_form,
				  cb => \&gen_sat_cert_cb },
	        gen_bootstrap => { tag => \&build_gen_bootstrap_form,
				   cb => \&gen_bootstrap_cb },
	        install_done => { tag => \&build_install_done_form,
				  cb => \&install_done_cb },
	       );

sub satinstall_form_cb {
  my $pxt = shift;

  unless (PXT::Config->get('satellite_install')) {
    $pxt->redirect("/index.pxt");
  }

  my $pform = build_form($pxt);
  my $rform = $pform->prepare_response;
  undef $pform;

  my $errors = Sniglets::Forms::load_params($pxt, $rform);

  if (@{$errors}) {
    foreach my $error (@{$errors}) {
      $pxt->push_message(local_alert => $error);
    }
    return;
  }

  my $form_name = $pxt->dirty_param('form_name') || '';
  throw "Invalid form name: $form_name" unless exists $form_map{$form_name};

  return &{$form_map{$form_name}->{cb}}($pxt, $rform);
}

sub build_form {
  my $pxt = shift;
  my %params = @_;

  my $form_name = $params{form_name} || $pxt->dirty_param('form_name') || '';
  throw "Invalid form name: $form_name" unless exists $form_map{$form_name};

  return &{$form_map{$form_name}->{tag}}($pxt, %params);
}

sub build_admin_email_form {
  my $pxt = shift;
  my %attr = @_;

  my $form = new RHN::Form::ParsedForm(name => 'Admin Email',
				       label => 'admin_email',
				       action => $attr{action},
				      );

  if (RHN::SatInstall->is_embedded_db) {
    my $db_info = { user => 'rhnsat',
		    password => 'rhnsat',
		    sid => 'rhnsat',
		    host => 'localhost',
		    port => 1521,
		    protocol => 'TCP',
		  };

    RHN::SatInstall->write_tnsnames($db_info->{sid} => [ $db_info ]);

    my $dsn = make_dsn(@{$db_info}{qw/user password sid/});
    set_default_db($dsn);

    if (not RHN::SatInstall->test_db_connection()) {
      $pxt->push_message(local_alert => 'Could not connect to the embedded database.  Check the database installation log at /var/log/rhn/rhn-database-installation.log for more information.');
      return $form;
    }
  }

  add_admin_email_widget($form);

  $form->add_widget(hidden => {name => 'pxt:trap',
			       value => 'rhn:satinstall_form_cb'});
  $form->add_widget(hidden => {name => 'form_name',
			       value => 'admin_email'});
  $form->add_widget(submit => {name => 'Continue'});

  return $form;
}

sub add_admin_email_widget {
  my $form = shift;

  my $current_email = PXT::Config->get('traceback_mail') || '';
  $current_email = ''
    if ($current_email =~ /^@@/ or $current_email eq 'user@example.com');

  $form->add_widget(text => { name => 'Administrator Email Address',
			      label => 'admin_email',
			      size => 32,
			      default => $current_email,
			      requires => {'max-length' => 256,
					   'valid-multi-email' => 1,
					   response => 1},
			    });

  return;
}

sub admin_email_form_cb {
  my $pxt = shift;
  my $rform = shift;

  set_admin_email($rform);

# TODO: not needed when we generate globally.
  RHN::SatInstall->generate_satcon_dict();

  if (RHN::SatInstall->is_embedded_db) {
    $pxt->redirect('/install/db_config.pxt?pxt:trap=rhn:satinstall_form_cb&form_name=db_config&db_user=rhnsat&db_password=rhnsat&db_sid=rhnsat&db_host=localhost&db_port=1521&db_protocol=TCP')
  }
  else {
    $pxt->redirect('/install/db_config.pxt');
  }

  return;
}

sub set_admin_email {
  my $rform = shift;

  my $admin_email = $rform->lookup_value('admin_email');

  # untaint - not much to do, since we check for a valid email address
  PXT::Utils->untaint(\$admin_email);

  RHN::SatInstall->write_config( {traceback_mail => $admin_email} );

  return
}

sub build_db_config_form {
  my $pxt = shift;
  my %attr = @_;

  # Redirect if we are embedded db, but not in the callback
  if (RHN::SatInstall->is_embedded_db and not $pxt->dirty_param('pxt:trap')) {
    $pxt->redirect('/install/populate_db.pxt');
  }

  my $form = new RHN::Form::ParsedForm(name => 'Database Configuration',
				       label => 'db_config',
				       action => $attr{action},
				      );

  $form->add_widget(text => { name => 'Database User',
			      label => 'db_user',
			      size => 16,
			      default => $pxt->dirty_param('db_user') || 'rhnsat',
			      requires => {'max-length' => 128,
					   response => 1},
			    });

  $form->add_widget(text => { name => 'Database Password',
			      label => 'db_password',
			      size => 16,
			      default => $pxt->dirty_param('db_password') || 'rhnsat',
			      requires => {'max-length' => 128,
					   response => 1},
			    });

  $form->add_widget(text => { name => 'Database SID',
			      label => 'db_sid',
			      size => 16,
			      default => $pxt->dirty_param('db_sid') || 'rhnsat',
			      requires => {'max-length' => 128,
					   response => 1},
			    });

  $form->add_widget(text => { name => 'Database host',
			      label => 'db_host',
			      size => 24,
			      default => $pxt->dirty_param('db_host') || 'localhost',
			      requires => {'max-length' => 256,
					   response => 1},
			    });

  $form->add_widget(text => { name => 'Database port',
			      label => 'db_port',
			      size => 6,
			      default => $pxt->dirty_param('db_port') || '1521',
			      requires => {'max-length' => 8,
					   response => 1},
			    });

  $form->add_widget(text => { name => 'Database protocol',
			      label => 'db_protocol',
			      size => 4,
			      default => $pxt->dirty_param('db_protocol') || 'TCP',
			      requires => {'max-length' => 16,
					   response => 1},
			    });

  $form->add_widget(hidden => {name => 'pxt:trap',
			       value => 'rhn:satinstall_form_cb'});
  $form->add_widget(hidden => {name => 'form_name',
			       value => 'db_config'});
  $form->add_widget(submit => {name => 'Test DB connection'});

  return $form;
}

sub db_config_cb {
  my $pxt = shift;
  my $rform = shift;

  PXT::Config->set(debug_disable_database => 0);
  RHN::SatInstall->write_config( {debug_disable_database => 0} );

  my $db_info = { };
  @{$db_info}{qw/user password sid host port protocol/}
    = (map { $rform->lookup_value($_) } qw/db_user db_password db_sid
					   db_host db_port db_protocol/);

  my $dsn;

  untaint_hashref($db_info);

  RHN::SatInstall->write_tnsnames($db_info->{sid} => [ $db_info ]);

  $dsn = make_dsn(@{$db_info}{qw/user password sid/});
  set_default_db($dsn);

  my $connected = RHN::SatInstall->test_db_connection();

  if (not $connected) {
    $pxt->push_message(local_alert => 'Could not connect to the database.');
    return;
  }

  my $hib_config = { };
  @{$hib_config}{qw/db_user db_password db_sid db_host db_port/}
    = (map { $rform->lookup_value($_) } qw/db_user db_password db_sid
					   db_host db_port/);
  untaint_hashref($hib_config);

  RHN::SatInstall->write_config($hib_config,
				'/etc/sysconfig/rhn-satellite-prep/satellite-local-rules.conf');

  # TODO - intelligently decide which errors to pass to the user
  # unchanged, and which to munge.

  eval {
    RHN::SatInstall->check_db_version();
    RHN::SatInstall->check_db_tablespace_settings($db_info->{user});
    RHN::SatInstall->check_db_charsets();
  };
  if ($EVAL_ERROR) {
    my $error = $EVAL_ERROR;

    $pxt->push_message(local_alert => $error);
    return;
  }

  $pxt->redirect('/install/populate_db.pxt');

  return;
}

sub build_populate_db_form {
  my $pxt = shift;
  my %attr = @_;

  my $form = new RHN::Form::ParsedForm(name => 'Populate Database Schema',
				       label => 'populate_db',
				       action => $attr{action},
				      );

  if (RHN::SatInstall->is_embedded_db) {
    my $test_dbh = RHN::DB->connect; # throw an exception if we can't connect to db
  }
  else {
    unless (RHN::SatInstall->test_db_connection()) {
      $pxt->push_message(local_alert => <<EOQ);
Could not connect to the database.
Please check your database configuration and try again.
EOQ
      $pxt->redirect('/install/db_config.pxt');
    }
  }

  if (RHN::SatInstall->test_db_schema and not $pxt->dirty_param('pxt:trap')) {
    $pxt->push_message(local_alert => <<EOQ);
There is already schema in this database.
Check the box below to empty it and repopulate.
EOQ

    $form->add_widget(checkbox => { name => 'Clear DB and repopulate?',
				    label => 'clear_db',
				    value => 1,
				    checked => 1,
				  });
  }
  else {
    $form->add_widget(hidden => { name => 'clear_db', value => 0 });
  }

  $form->add_widget(hidden => { name => 'populate_db', value => 1 });

  $form->add_widget(hidden => {name => 'pxt:trap',
			       value => 'rhn:satinstall_form_cb'});
  $form->add_widget(hidden => {name => 'form_name',
			       value => 'populate_db'});
  $form->add_widget(submit => {name => 'Continue'});

  return $form;
}

sub populate_db_cb {
  my $pxt = shift;
  my $rform = shift;

  my $clear_db = $rform->lookup_value('clear_db');

  if ((not $clear_db) and RHN::SatInstall->test_db_schema()) {
    $pxt->redirect('/install/configure.pxt');
  }

  my %opts;

  if ($clear_db) {
    $opts{-clear_db} = 1;
  }

  if ($rform->lookup_value('populate_db')) {
    my $dsn = RHN::DB->get_default_handle();

    # untaint
    if ($dsn =~ /^(\S+\/\S+\@\S+)$/) {
      $dsn = $1;
    }
    else {
      $pxt->push_message(local_alert => "Invalid DSN: $dsn");
      $pxt->redirect('/install/db_config.pxt');
    }

    my @array = split_dsn($dsn);

    @{\%opts}{qw/-user -password -sid/} = @array;

    eval {
      RHN::SatInstall->populate_database(%opts);
    };
    if ($@) {
      my $E = $@;

      if (ref $E and $E->is_rhn_exception('satinstall:db_population_in_progress')) {
	$pxt->push_message(local_alert => 'Database population is already in progress');
	$pxt->redirect('/install/populate_in_progress.pxt');
      }

      throw $E;
    }

    RHN::SatInstall->write_config( {debug_disable_database => 1} );

    $pxt->redirect('/install/populate_in_progress.pxt');
  }

  eval {
    my $version = RHN::SatInstall->schema_version;
  };
  if ($EVAL_ERROR) {
    my $error = $EVAL_ERROR;

    $pxt->push_message(local_alert => $error);
    return;
  }

  $pxt->redirect('/install/configure.pxt');
}

sub build_configure_rhn_form {
  my $pxt = shift;
  my %attr = @_;

  my $form = new RHN::Form::ParsedForm(name => 'Configure RHN',
				       label => 'configure_rhn',
				       action => $attr{action},
				      );

  $form->add_widget(text => { name => 'Spacewalk Hostname',
			      label => 'jabberDOThostname',
			      size => 32,
			      default => Sys::Hostname::hostname,
			      requires => {'max-length' => 512,
					   response => 1},
			    });

  add_satellite_config_widgets($form);

  $form->add_widget(hidden => {name => 'pxt:trap',
			       value => 'rhn:satinstall_form_cb'});
  $form->add_widget(hidden => {name => 'form_name',
			       value => 'configure_rhn'});
  $form->add_widget(submit => {name => 'Continue'});

  return $form;
}

sub add_satellite_config_widgets {
  my $form = shift;

  $form->add_widget(text => { name => 'HTTP proxy',
			      label => 'serverDOTsatelliteDOThttp_proxy',
			      size => 32,
			      default => '',
			      requires => {'max-length' => 512},
			    });

  $form->add_widget(text => { name => 'HTTP proxy username',
			      label => 'serverDOTsatelliteDOThttp_proxy_username',
			      size => 16,
			      default => '',
			      requires => {'max-length' => 128},
			    });

  $form->add_widget(password => { name => 'HTTP proxy password',
			      label => 'serverDOTsatelliteDOThttp_proxy_password',
			      size => 16,
			      default => '',
			      requires => {'max-length' => 128},
			    });

  $form->add_widget(text => { name => 'RPM repository mount point',
			      label => 'mount_point',
			      size => 32,
			      default => '/var/satellite',
			      requires => {'max-length' => 512,
					   response => 1},
			    });

  my $ssl_checked = 0;
  $ssl_checked = 1 if PXT::Config->get('satellite_install');
  $ssl_checked = 1 if PXT::Config->get('ssl_available');

  $form->add_widget(checkbox => { name => 'Enable SSL',
				  label => 'enable_ssl',
				  value => 1,
				  checked => $ssl_checked,
				} );

  my $enable_solaris = 0;
  $enable_solaris = 1 if PXT::Config->get('satellite_install');
  $enable_solaris = 1 if PXT::Config->get('enable_solaris_support');

  $form->add_widget(checkbox => { name => 'Enable Solaris Support',
				  label => 'webDOTenable_solaris_support',
				  value => 1,
				  checked => $enable_solaris,
				} );

  my $disconnected_checked = PXT::Config->get('server.satellite', 'rhn_parent') ? 0 : 1;

  $form->add_widget(checkbox => { name => 'Disconnected Spacewalk',
				  label => 'disconnected',
				  value => 1,
				  checked => $disconnected_checked,
				} );

  if (RHN::SatInstall->monitoring_available()) {
    $form->add_widget(checkbox => { name => 'Enable monitoring backend',
				    label => 'webDOTis_monitoring_backend',
				    value => 1,
				    checked => PXT::Config->get('is_monitoring_backend') ? 1 : 0,
				  });

    $form->add_widget(checkbox => { name => 'Enable monitoring scout',
				    label => 'webDOTis_monitoring_scout',
				    value => 1,
				    checked => PXT::Config->get('is_monitoring_scout') ? 1 : 0,
				  });
  }

  my @widgets = qw/mount_point serverDOTsatelliteDOThttp_proxy
		   serverDOTsatelliteDOThttp_proxy_username
		   serverDOTsatelliteDOThttp_proxy_password
		   webDOTis_monitoring_backend
		   webDOTis_monitoring_scout/;

  foreach my $label (@widgets) {
    check_current_config($form->lookup_widget($label));
  }

  return;
}

sub check_current_config {
  my $widget = shift;
  return unless $widget;

  my $label = $widget->label;
  $label =~ s/DOT/./g;

  my ($domain, $var);
  if ($label =~ /^(.*)\.(.*)$/) {
    $domain = $1;
    $var = $2;
  }
  else {
    $domain = 'web';
    $var = $label;
  }

  my $value = PXT::Config->get($domain, $var);

  if ($value =~ /^@@/) {
    return;
  }

  $widget->default($value);

  return;
}

sub configure_rhn_cb {
  my $pxt = shift;
  my $rform = shift;

  RHN::SatInstall->write_config( {debug_disable_database => 0} );
  PXT::Config->set(debug_disable_database => 0);

  my $config_opts = { };

  populate_config_opts($pxt, $rform, $config_opts);

  $config_opts->{jabberDOThostname} = $rform->lookup_value('jabberDOThostname');;

  if ($config_opts->{webDOTis_monitoring_scout} and not $config_opts->{webDOTis_monitoring_backend}) {
    $pxt->push_message(local_alert => 'The Monitoring backend must be enabled if Monitoring scout is enabled.');
    return;
  }

  if ($config_opts->{serverDOTsatelliteDOThttp_proxy}) {
    my $proxy = check_proxy_url_format($pxt, $config_opts->{serverDOTsatelliteDOThttp_proxy});

    return unless $proxy;

    $config_opts->{serverDOTsatelliteDOThttp_proxy} = $proxy;
  }

  $config_opts->{encrypted_passwords} = 1;
  $config_opts->{satellite_install} = 1;
  $config_opts->{webDOTssl_available} = "0";
  $config_opts->{default_db} = RHN::DB->get_default_handle();
  $config_opts->{traceback_mail} = PXT::Config->get('traceback_mail');
  $config_opts->{jabberDOTusername} = 'rhn-dispatcher-sat';
  $config_opts->{jabberDOTpassword} = 'rhn-dispatcher-' . PXT::Utils->random_password(6);

  foreach my $opt_name (qw/session_swap_secret session_secret/) {
    foreach my $i (1 .. 4) {
      $config_opts->{"${opt_name}_${i}"} = RHN::SatInstall->generate_secret;
    }
  }

  $config_opts->{server_secret_key} = RHN::SatInstall->generate_secret;

# TODO: set up ca_chain properly.
  $config_opts->{"serverDOTsatelliteDOTca_chain"} = '/usr/share/rhn/RHNS-CA-CERT';

  # Bugzilla: 159721 - set character set in NLS_LANG based upon
  # nls_database_paramaters from DB.
  my %nls_database_paramaters = RHN::SatInstall->get_nls_database_parameters();
  $config_opts->{serverDOTnls_lang} = 'english.' . $nls_database_paramaters{NLS_CHARACTERSET};

  untaint_hashref($config_opts);
  RHN::SatInstall->write_config($config_opts,
				'/etc/sysconfig/rhn-satellite-prep/satellite-local-rules.conf');

  my $disconnected = $pxt->dirty_param('disconnected') || 0;
  if ($disconnected) {
    RHN::SatInstall->write_config( { 'server.satellite.rhn_parent' => '' },
				   '/etc/sysconfig/rhn-satellite-prep/etc/rhn/rhn.conf' );
  } elsif (not PXT::Config->get('server.satellite', 'rhn_parent')) {
    RHN::SatInstall->write_config( { 'server.satellite.rhn_parent' => 'satellite.rhn.redhat.com' },
				   '/etc/sysconfig/rhn-satellite-prep/etc/rhn/rhn.conf' );
  }

  RHN::SatInstall->satcon_deploy();

  # have to write this to satellite-prep but not deploy because we
  # can't turn on SSL for a few more pages.
  RHN::SatInstall->write_config({webDOTssl_available => $pxt->dirty_param('enable_ssl') ? "1" : "0"},
				'/etc/sysconfig/rhn-satellite-prep/satellite-local-rules.conf');

  RHN::SatInstall->config_up2date(-http_proxy => $config_opts->{serverDOTsatelliteDOThttp_proxy},
				  -http_proxy_username => $config_opts->{serverDOTsatelliteDOThttp_proxy_username},
				  -http_proxy_password => $config_opts->{serverDOTsatelliteDOThttp_proxy_password},
				 );

  my @args = ();

  if ($config_opts->{webDOTis_monitoring_backend}) {
    push @args, 'backend=1';
  }
  if ($config_opts->{webDOTis_monitoring_scout}) {
    push @args, 'scout=1';
  }

  if (@args) {
    my $string = '?' . (join '&', @args);
    $pxt->redirect("/install/configure_monitoring.pxt${string}");
  }

  if ($disconnected) {
    $pxt->redirect('/install/satellite_cert.pxt?disconnected=1')
  }
  else {
    $pxt->redirect('/install/register.pxt');
  }
}

# This subroutine populates config options that are common both to the
# installation configuration page and the post-install configuration
# page.
sub populate_config_opts {
  my $pxt = shift;
  my $rform = shift;
  my $config_opts = shift;

  my @valid_opts = qw/mount_point
		      serverDOTsatelliteDOThttp_proxy
		      serverDOTsatelliteDOThttp_proxy_username
		      serverDOTsatelliteDOThttp_proxy_password
		      /;

  @{$config_opts}{@valid_opts} = map { $rform->lookup_value($_) } @valid_opts;

  $config_opts->{webDOTis_monitoring_backend} = $pxt->dirty_param('webDOTis_monitoring_backend');
  $config_opts->{webDOTis_monitoring_scout} = $pxt->dirty_param('webDOTis_monitoring_scout');
  $config_opts->{webDOTenable_solaris_support} = $pxt->dirty_param('webDOTenable_solaris_support');

  return;
}

sub build_configure_monitoring_form {
  my $pxt = shift;
  my %attr = @_;

  my $form = new RHN::Form::ParsedForm(name => 'Monitoring Configuration',
				       label => 'configure_monitoring',
				       action => $attr{action},
				      );

  my ($db_user, $db_pass, $db_name) = split_dsn(PXT::Config->get('default_db'));

  if ($pxt->dirty_param('backend')) {
    $form->add_widget(hidden => { name => 'Monitoring Admin Email',
				  label => 'RHN_ADMIN_EMAIL',
				  default => PXT::Config->get('traceback_mail'),
				});

    $form->add_widget(text => { name => 'Local Mail Exchanger',
				label => 'MAIL_MX',
				size => 32,
				default => 'localhost',
				requires => {'max-length' => 256,
					     response => 1},
			      });

    $form->add_widget(text => { name => 'Local Mail Domain',
				label => 'MDOM',
				size => 32,
				default => Sys::Hostname::hostname,
				requires => {'max-length' => 256,
					     response => 1},
			      });

    $form->add_widget(hidden => { name => 'Monitoring DB Name',
				  label => 'monitoringDOTdbname',
				  default => $db_name,
				});
    $form->add_widget(hidden => { name => 'Monitoring DB username',
				  label => 'monitoringDOTusername',
				  default => $db_user,
				});
    $form->add_widget(hidden => { name => 'Monitoring DB password',
				  label => 'monitoringDOTpassword',
				  default => $db_pass,
				});

    $form->add_widget(hidden => {name => 'backend', value => 1});
  }

  if ($pxt->dirty_param('scout')) {
    $form->add_widget(hidden => { name => 'Scout Address',
				  label => 'monitoringDOTsmonDOTaddr',
				  default => '127.0.0.1',
				});
    $form->add_widget(hidden => { name => 'Scout FQDN',
				  label => 'monitoringDOTsmonDOTfqdn',
				  default => 'localhost',
				});
    $form->add_widget(hidden => { name => 'Scout Test Address',
				  label => 'monitoringDOTsmonDOTtestaddr',
				  default => '127.0.0.1',
				});
    $form->add_widget(hidden => { name => 'Scout Test FQDN',
				  label => 'monitoringDOTsmonDOTtestfqdn',
				  default => 'localhost',
				});

    $form->add_widget(hidden => {name => 'scout', value => 1});
  }

  $form->add_widget(hidden => {name => 'pxt:trap',
			       value => 'rhn:satinstall_form_cb'});
  $form->add_widget(hidden => {name => 'form_name',
			       value => 'configure_monitoring'});
  $form->add_widget(submit => {name => 'Continue'});

  return $form;
}

sub configure_monitoring_cb {
  my $pxt = shift;
  my $rform = shift;

  my @valid_opts = qw/monitoringDOTdbname monitoringDOTusername
                      monitoringDOTpassword monitoringDOTsmonDOTaddr
                      monitoringDOTsmonDOTfqdn monitoringDOTsmonDOTtestaddr
                      monitoringDOTsmonDOTtestfqdn/;

  my $config_opts = { };

  @{$config_opts}{@valid_opts} = map { $rform->lookup_value($_) || '' }
    @valid_opts;

  # save and deploy monitoring configs.
  untaint_hashref($config_opts);

  $config_opts->{monitoringDOTorahome} = '/opt/oracle';
  $config_opts->{monitoringDOTdbd} = 'Oracle';
  $config_opts->{monitoringDOTscout_shared_key} = ''; # blank for now.

  RHN::SatInstall->write_config($config_opts,
				'/etc/sysconfig/rhn-satellite-prep/satellite-local-rules.conf');

  # write monitoring config to DB.
  my %mon_config =
    (
     RHN_ADMIN_EMAIL => $rform->lookup_value('RHN_ADMIN_EMAIL'),
     MAIL_MX => $rform->lookup_value('MAIL_MX') || '',
     MDOM => $rform->lookup_value('MDOM') || '',
     RHN_DB_NAME => $config_opts->{monitoringDOTdbname},
     RHN_DB_USERNAME => $config_opts->{monitoringDOTusername},
     RHN_DB_PASSWD => $config_opts->{monitoringDOTpassword},
     RHN_DB_TABLE_OWNER => $config_opts->{monitoringDOTusername},
     RHN_SAT_HOSTNAME => PXT::Config->get('server', 'jabber_server'),
     XPROTO => 'https',
     RHN_SAT_WEB_PORT => 443
    );

  untaint_hashref(\%mon_config);
  RHN::SatInstall->update_monitoring_config(\%mon_config);

  my $dbname = $mon_config{RHN_DB_NAME};

  RHN::SatInstall->update_monitoring_environment($dbname);

  RHN::SatInstall->enable_notification_cron();

  if (PXT::Config->get('server.satellite', 'rhn_parent')) {
    $pxt->redirect('/install/register.pxt');
  }
  else {
    $pxt->redirect('/install/satellite_cert.pxt?disconnected=1');
  }
}

sub build_rhn_register_form {
  my $pxt = shift;
  my %attr = @_;

  my $form = new RHN::Form::ParsedForm(name => 'RHN Registration',
				       label => 'rhn_register',
				       action => $attr{action},
				      );

  $form->add_widget(literal => { name => 'Parent Server',
				 value => PXT::Config->get('server.satellite', 'rhn_parent'),
			       });

  $form->add_widget(text => { name => 'System Profile Name',
			      label => 'profilename',
			      size => 32,
			      default => PXT::Config->get('server', 'jabber_server'),
			      requires => {'max-length' => 128,
					   response => 1}
				});

  $form->add_widget(text => { name => 'RHN Username',
			      label => 'username',
			      size => 16,
			      default => '',
			      requires => {'max-length' => 128,
					   response => 1}
			    });

  $form->add_widget(password => { name => 'RHN Password',
				  label => 'password',
				  size => 16,
				  default => '',
				  requires => {'max-length' => 128,
					       response => 1},
				});

  $form->add_widget(hidden => {name => 'pxt:trap',
			       value => 'rhn:satinstall_form_cb'});
  $form->add_widget(hidden => {name => 'form_name',
			       value => 'rhn_register'});
  $form->add_widget(submit => {name => 'Continue'});

  return $form;
}

sub rhn_register_cb {
  my $pxt = shift;
  my $rform = shift;

  my @valid_opts = qw/username password profilename/;

  my $register_opts = { };

  @{$register_opts}{map { "-$_" } @valid_opts} = map { $rform->lookup_value($_) } @valid_opts;

  untaint_hashref($register_opts);

  eval {
    RHN::SatInstall->register_system(%{$register_opts});
  };
  if ($@) {
    my $E = $@;
    if (ref $E and $E->is_rhn_exception('satellite_registration_failed')) {
      $E =~ /\(satellite_registration_failed\) (.*)/;
      my $error = $1;
      $pxt->push_message(local_alert => $error);
      return;
    }

    throw $E;
  }

  $pxt->redirect('/install/satellite_cert.pxt');
}

sub build_satellite_cert_form {
  my $pxt = shift;
  my %attr = @_;

  my $form = new RHN::Form::ParsedForm(name => 'Spacewalk Certificate',
				       label => 'satellite_cert',
				       action => $attr{action},
				       enctype => 'multipart/form-data',
				      );

  $form->add_widget(file => {name => 'Upload Certificate File',
			     label => 'cert_file',
			    });

  $form->add_widget(textarea => { name => '-or- Certificate Text',
				  label => 'cert_text',
				  cols => 80,
				  rows => 24,
				  default => '',
				});

  my $disconnected = $pxt->dirty_param('disconnected') ? 1 : 0;

  $form->add_widget(hidden => {name => 'pxt:trap',
			       value => 'rhn:satinstall_form_cb'});
  $form->add_widget(hidden => {name => 'disconnected',
			       value => $disconnected});
  $form->add_widget(hidden => {name => 'form_name',
			       value => 'satellite_cert'});
  $form->add_widget(submit => {name => 'Validate Certificate'});

  return $form;
}

sub satellite_cert_cb {
  my $pxt = shift;
  my $rform = shift;

  my $cert_contents;

  if ($pxt->upload('cert_file')) {
    my $fh = $pxt->upload->fh;
    $cert_contents = do { local $/; <$fh> };
  }
  else {
    $cert_contents = $rform->lookup_value('cert_text');
  }

  if (length $cert_contents >= PXT::Config->get('maximum_config_file_size')) {
    $pxt->push_message(local_alert => sprintf('Spacewalk certificates must be no larger than %s.',
					      PXT::Utils->humanify(PXT::Config->get('maximum_config_file_size')),
					     ));
    return;
  }

  unless ($cert_contents) {
    $pxt->push_message(local_alert => sprintf('You must specify a Spacewalk certificate.'));
    return;
  }

  PXT::Utils->untaint(\$cert_contents);
  my $cert_file = RHN::SatInstall->write_satellite_cert(-contents => $cert_contents);

  PXT::Utils->untaint(\$cert_file);

  my %opts;

  if ($rform->lookup_value('disconnected')) {
    $opts{"-disconnected"} = 1;
  }

  eval {
    RHN::SatInstall->satellite_activate(-filename => $cert_file,
					-sanity_only => 1,
				        -check_monitoring => (PXT::Config->get('is_monitoring_backend') ? 1 : 0),
				       );

    RHN::SatInstall->satellite_activate(-filename => $cert_file, %opts);
  };

  if ($@) {
    my $E = $@;

    if (ref $E) {
      if ($E->is_rhn_exception('satellite_activation_failed')) {
	$E =~ /\(satellite_activation_failed\) (.*)/g;
	my $msg = $1;

	$pxt->push_message(local_alert => "There was a problem registering the satellite: ${msg}.");
	return;
      }
      elsif ($E->is_rhn_exception('no_monitoring_entitlements')) {
	$E =~ /\(no_monitoring_entitlements\) (.*)/g;
	my $msg = $1;

	$pxt->push_message(local_alert => $msg . <<EOQ);
Please either provide a certificate with monitoring entitlements, or
<a href="/install/configure.pxt">do not enable Monitoring</a> on this
Spacewalk.
EOQ

	return;
      }
      elsif ($E->is_rhn_exception('parse_error')) {
	$E =~ /\(parse_error\) (.*)/g;
	my $msg = $1;

	$pxt->push_message(local_alert => $msg);

	return;
      }
      else {
	$pxt->push_message(local_alert => "There was a problem activating the satellite with the provided certificate.");
	return;
      }
    }

    throw $E;
  }

  if ($rform->lookup_value('disconnected')) {
    $pxt->redirect('/install/gen_sat_cert.pxt');
  }
  else {
    $pxt->redirect('/install/satellite_sync.pxt');
  }
}

sub build_satellite_sync_form {
  my $pxt = shift;
  my %attr = @_;

  my $form = new RHN::Form::ParsedForm(name => 'Spacewalk Sync',
				       label => 'satellite_sync',
				       action => $attr{action},
				      );

  my $sat_sync = $pxt->dirty_param('sat_sync');

  $form->add_widget(checkbox => { name => 'Perform Spacewalk Sync',
				  label => 'sat_sync',
				  checked => defined $sat_sync ? $sat_sync : 1,
				  value => 1,
				});

  $form->add_widget(hidden => {name => 'pxt:trap',
			       value => 'rhn:satinstall_form_cb'});
  $form->add_widget(hidden => {name => 'form_name',
			       value => 'satellite_sync'});
  $form->add_widget(submit => {name => 'Continue'});

  return $form;
}

sub satellite_sync_cb {
  my $pxt = shift;
  my $rform = shift;

  unless ($pxt->dirty_param('sat_sync')) {
    $pxt->push_message(site_info => 'Skipping Spacewalk Sync.  You will not be able to perform Management functions until a syncronization is done.');
    $pxt->redirect('/install/gen_sat_cert.pxt');
  }

  my $ca_cert_file = PXT::Config->get('server.satellite', 'ca_chain');

  my $dsn = RHN::DB->get_default_handle();

  if ($dsn =~ /^(\S+\/\S+\@\S+)$/) {
    $dsn = $1;
  }
  else {
    $pxt->push_message(local_alert => "Invalid DSN: $dsn");
    $pxt->redirect('/install/db_config.pxt');
  }

  PXT::Utils->untaint(\$ca_cert_file);

  RHN::SatInstall->sat_sync(-ca_cert_file => $ca_cert_file,
			    -dsn => $dsn,
			    -step => 'channel-families');

  $pxt->redirect('/install/gen_sat_cert.pxt');
}

sub build_gen_sat_cert_form {
  my $pxt = shift;
  my %attr = @_;

  my $form = new RHN::Form::ParsedForm(name => 'Generate CA cert',
				       label => 'gen_sat_cert',
				       action => $attr{action},
				      );

  $form->add_widget(password => { name => 'CA cert password',
				  label => 'password',
				  size => 16,
				  default => '',
				  requires => {'max-length' => 128,
					       response => 1},
				});

  $form->add_widget(password => { name => 'Re-enter CA cert password',
				  label => 'password_2',
				  size => 16,
				  default => '',
				  requires => {'max-length' => 128,
					       response => 1},
				});

  $form->add_widget(text => { name => 'Organization',
			      label => 'set-org',
			      size => 24,
			      default => $pxt->dirty_param('set-org') || '',
			      requires => {'max-length' => 128,
					   response => 1},
			    });

  $form->add_widget(text => { name => 'Organizational Unit',
			      label => 'set-org-unit',
			      size => 24,
			      default => $pxt->dirty_param('set-org-unit') || '',
			      requires => {'max-length' => 128},
			    });

  $form->add_widget(text => { name => 'CA Cert Common Name',
			      label => 'set-common-name',
			      size => 32,
			      default => $pxt->dirty_param('set-common-name') || '',
			      requires => {'max-length' => 128,
					   response => 1},
			    });

  $form->add_widget(text => { name => 'Email Address',
			      label => 'set-email',
			      size => 32,
			      default => $pxt->dirty_param('set-email') || PXT::Config->get('traceback_mail') || '',
			      requires => {'max-length' => 128,
					   response => 1},
			    });

  my @country_options = RHN::SatInstall->valid_cert_countries();

  $form->add_widget(text => { name => 'City',
			      label => 'set-city',
			      size => 16,
			      default => $pxt->dirty_param('set-city') || '',
			      requires => {'max-length' => 128,
					   response => 1},
			    });

  $form->add_widget(text => { name => 'State',
			      label => 'set-state',
			      size => 16,
			      default => $pxt->dirty_param('set-state') || '',
			      requires => {'max-length' => 128,
					   response => 1},
			    });

  $form->add_widget(select => { name => 'Country',
				label => 'set-country',
				size => 1,
				default => $pxt->dirty_param('set-country') || 'US',
				options => \@country_options,
				requires => {response => 1},
			    });

  $form->add_widget(text => { name => 'CA Cert Expiration (years)',
			      label => 'cert-expiration',
			      size => 3,
 			      default => $pxt->dirty_param('cert-expiration') ||
			                 RHN::SatInstall->default_cert_expiration,
			      requires => {'max-length' => 128,
					   response => 1},
			    });

  $form->add_widget(text => { name => 'Server Cert Expiration (years)',
			      label => 'server-cert-expiration',
			      size => 3,
			      default => RHN::SatInstall->default_cert_expiration,,
 			      default => $pxt->dirty_param('server-cert-expiration') ||
			                 RHN::SatInstall->default_cert_expiration,
			      requires => {'max-length' => 4,
					   response => 1},
			    });

  $form->add_widget(hidden => {name => 'pxt:trap',
			       value => 'rhn:satinstall_form_cb'});
  $form->add_widget(hidden => {name => 'form_name',
			       value => 'gen_sat_cert'});
  $form->add_widget(submit => {name => 'Generate Cert'});

  return $form;
}

sub gen_sat_cert_cb {
  my $pxt = shift;
  my $rform = shift;

  my $password = $pxt->dirty_param('password') || '';
  my $password_2 = $pxt->dirty_param('password_2') || '';

  if ($password ne $password_2) {
    $pxt->push_message(local_alert => 'The CA Cert passwords did not match');
    return;
  }

  my @hostname_parts = split(/\./, PXT::Config->get('server', 'jabber_server'));
  my $system_name;

  if (scalar @hostname_parts > 2) {
    $system_name = join('.', splice(@hostname_parts, 0, -2));
  }
  else {
    $system_name = join('.', @hostname_parts);
  }

  my %ssl_cert_opts =
    (
     dir => '/root/ssl-build',
     password => '',
     'set-country' => '',
     'set-state' => '',
     'set-city' => '',
     'set-org' => '',
     'set-org-unit' => '',
     'set-common-name' => '',
     'server-rpm' => 'rhn-org-httpd-ssl-key-pair-' . $system_name,
     'cert-expiration' => 0,
    );

  foreach my $field (qw/password set-country set-state set-city set-org
			set-org-unit set-common-name cert-expiration/) {
    $ssl_cert_opts{$field} = $rform->lookup_value($field);
  }

  untaint_hashref(\%ssl_cert_opts);
  my $invalid_char =
    RHN::SatInstall->check_valid_ssl_cert_password($ssl_cert_opts{ssl_password});

  if ($invalid_char) {
    $pxt->push_message(local_alert => "Invalid character '$invalid_char' in cert password.");
    return;
  }

  RHN::SatInstall->generate_ca_cert(%ssl_cert_opts);
  RHN::SatInstall->deploy_ca_cert("-source-dir" => $ssl_cert_opts{dir},
				  "-target-dir" => '/var/www/html/pub');

  delete $ssl_cert_opts{'server-rpm'};
  delete $ssl_cert_opts{'set-common-name'};

  $ssl_cert_opts{'set-email'} = $rform->lookup_value('set-email');
  $ssl_cert_opts{'set-hostname'} = PXT::Config->get('server', 'jabber_server');
  $ssl_cert_opts{'cert-expiration'} = $rform->lookup_value('server-cert-expiration');

  untaint_hashref(\%ssl_cert_opts);
  RHN::SatInstall->generate_server_cert(%ssl_cert_opts);
  RHN::SatInstall->install_server_cert(-dir => $ssl_cert_opts{dir},
				       -system => $system_name);

  RHN::SatInstall->generate_server_pem(-ssl_dir => $ssl_cert_opts{dir},
				       -system => $system_name,
				       -out_file => '/etc/jabberd/server.pem');

  RHN::SatInstall->store_ssl_cert(-ssl_dir => $ssl_cert_opts{dir});

  $pxt->redirect('/install/gen_bootstrap.pxt');
}

sub build_gen_bootstrap_form {
  my $pxt = shift;
  my %attr = @_;

  my $form = new RHN::Form::ParsedForm(name => 'Generate Bootstrap Scripts',
				       label => 'gen_bootstrap',
				       action => $attr{action},

				      );

  $form->add_widget(text => {name => 'Spacewalk server hostname',
			     label => '-hostname',
			     default => PXT::Config->get('server', 'jabber_server'),
			     size => 48,
			     requires => {'max-length' => 256,
					  response => 1},
			    });

  if ($pxt->dirty_param('no_ssl')) {
    $form->add_widget(hidden => {name => 'no_ssl',
				 value => 1,
				});
  }
  else {
    $form->add_widget(text => {name => 'SSL cert location',
			       label => '-ssl-cert',
			       default => '/var/www/html/pub/RHN-ORG-TRUSTED-SSL-CERT',
			       size => 64,
			       requires => {'max-length' => 512,
					    response => 1},
			      });
    $form->add_widget(checkbox => {name => 'Enable SSL',
				   label => '-ssl',
				   default => 1,
				   checked => 1,
				  });
  }

  $form->add_widget(checkbox => {name => 'Enable Client GPG checking',
				 label => '-gpg',
				 default => 1,
				 checked => 1,
				});
  $form->add_widget(checkbox => {name => 'Enable Remote Configuration',
				 label => '-allow-config-actions',
				 default => 1,
				});
  $form->add_widget(checkbox => {name => 'Enable Remote Commands',
				 label => '-allow-remote-commands',
				 default => 1,
				});
  $form->add_widget(text => {name => 'Client HTTP proxy',
			     label => '-http-proxy',
			     default => '',
			    });
  $form->add_widget(text => {name => 'Client HTTP proxy username',
			     label => '-http-proxy-username',
			     default => '',
			    });
  $form->add_widget(text => {name => 'Client HTTP proxy password',
			     label => '-http-proxy-password',
			     default => '',
			    });

  $form->add_widget(hidden => {name => 'pxt:trap',
			       value => 'rhn:satinstall_form_cb'});
  $form->add_widget(hidden => {name => 'form_name',
			       value => 'gen_bootstrap'});
  $form->add_widget(submit => {name => 'Generate Bootstrap Script'});

  return $form;
}

sub gen_bootstrap_cb {
  my $pxt = shift;
  my $rform = shift;

  my %bootstrap_opts;

  foreach my $field (qw/-hostname -ssl-cert -http-proxy
			-http-proxy-username -http-proxy-password/) {
    $bootstrap_opts{$field} = $rform->lookup_value($field);
  }

  # generic solution for special cases.
  foreach (qw/-ssl -gpg/) {
    $bootstrap_opts{"-no" . $_} = 1 unless $pxt->dirty_param($_);
  }

  foreach (qw/-allow-config-actions -allow-remote-commands/) {
    $bootstrap_opts{$_} = 1 if $pxt->dirty_param($_);
  }

  if ($bootstrap_opts{"-http-proxy"}) {
    my $proxy = check_proxy_url_format($pxt, $bootstrap_opts{"-http-proxy"});

    return unless $proxy;

    $bootstrap_opts{"-http-proxy"} = $proxy;

  }

  if (   (    $bootstrap_opts{"-http-proxy-username"}
          and not $bootstrap_opts{"-http-proxy-password"})
      or (    $bootstrap_opts{"-http-proxy-password"}
	  and not $bootstrap_opts{"-http-proxy-username"})) {
    $pxt->push_message(local_alert =>
		       'You must specify both a proxy username and a proxy password if you specify either');
    return;
  }

  untaint_hashref(\%bootstrap_opts);

  my %options = ("-overrides" => 'client-config-overrides.txt',
		 "-script" => 'bootstrap.sh',
		);

  eval {
    RHN::SatInstall->generate_bootstrap_scripts(%bootstrap_opts, %options);
  };
  if ($@) {
    my $E = $@;
    if (ref $E and $E->is_rhn_exception('bootstrap_script_creation_failed')) {
      $E =~ /\(bootstrap_script_creation_failed\) (.*)/;
      my $error = $1;
      $pxt->push_message(local_alert => $error);
      return;
    }

    throw $E;
  }

  $pxt->redirect('/install/install_done.pxt');
}

sub build_install_done_form {
  my $pxt = shift;
  my %attr = @_;

  my $form = new RHN::Form::ParsedForm(name => 'Installation Complete',
				       label => 'install_done',
				       action => $attr{action},
				      );

  $form->add_widget(hidden => {name => 'pxt:trap',
			       value => 'rhn:satinstall_form_cb'});
  $form->add_widget(hidden => {name => 'form_name',
			       value => 'install_done'});
  $form->add_widget(submit => {name => 'Done'});

  return $form;
}

sub install_done_cb {
  my $pxt = shift;
  my $rform = shift;

  # start needed services, etc.
  if (PXT::Config->get('is_monitoring_backend')) {
    RHN::SatInstall->setup_monitoring_sysv_step('Monitoring');
  }

  if (PXT::Config->get('is_monitoring_scout')) {
    RHN::SatInstall->setup_monitoring_sysv_step('MonitoringScout');

    my $org_id = RHN::SatInstall->get_satellite_org_id();
    my $hostname = Sys::Hostname::hostname;
    my $ip = RHN::Utils::find_ip_address($hostname);
    my $sc = new RHN::SatCluster(customer_id => $org_id,
				 description => 'RHN Monitoring Spacewalk',
				 last_update_user => 'installer',
				 vip => $ip,
				);
    $sc->create_new();

    my $scout_shared_key = RHN::SatCluster->fetch_key($sc->recid);
    RHN::SatInstall->write_config({ monitoringDOTscout_shared_key => $scout_shared_key },
				  '/etc/sysconfig/rhn-satellite-prep/satellite-local-rules.conf');
  }

  # Finish install
  my $final_config = {satellite_install => 0,
		      osadispatcherDOTosa_ssl_cert => '/var/www/html/pub/RHN-ORG-TRUSTED-SSL-CERT',
		     };

  RHN::SatInstall->write_config($final_config);
  RHN::SatInstall->write_config($final_config,
				'/etc/sysconfig/rhn-satellite-prep/satellite-local-rules.conf');
  RHN::SatInstall->satcon_deploy(-tree => '/etc/sysconfig/rhn-satellite-prep/etc/rhn',
				 -dest => '/etc/rhn');

  PXT::Config->set(satellite_install => 0);
  PXT::Config->set(ssl_available => $final_config->{webDOTssl_available});

  RHN::SatInstall->restart_satellite(-delay => 5);

  $pxt->redirect('/install/restart_in_progress.pxt');
}

sub satinstall_restart {
  my $pxt = shift;
  my %attr = @_;

  my $delay = $attr{delay};
  my $redir = $attr{redir};

  throw "(missing_param) The 'delay' parameter is missing"
    unless $delay;

  throw "(missing_param) The 'redir' parameter is missing"
    unless $redir;

  my $url = $pxt->derelative_url($redir);

  $pxt->header_out(Refresh => "$delay; $url");
}

sub satinstall_progressmeter {
  my $pxt = shift;
  my %attr = @_;

  unless (PXT::Config->get('satellite_install')) {
    $pxt->redirect("/index.pxt");
  }

  my $html = $attr{__block__};
  my %subs;

  my $stage = $attr{stage};

  if ($stage eq 'populate_db') {
    get_populate_db_progress(\%subs);
  }
  else {
    throw "Unknown state '$stage' in satinstall_progressmeter";
  }

  if ($subs{percent_complete} != 100) {
    my $url = $pxt->derelative_url($pxt->uri);
    $pxt->header_out(Refresh => "5; $url");
  }

  return PXT::Utils->perform_substitutions($html, \%subs);
}

sub get_populate_db_progress {
  my $subs = shift;

  my $stats = RHN::SatInstall->get_db_population_log_stats;

  $subs->{continue_message} = '';
  $subs->{file_size} = '0';
  $subs->{percent_complete} = '0';
  $subs->{status} = 'Preparing database';

  if ($stats->{file_size}) {
    $subs->{file_size} = $stats->{file_size};
    $subs->{percent_complete} = $stats->{percent_complete};
    $subs->{status} = 'Database population in progress';

    if ($stats->{percent_complete} >= 100) {
      $subs->{status} = 'Database population complete';
      $subs->{continue_message} = 'Go to <a href="/install/configure.pxt">Configuration</a> page.';
      $subs->{percent_complete} = 100;
    }

    my @pop_errors = RHN::SatInstall->get_db_population_errors();
    if (@pop_errors) {
      my $text = join("\n", @pop_errors);
      $text = PXT::HTML->htmlify_text($text);
      $subs->{status} = 'Errors during database population';
      $subs->{continue_message} = <<EOQ;
There were errors during the database population phase.
Please contact RHN support for assistance.
Error message:<br/>
$text
EOQ
      $subs->{percent_complete} = 100;
    }
  }

  return;
}

sub set_default_db {
  my $dsn = shift;

  my %options = ('default_db' => $dsn);
  untaint_hashref(\%options);
  RHN::SatInstall->write_config(\%options);

  RHN::DB->set_default_handle($dsn);

  return;
}

sub make_dsn {
  my ($db_user, $db_pass, $db_sid) = @_;

  return sprintf('%s/%s@%s', $db_user, $db_pass, $db_sid);
}

sub split_dsn {
  my $dsn = shift;

  return split(/[\/@]/, $dsn);
}

sub untaint_hashref {
  my $hashref = shift;

  foreach my $key (keys %{$hashref}) {
    PXT::Utils->untaint(\$hashref->{$key});
  }

  return;
}

### Configuration ###

sub satinstall_config_form {
  my $pxt = shift;
  my %params = @_;

  my $pform = build_config_form($pxt, %params);
  my $rform = $pform->realize;
  undef $pform;

  my $style = new Sniglets::Forms::Style;
  my $html = $rform->render($style);

  return $html;
}

sub build_config_form {
  my $pxt = shift;
  my %attr = @_;

  my $form = new RHN::Form::ParsedForm(name => 'Configure Spacewalk',
				       label => 'config_satellite',
				       action => $attr{action},
				      );

  add_admin_email_widget($form);
  add_satellite_config_widgets($form);

  $form->add_widget(hidden => {name => 'pxt:trap',
			       value => 'rhn:satinstall_configure_cb'});
  $form->add_widget(submit => {name => 'Update Configuration'});

  return $form;
}

sub satinstall_config_cb {
  my $pxt = shift;

  my $pform = build_config_form($pxt);
  my $rform = $pform->prepare_response;
  undef $pform;

  my $errors = Sniglets::Forms::load_params($pxt, $rform);

  if (@{$errors}) {
    foreach my $error (@{$errors}) {
      $pxt->push_message(local_alert => $error);
    }
    return;
  }

  my $restart_required = 0;

  my $config_opts = { };
  set_admin_email($rform);
  populate_config_opts($pxt, $rform, $config_opts);
  $config_opts->{traceback_mail} = $rform->lookup_value('admin_email');

  my %redir_opts;

  my $ssl_was_enabled = PXT::Config->get('ssl_available') ? 1 : 0;
  my $ssl_is_enabled = $pxt->dirty_param('enable_ssl') ? 1 : 0;
  if ($ssl_was_enabled != $ssl_is_enabled) {
    $restart_required = 1;
    $redir_opts{enable_ssl} = $ssl_is_enabled;
  }

  my $was_monitoring_backend = PXT::Config->get('is_monitoring_backend') ? 1 : 0;
  my $is_monitoring_backend = $config_opts->{webDOTis_monitoring_backend} ? 1 : 0;
  if ($was_monitoring_backend != $is_monitoring_backend) {
    $restart_required = 1;
    $redir_opts{webDOTis_monitoring_backend} = $is_monitoring_backend;
  }

  my $was_monitoring_scout = PXT::Config->get('is_monitoring_scout') ? 1 : 0;
  my $is_monitoring_scout = $config_opts->{webDOTis_monitoring_scout} ? 1 : 0;
  if ($was_monitoring_scout != $is_monitoring_scout) {
    $restart_required = 1;
    $redir_opts{webDOTis_monitoring_scout} = $is_monitoring_scout;
  }

  if ($config_opts->{webDOTis_monitoring_scout} and
      not $config_opts->{webDOTis_monitoring_backend}) {
    $pxt->push_message(local_alert => 'The Monitoring backend must be enabled if Monitoring scout is enabled.');
    return;
  }

  my $disconnected = $pxt->dirty_param('disconnected') || 0;
  if ($disconnected) {
    RHN::SatInstall->write_config( { 'server.satellite.rhn_parent' => '' },
				   '/etc/sysconfig/rhn-satellite-prep/etc/rhn/rhn.conf' );
  } elsif (not PXT::Config->get('server.satellite', 'rhn_parent')) {
    RHN::SatInstall->write_config( { 'server.satellite.rhn_parent' => 'satellite.rhn.redhat.com' },
				   '/etc/sysconfig/rhn-satellite-prep/etc/rhn/rhn.conf' );
  }

  # We don't actually want to set these yet - only if the user chooses to restart.
  delete $config_opts->{webDOTis_monitoring_backend};
  delete $config_opts->{webDOTis_monitoring_scout};

  untaint_hashref($config_opts);

  RHN::SatInstall->write_config($config_opts,
				'/etc/sysconfig/rhn-satellite-prep/satellite-local-rules.conf');
  RHN::SatInstall->satcon_deploy(-tree => '/etc/sysconfig/rhn-satellite-prep/etc/rhn',
				 -dest => '/etc/rhn');

  my $redir = $pxt->uri;

  if ($restart_required) {
    my $opts = join('&', map { $_ . '=' . $redir_opts{$_} } keys %redir_opts);
    $redir = "/internal/satellite/config/restart_required.pxt?$opts";
  }

  my $url = $pxt->derelative_url($redir);
  $pxt->redirect($url);

  return;
}

sub satinstall_confirm_restart {
  my $pxt = shift;
  my %params = @_;

  my $pform = build_restart_form($pxt, %params);
  my $rform = $pform->realize;
  undef $pform;

  my $style = new Sniglets::Forms::Style;
  my $html = $rform->render($style);

  return $html;
}

sub build_restart_form {
  my $pxt = shift;
  my %attr = @_;

  my $form = new RHN::Form::ParsedForm(name => 'Restart Spacewalk',
				       label => 'restart_satellite',
				       action => $attr{action},
				      );

  my $enable_ssl = $pxt->dirty_param('enable_ssl');

  if (defined $enable_ssl) {
    $form->add_widget(literal => { name => 'SSL',
				   value => $enable_ssl ? 'Enable' : 'Disable' });
    $form->add_widget(hidden => { name => 'enable_ssl',
				  value => $enable_ssl });
  }

  my $is_monitoring_backend = $pxt->dirty_param('webDOTis_monitoring_backend');

  if (defined $is_monitoring_backend) {
    $form->add_widget(literal => { name => 'Monitoring Backend',
				   value => $is_monitoring_backend ? 'Enable' : 'Disable' });
    $form->add_widget(hidden => { name => 'webDOTis_monitoring_backend',
				  value => $is_monitoring_backend });
  }

  my $is_monitoring_scout = $pxt->dirty_param('webDOTis_monitoring_scout');

  if (defined $is_monitoring_scout) {
    $form->add_widget(literal => { name => 'Monitoring Scout',
				   value => $is_monitoring_scout ? 'Enable' : 'Disable' });
    $form->add_widget(hidden => { name => 'webDOTis_monitoring_scout',
				  value => $is_monitoring_scout });
  }

  $form->add_widget(hidden => {name => 'pxt:trap',
			       value => 'rhn:satinstall_restart_cb'});
  $form->add_widget(submit => {name => 'Restart'});

  return $form;
}

sub satinstall_restart_cb {
  my $pxt = shift;

  my $pform = build_restart_form($pxt);
  my $rform = $pform->prepare_response;
  undef $pform;

  my $errors = Sniglets::Forms::load_params($pxt, $rform);

  if (@{$errors}) {
    foreach my $error (@{$errors}) {
      $pxt->push_message(local_alert => $error);
    }
    return;
  }

  my $config_opts;

  my $ssl_was_enabled = PXT::Config->get('ssl_available') ? 1 : 0;
  my $ssl_is_enabled = $pxt->dirty_param('enable_ssl');

  if (defined $ssl_is_enabled and
      $ssl_was_enabled != ($ssl_is_enabled ? 1 : 0)) {
    $config_opts->{webDOTssl_available} = $ssl_is_enabled;
  }

  my $was_monitoring_backend = PXT::Config->get('is_monitoring_backend') ? 1 : 0;
  my $is_monitoring_backend = $pxt->dirty_param('webDOTis_monitoring_backend');

  if (defined $is_monitoring_backend and
      $was_monitoring_backend != ($is_monitoring_backend ? 1 : 0)) {
    $config_opts->{webDOTis_monitoring_backend} = $is_monitoring_backend;
    if ($is_monitoring_backend) {
      RHN::SatInstall->setup_monitoring_sysv_step('Monitoring');
      RHN::SatInstall->enable_notification_cron();
    }
    else {
      RHN::SatInstall->setup_monitoring_sysv_step('Monitoring', 'uninstall');
      RHN::SatInstall->disable_notification_cron();
    }
  }

  my $was_monitoring_scout = PXT::Config->get('is_monitoring_scout') ? 1 : 0;
  my $is_monitoring_scout = $pxt->dirty_param('webDOTis_monitoring_scout');

  if (defined $is_monitoring_scout and
      $was_monitoring_scout != ($is_monitoring_scout ? 1 : 0)) {
    $config_opts->{webDOTis_monitoring_scout} = $is_monitoring_scout;
    if ($is_monitoring_scout) {
      RHN::SatInstall->setup_monitoring_sysv_step('MonitoringScout');
    }
    else {
      RHN::SatInstall->setup_monitoring_sysv_step('MonitoringScout', 'uninstall');
    }
  }

  untaint_hashref($config_opts);

  RHN::SatInstall->write_config($config_opts,
				'/etc/sysconfig/rhn-satellite-prep/satellite-local-rules.conf');
  RHN::SatInstall->satcon_deploy(-tree => '/etc/sysconfig/rhn-satellite-prep/etc/rhn',
				 -dest => '/etc/rhn');

  my $redir = '/internal/satellite/config/restart_in_progress.pxt';
  RHN::SatInstall->restart_satellite(-delay => 5);

  my $url = $pxt->derelative_url($redir);
  $pxt->redirect($url);
}

sub is_fqdn {
  my $fqdn = shift;

  return 0 unless $fqdn;

  my @parts = split(/\./, $fqdn);
  my @non_empty_parts = grep { $_ } @parts;

  return 0
    unless (scalar @parts >= 3 and scalar @parts == scalar @non_empty_parts);

  return 1;
}

sub check_proxy_url_format {
  my $pxt = shift;
  my $proxy = shift;

  my $hostname;

  if ($proxy =~ /([^:\/]*)(:\d+)?/) {
    $hostname = $1; # Check the hostname seperately
    $proxy = "$hostname" . ($2 || ':8080');
  }
  else {
    $pxt->push_message(local_alert => "<strong>$proxy</strong> does not appear to be valid.");
    return;
  }

  unless (is_fqdn($hostname)) {
    $pxt->push_message(local_alert => "<strong>$hostname</strong> does not appear to be valid.");
    return;
  }

  return $proxy;
}

1;
