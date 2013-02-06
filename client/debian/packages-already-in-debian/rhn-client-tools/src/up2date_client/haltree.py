
# HalTree Purpose:
#
# HalTree is a way to organize the mess of data you get from hal.  In general,
# if you want to get all the information about every device in the system, you
# end up with a list of dicts, where each dict contains the property name/values
# for a device.  This list isn't very useful as the hal data is actually 
# organized into a tree.  For example, you have the computer as the head, then
# there may be a scsi card plugged in.  That in turn will have scsi channels
# and luns, which scsi devices may be connected to.  So this module will help
# you reorganize your hal data back to the way they were intended.
#
# HalTree Usage:
# 
# The tree gets built one device at a time.  Once you've created a HalTree
# object, devices get added to the tree with HalTree.add(hw_dev_dict).  The
# devices can be added in any particular order, and the tree gets properly
# structured as the devices get added.  But the tree structure isn't likely
# to be ready until all the devices have been added.  Those devices without a
# parent get stuck in the no_parent_yet list.
#
# When a device gets added, it is no longer a plain dict.  It is stored in a
# HalDevice.  The original dict can be found in HalDevice.properties.

import types


class HalDevice:
    "An object containing its udi, properties and children"
    def __init__ (self, properties):
        self.udi = properties['info.udi']

        self.properties = properties
        self.children = []
        self.classification = None
        
        if properties.has_key('info.parent'):
            self.parent_udi = properties['info.parent']
        else:
            self.parent_udi = None

        self.parent = None

    def print_properties(self):
        print self.udi, ":"
        for property, value in self.properties.items():
            print "    ", property," ==> ",  value

    
        

class HalTree:
    def __init__ (self):
        self.head = None
        self.no_parent_yet = []


    def add(self, hal_device):
        if hal_device.parent_udi:
            parent = self.__find_node(hal_device.parent_udi)
            if parent:
                parent.children.append(hal_device)
                hal_device.parent = parent
            else:  #parent isn't in the main tree yet, stick it in waiting
                self.no_parent_yet.append(hal_device)
        else: #if it doesn't have a parent, it must be the head 'computer'
            self.head = hal_device
            
        #check to see if there are any children waiting for this dev
        self.__get_lost_children(hal_device)
            

    def __get_lost_children(self, hal_device):
        found_list = []
        indexes = []
        no_parent_yet_copy = self.no_parent_yet[:]
        for dev in no_parent_yet_copy:
            if dev.parent_udi == hal_device.udi:
                dev.parent = hal_device
                hal_device.children.append(dev)
                self.no_parent_yet.remove(dev)

    def __find_node(self, udi):
        """ 
        This takes a node in the HalDevice tree and returns the HalDevice with
        the given udi.
        """
        if self.head:
            node = HalTree.__find_node_worker(self.head, udi)
            if node:
                return node

        for node in self.no_parent_yet:
            found_node = HalTree.__find_node_worker(node, udi)
            if found_node:
                return found_node
        return None

    @staticmethod
    def __find_node_worker(node, udi):
        if node.udi == udi:
            return node
        for device in node.children:
            res = HalTree.__find_node_worker(device, udi)
            if res:
                return res
        return None
    
    def print_tree(self):
        self.__print_dev_tree(self.head, "")
        
    def __print_dev_tree(self, node, indent):
        print indent, node.udi
        print indent, "CLASS:", node.classification
        for name, property in node.properties.items():
            if (type(property) == types.StringType):
                if property.isdigit():
                    print indent + "    ", "%-20s ==> %s" % (name, hex(int(property)))
                else:
                    print indent + "    ", "%-20s ==> %s" % (name, property)
            elif (type(property) == types.IntType): 
                print indent + "    ", "%-20s ==> %s" % (name, hex(int(property)))
            else:
                print indent + "    ", "%-20s ==> %s" % (name, property)
        print
        for child in node.children:
            self.__print_dev_tree(child, indent + "    ")
