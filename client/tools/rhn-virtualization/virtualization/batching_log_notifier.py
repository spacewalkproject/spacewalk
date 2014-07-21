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
# This module provides the BatchingLogNotifier class, which has the ability to
# queue up log messages and periodically forward them in a batch to the server.
#

from threading import Thread, Event, Lock

###############################################################################
# Constants
###############################################################################

POLL_INTERVAL = 5  # Seconds

###############################################################################
# BatchingLogNotifier Class
###############################################################################

class BatchingLogNotifier:

    def __init__(self, batch_notify_handler):
        self.__log_message_queue = LockableLogMessageQueue()
        self.__notify_thread = NotifyThread(self.__log_message_queue,
                                            batch_notify_handler)

    def add_log_message(self, log_message):
        self.__log_message_queue.lock()
        try:
            self.__log_message_queue.add(log_message)
        finally:
            self.__log_message_queue.unlock()

    def start(self):
        self.__notify_thread.start()

    def stop(self):
        self.__notify_thread.stop()
        if self.__notify_thread.isAlive():
            self.__notify_thread.join()

###############################################################################
# LogQueue Class
###############################################################################

class LockableLogMessageQueue:

    def __init__(self):
        self.__log_message_queue = []
        self.__queue_lock = Lock()

    def lock(self):
        self.__queue_lock.acquire()

    def unlock(self):
        self.__queue_lock.release()

    def add(self, log_message):
        self.__log_message_queue.append(log_message)

    def pop(self):
        first_item = self.__log_message_queue[0]
        self.__log_message_queue.remove(first_item)
        return first_item

    def is_empty(self):
        return len(self.__log_message_queue) == 0

###############################################################################
# BatchNotifyHandler Class
###############################################################################

class BatchNotifyHandler:
    """
    This class provides a generic mechanism for processing logging callbacks.
    This is just a stub class, which should be inherited by anyone who wants
    to respond to logging events.
    """

    def __init__(self):
        pass

    def batch_began():
        pass

    def log_message_discovered(log_message):
        pass

    def batch_ended():
        pass

###############################################################################
# NotifyThread Class
###############################################################################

class NotifyThread(Thread):

    ###########################################################################
    # Public Interface
    ###########################################################################

    def __init__(self, log_message_queue, batch_notify_handler):
        Thread.__init__(self)
        self.__log_message_queue = log_message_queue
        self.__batch_notify_handler = batch_notify_handler
        self.__stop_event = Event()

    def run(self):
        # First, clear the stop event in case it was already set.
        self.__stop_event.clear()

        # Enter the main loop, flushing the queue every interval.
        while not self.__stop_event.isSet():
            self.__flush_log_message_queue()
            self.__stop_event.wait(POLL_INTERVAL)

        # We've been signaled to stop, but flush the queue one more time before
        # exiting.
        self.__flush_log_message_queue()

    def stop(self):
        self.__stop_event.set()

    ###########################################################################
    # Helper Methods
    ###########################################################################

    def __flush_log_message_queue(self):
        self.__log_message_queue.lock()
        try:
            if not self.__log_message_queue.is_empty():
                self.__batch_notify_handler.batch_began()
                while not self.__log_message_queue.is_empty():
                    log_message = self.__log_message_queue.pop()
                    self.__batch_notify_handler.log_message_discovered(
                        log_message)
                self.__batch_notify_handler.batch_ended()
        finally:
            self.__log_message_queue.unlock()

if __name__ == "__main__":
    notifier = BatchingLogNotifier()
    notifier.start()

