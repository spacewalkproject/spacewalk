#
# Copyright (c) 2009 Red Hat, Inc.
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

# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl test.pl'

#########################

# change 'tests => 1' to 'tests => last_test_to_print';

use Test;
BEGIN { plan tests => 1 };
use NOCpulse::AbstractObjectRepository;
use NOCpulse::BlockingDBMNamespace;
use NOCpulse::BlockingFileNamespace;
use NOCpulse::DBMObjectRepository;
use NOCpulse::INIObjectRepository;
use NOCpulse::MultiFileObjectRepository;
use NOCpulse::Namespace;
use NOCpulse::NSObject;
use NOCpulse::Object;
use NOCpulse::ObjectProxy;
use NOCpulse::ObjectProxyServer;
use NOCpulse::PersistentObject;
use NOCpulse::SharedBlockingNamespace;
ok(1); # If we made it this far, we're ok.

#########################

# Insert your test code below, the Test module is use()ed here so read
# its man page ( perldoc Test ) for help writing this test script.

