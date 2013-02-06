#
# $Id$

import time
import config
import traceback

class Log:
    """
    attempt to log all interesting stuff, namely, anything that hits
    the network any error messages, package installs, etc
    """ # " emacs sucks
    def __init__(self):
        self.app = "up2date"
        self.cfg = config.initUp2dateConfig()
        self.log_info = ''
    
    def set_app_name(self, name):
        self.app = str(name)
    
    def log_debug(self, *args):
        if self.cfg["debug"] > 1:
            self.log_me("D: ", *args)
    
    def log_me(self, *args):
        """General logging function.
        Eg: log_me("I am a banana.")
        
        """
        self.log_info = "[%s] %s" % (time.ctime(time.time()), self.app)
        s = u""
        for i in args:
            if not isinstance(i, unicode):
                # we really need unicode(str(i)) here, because i can be anything
                # from string or int to list, dict or even class
                i = unicode(str(i), 'utf-8')
            s += i
        if self.cfg["debug"] > 1:
            print s
        self.write_log(s)

    def trace_me(self):
        self.log_info = "[%s] %s" % (time.ctime(time.time()), self.app)
        x = traceback.extract_stack()
        msg = ''.join(traceback.format_list(x))
        self.write_log(msg)

    def log_exception(self, logtype, value, tb):
        self.log_info = "[%s] %s" % (time.ctime(time.time()), self.app)
        output = ["\n"] # Accumulate the strings in a list
        output.append("Traceback (most recent call last):\n")
        output = output + traceback.format_list(traceback.extract_tb(tb))
        output.append("%s: %s\n" % (logtype, value))
        self.write_log("".join(output))
    
    def write_log(self, s):
        
        log_name = self.cfg["logFile"] or "/var/log/up2date"
        log_file = open(log_name, 'a')
        msg = u"%s %s\n" % (self.log_info, s)
        log_file.write(msg.encode('utf-8'))
        log_file.flush()
        log_file.close()

def initLog():
    global log
    try:
        log = log
    except NameError:
        log = None

    if log == None:
        log = Log()

    return log
