#
# Copyright (c) 2008--2015 Red Hat, Inc.
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

# system modules
import string
import sys

from spacewalk.common import rhnFlags, rhnMail
from spacewalk.common.rhnLog import log_debug, log_error
from spacewalk.common.rhnConfig import CFG
from spacewalk.common.rhnException import rhnFault
from spacewalk.common.rhnTranslate import _, cat
from spacewalk.common.rhnLib import checkValue
from spacewalk.server.rhnLib import normalize_server_arch
from spacewalk.server.rhnServer import server_route, server_lib
from spacewalk.server.rhnServer.server_certificate import Certificate
from spacewalk.server.rhnHandler import rhnHandler
from spacewalk.server import rhnUser, rhnServer, rhnSQL, rhnCapability, \
    rhnChannel, rhnVirtualization
from spacewalk.common.rhnTB import add_to_seclist


def hash_validate(data, *keylist):
    """ verify that a hash has all the keys and those have actual values """
    for k in keylist:
        if not data.has_key(k):
            return 0
        l = data[k]
        if l is None:
            return 0
        if type(l) == type("") and len(l) == 0:
            return 0
    return 1


def parse_smbios(smbios):
    vendor = smbios.get('smbios.bios.vendor')
    serial = smbios.get('smbios.system.serial', '')
    manufacturer = smbios.get('smbios.system.manufacturer')
    product = smbios.get('smbios.system.product')

    # XXX need to worry about uuid being none for other virt types and
    # available subs check
    uuid = None
    if smbios.has_key('smbios.system.uuid'):
        uuid = smbios['smbios.system.uuid']
        uuid = uuid.replace('-', '')

    if vendor == "QEMU" and uuid is not None:
        return (rhnVirtualization.VirtualizationType.QEMU, uuid)
    elif manufacturer == 'Bochs' and product == 'Bochs' and uuid is not None:
        # Bochs, Bochs is a virtual SUSE KVM machine
        return (rhnVirtualization.VirtualizationType.QEMU, uuid)
    elif manufacturer == 'Red Hat' and product == 'KVM' and uuid is not None:
        return (rhnVirtualization.VirtualizationType.QEMU, uuid)
    elif (manufacturer == 'Red Hat' and product == 'RHEV Hypervisor' and uuid is
          not None):
        return (rhnVirtualization.VirtualizationType.QEMU, uuid)
    elif manufacturer and manufacturer.startswith('Red Hat') and product == 'OpenStack Nova' and uuid is not None:
        return (rhnVirtualization.VirtualizationType.QEMU, uuid)
    elif manufacturer == 'oVirt' and product == 'oVirt Node' and uuid is not None:
        return (rhnVirtualization.VirtualizationType.QEMU, uuid)
    elif (manufacturer == 'Red Hat' and product == 'OpenStack Compute' and uuid
            is not None):
        return (rhnVirtualization.VirtualizationType.QEMU, uuid)
    elif manufacturer == 'Microsoft Corporation' and \
            product == 'Virtual Machine':
        if uuid is None:
            uuid = "flex-guest"
        return (rhnVirtualization.VirtualizationType.HYPERV, uuid)
    elif serial.startswith('VMware-'):
        if uuid is None:
            uuid = "flex-guest"
        return (rhnVirtualization.VirtualizationType.VMWARE, uuid)
    elif manufacturer == 'HITACHI' and product.endswith(' HVM LPAR'):
        if uuid is None:
            uuid = "flex-guest"
        return (rhnVirtualization.VirtualizationType.VIRTAGE, uuid)
    else:
        return (None, None)


class Registration(rhnHandler):

    """ encapsulate functions that we will provide for the outside world """

    def __init__(self):
        rhnHandler.__init__(self)
        self.functions.append("activate_registration_number")
        self.functions.append("activate_hardware_info")
        self.functions.append("available_eus_channels")
        self.functions.append("add_hw_profile")
        self.functions.append("add_packages")
        self.functions.append("anonymous")
        self.functions.append("delete_packages")
        self.functions.append("delta_packages")
        self.functions.append("finish_message")
        self.functions.append("get_possible_orgs")
        self.functions.append("new_system")
        self.functions.append("new_system_user_pass")
# self.functions.append("new_system_activation_key")
        self.functions.append("new_user")               # obsoleted
        self.functions.append("privacy_statement")
        self.functions.append("refresh_hw_profile")
        self.functions.append("register_osad")
        self.functions.append("register_osad_jid")
        self.functions.append("register_product")
        self.functions.append("remaining_subscriptions")  # obsoleted
        self.functions.append("reserve_user")           # obsoleted
        self.functions.append("send_serial")
        self.functions.append("upgrade_version")
        self.functions.append("update_contact_info")    # obsoleted
        self.functions.append("update_packages")
        self.functions.append("update_systemid")
        self.functions.append("update_transactions")
        self.functions.append("virt_notify")
        self.functions.append("welcome_message")

        # defaults for the authentication section
        self.load_user = 0
        self.check_entitlement = 0
        self.throttle = 0

        # a mapping between vendor and asset tags or serial numbers.
        # if we want to support other vendors for re
        self.vendor_tags = {'DELL': 'smbios.system.serial'}

    def reserve_user(self, username, password):
        """
        Get an username and a password and create a record for this user.
        Eventually mark it as such.
        Additionaly this method is used to verify login and password in early
        stage of rhn_register.

        Returns true value if user is reserved, otherwise fault is raised.
        """

        add_to_seclist(password)

        log_debug(1, username)
        # check user login/password and if not CFG.disallow_user_creation
        # then reserver the user
        ret = rhnUser.reserve_user(username, password)
        log_debug(3, "rhnUser.reserve_user returned: " + str(ret))
        if ret < 0:
            raise rhnFault(3)
        return ret

    def new_user(self, username, password, email=None,
                 org_id=None, org_password=None):
        """
        Finish off creating the user.

        The user has to exist (must be already reserved), the password must
        match and we set the e-mail address if one is given

        Return true if success
        """

        log_debug(1, username, email)
        # email has to be a string or nothing
        if not checkValue(email, None, "", type("")):
            raise rhnFault(30, _faultValueString(email, "email"))
        # be somewhat drastic about the org values
        if org_id and org_password:
            org_password = str(org_password)
            try:
                org_id = int(str(org_id))
            except ValueError:
                raise rhnFault(30, _faultValueString(org_id, "org_id")), None, sys.exc_info()[2]
        else:
            org_id = org_password = None
        username, password = rhnUser.check_user_password(username, password)
        email = rhnUser.check_email(email)
        # now create this user
        ret = rhnUser.new_user(username, password, email, org_id, org_password)
        # rhnUser.new_user will raise it's own faults.
        return ret

    def validate_system_input(self, data):
        """ check the input data """
        if not hash_validate(data, "os_release", "architecture", "profile_name"):
            log_error("Incomplete data hash")
            raise rhnFault(21, _("Required data missing"))
        # we require either a username and a password or a token
        if not hash_validate(data, "username", "password") and \
           not hash_validate(data, "token"):
            raise rhnFault(21, _("Required members missing"))

    def validate_system_user(self, username, password):
        username, password = rhnUser.check_user_password(username,
                                                         password)
        user = rhnUser.search(username)

        if user is None:
            log_error("Can't register server to non-existent user")
            raise rhnFault(2, _("Attempt to register a system to an invalid username"))

        # This check validates username and password
        if not user.check_password(password):
            log_error("User password check failed", username)
            raise rhnFault(2)

        if rhnUser.is_user_disabled(username):
            msg = _("""
                   %s Account has been deactivated on this server.
                   Please contact your Org administrator for more help.""")
            raise rhnFault(1, msg % username, explain=0)

        return user

    def create_system(self, user, profile_name, release_version,
                      architecture, data):
        """
        Create a system based on the input parameters.

        Return dict containing a server object for now.
        Called by new_system (< rhel5)
              and new_system_user_pass | new_system_activation_key (>= rhel5)
        """

        if profile_name is not None and not \
           rhnFlags.test("re_registration_token") and \
           len(profile_name) < 1:
            raise rhnFault(800)

        # log entry point
        if data.has_key("token"):
            log_item = "token = '%s'" % data["token"]
        else:
            log_item = "username = '%s'" % user.username

        log_debug(1, log_item, release_version, architecture)

        # Fetch the applet's UUID
        if data.has_key("uuid"):
            applet_uuid = data['uuid']
            log_debug(3, "applet uuid", applet_uuid)
        else:
            applet_uuid = None

        # Fetch the up2date UUID
        if data.has_key("rhnuuid"):
            up2date_uuid = data['rhnuuid']
            log_debug(3, "up2date uuid", up2date_uuid)
            # XXX Should somehow check the uuid uniqueness
            #raise rhnFault(105, "A system cannot be registered multiple times")
        else:
            up2date_uuid = None

        release = str(release_version)

        if data.has_key('token'):
            token_string = data['token']
            # Look the token up; if the token does not exist or is invalid,
            # stop right here (search_token raises the appropriate rhnFault)
            tokens_obj = rhnServer.search_token(token_string)
            log_user_id = tokens_obj.get_user_id()
        else:
            # user should not be null here
            log_user_id = user.getid()
            tokens_obj = rhnServer.search_org_token(user.contact["org_id"])
            log_debug(3, "universal_registration_token set as %s" %
                      str(tokens_obj.get_tokens()))
            rhnFlags.set("universal_registration_token", tokens_obj)

        if data.has_key('channel') and len(data['channel']) > 0:
            channel = data['channel']
            log_debug(3, "requested EUS channel: %s" % str(channel))
        else:
            channel = None

        newserv = None
        if tokens_obj:
            # Only set registration_token if we have token(s) available.
            # server_token.ActivationTokens.__nonzero__ should do the right
            # thing of filtering the case of no tokens
            rhnFlags.set("registration_token", tokens_obj)
            # Is the token associated with a server?
            if tokens_obj.is_rereg_token:
                # Also flag it's a re-registration token
                rhnFlags.set("re_registration_token", tokens_obj)
                # Load the server object
                newserv = rhnServer.search(tokens_obj.get_server_id())
                newserv.disable_token()
                # The old hardware info no longer applies
                newserv.delete_hardware()
                # Update the arch - it may have changed; we know the field was
                # provided for us
                newserv.set_arch(architecture)
                # if no creator_id use the activation key owner, else keep
                if not newserv.server['creator_id']:
                    newserv.user = user
                else:
                    newserv.user = rhnUser.User("", "")
                    newserv.user.reload(newserv.server['creator_id'])
                # Generate a new secret for this server
                newserv.gen_secret()
                # Get rid of the old package profile - it's bogus in this case
                newserv.dispose_packages()
                # The new server may have a different base channel
                newserv.change_base_channel(release)

        if newserv is None:
            # Not a re-registration token, we need a fresh server object
            rhnSQL.set_log_auth(log_user_id)
            newserv = rhnServer.Server(user, architecture)

        # Proceed with using the rest of the data
        newserv.server["release"] = release
        if data.has_key('release_name'):
            newserv.server["os"] = data['release_name']

        # add the package list
        if data.has_key('packages'):
            for package in data['packages']:
                newserv.add_package(package)
        # add the hardware profile
        if data.has_key('hardware_profile'):
            for hw in data['hardware_profile']:
                newserv.add_hardware(hw)
        # fill in the other details from the data dictionary
        if profile_name is not None and not \
           rhnFlags.test("re_registration_token"):
            newserv.server["name"] = profile_name[:128]
        if data.has_key("os"):
            newserv.server["os"] = data["os"][:64]
        if data.has_key("description"):
            newserv.server["description"] = data["description"][:256]
        else:
            newserv.default_description()

        # Check for virt params
        # Get the uuid, if there is one.
        if data.has_key('virt_uuid'):
            virt_uuid = data['virt_uuid']
            if virt_uuid is not None \
               and not rhnVirtualization.is_host_uuid(virt_uuid):
                # If we don't have a virt_type key, we'll assume PARA.
                virt_type = None
                if data.has_key('virt_type'):
                    virt_type = data['virt_type']
                    if virt_type == 'para':
                        virt_type = rhnVirtualization.VirtualizationType.PARA
                    elif virt_type == 'fully':
                        virt_type = rhnVirtualization.VirtualizationType.FULLY
                    else:
                        raise Exception(
                            "Unknown virtualization type: %s" % virt_type)
                else:
                    raise Exception("Virtualization type not provided")
                newserv.virt_uuid = virt_uuid
                newserv.virt_type = virt_type
            else:
                newserv.virt_uuid = None
                newserv.virt_type = None
        else:
            newserv.virt_uuid = None
            newserv.virt_type = None

        # If we didn't find virt info from xen, check smbios
        if data.has_key('smbios') and newserv.virt_uuid is None:
            (newserv.virt_type, newserv.virt_uuid) = \
                parse_smbios(data['smbios'])

        if tokens_obj.forget_rereg_token:
            # At this point we retained the server with re-activation
            # let the stacked activation keys do their magic
            tokens_obj.is_rereg_token = 0
            rhnFlags.set("re_registration_token", 0)

        # now if we have a token, load the extra registration
        # information from the token
        if rhnFlags.test("registration_token"):
            # Keep the original "info" field
            newserv.load_token()
            # we need to flush the registration information into the
            # database so we can proceed with processing the rest of
            # the token information (like subscribing the server to
            # groups, channels, etc)

            # bretm 02/19/2007 -- this shouldn't throw any of the following:
            #   BaseChannelDeniedError
            #   NoBaseChannelError
            # since we have the token object, and underneath the hood, we have none_ok=have_token

            # BUT - it does. So catch them and throw. this will make rhnreg_ks
            # die out, but oh well. at least they don't end up registered, and
            # without a base channel.
            try:
                # don't commit
                newserv.save(0, channel)
            except (rhnChannel.NoBaseChannelError), channel_error:
                raise rhnFault(70), None, sys.exc_info()[2]
            except rhnChannel.BaseChannelDeniedError, channel_error:
                raise rhnFault(71), None, sys.exc_info()[2]
            except server_lib.rhnSystemEntitlementException, e:
                raise rhnFault(90), None, sys.exc_info()[2]

            # Process any kickstart data associated with this server
            # Do this before using/processing the token, as the
            # potential pkg delta shadow action should happen first
            log_debug(3, "reg token process_kickstart_info")
            newserv.process_kickstart_info()

            # now do the rest of the processing for the token registration
            newserv.use_token()
        else:
            # Some information
            newserv.server["info"] = "rhn_register by %s" % log_item
            log_debug(3, "rhn_register process_kickstart_info")
            newserv.process_kickstart_info()

        # Update the uuid if necessary
        if up2date_uuid:
            newserv.uuid = up2date_uuid

        # save it
        # Commits to the db.
        #
        # bretm 02/19/2007 -- this *can* now throw any of the following:
        #   rhnChannel.BaseChannelDeniedError
        #   rhnChannel.NoBaseChannelError
        #   rhnSystemEntitlementException
        #   |
        #   +--rhnNoSystemEntitlementsException
        try:
            newserv.save(1, channel)
        except (rhnChannel.NoBaseChannelError), channel_error:
            raise rhnFault(70), None, sys.exc_info()[2]
        except rhnChannel.BaseChannelDeniedError, channel_error:
            raise rhnFault(71), None, sys.exc_info()[2]
        except server_lib.rhnSystemEntitlementException, e:
            # right now, don't differentiate between general ent issues & rhnNoSystemEntitlementsException
            raise rhnFault(90), None, sys.exc_info()[2]

        if CFG.SEND_EOL_MAIL and user and newserv.base_channel_is_eol():
            self.attempt_eol_mailing(user, newserv)

        # XXX: until this is complete, bug:
        #      http://bugzilla.redhat.com/bugzilla/show_bug.cgi?id=112450
        # store route in DB (schema for RHN 3.1+ only!)
        server_route.store_client_route(newserv.getid())

        return {'server': newserv, }

    def new_system(self, data):
        """
        This function expects at the INPUT a dictionary that has at least
        the following members: username, password, os_release, email
        If the username does not exist, it is created. If the username
        exists, then password is checked for a match.
        If all is well, we send back a server certificate.
        --
        Hash
        --
        Struct

        Starting with RHEL 5, the client will use activate_registration_number,
        activate_hardware_info, new_system_user_pass, and/or
        new_system_activation_key instead of this.

        In hosted, RHEL 4 and earlier will also call
        activate_registration_number
        """

        if data.has_key("password"):
            add_to_seclist(data["password"])

        # Validate we got the minimum necessary input.
        self.validate_system_input(data)

        # Authorize username and password, if used.
        # Store the user object in user.
        user = None
        if not data.has_key('token'):
            user = self.validate_system_user(data["username"],
                                             data["password"])

        release_version = data['os_release']
        profile_name = data['profile_name']
        architecture = data['architecture']

        # Create the system and get back the rhnServer object.
        #
        # bretm 02/19/2007 -- the following things get thrown underneath,
        # but we issue the faults in create_system for uniformity:
        #
        #   rhnChannel.BaseChannelDeniedError
        #   rhnChannel.NoBaseChannelError
        #   rhnSystemEntitlementException
        #   |
        #   +--rhnNoSystemEntitlementsException
        server_data = self.create_system(user, profile_name,
                                         release_version,
                                         architecture, data)
        newserv = server_data['server']

        system_certificate = newserv.system_id()

        # Return the server certificate file down to the client.
        return system_certificate

    def new_system_user_pass(self, profile_name, os_release_name,
                             version, arch, username,
                             password, other):
        """ Registers a new system to an org specified by a username, password, and
            optionally an org id.

            New for RHEL 5.

            All args are strings except other.
            other is a dict with:
            * org_id - optional. Must be a string that contains the number. If it's
            not given, the default org is used.

            If a profile is created it will return a dict with:
            * system_id - the same xml as was previously returned
            * channels - a list of the channels (as strings) the system was
              subscribed to
            * failed_channels - a list of channels (as strings) that
              the system should have been subscribed to but couldn't be because they
              don't have the necessary entitlements available. Can contain all the
              channels including the base channel.
            * system_slots - a list of the system slots used (as strings).
            * failed_system_slots - a list of system slots (as strings) that they
              should have used but couldn't because there weren't available
              entitlements
            * universal_activation_key - a list of universal default activation keys
              (as strings) that were used while registering.
            The call will try to use the highest system slot available. An entry will
            be added to failed_system_slots for each one that is tried and fails and
            system_slots will contain the one that succeeded if any.

            If an error occurs which prevents the creation of a profile, a fault will
            be raised:
            TODO
        """

        add_to_seclist(password)

        log_debug(4, 'in new_system_user_pass')

        # release_name wasn't required in the old call, so I'm just going to
        # add it to other
        other['release_name'] = os_release_name

        # Authorize the username and password. Save the returned user object.
        user = self.validate_system_user(username, password)

        # This creates the rhnServer record and commits it to the db.
        # It also assigns the system a base channel.
        server_data = self.create_system(user, profile_name,
                                         version,
                                         arch,
                                         other)
        # Save the returned Server object
        newserv = server_data['server']

        # Get the server db id.
        server_id = newserv.getid()

        # Get the server certificate file
        system_certificate = newserv.system_id()

        log_debug(4, 'Server id created as %s' % server_id)

        failures = []
        unknowns = []

        # Build our return values.
        attempted_channels = []
        successful_channels = []
        failed_channels = []

        actual_channels = rhnChannel.channels_for_server(server_id)
        for channel in actual_channels:
            successful_channels.append(channel['label'])

        # If we don't have any successful channels, we know the base channel
        # failed.
        if len(successful_channels) == 0:
            log_debug(4, 'System %s not subscribed to any channels' % server_id)

            # Look up the base channel, and store it as a failure.
            try:
                base = rhnChannel.get_channel_for_release_arch(
                    version,
                    arch, newserv['org_id'])
                failed_channels.append(base['label'])
            # We want to swallow exceptions here as we are just generating data
            # for the review screen in rhn_register.
            except:
                pass

        # Store any of our child channel failures
        failed_channels = failed_channels + failures

        attempted_system_slots = ['enterprise_entitled']
        successful_system_slots = server_lib.check_entitlement(server_id)
        successful_system_slots = successful_system_slots.keys()
        failed_system_slots = []

        # Check which entitlement level we got, starting with the highest.
        i = 0
        for slot in attempted_system_slots:
            if slot in successful_system_slots:
                break
            i = i + 1

        # Any entitlements we didn't have, we'll store as a failure.
        failed_system_slots = attempted_system_slots[0:i]

        universal_activation_key = []
        if rhnFlags.test("universal_registration_token"):
            token = rhnFlags.get("universal_registration_token")
            universal_activation_key = token.get_tokens()

        return {'system_id': system_certificate,
                'channels': successful_channels,
                'failed_channels': failed_channels,
                'failed_options': unknowns,
                'system_slots': successful_system_slots,
                'failed_system_slots': failed_system_slots,
                'universal_activation_key': universal_activation_key
                }

    # Registers a new system to an org specified by an activation key.
    #
    # New for RHEL 5.
    #
    # See documentation for new_system_user_pass. This behaves the same way
    # except it takes an activation key instead of username, password, and
    # maybe org id.
# def new_system_activation_key(self, profile_name, os_release_name,
# os_release_version, arch, activation_key, other):
# return { 'system_id' : self.new_system({'profile_name' : profile_name,
# 'os_release' : os_release_version,
# 'release_name' : os_release_name,
# 'architecture' : arch,
# 'token' : activation_key,
# }),
# 'channels' : ['UNDER CONSTRUCTION'],
# 'failed_channels' : ['UNDER CONSTRUCTION'],
# 'system_slots' : ['UNDER CONSTRUCTION'],
# 'failed_system_slots' : ['UNDER CONSTRUCTION'],
# }

    def get_possible_orgs(self, username, password):
        """ Gets all the orgs that a user belongs to.
            In the OCS-future, users may belong to more than one org.

            New for RHEL 5.

            Returns a dict like:
            {
                'orgs': {'19': 'Engineering', '4009': 'Finance'},
                'default_org': '19'
            }
            'orgs' must have at least one pair and 'default_org' must exist and point
            to something in 'orgs'.

            TODO Pick fault number for this and document it here
            Fault:
            * Bad credentials
        """
        user = rhnUser.auth_username_password(username, password)

        # buzilla #229362, jslagle
        # Clients currently are calling this method in hopes
        # to one day support multi-org satellite.
        # So, if we're running on a sat, return the default org
        # for now.
        org_id = user.contact["org_id"]
        org_name = user.customer["name"]
        orgs = {str(org_id): org_name}
        default_org = str(org_id)
        return {'orgs': orgs, 'default_org': default_org}

    def activate_registration_number(self, username, password, key, other):
        """ Entitle a particular org using an entitlement number.

            New for RHEL 5.

            username, password, and key are strings.
            other is a dict with:
            * org_id - optional. If it's not given, the user's default org is used.

            Returns a dict:
            {
                'status_code': <status code>,
                'registration_number': 'EN for this system'
                'channels' : channels,
                'system_slots' : system_slots
            }
            'status_code' must be 0 for "we just activated the key" or 1 for "this
            key was already activated."
            'registration_number' will be the EN corresponding to this activation. If
            we activated an EN we'll get the same thing back. If we activate an OEM
            number (eg asset tag) and maybe a pre-rhel 5 subscription number, we'll
            get back the EN that was generated from it.
            'channels' is a dict of the channel susbscriptions that the key activated
            the key/value pairs are label (string) / quantity (int)
            'system_slots' is a dict of the system slots that the key activated
            the key/value pairs are label (string) / quantity (int)

            TODO Assign fault values and document them here
            Faults:
            * Invalid key (600)
            * Bad credentials (?) - covers bad username and password, bad org id, and
            user not in specified org
        """
        # bugzilla# 236927, jslagle
        # Clients are currently broken in that they try to activate
        # installation numbers against a satellite.
        # We can work around this by just raising the 'number is not
        # entitling' fault.
        raise rhnFault(602)

    def __findAssetTag(self, vendor, hardware_info):
        """ Given some hardware information, we try to find the asset tag or
            serial number.

            See activate_hardware_info below for the structure of the
            hardware_info
        """

        if self.vendor_tags.has_key(vendor):
            asset_value = ""
            key = self.vendor_tags[vendor]
            log_debug(5, "key: " + str(key))
            if hardware_info.has_key(key):
                return hardware_info[key]

        # nothing found
        log_debug(5, "no tag found for vendor: " + str(vendor))
        return None

    def __transform_vendor_to_const(self, vendor):
        if vendor in [None, "", "Not Available", "None", "N/A"]:
            return None

        if vendor.lower().startswith("dell"):
            return "DELL"
        else:
            return None

    def activate_hardware_info(self, username, password, hardware_info, other):
        """
        Given some hardware-based criteria per-vendor, try giving entitlements.

        New for RHEL 5.

        Mostly the same stuff as activate_registration_number.
        hardware_info is a dict of stuff we get from hal from
        Computer -> system.* and smbios.*. For example:
        {
            'system.product': '2687D8U ThinkPad T43',
            'system.vendor': 'IBM',
            'smbios.chassis.type': 'Notebook',
            ...
        }
        """

        log_debug(5, username, hardware_info, other)

        # bugzilla #236927, jslagle
        # RHN clients are currently broken in that they always try to activate
        # hardware info regardless of if they're pointed at satellite or hosted.
        # To fix the satellite case, just raise the 'no entitlements tied to
        # this hardware' fault.
        raise rhnFault(601)

    def attempt_eol_mailing(self, user, server):

        if not user:
            raise Exception("user required to attempt eol mailing")

        if user.info.has_key("email"):
            log_debug(4, "sending eol mail...")
            body = EOL_EMAIL % {'server': server.server['name']}
            headers = {}
            headers['From'] = 'Red Hat Satellite <dev-null@rhn.redhat.com>'
            headers['To'] = user.info['email']
            headers['Subject'] = 'End of Life RHN Channel Subscription'
            rhnMail.send(headers, body)

    def send_serial(self, system_id, number, vendor=None):
        """
        Receive a vendor serial number from the client and tag it to the server.
        """
        log_debug(1, number, vendor)
        # well, we don't do that anymore
        return 0

    # XXX: update this function to deal with the channels and stuff
    # TODO: Is this useful? we think not. investigate and possibly replace
    # with a NOOP.
    def upgrade_version(self, system_id, newver):
        """ Upgrade a certificate's version to a different release. """
        log_debug(5, system_id, newver)
        # we need to load the user because we will generate a new certificate
        self.load_user = 1
        server = self.auth_system(system_id)
        newver = str(newver)
        if not newver:
            raise rhnFault(21, _("Invalid system release version requested"))
        # log the entry
        log_debug(1, server.getid(), newver)
        ret = server.change_base_channel(newver)
        server.save()
        return server.system_id()

    def add_packages(self, system_id, packages):
        """ Add one or more package to the server profile. """
        log_debug(5, system_id, packages)
        if CFG.DISABLE_PACKAGES:
            return 0
        packages = self._normalize_packages(system_id, packages)
        server = self.auth_system(system_id)
        # log the entry
        log_debug(1, server.getid(), "packages: %d" % len(packages))
        for package in packages:
            server.add_package(package)
        # XXX: check return code
        server.save_packages()
        return 0

    def delete_packages(self, system_id, packages):
        """ Delete one or more packages from the server profile """
        log_debug(5, system_id, packages)
        if CFG.DISABLE_PACKAGES:
            return 0
        packages = self._normalize_packages(system_id, packages)
        server = self.auth_system(system_id)
        # log the entry
        log_debug(1, server.getid(), "packages: %d" % len(packages))
        for package in packages:
            server.delete_package(package)
        # XXX: check return code
        server.save_packages()
        return 0

    def delta_packages(self, system_id, packages):
        log_debug(5, system_id, packages)
        if CFG.DISABLE_PACKAGES:
            return 0
        if type(packages) != type({}):
            log_error("Invalid argument type", type(packages))
            raise rhnFault(21)
        added_packages = self._normalize_packages(system_id, packages.get('added'), allow_none=1)
        removed_packages = self._normalize_packages(system_id, packages.get('deleted'), allow_none=1)

        server = self.auth_system(system_id)
        # log the entry
        if added_packages is not None:
            log_debug(1, self.server_id, "added: %d" % len(added_packages))
        if removed_packages is not None:
            log_debug(1, self.server_id, "deleted: %d" % len(removed_packages))
        # Update the capabilities list
        rhnCapability.update_client_capabilities(self.server_id)
        for package in added_packages or []:
            server.add_package(package)
        for package in removed_packages or []:
            server.delete_package(package)
        server.save_packages()
        return 0

    def virt_notify(self, system_id, actions):
        """ This function fields virtualization-related notifications from the
            client and delegates them out to the appropriate downstream handlers.
            The 'actions' argument is formatted as follows:

            actions = [ ( timestamp, event, target, properties ), ... ]
        """
        log_debug(3, "Received virt notification:", system_id, actions)

        # Authorize the client.
        server = self.auth_system(system_id)
        server_id = server.getid()

        rhnVirtualization._virt_notify(server_id, actions)

        rhnSQL.commit()

        return 0

    def update_packages(self, system_id, packages):
        """ This function will update the package list associated with a server
            to be exactly the list of packages passed on the argument list
        """
        log_debug(5, system_id, packages)
        if CFG.DISABLE_PACKAGES:
            return 0
        packages = self._normalize_packages(system_id, packages)

        server = self.auth_system(system_id)
        # log the entry
        log_debug(1, server.getid(), "packages: %d" % len(packages))
        server.dispose_packages()
        for package in packages:
            server.add_package(package)
        server.save_packages()
        return 0

    def _normalize_packages(self, system_id, packages, allow_none=0):
        """ the function checks if list of packages is well formated
            and also converts packages from old list of lists
            (extended_profile >= 2) to new list of dicts (extended_profile = 2)
        """

        if allow_none and packages is None:
            return None
        # we need to be paranoid about the format of the argument because
        # if we accept wrong input then we might end up disposing in error
        # of all packages registered here
        if type(packages) != type([]):
            log_error("Invalid argument type", type(packages))
            raise rhnFault(21)

        # Update the capabilities list
        server = self.auth_system(system_id)
        rhnCapability.update_client_capabilities(self.server_id)

        # old clients send packages as a list of arrays
        # while new (capability packages.extended_profile >= {version: 2, value: 1})
        # use a list of dicts
        client_caps = rhnCapability.get_client_capabilities()
        package_is_dict = 0
        packagesV2 = []
        if client_caps and client_caps.has_key('packages.extended_profile'):
            cap_info = client_caps['packages.extended_profile']
            if cap_info and int(cap_info['version']) >= 2:
                package_is_dict = 1
                packagesV2 = packages

        for package in packages:
            if package_is_dict:
                # extended_profile >= 2
                if type(package) != type({}):
                    log_error("Invalid package spec for extended_profile >= 2",
                              type(package), "len = %d" % len(package))
                    raise rhnFault(21)
            else:
                # extended_profile < 2
                if (type(package) != type([]) or len(package) < 4):
                    log_error("Invalid package spec", type(package),
                              "len = %d" % len(package))
                    raise rhnFault(21)
                else:
                    p = {'name': package[0],
                         'version': package[1],
                         'release': package[2],
                         'epoch': package[3],
                         }
                    if len(package) > 4:
                        p['arch'] = package[4]
                    if len(package) > 5:
                        p['cookie'] = package[5]
                    packagesV2.append(p)
        return packagesV2

    def __add_hw_profile_no_auth(self, server, hwlist):
        """ Insert a new profile for the server, but do not authenticate """
        log_debug(1, server.getid(), "items: %d" % len(hwlist))
        for hardware in hwlist:
            server.add_hardware(hardware)
        # XXX: check return code
        server.save_hardware()

    def add_hw_profile(self, system_id, hwlist):
        """ Insert a new profile for the server """
        log_debug(5, system_id, hwlist)
        server = self.auth_system(system_id)
        self.__add_hw_profile_no_auth(server, hwlist)
        # set primary interface to the one that is used to reach the server
        sid = server.getid()
        h = rhnSQL.prepare("""
            select * from rhnServerNetwork where server_id = :server_id
        """)
        h.execute(server_id=sid)
        row = h.fetchone_dict()
        if row:
            ipaddr=row['ipaddr']
            ip6addr=row['ip6addr']
            if ipaddr:
                h = rhnSQL.prepare("""
                    select interface_id from rhnServerNetAddress4 where address = :address
                """)
                h.execute(address=ipaddr)
                row = h.fetchone_dict()
                if row:
                    primif=row['interface_id']
            elif ip6addr:
                h = rhnSQL.prepare("""
                    select interface_id from rhnServerNetAddress6 where address = :address
                """)
                h.execute(address=ip6addr)
                row = h.fetchone_dict()
                if row:
                    primif=row['interface_id']
            if primif:
                h = rhnSQL.prepare("""
                    update rhnservernetinterface set is_primary = 'Y' where id = :id
                """)
                h.execute(id=primif)
                rhnSQL.commit()
        return 0

    def refresh_hw_profile(self, system_id, hwlist):
        """ Recreate the server HW profile """
        log_debug(5, system_id, hwlist)
        server = self.auth_system(system_id)
        sid = server.getid()
        # clear out the existing list first
        # the only difference between add_hw_profile and refresh_hw_profile
        # make sure primary network interface does not get reset
        h = rhnSQL.prepare("""
            select name from rhnservernetinterface where server_id = :server_id AND is_primary ='Y'
        """)
        h.execute(server_id=sid)
        row = h.fetchone_dict()
        server.delete_hardware()
        self.__add_hw_profile_no_auth(server, hwlist)
        if row:
            h = rhnSQL.prepare("""
                update rhnservernetinterface set is_primary = 'Y' where server_id = :server_id AND name = :name
            """)
            h.execute(server_id=sid, name=row['name'])
            rhnSQL.commit()
        return 0

    def welcome_message(self, lang=None):
        """ returns string of welcome message """
        log_debug(1, "lang: %s" % lang)
        if lang:
            cat.setlangs(lang)
        msg = _("Red Hat Satellite Welcome Message")
        # compress this one
        rhnFlags.set("compress_response", 1)
        return msg

    def privacy_statement(self, lang=None):
        """ returns string of privacy statement """
        log_debug(1, "lang: %s" % lang)
        if lang:
            cat.setlangs(lang)
        msg = _("Red Hat Satellite Privacy Statement")
        # compress this one
        rhnFlags.set("compress_response", 1)
        return msg

    def register_product(self, system_id, product, oeminfo={}):
        """ register a product and record the data sent with the registration

            bretm:  hasn't registered a product or recorded anything since 2001, near
              as I can tell what it actually appears to be responsible for is
              protecting us against people registering systems from t7/t9
              countries

              actual use of registration numbers has been moved into the
              server_class.__save stuff
        """

        log_debug(5, system_id, product, oeminfo)
        if type(product) != type({}):
            log_error("Invalid argument type", type(product))
            raise rhnFault(21, _(
                "Expected a dictionary as a product argument"))
        log_debug(4, product)
        # As per bug 129996 using an activation key should not overwrite the
        # user's info. Also, the reg number stuff doesn't work anyway
        # Keep doing the authentication and then just bail out
        self.auth_system(system_id)
        return 0

    def update_contact_info(self, username, password, info={}):
        """ this API call is no longer used """
        log_debug(5, username, info)
        username, password = str(username), str(password)
        user = rhnUser.search(username)
        if user is None:
            log_error("invalid username", username)
            raise rhnFault(2)

        if not user.check_password(password):
            log_error("User password check failed", username)
            raise rhnFault(2)

        return 0

    def update_transactions(self, system_id, timestamp, transactions_hash):
        """ Updates the RPM transactions """
        log_debug(1)
        # Authenticate
        server = self.auth_system(system_id)
        # No op as of 20030923
        return 0

    def anonymous(self, release=None, arch=None):
        """ To reduce the number of tracebacks """
        log_debug(1, "Disabled!", release, arch)
        raise rhnFault(28)

    def finish_message(self, system_id):
        """ Presents the client with a message to display
            Returns:
            (returnCode, titleText, messageText)
            titleText is the window's title, messageText is the message displayed in
            that window by the client

            if returnCode is 1, the client
              will show the message in a window with the
              title of titleText, and allow the user to
              continue.
            if returnCode is -1, the client
              will show the message in a window with the
              title of titleText, and not allow the user
              to continue
            if returnCode is 0, no message
              screen will be shown.
        """
        log_debug(1)
        # Authenticate
        self.auth_system(system_id)

        return_code, text_title, text_message = \
            self.server.fetch_registration_message()
        if return_code:
            return return_code, text_title, text_message

        # If return_code is 0, check to see if we don't have a system-wide
        # message that we want to push
        return_code = int(CFG.REG_FINISH_MESSAGE_RETURN_CODE)
        if return_code == 0:
            # Nothing to display
            return (0, "", "")

        # We need to send back something
        text_title = CFG.REG_FINISH_MESSAGE_TITLE or ""
        text_file = CFG.REG_FINISH_MESSAGE_TEXT_FILE
        try:
            text_message = open(text_file).read()
        except IOError, e:
            log_error("reg_fishish_message_return_code is set, but file "
                      "%s invalid: %s" % (text_file, e))
            return (0, "", "")
        return (return_code, text_title, text_message)

    _query_get_dispatchers = rhnSQL.Statement("""
        select jabber_id from rhnPushDispatcher
    """)

    def _get_dispatchers(self):
        h = rhnSQL.prepare(self._query_get_dispatchers)
        h.execute()
        return map(lambda x: x['jabber_id'], h.fetchall_dict() or [])

    def register_osad(self, system_id, args={}):
        log_debug(1)

        # Authenticate
        server = self.auth_system(system_id)

        jabber_server = CFG.JABBER_SERVER
        if not jabber_server:
            log_error("Jabber server not defined")
            return {}

        server_timestamp, client_name, shared_key = \
            server.register_push_client()

        ret = args.copy()
        dispatchers = self._get_dispatchers()
        ret.update({
            'client-name': client_name,
            'shared-key': shared_key,
            'server-timestamp': server_timestamp,
            'jabber-server': jabber_server,
            'dispatchers': dispatchers,
        })
        return ret

    def register_osad_jid(self, system_id, args={}):
        log_debug(1)

        # Authenticate
        server = self.auth_system(system_id)

        if not args.has_key('jabber-id'):
            raise rhnFault(160, "No jabber-id specified", explain=0)

        jid = args['jabber-id']
        server.register_push_client_jid(jid)
        return {}

    def available_eus_channels(self, username, password, arch,
                               version, release, other=None):
        '''
        Given a server arch, redhat-release version, and redhat-release release
        returns the eligible channels for that system based on the entitlements
        in the org specified by username/password

        Returns a dict of the available channels in the format:
        {'default_channel' : 'channel_label',
         'receiving_updates' : ['channel_label1', 'channel_label2'],
         'channels' : {'channel_label1' : 'channel_name1',
         'channel_lable2' : 'channel_name2'}
        }
        '''

        user = rhnUser.search(username)

        if user is None:
            log_error("invalid username", username)
            raise rhnFault(2)

        if not user.check_password(password):
            log_error("User password check failed", username)
            raise rhnFault(2)

        server_arch = normalize_server_arch(arch)
        user_id = user.getid()
        org_id = user.contact['org_id']

        channels = rhnChannel.base_eus_channel_for_ver_rel_arch(
            version, release, server_arch,
            org_id, user_id)

        log_debug(4, "EUS Channels are: %s" % str(channels))

        default_channel = ''
        eus_channels = {}
        receiving_updates = []

        if channels is not None:
            eus_channels = {}
            for channel in channels:
                eus_channels[channel['label']] = channel['name']
                if channel['is_default'] == 'Y':
                    default_channel = channel['label']
                if channel['receiving_updates'] == 'Y':
                    receiving_updates.append(channel['label'])

        return {'default_channel': default_channel,
                'receiving_updates': receiving_updates,
                'channels': eus_channels}

    def remaining_subscriptions(self, username, password, arch, release):
        """ This is an obsoleted API call used in old RHEL5 clients to determine
            if they should show the "activate a subscription" page.
        """
        return 1

    def update_systemid(self, system_id):
        """ update_systemid: update client server and certificate
            In case the calling system is not using a certificate with a SHA-256
            checksum, update its secret and issue it a new client certificate.
        """
        server = self.auth_system(system_id)
        cert = Certificate()
        cert.reload(system_id)

        # System already uses certificate with a SHA-256 checksum,
        # we'll just return current systemid back
        if len(server.server['secret']) == 64:
            return cert.certificate()
        else:  # MD5 checksum
            server.set_arch(cert['architecture'])
            server.user = rhnUser.User("", "")
            server.user.reload(server.server['creator_id'])
            server.gen_secret()  # create new SHA-256 server secret
            server.save()
            return server.system_id()


def _faultValueString(value, name):
    return _("Invalid value '%s' for %s (%s)") % (
        str(value), str(name), type(value))


EOL_EMAIL = """
Dear Red Hat Satellite User,

This email has been autogenerated to alert you that you recently subscribed the
following system to an RHN channel related to a Red Hat Linux distribution that
has reached End of Life:

%(server)s

Distributions that have reached End of Life are no longer receiving maintenance
support (errata), which may make them unsuitable to your needs.

For more information regarding Red Hat Linux support, please go to:

http://www.redhat.com/apps/support/errata/

If you are interested in a distribution of Red Hat with a longer release
lifecycle, 5+ year maintenance period, ISV support, and enhanced functionality,
check out Red Hat Enterprise Linux at:

http://www.redhat.com/software/rhel/


Thank you for using Red Hat Satellite.
"""


#-------------------------------------------------------------------------------
