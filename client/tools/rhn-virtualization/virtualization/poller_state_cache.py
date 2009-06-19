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

import sys
sys.path.append("/usr/share/rhn/")

import os
import cPickle
import time
import traceback

###############################################################################
# Constants
###############################################################################

CACHE_DATA_PATH = '/var/cache/rhn/virt_state.cache'
CACHE_EXPIRE_SECS = 60 * 60 * 6   # 6 hours, in seconds

###############################################################################
# PollerStateCache Class
###############################################################################

class PollerStateCache:

    ###########################################################################
    # Public Interface
    ###########################################################################

    def __init__(self, domain_data, debug = 0):
        """
        This method creates a new poller state based on the provided domain 
        list.  The domain_data list should be in the form returned from 
        poller.poll_hypervisor.  That is,

             { uuid : { 'name'        : '...',
                        'uuid'        : '...',
                        'virt_type'   : '...',
                        'memory_size' : '...',
                        'vcpus'       : '...',
                        'state'       : '...' }, ... }
        """
        self.__debug = debug

        # Start by loading the old state, if necessary.
        self._load_state()
        self.__new_domain_data = domain_data

        # Now compare the given domain_data against the one loaded in the old
        # state.
        self._compare_domain_data()

        self._log_debug("Added: %s"    % repr(self.__added))
        self._log_debug("Removed: %s"  % repr(self.__removed))
        self._log_debug("Modified: %s" % repr(self.__modified))

    def save(self):
        """
        Updates the cache on disk with the latest domain data.
        """
        self._save_state()

    def is_expired(self):
        """
        Returns true if this cache is expired.
        """
        if self.__expire_time is None:
            return False
        else:
            return long(time.time()) >= self.__expire_time

    def is_changed(self):
        return self.__added or self.__removed or self.__modified

    def get_added(self):
        """
        Returns a list of uuids for each domain that has been added since the
        last state poll.
        """
        return self.__added

    def get_modified(self):
        """
        Returns a list of uuids for each domain that has been modified since 
        the last state poll.
        """
        return self.__modified

    def get_removed(self):
        """
        Returns a list of uuids for each domain that has been removed since 
        the last state poll.
        """
        return self.__removed

    ###########################################################################
    # Helper Methods
    ###########################################################################

    def _load_state(self):
        """
        Loads the last hypervisor state from disk.
        """
        # Attempt to open up the cache file.
        cache_file = None
        try:
            cache_file = open(CACHE_DATA_PATH, 'r')
        except IOError, ioe:
            # Couldn't open the cache file.  That's ok, there might not be one.
            # We'll only complain if debugging is enabled.
            self._log_debug("Could not open cache file '%s': %s" % \
                               (CACHE_DATA_PATH, str(ioe)))
    
        # Now, if a previous state was cached, load it.
        state = {}
        if cache_file:
            try:
                state = cPickle.load(cache_file)
            except cPickle.PickleError, pe:
                # Strange.  Possibly, the file is corrupt.  We'll load an empty
                # state instead.
                self._log_debug("Error occurred while loading state: %s" % \
                                    str(pe))
            except EOFError:
                self._log_debug("Unexpected EOF. Probably an empty file.")
                cache_file.close()

            cache_file.close()
    
        if state:
            self._log_debug("Loaded state: %s" % repr(state))

            self.__expire_time = long(state['expire_time'])

            # If the cache is expired, set the old data to None so we force
            # a refresh.
            if self.is_expired():
                self.__old_domain_data = None
                os.unlink(CACHE_DATA_PATH)
            else:
                self.__old_domain_data = state['domain_data']
                
        else:
            self.__old_domain_data = None
            self.__expire_time     = None

    def _save_state(self):
        """
        Saves the given polling state to disk.
        """
        # First, ensure that the proper parent directory is created.
        cache_dir_path = os.path.dirname(CACHE_DATA_PATH)
        if not os.path.exists(cache_dir_path):
            os.makedirs(cache_dir_path, 0700)
    
        state = {}
        state['domain_data'] = self.__new_domain_data
        if self.__expire_time is None or self.is_expired():
            state['expire_time'] = long(time.time()) + CACHE_EXPIRE_SECS
        else:
            state['expire_time'] = self.__expire_time

        # Now attempt to open the file for writing.  We'll just overwrite
        # whatever's already there.  Also, let any exceptions bounce out.
        cache_file = open(CACHE_DATA_PATH, "wb")
        cPickle.dump(state, cache_file)
        cache_file.close()

    def _compare_domain_data(self):
        """
        Compares the old domain_data to the new domain_data.  Returns a tuple 
        of lists, relative to the new domain_data:
    
            (added, removed, modified)
        """
        self.__added    = {}
        self.__removed  = {}
        self.__modified = {}
    
        # First, figure out the modified and added uuids.
        if self.__new_domain_data:
            for (uuid, new_properties) in self.__new_domain_data.items():
                if not self.__old_domain_data or \
                    not self.__old_domain_data.has_key(uuid):

                    self.__added[uuid] = self.__new_domain_data[uuid]
                else:
                    old_properties = self.__old_domain_data[uuid]
                    if old_properties != new_properties:
                        self.__modified[uuid] = self.__new_domain_data[uuid]
    
        # Now, figure out the removed uuids.
        if self.__old_domain_data:
            for uuid in self.__old_domain_data.keys():
                if not self.__new_domain_data or \
                    not self.__new_domain_data.has_key(uuid):

                    self.__removed[uuid] = self.__old_domain_data[uuid]
    
    def _log_debug(self, msg, include_trace = 0):
        if self.__debug:
            print "DEBUG: " + str(msg)
            if include_trace:
                e_info = sys.exc_info()
                traceback.print_exception(e_info[0], e_info[1], e_info[2])


