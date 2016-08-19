#
# Copyright (c) 2008--2016 Red Hat, Inc.
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

import os

#Base class for all modes.
class BaseMode:
    def __init__(self):
        self.state = False
        self.name = ""

    def on(self):
        self.state = True

    def off(self):
        self.state = False

    def is_on(self):
        if self.state:
            return True
        else:
            return False

    def is_off(self):
        if not self.state:
            return True
        else:
            return False

    def set_name(self, name):
        self.name = name

    def get_name(self):
        return self.name

#Contains the directory and file manipulation stuff
class PathHandler:
    def __init__(self):
        self.rhn_root = "/etc/sysconfig/rhn/allowed-actions/configfiles"

    #Set the rhn_root variable.
    def set_rhn_root(self, rhn_root):
        self.rhn_root = rhn_root

    #Creates the self.rhn_root directories if they don't already exist. This allows subclasses to implement modes in different locations.
    def _create_rhnconfig_path(self):
        if not os.path.exists(self.rhn_root):
            os.makedirs(self.rhn_root, int('0770', 8))

    #Create the file if it doesn't already exist.
    def add_file(self, filename):
        self._create_rhnconfig_path()
        if not self.check_for_file(filename):
            try:
                f = open(os.path.join(self.rhn_root, filename), "w")
                f.close()
            except Exception:
                raise

    #remove the file if it's present.
    def remove_file(self, filename):
        self._create_rhnconfig_path()
        if self.check_for_file(filename):
            try:
                os.remove(os.path.join(self.rhn_root, filename))
            except Exception:
                raise

    #Returns True if filename exists in /etc/sysconfig/rhn/allowed-actions/configfiles
    def check_for_file(self, filename):
        self._create_rhnconfig_path()
        return os.path.exists(os.path.join(self.rhn_root, filename))


#Stuff that's common to the Mode subclasses.
class ConfigFilesBaseMode(BaseMode):
    def __init__(self):
        BaseMode.__init__(self)
        self.ph = PathHandler()
        self.name = None       #Must be set in subclass

    def on(self):
        self.ph.add_file(self.name)
        self.state = True

    def off(self):
        self.ph.remove_file(self.name)
        self.state = False

    #Could probably just check the value of state...
    def is_on(self):
        return self.ph.check_for_file(self.name)

    def is_off(self):
        if self.ph.check_for_file(self.name):
            return False
        elif not self.ph.check_for_file(self.name):
            return True

class RunMode(ConfigFilesBaseMode):
    def __init__(self):
        ConfigFilesBaseMode.__init__(self)
        self.name = "run"
        self.ph.set_rhn_root("/etc/sysconfig/rhn/allowed-actions/script")

class RunAllMode(ConfigFilesBaseMode):
    def __init__(self):
        ConfigFilesBaseMode.__init__(self)
        self.name = "all"
        self.ph.set_rhn_root("/etc/sysconfig/rhn/allowed-actions/script")

class AllMode(ConfigFilesBaseMode):
    def __init__(self):
        ConfigFilesBaseMode.__init__(self)
        self.name = "all"

class DeployMode(ConfigFilesBaseMode):
    def __init__(self):
        ConfigFilesBaseMode.__init__(self)
        self.name = "deploy"

class DiffMode(ConfigFilesBaseMode):
    def __init__(self):
        ConfigFilesBaseMode.__init__(self)
        self.name = "diff"

class UploadMode(ConfigFilesBaseMode):
    def __init__(self):
        ConfigFilesBaseMode.__init__(self)
        self.name = "upload"

class MTimeUploadMode(ConfigFilesBaseMode):
    def __init__(self):
        ConfigFilesBaseMode.__init__(self)
        self.name = "mtime_upload"

#Solaris Specific Modes
class SolarisRunMode(ConfigFilesBaseMode):
    def __init__(self):
        ConfigFilesBaseMode.__init__(self)
        self.name = "run"
        self.ph.set_rhn_root("/opt/redhat/rhn/solaris/etc/sysconfig/rhn/allowed-actions/script")

class SolarisAllRunMode(ConfigFilesBaseMode):
    def __init__(self):
        ConfigFilesBaseMode.__init__(self)
        self.name = "all"
        self.ph.set_rhn_root("/opt/redhat/rhn/solaris/etc/sysconfig/rhn/allowed-actions/script")

class SolarisAllMode(ConfigFilesBaseMode):
    def __init__(self):
        ConfigFilesBaseMode.__init__(self)
        self.name = "all"
        self.ph.set_rhn_root("/opt/redhat/rhn/solaris/etc/sysconfig/rhn/allowed-actions/configfiles")

class SolarisDeployMode(ConfigFilesBaseMode):
    def __init__(self):
        ConfigFilesBaseMode.__init__(self)
        self.name = "deploy"
        self.ph.set_rhn_root("/opt/redhat/rhn/solaris/etc/sysconfig/rhn/allowed-actions/configfiles")

class SolarisDiffMode(ConfigFilesBaseMode):
    def __init__(self):
        ConfigFilesBaseMode.__init__(self)
        self.name = "diff"
        self.ph.set_rhn_root("/opt/redhat/rhn/solaris/etc/sysconfig/rhn/allowed-actions/configfiles")

class SolarisUploadMode(ConfigFilesBaseMode):
    def __init__(self):
        ConfigFilesBaseMode.__init__(self)
        self.name = "upload"
        self.ph.set_rhn_root("/opt/redhat/rhn/solaris/etc/sysconfig/rhn/allowed-actions/configfiles")

class SolarisMTimeUploadMode(ConfigFilesBaseMode):
    def __init__(self):
        ConfigFilesBaseMode.__init__(self)
        self.name = "mtime_upload"
        self.ph.set_rhn_root("/opt/redhat/rhn/solaris/etc/sysconfig/rhn/allowed-actions/configfiles")


