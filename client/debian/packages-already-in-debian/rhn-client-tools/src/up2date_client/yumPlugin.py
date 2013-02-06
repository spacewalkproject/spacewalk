# Client code for enabling yum-rhn-plugin
# Copyright (c) 2000--2012 Red Hat, Inc.

import os
import re
import rpm

# global variables 
YUM_PLUGIN_CONF = '/etc/yum/pluginconf.d/rhnplugin.conf' 

def pluginEnable():
    """Enables yum-rhn-plugin, may throw IOError"""
    conf_changed = 0
    plugin_present = 0
    if YumRHNPluginPackagePresent():
        plugin_present = 1
        if YumRHNPluginConfPresent():
            if not YumRhnPluginEnabled():
                enableYumRhnPlugin()
                conf_changed = 1
        else:
            createDefaultYumRHNPluginConf()
            conf_changed = 1
    elif os.path.exists("/usr/lib/zypp/plugins/services/spacewalk"):
        """SUSE zypp plugin is installed"""
        plugin_present = 1
    return plugin_present, conf_changed

def YumRHNPluginPackagePresent():
    """ Returns positive number if packaga yum-rhn-plugin is installed, otherwise it return 0 """
    ts = rpm.TransactionSet()
    headers = ts.dbMatch('providename', 'yum-rhn-plugin')
    return headers.count()

def YumRHNPluginConfPresent():
    """ Returns true if /etc/yum/pluginconf.d/rhnplugin.conf is presented """
    try:
        os.stat(YUM_PLUGIN_CONF)
        return True
    except OSError:
        return False

def createDefaultYumRHNPluginConf():
    """ Create file /etc/yum/pluginconf.d/rhnplugin.conf with default values """
    f = open(YUM_PLUGIN_CONF, 'w')
    f.write("""[main]
enabled = 1
gpgcheck = 1""")
    f.close()

def YumRhnPluginEnabled():
    """ Returns True if yum-rhn-plugin is enabled
        Can thrown IOError exception.
    """
    f = open(YUM_PLUGIN_CONF, 'r')
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

def enableYumRhnPlugin():
    """ enable yum-rhn-plugin by setting enabled=1 in file
        /etc/yum/pluginconf.d/rhnplugin.conf
        Can thrown IOError exception.
    """
    f = open(YUM_PLUGIN_CONF, 'r')
    lines = f.readlines()
    f.close()
    main_section = False
    f = open(YUM_PLUGIN_CONF, 'w')
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
