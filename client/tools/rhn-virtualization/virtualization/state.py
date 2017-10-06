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

from virtualization.constants import StateType

###############################################################################
# Classes
###############################################################################

class State:
    """
    This class represents the state of a virtual instance.  It provides
    abstraction to categorize the state into running, stopped, paused, or
    crashed.
    """

    def __init__(self, state_type):
        """
        Create a new state.  If state_type is None, this state is assumed to be
        stopped.  If state_type is not None, it must be a StateType type.
        """
        self.__state_type = state_type

    def get_state_type(self):
        """
        Returns the state type used to create this instance.
        """
        return self.__state_type

    def is_running(self):
        """
        Returns true if this object represents a running state.
        """
        return self.__state_type == StateType.NOSTATE or \
               self.__state_type == StateType.RUNNING or \
               self.__state_type == StateType.BLOCKED or \
               self.__state_type == StateType.SHUTDOWN

    def is_paused(self):
        """
        Returns true if this object represents a paused instance.
        """
        return self.__state_type == StateType.PAUSED

    def is_stopped(self):
        """
        Returns true if this object represents a stopped instance.
        """
        return self.__state_type == None or \
               self.__state_type == StateType.SHUTOFF

    def is_crashed(self):
        """
        Returns true if this object represents a crashed instance.
        """
        return self.__state_type == StateType.CRASHED

