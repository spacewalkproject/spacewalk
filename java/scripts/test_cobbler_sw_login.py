#!/usr/bin/python
import sys
from xmlrpclib import Server

sys.path.append('/usr/share/rhn')
try:
   from common import initCFG, CFG
except:
   print "Couldn't load needed libs, Are you sure you are running this on a satellite?"
   sys.exit(1)

initCFG()
user = 'taskomatic_user'
passw = CFG.SESSION_SECRET_1

c = Server('http://localhost/rpc/api')
print("Satellite auth.checkAuthToken (should be 1): ")
print( c.auth.checkAuthToken(user, passw))

print("Trying cobbler login (should be a random token): ")
c = Server('http://localhost/cobbler_api')
print(c.login(user, passw))
