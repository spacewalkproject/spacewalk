#
# Copyright (c) 2011--2012 Red Hat, Inc.
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

package RHN::DBI;

use strict;
use warnings FATAL => 'all';
use DBI ();
use PXT::Config ();
use Carp ();

my %DEFAULT_ATTRIBUTES = (
	RaiseError => 1,
	PrintError => 0,
	Taint => 0,
	AutoCommit => 0,
	FetchHashKeyName => 'NAME_uc',
	pg_enable_utf8 => 1,
);

# Return a DBI connect parameters, based on data in
# /etc/rhn/rhn.conf. It will get the configuration values once
# and use them for subsequent calls.
my ($DSN, $LOGIN, $PASSWORD);
sub _get_dbi_connect_parameters {
	if (not defined $DSN) {
		my $backend = PXT::Config->get("db_backend");
		my $dbname = PXT::Config->get("db_name");
		if ($backend eq "oracle") {
			$DSN = "dbi:Oracle:$dbname";

			my $nls_lang = PXT::Config->get('server', 'nls_lang');
			if (defined $nls_lang and $nls_lang ne '') {
				$ENV{NLS_LANG} = $nls_lang;
			}
		} else {
			$DSN = "dbi:Pg:dbname=$dbname";
			my $host = PXT::Config->get("db_host");
			if (defined $host and $host ne '') {
				$DSN .= ";host=$host";
				my $port = PXT::Config->get("db_port");
				if (defined $port and $port ne '') {
					$DSN .= ";port=$port";
				}
			}
		}
		$LOGIN = PXT::Config->get("db_user");
		$PASSWORD = PXT::Config->get("db_password");
	}

	return ($DSN, $LOGIN, $PASSWORD, { %DEFAULT_ATTRIBUTES });
}

# Do a connect via DBI to database configured in /etc/rhn/rhn.conf.
sub connect {
	my $class = shift;
	if (@_) {
		Carp::confess "The RHN::DBI::connect does not accept any parameters.\n";
	}
	return DBI->connect(_get_dbi_connect_parameters());
}

1;

