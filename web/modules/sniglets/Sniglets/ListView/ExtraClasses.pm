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

package Sniglets::ListView::ExtraClasses;

# these are purposely at the bottom because, otherwise,
# Apache::StatINC gets confused and doesn't reload the file.  Also, if
# you change anything below, restart your httpd's, as StatINC doesn't
# fix this.

use Class::Struct 'Sniglets::ListView::ParsedView' =>
  { mode => '$', set_label => '$', set_acl => '$', columns => '$', empty_list_message => '$', formvars => '$', actions => '$' };
use Class::Struct 'Sniglets::ListView::ParsedColumn' =>
  { name => '$', label => '$', sort_by => '$', align => '$', width => '$', url => '$', acl => '$', nowrap => '$', htmlify => '$', content => '$', pre_content => '$', post_content => '$', is_date => '$'};
use Class::Struct 'Sniglets::ListView::ParsedAction' =>
  { name => '$', label => '$', class => '$', url => '$', acl => '$'};
use Class::Struct 'Sniglets::ListView::ParsedFormvar' =>
  { name => '$', type => '$', value => '$' };


1;
