#
# Copyright (c) 2008--2009 Red Hat, Inc.
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
from server import rhnSQL
from server.rhnDependency import find_package_with_arch
from server.rhnChannel import channels_for_server
from server import rhnAction

class PackageNotFound(Exception):
    pass

class NoActionInfo(Exception):
    pass

class SubscribedChannel:
    """
        SubscribedChannel represents a channel to which the server is subscribed.
    """
    def __init__(self, server_id, channel_lookup_string):
        """
            Constructor. 

            server_id is a string containing the unique number that the 
            database has assigned to the server.

            channel_lookup_string is a string that the _get_channel_info function
            uses to look up the correct channel by channel label. It does NOT have 
            to be the entire channel label, but it does have to occur at the beginning
            of the channel label. For instance "rhn-tools" would match any of the
            rhn-tools channels because they all begin with "rhn-tools". It can also be
            the entire channel label, of course.
        """
        self.server_id = server_id
        self.found_channel = None
        self.channel_id = None
        self.channel_lookup_string = channel_lookup_string
        self.channel_label = None

    def _get_channel_info(self):
        """
            Looks up the correct channel based on channel_lookup_string.
            Populates the id, label, and a boolean that tells whether the
            channel is found.
        """
        subscribed_channels = channels_for_server(self.server_id)

        #Our tools channels all start with "rhn-tools", which seems
        #to be the only way to reliably tell one channel from the other
        #automagically.
        self.found_tools_channel = False
        for channel_info in subscribed_channels:
            label_position = channel_info['label'].find(self.channel_lookup_string)
            if label_position > -1 and label_position == 0:
                self.found_channel = True
                self.channel_id = channel_info['id']
                self.channel_label = channel_info['label']

    def is_subscribed_to_channel(self):
        """
            Returns True if server_id is subscribed to the 
            channel, False otherwise
        """
        if not self.found_channel:
            self._get_channel_info()
        return self.found_channel

    def get_channel_id(self):
        """
            Returns the channel's unique id.
        """
        if not self.channel_id:
            self._get_channel_info()
        return self.channel_id

    def get_channel_label(self):
        """
            Returns the channel's label.
        """
        if not self.channel_label:
            self._get_channel_info()
        return self.channel_label


class ChannelPackage:
    """
        Represents a package contained in a channel that the server is
        subscribed to.
    """
    def __init__(self, server_id, package_name):
        """
            Constructor.

            server_id is the unique value assigned to the server by the db.
            package_name is a string containing the name of the package
                to be looked up.
        """
        self.server_id = server_id
        self.package_name = package_name
        
        self.package_info = None
        self.id = None
        self.version = None
        self.release = None
        self.epoch = None
        self.arch = None

        self.name_id = None
        self.evr_id = None
        self.arch_id = None

        self.id_index = 0
        self.name_index = 1
        self.version_index = 2
        self.release_index = 3
        self.epoch_index = 4
        self.arch_index = 5

    def _get_package_info(self):
        """
            "Private" function that retrieves info about the package.
            Populates self.package_info, self.id, self.version, self.release, and self.epoch.
        """
        #Get info on the package we want to install.
        possible_packages = find_package_with_arch(self.server_id, [self.package_name])

        #There's a possibility, however slight, that more than one package
        #may be returned by find_by_packages. If that's the case, we only
        #want the info about package_name.
        package_info = None
        if possible_packages.has_key(self.package_name):
            for package in possible_packages[self.package_name]:
                if package[self.name_index] == self.package_name:
                    self.package_info = package
                    self.id = package[self.id_index]
                    self.version = package[self.version_index]
                    self.release = package[self.release_index]
                    self.epoch = package[self.epoch_index]
                    self.arch = package[self.arch_index]

    def _get_package_field_ids(self):
        """
            "Private" function that retrieves the database id's for the name, EVR, and
            package architecture and sets self.name_id, self.evr_id, and self.arch_id to
            their values.
        """
        package_id = self.get_id()

        if not package_id:
            raise PackageNotFound("ID for package %s was not found." % self.get_name())
        
        _package_info_query = rhnSQL.Statement("""
            select
                    p.name_id name_id,
                    p.evr_id evr_id,
                    p.package_arch_id arch_id
            from
                    rhnPackage p
            where
                    p.id = :package_id
        """)
        prepared_query = rhnSQL.prepare(_package_info_query)
        prepared_query.execute(package_id=package_id)
        package_info_results = prepared_query.fetchone_dict()

        if not package_info_results:
            raise PackageNotFound("Name, EVR, and Arch info not found for %s" % self.get_name())

        self.name_id = package_info_results['name_id']
        self.evr_id = package_info_results['evr_id']
        self.arch_id = package_info_results['arch_id']

    def exists(self):
        """
            Returns True if the package is available for the server according to the db, 
            False otherwise.
        """
        if not self.package_info:
            self._get_package_info()

        if not self.package_info:
            return False
        else:
            return True

    def get_name_id(self):
        """
            Returns the name_id of the package.
        """
        if not self.name_id:
            self._get_package_field_ids()
        return self.name_id

    def get_evr_id(self):
        """
            Returns the evr_id of the package.
        """
        if not self.evr_id:
            self._get_package_field_ids()
        return self.evr_id

    def get_arch_id(self):
        """
            Returns the arch_id of the package.
        """
        if not self.arch_id:
            self._get_package_field_ids()
        return self.arch_id
    
    def get_id(self):
        """
            Returns the id of the package.
        """
        if not self.id:
            self._get_package_field_ids()
        return self.id

    def get_name(self):
        """
            Returns the name of the package.
        """
        return self.package_name

    def get_version(self):
        """
            Returns the version of the package.
        """
        if not self.version:
            self._get_package_info()
        return self.version

    def get_release(self):
        """
            Returns the release of the package.
        """
        if not self.release:
            self._get_package_info()
        return self.release

    def get_epoch(self):
        """
            Returns the epoch of the package.
        """
        if not self.epoch:
            self._get_package_info()
        return self.epoch

    def get_arch(self):
        """
            Returns the arch of the package.
        """
        if not self.arch:
            self._get_package_info()
        return self.arch


class PackageInstallScheduler:
    """
        Class responsible for scheduling package installs. Can
        only be used inside actions during a kickstart.
    """
    def __init__(self, server_id, this_action_id, package):
        """
            Constructor.

            server_id is the unique number assigned to the server by the database.
            this_action_id is the unique number assigned to the current action.
            package is an instance of ChannelPackage.
        """
        self.server_id = server_id
        self.package = package
        self.this_action_id =  this_action_id
        self.new_action_id = None

    def _get_action_info(self, action_id):
        """
            Private function that returns the org_id and scheduler for action_id.
        """
        h = rhnSQL.prepare("""
            select  org_id, scheduler
            from    rhnAction
            where   id = :id
        """)
        h.execute(id=action_id)
        row = h.fetchone_dict()
        if not row:
            raise NoActionInfo("Couldn't find org_id or scheduler for action %s." % str(action_id))
        return (row['org_id'], row['scheduler'])

    def schedule_package_install(self):
        """
            Public function that schedules self.package for installation during the next rhn_check.
        """
        org_id, scheduler = self._get_action_info(self.this_action_id)

        self.new_action_id = rhnAction.schedule_server_action(
                            self.server_id,
                            action_type="packages.update",
                            action_name="Scheduling install of RHN's virtualization host packages.",
                            delta_time=0,
                            scheduler=scheduler,
                            org_id=org_id
                        )

        self._add_package_to_install_action(self.new_action_id)
    
    def _add_package_to_install_action(self, action_id):
        """
            Private function that adds self.package to the rhnActionPackage table.
        """
        name_id = self.package.get_name_id() 
        package_arch_id = self.package.get_arch_id()
        evr_id = self.package.get_evr_id()

        insert_package_query = rhnSQL.Statement("""
            insert into rhnActionPackage(id, 
                                         action_id, 
                                         parameter, 
                                         name_id, 
                                         evr_id, 
                                         package_arch_id)
            values (sequence_nextval('rhn_act_p_id_seq'),
                    :action_id,
                    'install',
                    :name_id,
                    :evr_id,
                    :package_arch_id)
        """)
        prepared_query = rhnSQL.prepare(insert_package_query)
        prepared_query.execute(action_id=str(action_id),
                               name_id=str(name_id),
                               evr_id=str(evr_id),
                               package_arch_id=str(package_arch_id))
