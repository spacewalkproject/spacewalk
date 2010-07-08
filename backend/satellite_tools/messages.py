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
#
# $Id$
""" Red Hat Network Management Satellite Synchronization Tool Messages

    Copyright (c) 2002-2005 Red Hat, Inc.
    All rights reserved.
"""

failed_step = """
ERROR: executing step %s. Error is:
%s
"""

file_dir_error = """
ERROR: there was a problem accessing the channel data from your temporary
       repository. Did you migrate all of the data from the channel ISOs
       do this directory? If so, please recheck the channels ISOs, ensure
       that you have them all, and then iteratively remount and repopulate
       the temporary repository (%s).
"""

syncer_error = """
ERROR: there was a problem synchronizing the information.
       Error message: %s
"""

iss_not_available = """
ERROR: The Server listed within iss-parent is not configured for ISS 
       capability.
       Please review your configuration before trying again.
"""
            
parent_channel_error = """
ERROR: a child-channel cannot be synced without its parent being synced as
       well. A parent needs to be either (a) previously synced or (b) synced
       in tandem with the desired child-channel. Missing parents for this
       transaction:
       %s
"""

invalid_channel_family_error = """
ERROR: you are not entitled to sync a channel in this set of channels.
Please contact your sales rep or RHN contact
%s"""

missing_user = "*** ERROR: user '%s' doesn't exist. Cannot set permissions properly."

missing_group = "*** ERROR: group '%s' doesn't exist. Cannot set permissions properly."

not_enough_diskspace = "  ERROR: not enough free space (%s KB) on device."

package_fetch_successful = "    %3d/%s Fetch successful: %s (%s bytes)" 
package_fetch_extinct =    "    %3d/%s Extinct package:  %s" 
package_fetch_failed  =    "    %3d/%s Fetch unsuccessful: %s"
package_fetch_summary =         "   RPM fetch summary: %s"
package_fetch_summary_success = "       success: %d"
package_fetch_summary_failed =  "       failed:  %d"
package_fetch_summary_extinct = "       extinct: %d"

package_parsing = "   Retrieving / parsing *relevant* package metadata: %s (%s)"
erratum_parsing = "   Retrieving / parsing errata data: %s (%s)"
kickstart_parsing = "   Retrieving / parsing kickstart data: %s (%s)"
kickstart_downloading = "   Retrieving / parsing kickstart tree files: %s (%s)"
package_importing = "   Importing *relevant* package metadata: %s (%s)"
warning_slow = "   * WARNING: this may be a slow process."
link_channel_packages = "Linking packages to channels"
errata_importing = "   Importing *relevant* errata: %s (%s)"
kickstart_import_nothing_to_do = "   No new kickstartable tree to import"
kickstart_importing = "Importing kickstartable trees (%d)"
kickstart_imported = "Imported kickstartable trees (%d)"
