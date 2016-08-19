# Client code for enabling plugin
# Copyright (c) 2000--2016 Red Hat, Inc.

import os
import re
import rpm

# global variables
try:
   from dnf import __version__
   PM_PLUGIN_CONF = '/etc/dnf/plugins/spacewalk.conf'
   PM_PLUGIN_NAME = 'dnf-plugin-spacewalk'
   PM_NAME        = 'dnf'
except ImportError:
   PM_PLUGIN_CONF = '/etc/yum/pluginconf.d/rhnplugin.conf'
   PM_PLUGIN_NAME = 'yum-rhn-plugin'
   PM_NAME        = 'yum'

def pluginEnable():
    """Enables plugin, may throw IOError"""
    conf_changed = 0
    plugin_present = 0
    if PluginPackagePresent():
        plugin_present = 1
        if PluginConfPresent():
            if not PluginEnabled():
                enablePlugin()
                conf_changed = 1
        else:
            createDefaultPluginConf()
            conf_changed = 1
    elif os.path.exists("/usr/lib/zypp/plugins/services/spacewalk"):
        """SUSE zypp plugin is installed"""
        plugin_present = 1
    return plugin_present, conf_changed

def PluginPackagePresent():
    """ Returns positive number if plugin package is installed, otherwise it return 0 """
    ts = rpm.TransactionSet()
    headers = ts.dbMatch('providename', PM_PLUGIN_NAME)
    return headers.count()

def PluginConfPresent():
    """ Returns true if PM_PLUGIN_CONF is presented """
    try:
        os.stat(PM_PLUGIN_CONF)
        return True
    except OSError:
        return False

def createDefaultPluginConf():
    """ Create file PM_PLUGIN_CONF, with default values """
    f = open(PM_PLUGIN_CONF, 'w')
    f.write("""[main]
enabled = 1
gpgcheck = 1""")
    f.close()

def PluginEnabled():
    """ Returns True if plugin is enabled
        Can thrown IOError exception.
    """
    f = open(PM_PLUGIN_CONF, 'r')
    lines = f.readlines()
    f.close()
    main_section = False
    result = False
    for line in lines:
        if re.match("^\[.*]", line):
            if re.match("^\[main]", line):
                main_section = True
            else:
                main_section = False
        if main_section:
            m = re.match('^\s*enabled\s*=\s*([0-9])', line)
            if m:
                if int(m.group(1)):
                    result = True
                else:
                    result = False
    return result

def enablePlugin():
    """ enable plugin by setting enabled=1 in file PM_PLUGIN_CONF
        Can thrown IOError exception.
    """
    f = open(PM_PLUGIN_CONF, 'r')
    lines = f.readlines()
    f.close()
    main_section = False
    f = open(PM_PLUGIN_CONF, 'w')
    for line in lines:
        if re.match("^\[.*]", line):
            if re.match("^\[main]", line):
                main_section = True
            else:
                main_section = False
        if main_section:
            line = re.sub('^(\s*)enabled\s*=.+', r'\1enabled = 1', line)
        f.write(line)
    f.close()
