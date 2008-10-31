import xmlrpclib
import os
my_uri = "http://spacewalk.pdx.redhat.com/cobbler_api_rw"
remote =  xmlrpclib.Server(my_uri)
testuser = "admin"
testpass = "redhat"

token = remote.login(testuser,testpass)
print token
# rc = remote.test(token)
# print "test result: %s" % rc

# just to make things "work"
os.system("touch /tmp/vmlinuz")
os.system("touch /tmp/initrd.img")
os.system("touch /tmp/fake.ks")

## now add a distro
distro_id = remote.new_distro(token)
remote.modify_distro(distro_id, 'name',   'example-distro2',token)
remote.modify_distro(distro_id, 'kernel', '/tmp/vmlinuz',token)
remote.modify_distro(distro_id, 'initrd', '/tmp/initrd.img',token)
remote.save_distro(distro_id,token)

## add a profile
profile_id = remote.new_profile(token)
remote.modify_profile(profile_id, 'name',   'example-profile',token)
remote.modify_profile(profile_id, 'distro', 'example-distro2', token)
remote.modify_profile(profile_id, 'kickstart', 'http://spacewalk.pdx.redhat.com/kickstart/ks/org/1/label/test234', token)
remote.save_profile(profile_id,token)

# modify existing profile
#profile_handle = remote.get_profile_handle('example-distro2-modified', token)
#remote.modify_profile(profile_handle, 'distro', 'test-cli', token)
#remote.save_profile(profile_handle,token)
#print "profile: " + str(profile_handle)


