#!/usr/bin/python
#

import time
import string
import config

class Log:
    """
    attempt to log all interesting stuff, namely, anything that hits
    the network any error messages, package installs, etc
    """ # " emacs sucks
    def __init__(self):
        self.app = "rhn client"
        self.cfg = config.initUp2dateConfig()
        

    def log_debug(self, *args):
        if self.cfg["debug"] > 1:
            apply(self.log_me, args, {})
            if self.cfg["isatty"]:
                print "D:", string.join(map(lambda a: str(a), args), " ")
                
    def log_me(self, *args):
        self.log_info = "[%s] %s" % (time.ctime(time.time()), self.app)
	s = ""
        for i in args:
            s = s + "%s" % (i,)
        self.write_log(s)

    def trace_me(self):
        self.log_info = "[%s] %s" % (time.ctime(time.time()), self.app)
        import traceback
        x = traceback.extract_stack()
        bar = string.join(traceback.format_list(x))
        self.write_log(bar)

    def write_log(self, s):
        
        log_name = self.cfg["logFile"] or "%s//var/log/up2date" % config.PREFIX
        log_file = open(log_name, 'a')
        msg = "%s %s\n" % (self.log_info, str(s))
        log_file.write(msg)
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
