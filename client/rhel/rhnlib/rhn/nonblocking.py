#
#
#
# $Id$

import select
import fcntl
import os

class NonBlockingFile:
    def __init__(self, fd):
        # Keep a copy of the file descriptor
        self.fd = fd
        fcntl.fcntl(self.fd.fileno(), fcntl.F_SETFL, os.O_NDELAY)
        # Set the callback-related stuff
        self.read_fd_set = []
        self.write_fd_set = []
        self.exc_fd_set = []
        self.user_data = None
        self.callback = None

    def set_callback(self, read_fd_set, write_fd_set, exc_fd_set, 
            user_data, callback):
        self.read_fd_set = read_fd_set
        # Make the objects non-blocking
        for f in self.read_fd_set:
            fcntl.fcntl(f.fileno(), fcntl.F_SETFL, os.O_NDELAY)
            
        self.write_fd_set = write_fd_set
        self.exc_fd_set = exc_fd_set
        self.user_data = user_data
        self.callback = callback

    def read(self, amt=0):
        while 1:
            status_changed = 0
            readfds = self.read_fd_set + [self.fd]
            writefds = self.write_fd_set
            excfds = self.exc_fd_set
            print "Calling select", readfds
            readfds, writefds, excfds = select.select(readfds, writefds, excfds)
            print "Select returned", readfds, writefds, excfds
            if self.fd in readfds:
                # Our own file descriptor has changed status
                # Mark this, but also try to call the callback with the rest
                # of the file descriptors that changed status
                status_changed = 1
                readfds.remove(self.fd)
            if self.callback and (readfds or writefds or excfds):
                self.callback(readfds, writefds, excfds, self.user_data)
            if status_changed:
                break
        print "Returning"
        return self.fd.read(amt)

    def write(self, data):
        return self.fd.write(data)

    def __getattr__(self, name):
        return getattr(self.fd, name)

def callback(r, w, e, user_data):
    print "Callback called", r, w, e
    print r[0].read()

if __name__ == '__main__':
    import socket

    s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    s.connect(("localhost", 5555))
    f = s.makefile()
    ss = NonBlockingFile(f)

    s2 = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    s2.connect(("localhost", 5556))
    f = s2.makefile()
    ss.set_callback([f], [], [], None, callback)

    xx = ss.read()
    print len(xx)
