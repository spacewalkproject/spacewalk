#
# Copyright (c) 2008 Red Hat, Inc.
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

from xml.dom.minidom import parse
import string
import os

###############################################################################
# Exceptions
###############################################################################

class DomainConfigError(Exception): pass

###############################################################################
# Classes
###############################################################################

class DataType:
    ATTRIBUTE = "attribute"
    VALUE     = "value"

class DomainConfigItem:
    def __init__(self, path, data_type):
        self.path      = path
        self.data_type = data_type

class DomainConfig:
    
    ###########################################################################
    # Constants
    ###########################################################################

    NAME            = DomainConfigItem("domain/name",       DataType.VALUE)
    UUID            = DomainConfigItem("domain/uuid",       DataType.VALUE)
    BOOTLOADER      = DomainConfigItem("domain/bootloader", DataType.VALUE)
    MEMORY          = DomainConfigItem("domain/memory",     DataType.VALUE)
    VCPU            = DomainConfigItem("domain/vcpu",       DataType.VALUE)
    OS              = DomainConfigItem("domain/os",         DataType.VALUE)
    OS_TYPE         = DomainConfigItem("domain/os/type",    DataType.VALUE)
    ROOT_DEVICE     = DomainConfigItem("domain/os/root",    DataType.VALUE)
    COMMAND_LINE    = DomainConfigItem("domain/os/cmdline", DataType.VALUE)
    KERNEL_PATH     = DomainConfigItem("domain/os/kernel",  DataType.VALUE)
    RAMDISK_PATH    = DomainConfigItem("domain/os/initrd",  DataType.VALUE)
    DISK_IMAGE_PATH = DomainConfigItem("domain/devices/disk/source/file", 
                                       DataType.ATTRIBUTE)
    DOMAIN_ID       = DomainConfigItem("domain/id",         DataType.ATTRIBUTE)

    ###########################################################################
    # Public Interface
    ###########################################################################

    def __init__(self, config_path, uuid):
        # Prepare the file name and parse the XML file.
        if string.find(uuid, ".xml") > 1 and os.path.exists(uuid):
            self.__file_name = uuid
        else:
            self.__file_name = "%s/%s.xml" % (config_path, uuid)

        self.__dom_tree = None
        try:
            self.__dom_tree = parse(self.__file_name).documentElement
        except Exception, e:
            raise DomainConfigError("Error reading config file '%s': %s" % \
                                        (self.__file_name, str(e)))

    def save(self):
        """Saves any changes made to this configuration."""
        file = None
        try:
            try:
                file = open(self.__file_name, "w")
                file.write(self.__dom_tree.toxml())
            except IOError, ioe:
                raise DomainConfigError("Error saving config file '%s': %s" % \
                                            (self.__file_name, str(ioe)))
        finally:
            if file is not None:
                file.close()

    def getFileName(self):
        """
        Returns the path to the configuration file represented by this
        object.
        """
        return self.__file_name

    def toXML(self):
        """Returns the XML representation of this configuration."""
        return self.__dom_tree.toxml()

    def getConfigItem(self, config_item):
        if config_item.data_type == DataType.ATTRIBUTE:
            return self.__getElementAttribute(
                self.__dom_tree,
                *config_item.path.split("/"))
        elif config_item.data_type == DataType.VALUE:
            return self.__getElementValue(
                self.__dom_tree, 
                *config_item.path.split("/"))

        raise DomainConfigError("Unknown config item data type '%s'" % \
                                    str(config_item.data_type))

    def hasConfigItem(self, config_item):
        try:
            self.getConfigItem(config_item)
        except DomainConfigError:
            return 0
        return 1

    def removeConfigItem(self, config_item):
        if config_item.data_type == DataType.ATTRIBUTE:
            return self.__removeElementAttribute(
                self.__dom_tree,
                *config_item.path.split("/"))
        elif config_item.data_type == DataType.VALUE:
            return self.__removeElementValue(
                self.__dom_tree, 
                *config_item.path.split("/"))

        raise DomainConfigError("Unknown config item data type '%s'" % \
                                    str(config_item.data_type))

    def setConfigItem(self, config_item, value):
        """
        Sets the value of an item in the tree.  If the item does not yet exist,
        it will be created.
        """
        if config_item.data_type == DataType.ATTRIBUTE:
            return self.__setElementAttribute(
                self.__dom_tree,
                value,
                *config_item.path.split("/"))
        elif config_item.data_type == DataType.VALUE:
            return self.__setElementValue(
                self.__dom_tree,
                value,
                *config_item.path.split("/"))

        raise DomainConfigError("Unknown config item data type '%s'" % \
                                    str(config_item.data_type))

    def isInstallerConfig(self):
        """
        Returns true if this configuration indicates that the domain was
        started in a method that would put it into the installer.
        """
        result = 0
        if self.hasConfigItem(DomainConfig.COMMAND_LINE):
            # Convert the command line to a dict for easy parsability.
            command_line = self.getConfigItem(DomainConfig.COMMAND_LINE)
            command_line_parts = command_line.strip().split(" ")
            command_line_dict = {}
            for part in command_line_parts:
                command_line_args = part.split("=")
                key = command_line_args[0]
                command_line_dict[key] = None
                if len(command_line_args) >= 2:
                    command_line_dict[key] = '='.join(command_line_args[1:])
            
            # Look for the "method" argument.  This is a good indication that
            # the instance is in the installer.
            if command_line_dict.has_key("method") or command_line_dict.has_key("ks"):
                result = 1

        return result

    ###########################################################################
    # Helpers
    ###########################################################################

    def __getElementValue(self, start_tree, *tag_path):
        found = self.__extractElement(start_tree, *tag_path)

        if len(found.childNodes) == 0:
            raise DomainConfigError, \
                  "Unable to find config value: " + "/".join(tag_path)
    
        return found.childNodes[0].data 

    def __getElementAttribute(self, start_tree, *tag_path):
        """
        Returns the value of the requested XML attribute.  The attribute name
        is the last value in the tag_path.
        """
        attribute_name = tag_path[-1]
        found = self.__extractElement(start_tree, *tag_path[:-1])

        # Dig out the value of the requested attribute.
        if not found.hasAttribute(attribute_name):
            raise DomainConfigError, \
                  "Unable to find config attribute: " + "/".join(tag_path)

        return found.getAttribute(attribute_name)

    def __removeElementValue(self, start_tree, *tag_path):
        found = self.__extractElement(start_tree, *tag_path)

        if len(found.childNodes) == 0:
            raise DomainConfigError, \
                  "Unable to find config value: " + "/".join(tag_path)
    
        found.parentNode.removeChild(found)

    def __removeElementAttribute(self, start_tree, *tag_path):
        attribute_name = tag_path[-1]
        found = self.__extractElement(start_tree, *tag_path[:-1])
        
        if not found.hasAttribute(attribute_name):
            raise DomainConfigError, \
                  "Unable to find config attribute: " + "/".join(tag_path)

        found.removeAttribute(attribute_name)

    def __setElementValue(self, start_tree, value, *tag_path):
        try:
            found = self.__extractElement(start_tree, *tag_path)
        except DomainConfigError:
            # If an exception was thrown, the element did not exist.  We'll
            # add it.
            found = self.__makeElement(start_tree, *tag_path)

        if len(found.childNodes) == 0:
            document = self.__dom_tree.parentNode
            element_text = document.createTextNode('')
            found.appendChild(element_text)

        try:
            found.childNodes[0].data = str(value)
        except IndexError, ie:
            raise DomainConfigError(
                "Error writing %s tag in '%s'." % \
                    (string.join(tag_path, '/'), self.__file_name))

    def __setElementAttribute(self, start_tree, value, *tag_path):
        attribute_name = tag_path[-1]
        found = self.__extractElement(start_tree, *tag_path[:-1])
        found.setAttribute(attribute_name, str(value))

    def __addElementValue(self, start_tree, value, *tag_path):
        self.__makeElement(start_tree, *tag_path)
        self.__setElementValue(start_tree, value, *tag_path)

    def __addElementAttribute(self, start_tree, value, *tag_path):
        self.__setElementAttribute(start_tree, value, *tag_path)

    def __makeElement(self, start_tree, *tag_path):
        # If there are no more tags left in the path, there's nothing more to 
        # add.
        if len(tag_path) == 0:
            return start_tree

        # Look for the first part of the tag.
        tag = tag_path[0]
        try:
            element = self.__extractElement(start_tree, tag)
        except DomainConfigError:
            # No matching tag found.  Create one.
            document = self.__dom_tree.parentNode
            element = document.createElement(tag)
            start_tree.appendChild(element)

        tag_path = tag_path[1:]
        return self.__makeElement(element, *tag_path)

    def __extractElement(self, start_tree, *tag_path):
        # If there are no more tags left in the path, we're done.
        if len(tag_path) == 0:
            return start_tree

        # Extract the first matching child from this tree.
        tag = tag_path[0]

        if start_tree == self.__dom_tree:
            # If this is the root node, ensure that the first part of the path
            # matches.  This is a special case because the getElementsByTagName
            # only applies to elements below the root node.
            if start_tree.nodeName != tag:
                # First part of the tag path didn't match.  Raise exception.
               raise DomainConfigError, "Could not locate tag <%s>." % tag
            else:
               # First part matched; adjust the tag pointer, if there's any
               # thing left.
               tag_path = tag_path[1:]
               if len(tag_path) == 0:
                   return start_tree
               else:
                   tag = tag_path[0]

        node_list = start_tree.getElementsByTagName(tag)

        if node_list is not None and len(node_list) > 0:
            tag_node = node_list[0]
            return self.__extractElement(tag_node, *tag_path[1:])

        # If we got here, we couldn't find the tag in question.  Raise an 
        # exception
        raise DomainConfigError, "Could not locate tag " + str(tag)

###############################################################################
# Test Method
###############################################################################

if __name__ == "__main__":
    import sys
    uuid = sys.argv[1]
    f = DomainConfig("/etc/sysconfig/rhn/virt", uuid)
    print "name=", f.getConfigItem(DomainConfig.NAME)
    print "memory=", f.getConfigItem(DomainConfig.MEMORY)
    print "domain_id=", f.getConfigItem(DomainConfig.DOMAIN_ID)
    f.setConfigItem(DomainConfig.DOMAIN_ID, 22322)
    f.setConfigItem(DomainConfigItem("domain/argh", DataType.ATTRIBUTE), 22322)
    f.setConfigItem(DomainConfigItem("domain/pete", DataType.VALUE), "hello")
    f.setConfigItem(DomainConfigItem("domain/vcpu", DataType.VALUE), "22")
    f.setConfigItem(DomainConfig.BOOTLOADER, "/usr/pete/bin/pygrub")
    f.removeConfigItem(DomainConfigItem("domain/os", DataType.VALUE))
    print f.toXML()

