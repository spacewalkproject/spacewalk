#
# Copyright (c) 2013 Red Hat, Inc.
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

package PXT::Apache24Config;

use Apache2::Util ();
use Apache2::RequestUtil ();
use Apache2::ServerUtil ();
use Apache2::ServerRec ();
use Apache2::Process ();
use Apache2::Const qw/:common AUTHZ_PROVIDER_VERSION AUTHZ_PROVIDER_GROUP
                              AUTH_INTERNAL_PER_CONF
                              AUTHZ_GRANTED AUTHZ_DENIED OK/;
use PXT::ApacheAuth;

Apache2::RequestUtil::register_auth_provider(
                        Apache2::ServerUtil->server->process->pool,
                        Apache2::Const::AUTHZ_PROVIDER_GROUP, "acl",
                        Apache2::Const::AUTHZ_PROVIDER_VERSION,
                        \&acl_check_authorization,
                        \&parse_require_line,
                        Apache2::Const::AUTH_INTERNAL_PER_CONF);

sub parse_require_line {
        my $parms = shift; # Apache2::CmdParms
        my $require_line = shift;

        # Return non-empty string if there is an error in require_line, othewise
        # return empty string.
	# acl could be any string, we check syntax in runtime
        return "";
}

sub acl_check_authorization {
        my $r = shift;
        my $require_args = shift;

        # print acl to log.
        #$r->log_error($require_args);
        PXT::ApacheAuth::handler($r);
        return (PXT::ApacheAuth::authz_handler($r, $require_args) == Apache2::Const::OK ?
                Apache2::Const::AUTHZ_GRANTED : Apache2::Const::AUTHZ_DENIED);

}


1;
