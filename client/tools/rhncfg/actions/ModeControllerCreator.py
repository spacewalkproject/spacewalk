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

import sys
import ModeController
import Modes

class ModeControllerCreator:
    #if mode_list isn't set in the constructor, the populate_list is going to have to be called before create_controller.
    def __init__(self, mode_list=None):
        self.mode_list = mode_list or []

        #A reference to a class obj. This is the type of controller that will be returned by create_controller.
        self.controller_class = ModeController.ModeController

    #Sets the class that the controller will be instantiated as. The constructor for the class shouldn't have
    #to take any parameters.
    def set_controller_class(self, controller_class):
        self.controller_class = controller_class

    #Populates self.mode_list with concrete implementations of Modes.
    def populate_list(self, mode_list):
        self.mode_list = mode_list

    #using the Modes in self.mode_list, create, populate, and return a ModeController
    def create_controller(self):
        controller = self.controller_class()

        for m in self.mode_list:
            controller.add_mode(m)

        return controller

def get_controller_creator():
    if sys.platform.find('sunos') > -1:
        mode_list = [Modes.SolarisDeployMode(), Modes.SolarisDiffMode(), Modes.SolarisUploadMode(), Modes.SolarisMTimeUploadMode(), Modes.SolarisAllMode()]
    else:
        mode_list = [Modes.DeployMode(), Modes.DiffMode(), Modes.UploadMode(), Modes.MTimeUploadMode(), Modes.AllMode()]

    controller = ModeControllerCreator(mode_list=mode_list)
    controller.set_controller_class(ModeController.ConfigFilesModeController)
    return controller

def get_run_controller_creator():
    if sys.platform.find('sunos') > -1:
        mode_list = [Modes.SolarisRunMode(), Modes.SolarisRunAllMode()]
    else:
        mode_list = [Modes.RunMode(), Modes.RunAllMode()]

    controller = ModeControllerCreator(mode_list=mode_list)
    return controller
