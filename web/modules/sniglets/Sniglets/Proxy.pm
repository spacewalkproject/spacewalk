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

### THIS SHOULD ALL BE DEPRECATED SOMEDAY, EXCEPT THERE MIGHT BE OLD PROXIES OUT THERE :(

use strict;

package Sniglets::Proxy;

use RHN::Exception;
use MIME::Lite;
use MIME::Base64;
use RHN::Mail;

sub register_xmlrpc {
  my $class = shift;
  my $pxt = shift;

  $pxt->register_xmlrpc('proxy.activate_proxy', \&activate_proxy_xmlrpc);
  $pxt->register_xmlrpc('proxy.send_debug_data', \&send_debug_data);
}

sub activate_proxy_xmlrpc {
  my $pxt = shift;
  my $system_id = shift;
  my $version = shift;

  my $transaction = RHN::DB->connect();
  $transaction->nest_transactions();


  my $server;
  eval {
    $server = RHN::Server->lookup_by_cert($system_id);
  };

  if ($@) {
    $pxt->rpc_fault('proxy_invalid_systemid');
  }

  eval {
    unless ($server->has_entitlement('enterprise_entitled')) {
      $transaction = $server->entitle_server('enterprise_entitled');
    }
    $transaction->commit;
  };

  my $E = $@;
  if ($E) {
    $transaction->nested_rollback();

    if (ref $E and catchable($E) and $E->is_rhn_exception('servergroup_max_members')) {
      $pxt->rpc_fault("proxy_no_enterprise_entitlements");
    }

    # couldn't handle it; ISE and report
    throw $E;
  }

  eval {
    $server->activate_proxy(version => $version);
  };

  $E = $@;
  if ($E) {
    $transaction->nested_rollback();

    if (ref $E and catchable($E)) {
      if ($E->is_rhn_exception('channel_family_no_subscriptions')) {
	$pxt->rpc_fault('proxy_no_channel_entitlements');
      }
      elsif ($E->is_rhn_exception('proxy_no_proxy_child_channel')) {
	$pxt->rpc_fault('proxy_no_proxy_child_channel');
      }
    }

    # couldn't handle it; ISE and report
    throw $E;
  }

  $transaction->nested_commit();

  return 1;
}

sub send_debug_data {
  my $pxt = shift;
  my $debug_file = MIME::Base64::decode_base64(shift);

  my $to = PXT::Config->get('traceback_mail');

  my $mime = MIME::Lite->new(From => "Spacewalk <rhn-admin\@rhn.redhat.com>",
			     To => $to,
			     Subject => "RHN Proxy Debug Dump",
			     Type => "application/octet-stream",
			     Data => $debug_file,
			     Encoding => "base64",
			     Filename => "proxy-debug.tar.bz2");

  RHN::Mail->send_raw($mime->as_string);

  return 1;
}

1;
