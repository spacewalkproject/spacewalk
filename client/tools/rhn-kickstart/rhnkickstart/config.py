#
# Copyright (c) 2008--2013 Red Hat, Inc.
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
# Configuration option for RHN kickstart functionality.

# Number of seconds we're willing to wait for a guest kickstart to "start".
# (i.e. the domain ID appears in the list of running domains)
GUEST_KS_START_THRESHOLD = 5 * 60 # 5 minutes

# Number of seconds we're willing to wait for a guest kickstart to "finish".
# The process will end much faster than this in normal operation, this is just
# a ceiling time at which we assume that something is wrong with the kickstart
# and report failure back to the satellite.
GUEST_KS_END_THRESHOLD = 2 * 60 * 60 # 2 hours

