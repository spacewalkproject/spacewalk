#!/usr/bin/python
#will clean up a satellite deleting all extra things not needed
from config import *
import sys
key = login()

#clean up orgs
if False:
   list = client.org.listOrgs(key)
   for i in range(0, len(list)):
      t = list.pop()
      print "deleting org: " + str(t['id'])
      try: 
         if t['id'] != 1:
            client.org.delete(key, t['id'])
      except:
         print sys.exc_info()[0]


#clean up users
if False:
   list = client.user.listUsers(key)
   for i in range(0, len(list)):
      t = list.pop()
      if t['id'] != 1:
         print "deleting user: " + str(t['login'])
         client.user.delete(key, t['login'])

if False:
   list = client.kickstart.listKickstarts(key)
   for i in list:
      print "deleting kickstart" + i['label']
      client.kickstart.deleteProfile(key, i['label'])


if False:
   list = client.activationkey.listActivationKeys(key)
   for i in list:
      print "deleting activation key" + i['key']
      client.activationkey.delete(key, i['key'])

if False:
   list = client.systemgroup.listAllGroups(key)
   for i in list:
      print "deleting group: " + i['name']
      client.systemgroup.delete(key, i['name'])

if True: 
   list = client.kickstart.tree.list(key)
   print list
   for i in list:
       print "deleting Distro " + i['label']
       client.kickstart.tree.deleteTreeAndProfiles(key, i['label'])

if True:
   for j in range(1,3):
      list = client.channel.listSoftwareChannels(key)
      for i in list:
         print "deleting channel:" + i['name']
         try: 
            client.channel.software.delete(key, i['label'])
         except:
            print sys.exc_info()[0]
