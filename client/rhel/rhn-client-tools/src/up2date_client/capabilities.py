
from up2date_client import config
from up2date_client import up2dateErrors

try: # python2
    import UserDict
except ImportError: # python3
    import collections as UserDict

import gettext
t = gettext.translation('rhn-client-tools', fallback=True)
# Python 3 translations don't have a ugettext method
if not hasattr(t, 'ugettext'):
    t.ugettext = t.gettext
_ = t.ugettext

# a dict with "capability name" as the key, and the version
# as the value.
neededCaps = {"caneatCheese": {'version':"21"},
              "supportsAutoUp2dateOption": {'version': "1"},
              "registration.finish_message": {'version': "1"},
              "xmlrpc.packages.extended_profile": {'version':"1"},
              "registration.delta_packages": {'version':"1"},
              "registration.update_contact_info": {'version': "1"},
              "registration.extended_update_support": {"version" : "1"},
              "registration.smbios": {"version" : "1"}}

def parseCap(capstring):
    value = None
    caps = capstring.split(',')

    capslist = []
    for cap in caps:
        try:
            (key_version, value) = [i.strip() for i in cap.split("=", 1)]
        except ValueError:
            # Bad directive: not in 'a = b' format
            continue

        # parse out the version
        # lets give it a shot sans regex's first...
        (key,version) = key_version.split("(", 1)

        # just to be paranoid
        if version[-1] != ")":
            print("something broke in parsing the capabilited headers")
        #FIXME: raise an approriate exception here...

        # trim off the trailing paren
        version = version[:-1]
        data = {'version': version, 'value': value}

        capslist.append((key, data))

    return capslist

class Capabilities(UserDict.UserDict):
    def __init__(self):
        UserDict.UserDict.__init__(self)
        self.missingCaps = {}
        #self.populate()
#        self.validate()
        self.neededCaps = neededCaps
        self.cfg = config.initUp2dateConfig()


    def populate(self, headers):
        for key, val in headers.items():
            if key.lower() == "x-rhn-server-capability":
                capslist = parseCap(val)

                for (cap,data) in capslist:
                    self.data[cap] = data

    def parseCapVersion(self, versionString):
        index = versionString.find('-')
        # version of "-" is bogus, ditto for "1-"
        if index > 0:
            rng = versionString.split("-")
            start = rng[0]
            end = rng[1]
            versions = range(int(start), int(end)+1)
            return versions

        vers = versionString.split(':')
        if len(vers) > 1:
            versions = [int(a) for a in vers]
            return versions

        return [int(versionString)]

    def validateCap(self, cap, capvalue):
        if not cap in self.data:
            errstr = _("This client requires the server to support %s, which the current " \
                       "server does not support") % cap
            self.missingCaps[cap] = None
        else:
            data = self.data[cap]
            # DOES the server have the version we need
            if int(capvalue['version']) not in self.parseCapVersion(data['version']):
                self.missingCaps[cap] =  self.neededCaps[cap]


    def validate(self):
        for key in self.neededCaps.keys():
            self.validateCap(key, self.neededCaps[key])

        self.workaroundMissingCaps()

    def setConfig(self, key, configItem):
        if key in self.tmpCaps:
            self.cfg[configItem] = 0
            del self.tmpCaps[key]
        else:
            self.cfg[configItem] = 1

    def workaroundMissingCaps(self):
        # if we have caps that we know we want, but we can
        # can work around, setup config variables here so
        # that we know to do just that
        self.tmpCaps = self.missingCaps

        # this is an example of how to work around it
        key = 'caneatCheese'
        if key in self.tmpCaps:
            # do whatevers needed to workaround
            del self.tmpCaps[key]
        else:
            # we support this, set a config option to
            # indicate that possibly
            pass

        # dict of key to configItem, and the config item that
        # corresponds with it

        capsConfigMap = {'supportsAutoUp2dateOption': 'supportsAutoUp2dateOption',
                         'registration.finish_message': 'supportsFinishMessage',
                         "registration.update_contact_info" : 'supportsUpdateContactInfo',
                         "registration.delta_packages" : 'supportsDeltaPackages',
                         "xmlrpc.packages.extended_profile" : 'supportsExtendedPackageProfile',
                         "registration.extended_update_support" : "supportsEUS",
                         "registration.smbios" : "supportsSMBIOS"}

        for key in capsConfigMap.keys():
            self.setConfig(key, capsConfigMap[key])

        # if we want to blow up on missing caps we cant eat around
        missingCaps = []
        wrongVersionCaps = []

        if len(self.tmpCaps):
            for cap in self.tmpCaps:
                capInfo = self.tmpCaps[cap]
                if capInfo == None:
                    # it's completly mssing
                    missingCaps.append((cap, capInfo))
                else:
                    wrongVersionCaps.append((cap, capInfo))

        errString = ""
        errorList = []
        if len(wrongVersionCaps):
            for (cap, capInfo) in wrongVersionCaps:
                errString = errString + "Needs %s of version: %s but server has version: %s\n" % (cap,
                                                                                    capInfo['version'],
                                                                                    self.data[cap]['version'])
                errorList.append({"capName":cap, "capInfo":capInfo, "serverVersion":self.data[cap]})

        if len(missingCaps):
            for (cap, capInfo) in missingCaps:
                errString = errString + "Needs %s but server does not support that capability\n" % (cap)
                errorList.append({"capName":cap, "capInfo":capInfo, "serverVersion":""})

        if len(errString):
            raise up2dateErrors.ServerCapabilityError(errString, errorList)

    def hasCapability(self, capability, version=None):
        """Checks if the server supports a capability and optionally a version.
        Returns True or False.

        This complements the neededCaps mechanism provided by this module.
        Using hasCapability makes it easier to do something only if the server
        supports it or to put workaround code in the user of this class. The
        neededCaps mechanism makes it easier to put workaround code in this
        module, which makes sense if it is to be shared.

        'capability' should be a string such as 'registration.foobar'. It can
        be a capability in 'neededCaps' above or one that isn't there. 'version'
        can be a string (where isdigit() is True) or an int.

        """
        assert version is None or str(version).isdigit()

        if not capability in self.data:
            return False
        if version:
            data = self.data[capability]
            if int(version) not in self.parseCapVersion(data['version']):
                return False
        return True
