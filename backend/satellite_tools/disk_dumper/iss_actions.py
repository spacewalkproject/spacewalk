#
# Copyright (c) 2008--2010 Red Hat, Inc.
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

import sys

class ActionDeps:
    def __init__(self, options):
        #self.step_precedence contains the dependencies among the export steps. 
        self.step_precedence = {
            'packages'                  : [''],
            'source-packages'           : [''],
            'errata'                    : [''],
            'kickstarts'                : [''],
            'rpms'                      : [''],
#            'srpms'                     : ['channels'],
            'channels'                  : ['channel-families'],
            'channel-families'          : ['blacklists'],
            'blacklists'                : ['arches'],
            'short'                     : ['channels'],
            'arches'                    : ['arches-extra'],
            'arches-extra'              : [''], 
        }
        
        #self.step_hierarchy lists the export steps in the order they need to be run.
        self.step_hierarchy = [
            'channel-families',
            'arches',
            'arches-extra',
            'channels',
            'blacklists',
            'short',
            'rpms',
            'packages',
            'errata',
            'kickstarts',
        ]
        self.options = options
        self.action_dict = { 'blacklists' : 0 }
    
    def list_steps(self):
        print "LIST OF STEPS:"
        for step in self.step_hierarchy:
            print step
        sys.exit(0)
        
    
    #Contains the logic for the --step option
    def handle_step_option(self):
        #If the user didn't use --step, set the last step to the end of self.step_hierarchy.
        if not self.options.step:
            self.options.step = self.step_hierarchy[-1]

        #Make sure that the step entered by the user is actually a step.
        if self.options.step not in self.step_hierarchy:
            sys.stderr.write("Error: '%s' is not a valid step.\n" % self.options.step)
            sys.exit(-1)
 
        #Turn on all of the steps up to the option set as self.options.step.
        for step in self.step_hierarchy:
            self.action_dict[step] = 1
            if step == self.options.step:
                break
        
        #This will set the rest of the steps to 0.
        for step in self.step_hierarchy:
            self.action_dict[step] = self.action_dict.has_key(step)

    #Handles the logic for the --no-rpms, --no-packages, --no-errata, --no-kickstarts, and --list-channels.
    def handle_options(self):
        
        if self.options.list_steps:
            self.list_steps()
        
        if self.options.no_rpms:
            self.action_dict['rpms'] = 0

        if self.options.no_packages:
            self.action_dict['packages'] = 0

        if self.options.no_errata:
            self.action_dict['errata'] = 0

        if self.options.no_kickstarts:
            self.action_dict['kickstarts'] = 0

        if self.options.list_channels:
            self.action_dict['channels'] = 1
            self.action_dict['blacklists'] = 0
            self.action_dict['arches'] = 0
            self.action_dict['channel-families'] = 1

    #This method uses self.step_precendence to figure out if a step needs to be turned off.
    def turn_off_dep_steps(self, step):
        for dependent in self.step_precedence[step]:
            if self.action_dict.has_key(dependent):
                self.action_dict[dependent] = 0
    
    #This method will call turn_off_dep_steps if the step is off or not present in self.action_dict.
    def handle_step_dependents(self):
        for step in self.step_hierarchy:
            if self.action_dict.has_key(step):
                if self.action_dict[step] == 0:
                    self.turn_off_dep_steps(step)
            else:
                self.turn_off_dep_steps(step)    

    #This will return the step_hierarchy and the action_dict.
    def get_actions(self):
        self.handle_step_option()
        self.handle_options()
        self.handle_step_dependents()
        return self.step_hierarchy, self.action_dict

if __name__ == "__main__":
    import iss_ui
    a = iss_ui.UI()
    b = ActionDeps(a)
    print b.get_actions()

    
