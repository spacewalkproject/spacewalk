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
import string

True = 1
False = 0

class ModeMissingException(Exception):
    pass

#Handles operations on a group of Modes.
class ModeController:
    def __init__(self, force=None):
        self.mode_list = {} #Indexed on the name of the mode
        self.force = False  
    
    #Enable the mode. 
    def on(self, mode_name):
        if self.mode_list.has_key(mode_name):
            self.mode_list[mode_name].on()
        else:
            raise ModeMissingException()            

    #Disable the mode
    def off(self, mode_name):
        if self.mode_list.has_key(mode_name):
            self.mode_list[mode_name].off()
        else:
            raise ModeMissingException()
    
    #Turn on all of the modes.
    def all_on(self):
        for m in self.mode_list.keys():
            self.mode_list[m].on()

    #Turn off all of the modes.
    def all_off(self):
        for m in self.mode_list.keys():
            self.mode_list[m].off()

    #Check to see if the mode is on.
    def is_on(self, mode_name):
        if self.mode_list.has_key(mode_name):
            return self.mode_list[mode_name].is_on()
        else:
            return 0

    #Check to see if the mode is off.
    def is_off(self, mode_name):
        if self.mode_list.has_key(mode_name):
            return self.mode_list[mode_name].is_off()
        else:
            return 0

    #Add another mode to the batch.
    def add_mode(self, mode_obj):
        mode_name = mode_obj.get_name()

        if not self.mode_list.has_key(mode_name):
            self.mode_list[mode_name] = mode_obj

    #Remove a mode from the batch.
    def del_mode(self, mode_obj):
        mode_name = mode_obj.get_name()
        if self.mode_list.has_key(mode_name):
            del self.mode_list[mode_name]

    #set the value of force
    def set_force(self, force):
        self.force = force

class ConfigFilesModeController(ModeController):
    def __init__(self):
        ModeController.__init__(self)

    def is_on(self, mode_name):
        if ModeController.is_on(self, 'all'):
            return 1
        else:
            return ModeController.is_on(self, mode_name)

    def is_off(self, mode_name):
        if ModeController.is_off(self, 'all'):
            return 1
        else:
            return ModeController.is_off(self, mode_name)

    #the possible presence of the 'all' file confuses things a little.
    #If the user enables something while the 'all' file is present, nothing should be added to the configfiles dir.
    def on(self, mode_name):
        if mode_name != 'all':
            if self.is_off('all'):
                ModeController.on(self, mode_name)
                
                #Go through each of the modes and see if they're on. If they're all on, then place the 'all' file in there.
                all_modes_on = 1
                for m in self.mode_list.keys():
                    if m != 'all' and self.mode_list[m].is_off():
                        all_modes_on = 0
                if all_modes_on:
                    self.all_on()
        else:
            self.all_on()

    #If the 'all' file is present and the user disables a mode, then the all file must be removed, and all modes other than
    #the specified mode need to be turned on.
    def off(self, mode_name):
        if mode_name != 'all':
            if self.is_on('all'):
                if not self.force:
                    ask_before_continuing("All modes are currently enabled. Continue? (y or n):")

                #Turn off all modes
                self.all_off()

                #Manually flip on all of the modes except 'all'.
                for m in self.mode_list.keys():
                    if m != 'all':
                        self.mode_list[m].on()

            #Turn off the specified mode. Calls off() at the Mode level, not at the Controller level.
            self.mode_list[mode_name].off()
        else:
            self.all_off()
            

    #This is a little different when the 'all' file is used.
    #There shouldn't be any other files in the directory when 'all' is used.
    def all_on(self):
        #Get rid of all of the files.
        self.all_off()        
        #Turn on the 'all' mode.
        self.mode_list['all'].on()

def ask_before_continuing(question=None):
    if question is None:
        the_question = "Continue? (y or n):"
    else:
        the_question = question

    answer = '-1'

    while answer != 'y' and answer != 'n':
        answer = raw_input(the_question)
        answer = string.lower(answer)[0]

    if answer == 'n':
        sys.exit(0)
            
