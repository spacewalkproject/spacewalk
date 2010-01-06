#
# Copyright (c) 2008--2010 Red Hat, Inc.
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

package Sniglets::Probes;

use Data::Dumper;

use RHN::Command;
use RHN::ContactGroup;
use RHN::DataSource;
use RHN::Exception;
use RHN::Probe;
use RHN::Server;

use RHN::Form::Widget::Checkbox;
use RHN::Form::Widget::Hidden;
use RHN::Form::Widget::Literal;
use RHN::Form::Widget::Password;
use RHN::Form::Widget::Select;
use RHN::Form::Widget::Submit;
use RHN::Form::Widget::Text;

use PXT::Utils;
use PXT::HTML;

use Sniglets::Forms;
use Sniglets::Navi::Style;

1;
