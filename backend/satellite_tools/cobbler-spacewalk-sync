#!/usr/bin/python
import xmlrpclib
import pprint
import sys
import re
from optparse import OptionParser
from cobbler import api as cobbler_api

#############################################################################################



#### Command line parser
parser = OptionParser()
parser.add_option('-s','--spacewalk',dest='SATELLITE_HOST',default='localhost.localdomain',help='spacewalk host name')
parser.add_option('-u','--username',dest='login',default='admin',help='spacewalk username')
parser.add_option('-p','--password',dest='password',default='password',help='spacewalk password')
(options,args) = parser.parse_args()

#### Parsed options
SATELLITE_HOST = options.SATELLITE_HOST
login = options.login
password = options.password

#### Constants
SATELLITE_URL = "http://%s/rpc/api" % SATELLITE_HOST
#cobbler vm type to spacewalk vm type
vmmap = {"qemu":"none", "xenpv":"para_guest", "xenfv":"none", "vmware":"none", "vmwarew":"none", "auto":"none"}
overload_separator = '--'
url_parser = re.compile('^http://([^/:]+)(:(\d+))?(/.*)?$')

#### Debugging etc
pp = pprint.PrettyPrinter(indent=4)

#### Set up API handles
cobbler_api = cobbler_api.BootAPI()
client = xmlrpclib.Server(SATELLITE_URL, verbose=0)
key = client.auth.loginAndSkipIntegrationAuth(login, password)


#### Retrieve valid sw kickstart install types
rawInstallTypes = client.kickstart.tree.listKickstartInstallTypes(key)
installTypes = { "fedora_9":"Fedora 9", "rhel_2.1":"RHEL 2.1", "rhel_3":"RHEL 3", "rhel_4":"RHEL 4", "rhel_5":"RHEL 5" }
for itype in rawInstallTypes:
	installTypes[itype['label']] = itype['name']



##############################   Sync Distros/KS Trees   #################################
####
#### Presumption: Cobbler distro names have the format: <sw_channel_name><overload separator><ks_tree_name>
####              The overload separator (as opposed to a comma or whatever) are because cobbler
####              constrains composition of the name such that few special chars can
####              be used. Not sure why - not worth fighting over.
####
#### Presumption: We're only concerned with stuff that we have that spacewalk does not - 
####              if a ks tree exists in sw but not in cobbler, we presume it's a 
####              sw only tree.  Any creation of cobbler stuff in sw should have
####              been mirrored in cobbler by the UI if that was what the user intended
#### 
#### Issue: Spacwalk profile createion requires an "installType" which must be one of
####        rhel_2.1, rhel_3, rhel_4, rhel_5, fedora_9.  

##### Get list of existing channels
spacewalkChannelList = client.channel.listSoftwareChannels(key)
##### Then get list of existing kickstart trees
spacewalk_ks_trees = {}
for channel in spacewalkChannelList:
	for tree in client.kickstart.listKickstartableTrees(key,channel['channel_label']):
		tree['channel'] = channel  # carry this along as we'll need it
		#### in sw the distro key is globally unique - the underlying channel can change
		spacewalk_ks_trees[tree['label']] = tree


#####  get list if cobbler distros (== kickstart trees in spacewalk)
cobbler_distros = cobbler_api.distros()

#### Add/edit ks trees cobbler->sw
cobbler_distro_labels = []
for distro in cobbler_distros:
	keys = distro.name.split(overload_separator)
	if len(keys) != 2: ## keys[0] == channel name, keys[1] == distro/ks_tree name
		print "-- Distro "+distro.name+"' is not managed by spacewalk- ignoring"
	else:
		cobbler_distro_labels.append(keys[1]) #### save this for deletion scanning

		print "++ Cobbler distro "+distro.name+" maps to spacewalk channel '"+keys[0]+"' as tree '"+keys[1]+"' - synching ks tree:"

		#### NOTE: Presumption here is that the kernel image resides within the structure that's to be the kickstart repository structure.  If this
		####       is inappropriate, we'll need to consider some switches.

		basePath = distro.kernel.split('/image')[0]
		if spacewalk_ks_trees.has_key(keys[1]):
			print "++ Spacewalk already knows about distro "+distro.name+" - just synching values"
			# Carry the "installType" field from the definition in spacewalk
			client.kickstart.tree.editTree(key,keys[1],basePath,distro.kernel,keys[0],'fedora_9')
		else:
			print "++ Spacewalk doesn't have distro "+distro.name+" -- adding it"
			done = False
			while not done:
				print "!!! Is distro "+distro.name+" a (n)ew distro or was it (r)enamed from something else?: ",
				action = sys.stdin.readline().strip().lower()
				if action == 'n':
					#### Ask user to choose install type from list of types provided by (new) api call
					installTypeMap = {}
					index = 0
					for installType in installTypes:
						index = index +1
						installTypeMap[str(index)] = installType
						print "\t"+str(index)+") "+installTypes[installType]
					typeSelection = '0'
					while not installTypeMap.has_key(typeSelection):
						print "!!! Select Spacewalk install type for new distro "+distro.name+": ",
						typeSelection = str(sys.stdin.readline().strip().lower())
					installTypeKey = installTypeMap[typeSelection]
					installTypeDescription = installTypes[installTypeKey]
					print "++ Adding distro "+distro.name+" to spacewalk with install type "+installTypeDescription
					client.kickstart.tree.createTree(key,keys[1],basePath,distro.kernel,keys[0],installTypeKey)
					done = True
				elif action == 'r':
					swdistromap = {}
					index = 0
					for swdistro in spacewalk_ks_trees:
						index = index +1
						swdistromap[str(index)] = swdistro
						print "\t"+str(index)+") "+swdistro
					selection = 0
					while not swdistromap.has_key(selection):
						print "!!! Select previous name of "+distro.name+": ",
						selection = sys.stdin.readline().strip()
					print "++ Renaming spacewalk distro "+swdistromap[selection]+" to "+keys[1]
					client.kickstart.tree.renameTree(key,swdistromap[selection],keys[1])
					done = True

		
########################   Sync Profiles  #########################
####
####

#### Get list of spacewalk ks profiles
spacewalkProfiles = client.kickstart.listKickstarts(key)
spacewalk_profile_keys = {}
### Collect what's in sw now
for profile in spacewalkProfiles:
	spacewalk_profile_keys[profile['name']] = profile

#### Get list of cobbler ks profiles
cobbler_profile_keys = {}
cobbler_profiles = cobbler_api.profiles()
#### Map cobbler profiles to a dictionary for easy lookup
for profile in cobbler_profiles:
	cobbler_profile_keys[profile.name] = profile


#### Add/edit ks profiles 
for profile in cobbler_profiles:
	# Ensure the profile is spacwalk managed
	keys = profile.distro.split(overload_separator)
	if len(keys) != 2:
		print "-- Cobbler profile "+profile.name+" is not managed by spacewalk - ignoring"
	else:
		url_result = url_parser.search(profile.kickstart)
		if url_result != None:
			ks_host = url_result.group(1)
		else:
			print "!! Unable to determine kickstart host from profile - please update profile's kickstart and resync"
			ks_host = ''
		if spacewalk_profile_keys.has_key(profile.name):
			print "++ Spacewalk already knows about profile "+profile.name+" - just synching values"
			#### NOTE!!!  This lets distro deletes happen, but misses synching vm type and the ks host.  If it's
			#### important to sync these, we should just do an 'edit' api call that mirrors the create call.
			client.kickstart.setKickstartTree(key,profile.name,keys[1])
		else:
			print "++ Spacewalk doesn't have profile "+profile.name+" -- adding it."
			done = False
			while not done:
				print "!!! Is profile "+profile.name+" (n)ew, or was it (r)enamed from something else?: ",
				action = sys.stdin.readline().strip().lower()
				if action == 'n':
					print "++ Adding profile "+profile.name+" to spacewalk - root password is 'spacewalk' - please change this!"
					client.kickstart.createProfile(key,profile.name,vmmap[profile.virt_type],keys[1],ks_host,'password')
					done = True
				elif action == 'r':
					swprofilemap = {}
					index = 0
					for swprofile in spacewalk_profile_keys:
						index = index +1
						swprofilemap[str(index)] = swprofile
						print "\t"+str(index)+") "+swprofile
					selection = 0
					while not swprofilemap.has_key(selection):
						print "!!! Select previous name of "+profile.name+": ",
						selection = sys.stdin.readline().strip()
					print "++ Renaming spacewalk profile "+swprofilemap[selection]+" to "+profile.name
					client.kickstart.renameProfile(key,swprofilemap[selection],profile.name)
					done = True

#### Remove any dangling spacewalk profiles
#### Get updated list of spacewalk ks profiles
spacewalkProfiles = client.kickstart.listKickstarts(key)
spacewalk_profile_keys = {}
for profile in spacewalkProfiles:
	spacewalk_profile_keys[profile['name']] = profile
for profile in spacewalk_profile_keys:
	if not profile in cobbler_profile_keys:
		done = False
		action = ''
		while not done:
			print "!!! Spacewalk profile "+profile+" appears to be stale - delete it? (y/n): ",
			action = sys.stdin.readline().strip().lower()
			if action == 'y':
				print "++ Removing stale spacewalk profile "+profile
				client.kickstart.deleteProfile(key,profile)
				done = True
			elif action == 'n':
				print "++ Leaving stale spacewalk profile "+profile
				done = True



#### Remove any remaining dangling spacewalk trees
####
####
#### Get updated list of spacewalk ks trees
spacewalk_ks_trees = {}
for channel in spacewalkChannelList:
	for tree in client.kickstart.listKickstartableTrees(key,channel['channel_label']):
		tree['channel'] = channel  # carry this along as we'll need it
		spacewalk_ks_trees[tree['label']] = tree
for distro in spacewalk_ks_trees:
	if not distro in cobbler_distro_labels:
		done = False
		action = ''
		while not done:
			print "!!! Spacewalk distribution "+distro+" appears to be stale - delete it? (y/n): ",
			action = sys.stdin.readline().strip().lower()
			if action == 'y':
				print "++  Deleting stale spacewalk distro "+distro
				client.kickstart.tree.deleteTreeAndProfiles(key,distro)
				done = True
			elif action == 'n':
				print "++ Leaving stale spacewalk distro "+distro
				done = True

print "++ Cobbler to Spacewalk synchronization complete"
