#
# Copyright (c) 2008--2012 Red Hat, Inc.
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
# Red Hat Network Management Satellite Incremental Synchronization Tool
#    main function.



# __lang. imports__
import datetime
import os
import sys
import stat
import string
import time
import types
import exceptions
import Queue
import threading
from optparse import Option, OptionParser
from rhn.connections import idn_ascii_to_pune, idn_pune_to_unicode

import gettext
t = gettext.translation('spacewalk-backend-server', fallback=True)
_ = t.ugettext

# __rhn imports__
from spacewalk.common import rhnMail, rhnLib, rhnFlags
from spacewalk.common.rhnLog import initLOG
from spacewalk.common.rhnConfig import CFG, initCFG
from spacewalk.common.rhnTB import exitWithTraceback
sys.path.append("/usr/share/rhn")
from up2date_client import config
from spacewalk.common import rhn_rpm
from spacewalk.common.checksum import getFileChecksum

from spacewalk.server import rhnSQL
from spacewalk.server.rhnSQL import SQLError, SQLSchemaError, SQLConnectError
from spacewalk.server.rhnServer import satellite_cert, server_packages
from spacewalk.server.rhnLib import get_package_path
from spacewalk.common import fileutils

initCFG('server.satellite')
initLOG(CFG.LOG_FILE, CFG.DEBUG)

# __rhn sync/import imports__
import xmlWireSource
import xmlDiskSource
from progress_bar import ProgressBar
from xmlSource import FatalParseException, ParseException
from diskImportLib import rpmsPath

from syncLib import log, log2, log2disk, log2stderr, log2email
from syncLib import RhnSyncException, RpmManip, ReprocessingNeeded
from syncLib import initEMAIL_LOG, dumpEMAIL_LOG
from syncLib import FileCreationError, FileManip

from SequenceServer import SequenceServer
from spacewalk.server.importlib.errataCache import schedule_errata_cache_update

from spacewalk.server.importlib.importLib import InvalidChannelFamilyError
from spacewalk.server.importlib.importLib import MissingParentChannelError
from spacewalk.server.importlib.importLib import get_nevra, get_nevra_dict

import satCerts
import req_channels
import messages
import sync_handlers
import constants

_DEFAULT_SYSTEMID_PATH = '/etc/sysconfig/rhn/systemid'
_DEFAULT_RHN_ENTITLEMENT_CERT_BACKUP = '/etc/sysconfig/rhn/rhn-entitlement-cert.xml'
DEFAULT_ORG = 1

# the option object is used everywhere in this module... make it a
# global so we don't have to pass it to everyone.
OPTIONS = None

class Runner:
    step_precedence = {
        'packages'                  : ['download-packages'],
        'source-packages'           : ['download-source-packages'],
        'errata'                    : ['download-errata'],
        'kickstarts'                : ['download-kickstarts'],
        'rpms'                      : [''],
        'srpms'                     : [''],
        'channels'                  : ['channel-families'],
        'channel-families'          : [''],
        'short'                     : [''],
        'download-errata'           : ['errata'],
        'download-packages'         : [''],
        'download-source-packages'  : [''],
        'download-kickstarts'       : [''],
        'arches'                    : [''], #5/26/05 wregglej 156079 Added arches to precedence list.
    }

    # The step hierarchy. We need access to it both for command line
    # processing and for the actions themselves
    step_hierarchy = [
        'channel-families',
        'arches',
        'channels',
        'short',
        'download-packages',
        'rpms',
        'packages',
        'srpms',
        'download-source-packages',
        'download-errata',
        'download-kickstarts',
        'source-packages',
        'errata',
        'kickstarts',
    ]
    def __init__(self):
        self.syncer = None
        self.packages_report = None
        self._xml_file_dir_error_message = ''
        self._affected_channels = None

    #5/24/05 wregglej - 156079 turn off a step's dependents in the step is turned off.
    def _handle_step_dependents(self, actionDict, step):
        ad = actionDict

        if ad.has_key(step):
            #if the step is turned off, then the steps that are dependent on it have to be turned
            #off as well.
            if ad[step] == 0:
                ad = self._turn_off_dependents(ad, step)

        #if the step isn't in the actionDict, then it's dependent actions must be turned off.
        else:
            ad = self._turn_off_dependents(ad, step)
        return ad

    #5/24/05 wregglej - 156079 actually turns off the dependent steps, which are listed in the step_precedence
    #dictionary.
    def _turn_off_dependents(self, actionDict, step):
        ad = actionDict
        for dependent in self.step_precedence[step]:
            if ad.has_key(dependent):
                ad[dependent] = 0
        return ad

    def main(self):
        """Main routine: commandline processing, etc..."""

        # let's time the whole process
        timeStart = time.time()

        actionDict, channels = processCommandline()

        #5/24/05 wregglej - 156079 turn off an step's dependent steps if it's turned off.
        #look at self.step_precedence for a listing of how the steps are dependent on each other.
        for st in self.step_hierarchy:
            actionDict = self._handle_step_dependents(actionDict, st)
        self._actions = actionDict

        #5/26/05 wregglej - 156079 have to handle the list-channels special case.
        if actionDict.has_key('list-channels'):
            if actionDict['list-channels'] == 1:
                actionDict['channels'] = 1
                actionDict['arches'] = 0
                actionDict['channel-families'] = 1
                channels = []

        # create and set permissions for package repository mountpoint.
        _verifyPkgRepMountPoint()

        if OPTIONS.email:
            initEMAIL_LOG()

        # init the synchronization processor
        self.syncer = Syncer(channels, actionDict['list-channels'], actionDict['rpms'],
                forceAllErrata=actionDict['force-all-errata'])
        try:
            self.syncer.initialize()
        except (KeyboardInterrupt, SystemExit):
            raise
        except xmlWireSource.rpclib.xmlrpclib.Fault, e:
            if CFG.ISS_PARENT:  
                # we met old satellite who do not know ISS
                log(-1, ['', messages.iss_not_available ], )
                sys.exit(26)
            else:
                log(-1, ['', messages.syncer_error % e.faultString], )
                sys.exit(9)
        except Exception, e:
            log(-1, ['', messages.syncer_error % e], )
            sys.exit(10)

        dbusername, dbpassword, dbinstance = _parseDbString(CFG.DEFAULT_DB)
        log(1, '   db:  %s/<password>@%s' % (dbusername, dbinstance))

        selected = filter(lambda action, ad=actionDict: ad[action],
                          actionDict.keys())
        log2(-1, 3, "Action list/commandline toggles: %s" % repr(selected),
            stream=sys.stderr)

        if OPTIONS.mount_point:
            self._xml_file_dir_error_message = messages.file_dir_error % \
                OPTIONS.mount_point

        for i in range(2):
            try:
                for step in self.step_hierarchy:
                    if not actionDict[step]:
                        continue
                    method_name = '_step_' + string.replace(step, '-', '_')
                    if not hasattr(self, method_name):
                        log(-1, _("No handler for step %s") % step)
                        continue
                    method = getattr(self, method_name)
                    ret = method()
                    if ret:
                        sys.exit(ret)
                else: # for
                    # Everything went fine
                    break
            except ReprocessingNeeded:
                # Try one more time - this time it should be faster since
                # everything should be cached
                log(1, _('Environment changed, trying again...'))
                continue
            except RhnSyncException:
                rhnSQL.rollback()
                raise
        else:
            log(1, _('Repeated failures'))

        timeEnd = time.time()
        delta_str = self._get_elapsed_time(timeEnd-timeStart)

        log(1, _("""\
    Import complete:
        Begin time: %s
        End time:   %s
        Elapsed:    %s
          """) % (formatDateTime(dt=time.localtime(timeStart)),
                  formatDateTime(dt=time.localtime(timeEnd)),
                  delta_str),
            cleanYN=1)

        # mail out that log if appropriate
        sendMail()
        return 0

    def _get_elapsed_time(self, elapsed):
        elapsed = int(elapsed)
        hours = elapsed/60/60
        mins = elapsed/60 - hours*60
        secs = elapsed - mins*60 - hours*60*60

        delta_list = [ [hours, _("hours")], [mins, _("minutes")], [secs, _("seconds")] ]
        delta_str = string.join(map(lambda l: "%s %s" % (l[0], l[1]),
                                    delta_list), ", ")
        return delta_str


    def _run_syncer_step(self, function, step_name):
        """ Runs a function, and catches the most common error cases """
        try:
            ret = function()
        except (xmlDiskSource.MissingXmlDiskSourceDirError,
                xmlDiskSource.MissingXmlDiskSourceFileError), e:
            log(-1, self._xml_file_dir_error_message +
                '\n       Error message: %s\n' % e)
            return 1
        except (KeyboardInterrupt, SystemExit):
            raise
        except xmlWireSource.rpclib.xmlrpclib.Fault, e:
            log(-1, messages.failed_step % (step_name, e.faultString))
            return 1
        except Exception, e:
            log(-1, messages.failed_step % (step_name, e))
            return 1
        return ret

    def _step_arches(self):
        self.syncer.processArches()

    def _step_channel_families(self):
        self.syncer.processChannelFamilies()
        # Sync the certificate (and update channel family permissions)
        if not CFG.ISS_PARENT:
            self.syncer.syncCert()

    def _step_channels(self):
        try:
            self.syncer.process_channels()
        except MissingParentChannelError, e:
            msg = messages.parent_channel_error % repr(e.channel)
            log(-1, msg)
            #log2email(-1, msg) # redundant
            sendMail()
            return 1

    def _step_short(self):
        try:
            return self.syncer.processShortPackages()
        except xmlDiskSource.MissingXmlDiskSourceFileError, e:
            msg = _("ERROR: The dump is missing package data, use --no-rpms to skip this step or fix the content to include package data.")
            log2disk(-1, msg)
            log2stderr(-1, msg, cleanYN=1)
            sys.exit(25)


    def _step_download_packages(self):
        return self.syncer.download_package_metadata()

    def _step_download_source_packages(self):
        return self.syncer.download_source_package_metadata()

    def _step_rpms(self):
        self._packages_report = self.syncer.download_rpms()
        return None

    # def _step_srpms(self):
    # 	return self.syncer.download_srpms()

    def _step_download_errata(self):
        return self.syncer.download_errata()

    def _step_download_kickstarts(self):
        return self.syncer.download_kickstarts()

    def _step_packages(self):
        self._affected_channels = self.syncer.import_packages()

    # def _step_source_packages(self):
    #     self.syncer.import_packages(sources=1)

    def _step_errata(self):
        self.syncer.import_errata()
        # Now that errata have been populated, schedule an errata cache
        # refresh
        schedule_errata_cache_update(self._affected_channels)

    def _step_kickstarts(self):
        self.syncer.import_kickstarts()

def sendMail(forceEmail=0):
    """ Send email summary """
    if forceEmail or (OPTIONS is not None and OPTIONS.email):
        body = dumpEMAIL_LOG()
        if body:
            print _("+++ sending log as an email +++")
            headers = {
                'Subject' : _('RHN Management Satellite sync. report from %s') % idn_pune_to_unicode(os.uname()[1]),
            }
            sndr = CFG.get('traceback_mail', 'root@localhost')
            rhnMail.send(headers, body, sender=sndr)
        else:
            print _("+++ email requested, but there is nothing to send +++")
        # mail was sent. Let's not allow it to be sent twice...
        OPTIONS.email = None


class Syncer:

    """ high-level sychronization/import class
        NOTE: there should *ONLY* be one instance of this.
    """

    def __init__(self, channels, listChannelsYN, check_rpms, forceAllErrata=False):
        """ Base initialization. Most work done in self.initialize() which
            needs to be called soon after instantiation.
        """

        self._requested_channels = channels
        self.mountpoint = OPTIONS.mount_point
        self.rhn_cert = OPTIONS.rhn_cert
        self.listChannelsYN = listChannelsYN
        self.forceAllErrata = forceAllErrata
        self.sslYN = not OPTIONS.no_ssl
        self._systemidPath = OPTIONS.systemid or _DEFAULT_SYSTEMID_PATH
        self._batch_size = OPTIONS.batch_size
        self.xml_dump_version = OPTIONS.dump_version or str(constants.PROTOCOL_VERSION)
        self.check_rpms = check_rpms

        # Object to help with channel math
        self._channel_req = None
        self._channel_collection = sync_handlers.ChannelCollection()

        self.containerHandler = sync_handlers.ContainerHandler()

        # instantiated in self.initialize()
        self.xmlDataServer = None
        self.systemid = None

        # self._*_full hold list of all ids for appropriate channel while
        # non-full self._* contain every id only once (in first channel it appeared)
        self._channel_packages = {}
        self._channel_packages_full = {}
        self._avail_channel_packages = {}

        self._missing_channel_packages = None
        self._missing_fs_packages = None

        self._failed_fs_packages = Queue.Queue()
        self._extinct_packages = Queue.Queue()

        self._channel_errata = {}
        self._missing_channel_errata = {}

        self._channel_source_packages = {}
        self._channel_source_packages_full = {}

        self._channel_kickstarts = {}

    def initialize(self):
        """Initialization that requires IO, etc."""

        # Sync from filesystem:
        if self.mountpoint:
            log(1, [_('Red Hat Network Satellite - file-system synchronization'),
                    '   mp:  %s' % self.mountpoint])
            self.xmlDataServer = xmlDiskSource.MetadataDiskSource(self.mountpoint)
        # Sync across the wire:
        else:
            self.xmlDataServer = xmlWireSource.MetadataWireSource(self.systemid,
                                                    self.sslYN, self.xml_dump_version)
            if CFG.ISS_PARENT:
                sync_parent = CFG.ISS_PARENT
                self.systemid = 'N/A'   # systemid is not used in ISS auth process
                is_iss = 1
            else:
                sync_parent = CFG.RHN_PARENT
                is_iss = 0

            url = self.xmlDataServer.schemeAndUrl(sync_parent)
            log(1, [_('Red Hat Network Satellite - live synchronization'),
                    _('   url: %s') % url,
                    _('   debug/output level: %s') % CFG.DEBUG])
            self.xmlDataServer.setServerHandler(isIss=is_iss)

            if not self.systemid:
                # check and fetch systemid (NOTE: systemid kept in memory... may or may not
                # be better to do it this way).
                if (os.path.exists(self._systemidPath)
                    and os.access(self._systemidPath, os.R_OK)):
                    self.systemid = open(self._systemidPath, 'rb').read()
                else:
                    raise RhnSyncException, _('ERROR: this server must be registered with RHN.'), sys.exc_info()[2]
            # authorization check of the satellite
            auth = xmlWireSource.AuthWireSource(self.systemid, self.sslYN,
                                                self.xml_dump_version)
            auth.checkAuth()

    def __del__(self):
        self.containerHandler.close()

    def _process_simple(self, remote_function_name, step_name):
        """ Wrapper function that can process metadata that is relatively
            simple. This does the decoding of data (over the wire or from
            disk).

            step_name is just for pretty printing the actual --step name to
            the console.

            The remote function is passed by name (as a string), to mimic the
            lazy behaviour of the if block
        """

        log(1, ["", _("Retrieving / parsing %s data") % step_name])
        # get XML stream
        stream = None
        method = getattr(self.xmlDataServer, remote_function_name)
        stream = method()

        # parse/process XML stream
        try:
            self.containerHandler.process(stream)
        except KeyboardInterrupt:
            log(-1, _('*** SYSTEM INTERRUPT CALLED ***'), stream=sys.stderr)
            raise
        except (FatalParseException, ParseException, Exception), e:
            # nuke the container batch upon error!
            self.containerHandler.clear()
            msg = ''
            if isinstance(e, FatalParseException):
                msg = (_('ERROR: fatal parser exception occurred ') +
                       _('(line: %s, col: %s msg: %s)') % (
                         e.getLineNumber(), e.getColumnNumber(),
                         e._msg))
            elif isinstance(e, ParseException):
                msg = (_('ERROR: parser exception occurred: %s') % (e))
            elif isinstance(e, exceptions.SystemExit):
                log(-1, _('*** SYSTEM INTERRUPT CALLED ***'), stream=sys.stderr)
                raise
            else:
                msg = _('ERROR: exception (during parse) occurred: ')
            log2stderr(-1, _('   Encountered some errors with %s data (see logs (%s) for more information)') % (step_name, CFG.LOG_FILE))
            log2(-1, 3, [_('   Encountered some errors with %s data:') % step_name,
                         _('   ------- %s PARSE/IMPORT ERROR -------') % step_name,
                         '   %s' % msg,
                         _('   ---------------------------------------')], stream=sys.stderr)
            exitWithTraceback(e, '', 11)
        self.containerHandler.reset()
        log(1, _("%s data complete") % step_name)

    def processArches(self):
        self._process_simple("getArchesXmlStream", "arches")
        self._process_simple("getArchesExtraXmlStream", "additional arches")

    def syncCert(self):
        "sync the RHN satellite cert if applicable (to local DB & filesystem)"

        store_cert = True
        if self.mountpoint:
            if self.rhn_cert:
                # Certificate was presented on the command line
                try:
                    cert = open(self.rhn_cert).read()
                except IOError, e:
                    raise RhnSyncException(_("Unable to open file %s: %s") % (
                        self.rhn_cert, e)), None, sys.exc_info()[2]
                cert = string.strip(cert)
            else:
                # Try to retrieve the certificate from the database
                row = satCerts.retrieve_db_cert()
                if row is None:
                    raise RhnSyncException(_("No certificate found. " 
                    "Please use --rhn-cert"))
                cert = row['cert']
                store_cert = False
        else:
            log2(1, 3, ["", _("RHN Entitlement Certificate sync")])
            certSource = xmlWireSource.CertWireSource(self.systemid, self.sslYN,
                                                      self.xml_dump_version)
            cert = string.strip(certSource.download())

        return self._process_cert(cert, store_cert)

    def _process_cert(self, cert, store_cert=1):
        """Give the cert a check - if it's broken xml we'd better find it out
           now
        """
        log2(1, 4, _("    - parsing for sanity"))
        sat_cert = satellite_cert.SatelliteCert()
        try:
            sat_cert.load(cert)
        except satellite_cert.ParseException:
            # XXX figure out what to do
            raise RhnSyncException(_("Error parsing the satellite cert")), None, sys.exc_info()[2]

        # Compare certificate generation - should match the stream's
        generation = rhnFlags.get('stream-generation')
        if sat_cert.generation != generation:
            raise RhnSyncException(_("""\
Unable to import certificate:
channel dump generation %s incompatible with cert generation %s.
Please contact your RHN representative""") % (generation, sat_cert.generation))


        satCerts.set_slots_from_cert(sat_cert, testonly=True)

        # push it into the database
        log2(1, 4, _("    - syncing to local database"))

        # possible place for bug 146395

        # Populate channel family permissions
        sync_handlers.populate_channel_family_permissions(sat_cert)

        # Get rid of the extra channel families
        sync_handlers.purge_extra_channel_families()

        if store_cert:
            # store it! (does a commit)
            # XXX bug 146395
            satCerts.storeRhnCert(cert)

        # Fix the channel family counts now
        sync_handlers.update_channel_family_counts()

        if store_cert:
            # save it to disk
            log2(1, 4, _("    - syncing to disk %s") %
                _DEFAULT_RHN_ENTITLEMENT_CERT_BACKUP)
            fileutils.rotateFile(_DEFAULT_RHN_ENTITLEMENT_CERT_BACKUP, depth=5)
            open(_DEFAULT_RHN_ENTITLEMENT_CERT_BACKUP, 'wb').write(cert)

        log2(1, 3, _("RHN Entitlement Certificate sync complete"))

    def processChannelFamilies(self):
        self._process_simple("getChannelFamilyXmlStream", "channel-families")
        try:
            self._process_simple("getProductNamesXmlStream", "product names")
        except Exception:
            None

    def _set_comps_for_channel(self, backend, channel_id, path, timestamp):
        sth = backend.dbmodule.prepare("""
                declare
                        /*pg_cs*/ cursor comps_data /*pg cursor*/ (cid_in numeric) is
                                select relative_filename, last_modified
                                from rhnChannelComps
                                where channel_id = cid_in;
                begin
                        for row in comps_data(:channel_id_in) loop
                                if row.relative_filename = :path_in
                                        and row.last_modified = to_date(:timestamp_in, 'YYYYMMDDHH24MISS') then
                                        return;
                                end if;
                        end loop;
                        delete from rhnChannelComps
                        where channel_id = :channel_id_in;
                        insert into rhnChannelComps (id, channel_id, relative_filename, last_modified, created, modified)
                        values (sequence_nextval('rhn_channelcomps_id_seq'), :channel_id_in, :path_in, to_date(:timestamp_in, 'YYYYMMDDHH24MISS'), current_timestamp, current_timestamp);
                end;
        """, params = ( 'channel_id_in numeric', 'path_in varchar', 'timestamp_in varchar' ))
        sth.execute(channel_id_in = channel_id, path_in = path, timestamp_in = timestamp)

    def _process_comps(self, backend, label, timestamp):
        comps_path = 'rhn/comps/%s/comps-%s.xml' % (label, timestamp)
        full_path = os.path.join(CFG.MOUNT_POINT, comps_path)
        if not os.path.exists(full_path):
            if self.mountpoint or CFG.ISS_PARENT:
                stream  = self.xmlDataServer.getComps(label)
            else:
                rpmServer = xmlWireSource.RPCGetWireSource(self.systemid, self.sslYN, self.xml_dump_version)
                stream = rpmServer.getCompsFileStream(label)
            f = FileManip(comps_path, timestamp, None)
            f.write_file(stream)
        data = { label : None }
        backend.lookupChannels(data)
        self._set_comps_for_channel(backend, data[label]['id'], comps_path, timestamp)

    def process_channels(self):
        """ push channels, channel-family and dist. map information
            as well upon parsing.
        """
        log(1, ["", _("Retrieving / parsing channel data")])

        h = sync_handlers.get_channel_handler()

        # get channel XML stream
        stream = self.xmlDataServer.getChannelXmlStream([])
        if self.mountpoint:
            for substream in stream:
                h.process(substream)
            doEOSYN = 0
        else:
            h.process(stream)
            doEOSYN = 1

        h.close()

        # clean up the channel request and populate self._channel_request
        # This essentially determines which channels are to be imported
        self._compute_channel_request()

        # print out the relevant channel tree
        #3/6/06 wregglej 183213 Don't print out the end-of-service message if 
        #satellite-sync is running with the --mount-point (-m) option. If it
        #did, it would incorrectly list channels as end-of-service if they had been 
        #synced already but aren't in the channel dump.
        self._printChannelTree(doEOSYN=doEOSYN)

        if self.listChannelsYN:
            # We're done here
            return

        requested_channels = self._channel_req.get_requested_channels()
        try:
            importer = sync_handlers.import_channels(requested_channels, \
                                          orgid=OPTIONS.orgid or None)
            for label in requested_channels:
                timestamp = self._channel_collection.get_channel_timestamp(label)
                ch = self._channel_collection.get_channel(label, timestamp)
                if ch.has_key('comps_last_modified') and ch['comps_last_modified'] != None:
                    self._process_comps(importer.backend, label, sync_handlers._to_timestamp(ch['comps_last_modified']))

        except InvalidChannelFamilyError:
            raise RhnSyncException(messages.invalid_channel_family_error %
                string.join(requested_channels)), None, sys.exc_info()[2]
        except MissingParentChannelError:
            raise

        rhnSQL.commit()

        log(1, _("Channel data complete"))

    def _formatChannelExportType(self, channel):
        """returns pretty formated text with type of channel export"""
        if 'export-type' not in channel or channel['export-type'] is None:
            return ''
        else:
            export_type = channel['export-type']
        if 'export-start-date' in channel and channel['export-start-date'] is not None:
            start_date = channel['export-start-date']
        else:
            start_date = ''
        if 'export-end-date' in channel and channel['export-end-date'] is not None:
            end_date = channel['export-end-date']
        else:
            end_date = ''
        if end_date and not start_date:
            return _("%10s import from %s") % (export_type,
                                               formatDateTime(end_date))
        elif end_date and start_date:
            return _("%10s import from %s - %s") % (export_type,
                                                    formatDateTime(start_date),
                                                    formatDateTime(end_date))
        else:
            return _("%10s") % export_type

    def _printChannel(self, label, channel_object, format, is_imported):
        assert channel_object is not None
        all_pkgs = channel_object['all-packages'] or channel_object['packages']
        pkgs_count = len(all_pkgs)
        if is_imported:
            status = _('p')
        else:
            status = _('.')
        log(1, format % (status, label, pkgs_count, self._formatChannelExportType(channel_object)))

    def _printChannelTree(self, doEOSYN=1, doTyposYN=1):
        "pretty prints a tree of channel information"

        log(1, _('   p = previously imported/synced channel'))
        log(1, _('   . = channel not yet imported/synced'))
        ch_end_of_service = self._channel_req.get_end_of_service()
        ch_typos = self._channel_req.get_typos()
        ch_requested_imported = self._channel_req.get_requested_imported()
        relevant = self._channel_req.get_requested_channels()
        if doEOSYN and ch_end_of_service:
            log(1, _('   e = channel no longer supported (end-of-service)'))
        if doTyposYN and ch_typos:
            log(1, _('   ? = channel label invalid --- typo?'))

        pc_labels = sorted(self._channel_collection.get_parent_channel_labels())

        t_format = _('   %s:')
        p_format = _('      %s %-40s %4s %s')
        log(1, t_format % _('base-channels'))
        # Relevant parent channels
        no_base_channel = True
        for plabel in pc_labels:
            if plabel not in relevant:
                continue

            no_base_channel = False
            timestamp = self._channel_collection.get_channel_timestamp(plabel)
            channel_object = self._channel_collection.get_channel(plabel,
                timestamp)
            self._printChannel(plabel, channel_object, p_format, (plabel in ch_requested_imported))
        if no_base_channel:
            log(1, p_format % (' ', _('NONE RELEVANT'), '', ''))

        # Relevant parent channels
        for plabel in pc_labels:
            cchannels = self._channel_collection.get_child_channels(plabel)
            # chns has only the channels we are interested in
            # (and that's all the channels if we list them)
            chns = []
            for clabel, ctimestamp in cchannels:
                if clabel in relevant:
                    chns.append((clabel, ctimestamp))
            if not chns:
                # No child channels, skip
                continue
            log(1, t_format % plabel)
            for clabel, ctimestamp in sorted(chns):
                channel_object = self._channel_collection.get_channel(clabel,
                    ctimestamp)
                self._printChannel(clabel, channel_object, p_format, (clabel in ch_requested_imported))
        log(2, '')

        if doEOSYN and ch_end_of_service:
            log(1, t_format % _('end-of-service'))
            status = _('e')
            for chn in ch_end_of_service:
                log(1, p_format % (status, chn, '', ''))
            log(2, '')

        if doTyposYN and ch_typos:
            log(1, _('   typos:'))
            status = _('?')
            for chn in ch_typos:
                log(1, p_format % (status, chn, '', ''))
            log(2, '')
        log(1, '')

    def _compute_channel_request(self):
        """ channels request is verify and categorized.

            NOTE: self.channel_req *will be* initialized by this method
        """

        # channels already imported, and all channels
        importedChannels = _getImportedChannels()
        availableChannels = self._channel_collection.get_channel_labels()
        log(6, _('XXX: imported channels: %s') % importedChannels, 1)
        log(6, _('XXX:   cached channels: %s') % availableChannels, 1)

        # if requested a channel list, we are requesting all channels
        if self.listChannelsYN:
            requested_channels = availableChannels
            log(6, _('XXX: list channels called'), 1)
        else:
            requested_channels = self._requested_channels

        rc = req_channels.RequestedChannels(requested_channels)
        rc.set_available(availableChannels)
        rc.set_imported(importedChannels)
        # rc does all the logic of doing intersections and stuff
        rc.compute()

        typos = rc.get_typos()
        if typos:
            log(-1, _("ERROR: these channels either do not exist or "
                        "are not available:"))
            for chn in typos:
                log(-1, "       %s" % chn)
            log(-1, _("       (to see a list of channel labels: %s --list-channels)") % sys.argv[0])
            sys.exit(12)
        self._channel_req = rc
        return rc

    def _get_channel_timestamp(self, channel):
        try:
            timestamp = self._channel_collection.get_channel_timestamp(channel)
        except KeyError:
            # XXX Do something with this exception
            raise
        return timestamp

    def _compute_unique_packages(self):
        """ process package metadata for one channel at a time """
        relevant = sorted(self._channel_req.get_requested_channels())
        self._channel_packages = {}
        self._channel_packages_full = {}
        self._avail_channel_packages = {}
        already_seen_ids = set()
        for chn in relevant:
            timestamp = self._get_channel_timestamp(chn)

            channel_obj = self._channel_collection.get_channel(chn, timestamp)
            avail_package_ids = sorted(set(channel_obj['packages'] or []))
            package_full_ids = sorted(set(channel_obj['all-packages'] or [])) or avail_package_ids
            package_ids = sorted(set(package_full_ids) - already_seen_ids)

            self._channel_packages[chn] = package_ids
            self._channel_packages_full[chn] = package_full_ids
            self._avail_channel_packages[chn] = avail_package_ids
            already_seen_ids.update(package_ids)

    def processShortPackages(self):
        log(1, ["", "Retrieving short package metadata (used for indexing)"])

        # Compute the unique packages and populate self._channel_packages
        self._compute_unique_packages()

        stream_loader = StreamProducer(
                sync_handlers.get_short_package_handler(),
                self.xmlDataServer, 'getChannelShortPackagesXmlStream')

        sorted_channels = sorted(self._channel_packages.items(), key=lambda x: x[0]) # sort by channel_label
        for channel_label, package_ids in sorted_channels:
            log(1, _("   Retrieving / parsing short package metadata: %s (%s)") %
                (channel_label, len(package_ids)))

            if package_ids:
                lm = self._channel_collection.get_channel_timestamp(channel_label)
                channel_last_modified = int(rhnLib.timestamp(lm))

                stream_loader.set_args(channel_label, channel_last_modified)
                stream_loader.process(package_ids)

        stream_loader.close()

        self._diff_packages()

    _query_compare_packages = """
        select p.id, c.checksum_type, c.checksum, p.path, p.package_size,
               TO_CHAR(p.last_modified, 'YYYYMMDDHH24MISS') last_modified
          from rhnPackage p
          join rhnChecksumView c
            on p.checksum_id = c.id
          join rhnPackageName pn
            on pn.id = p.name_id
          join rhnPackageEvr pe
            on p.evr_id = pe.id
          join rhnPackageArch pa
            on pa.id = p.package_arch_id
         where pn.name = :name
           and pe.epoch = :epoch and pe.version = :version and pe.release = :release
           and pa.name = :arch
           and (p.org_id = :org_id or
               (p.org_id is null and :org_id is null))
    """

    def _diff_packages_process(self, chunk, channel_label):
        package_collection = sync_handlers.ShortPackageCollection()

        h = rhnSQL.prepare(self._query_compare_packages)
        for pid in chunk:
            p_timestamp = package_collection.get_package_timestamp(pid)
            l_timestamp = rhnLib.timestamp(p_timestamp)
            package = package_collection.get_package(pid, p_timestamp)
            assert package is not None

            if package['org_id'] is not None:
                package['org_id'] = OPTIONS.orgid  or DEFAULT_ORG
            nevra = get_nevra_dict(package)
            nevra['org_id'] = package['org_id']

            h.execute(**nevra)
            row = None
            for r in (h.fetchall_dict() or []):
                # let's check which checksum we have in database
                if r['checksum_type'] in package['checksums'] and package['checksums'][r['checksum_type']] == r['checksum']:
                    row = r
                    break

            self._process_package(pid, package, l_timestamp, row,
                self._missing_channel_packages[channel_label],
                self._missing_fs_packages[channel_label],
                source=0, check_rpms=self.check_rpms)

    # XXX the "is null" condition will have to change in multiorg satellites
    def _diff_packages(self):
        self._missing_channel_packages = {}
        self._missing_fs_packages = {}

        sorted_channels = sorted(self._channel_packages.items(), key=lambda x: x[0]) # sort by channel_label
        for channel_label, upids in sorted_channels:
            log(1, _("Diffing package metadata (what's missing locally?): %s") %
                channel_label)
            self._missing_channel_packages[channel_label] = []
            self._missing_fs_packages[channel_label] = []
            self._proces_batch(channel_label, upids[:], None,
                                self._diff_packages_process,
                                _('Diffing:    '),
                                [channel_label])

        self._verify_missing_channel_packages(self._missing_channel_packages)

    def _verify_missing_channel_packages(self, missing_channel_packages, sources=0):
        """Verify if all the missing packages are actually available somehow.
        In an incremental approach, one may request packages that are actually
        not available in the current dump, probably because of applying an
        incremental to the wrong base"""
        for channel_label, pids in missing_channel_packages.items():
            if sources:
                avail_pids = map(lambda x: x[0], self._avail_channel_source_packages[channel_label])
            else:
                avail_pids = self._avail_channel_packages[channel_label]

            if set(pids or []) > set(avail_pids or []):
                raise RhnSyncException, _('ERROR: incremental dump skipped')

    def _get_rel_package_path(self, nevra, org_id, source, checksum_type, checksum):
        return get_package_path(nevra, org_id, prepend=CFG.PREPENDED_DIR,
            source=source, checksum_type=checksum_type, checksum=checksum)

    def _verify_file(self, path, mtime, size, checksum_type, checksum):
        """
        Verifies if the file is on the filesystem and matches the mtime and checksum.
        Computing the checksum is costly, that's why we rely on mtime comparisons.
        Returns errcode:
            0   - file is ok, it has either the specified mtime and size
                          or checksum matches (then function sets mtime)
            1   - file does not exist at all
            2   - file has a different checksum
        """
        if not path:
            return 1
        abs_path = os.path.join(CFG.MOUNT_POINT, path)
        try:
            stat_info = os.stat(abs_path)
        except OSError:
            # File is missing completely
            return 1

        l_mtime = stat_info[stat.ST_MTIME]
        l_size = stat_info[stat.ST_SIZE]
        if l_mtime == mtime and l_size == size:
            # Same mtime, and size, assume identity
            return 0

        # Have to check checksum
        l_checksum = getFileChecksum(checksum_type, filename=abs_path)
        if l_checksum != checksum:
            return 2

        # Set the mtime
        os.utime(abs_path, (mtime, mtime))
        return 0

    def _process_package(self, package_id, package, l_timestamp, row,
            m_channel_packages, m_fs_packages, source=0, check_rpms=1):
        path = None
        channel_package = None
        fs_package      = None
        if row:
            # package found in the DB
            checksum_type = row['checksum_type']
            if checksum_type in package['checksums']:
                checksum = package['checksums'][row['checksum_type']]
                package_size = package['package_size']

                db_timestamp = int(rhnLib.timestamp(row['last_modified']))
                db_checksum = row['checksum']
                db_package_size = row['package_size']
                db_path = row['path']

                if not (l_timestamp <= db_timestamp and
                    checksum == db_checksum and
                    package_size == db_package_size):
                    # package doesn't match
                    channel_package = package_id

                if check_rpms:
                    if db_path:
                        # check the filesystem
                        errcode = self._verify_file(db_path, l_timestamp,
                                package_size, checksum_type, checksum)
                        if errcode:
                            # file doesn't match
                            fs_package = package_id
                            channel_package = package_id
                        path = db_path
                    else:
                        # upload package and reimport metadata
                        channel_package = package_id
                        fs_package = package_id
        else:
            # package is missing from the DB
            channel_package = package_id
            fs_package = package_id

        if channel_package:
            m_channel_packages.append(channel_package)
        if fs_package:
            m_fs_packages.append((fs_package, path))
        return

    def download_rpms(self):
        log(1, ["", _("Downloading rpm packages")])
        # Lets go fetch the packages and push them to their proper location:
        sorted_channels = sorted(self._missing_fs_packages.items(), key=lambda x: x[0]) # sort by channel
        for channel, missing_fs_packages in sorted_channels:
            missing_packages_count = len(missing_fs_packages)
            log(1, _("   Fetching any missing RPMs: %s (%s)") %
                (channel, missing_packages_count or _('NONE MISSING')))
            if missing_packages_count == 0:
                continue

            # Fetch all RPMs whose meta-data is marked for need to be imported
            # (ie. high chance of not being there)
            self._fetch_packages(channel, missing_fs_packages)
            continue

        log(1, _("Processing rpm packages complete"))

    def _missing_not_cached_packages(self):
        missing_packages = {}

        # First, determine what has to be downloaded
        short_package_collection = sync_handlers.ShortPackageCollection()
        package_collection = sync_handlers.PackageCollection()
        for channel, pids in self._missing_channel_packages.items():
            missing_packages[channel] = mp = []

            if not pids:
                # Nothing to see here
                continue

            for pid in pids:
                # XXX Catch errors
                timestamp = short_package_collection.get_package_timestamp(pid)
                if not package_collection.has_package(pid, timestamp):
                    # not in the cache
                    mp.append(pid)

        return missing_packages

    def download_package_metadata(self):
        log(1, ["", _("Downloading package metadata")])
        # Get the missing but uncached packages
        missing_packages = self._missing_not_cached_packages()

        stream_loader = StreamProducer(
                sync_handlers.get_package_handler(),
                self.xmlDataServer, 'getPackageXmlStream')

        sorted_channels = sorted(missing_packages.items(), key=lambda x: x[0]) # sort by channel
        for channel, pids in sorted_channels:
            self._proces_batch(channel, pids[:], messages.package_parsing,
                               stream_loader.process, is_slow=True)
        stream_loader.close()

        # Double-check that we got all the packages
        missing_packages = self._missing_not_cached_packages()
        for channel, pids in missing_packages.items():
            if pids:
                # Something may have changed from the moment we started to
                # download the packages till now
                raise ReprocessingNeeded

    def download_srpms(self):
        self._compute_unique_source_packages()
        self._diff_source_packages()
        log(1, ["", _("Downloading srpm packages")])
        # Lets go fetch the source packages and push them to their proper location:
        sorted_channels = sorted(self._missing_fs_source_packages.items(), key=lambda x: x[0]) # sort by channel_label
        for channel, missing_fs_source_packages in sorted_channels:
            missing_source_packages_count = len(missing_fs_source_packages)
            log(1, _("   Fetching any missing SRPMs: %s (%s)") %
                (channel, missing_source_packages_count or _('NONE MISSING')))
            if missing_source_packages_count == 0:
                continue

            # Fetch all SRPMs whose meta-data is marked for need to be imported
            # (ie. high chance of not being there)
            self._fetch_packages(channel, missing_fs_source_packages, sources=1)
            continue

        log(1, "Processing srpm packages complete")

    def _compute_unique_source_packages(self):
        """ process package metadata for one channel at a time"""
        relevant = self._channel_req.get_requested_channels()
        self._channel_source_packages = {}
        self._channel_source_packages_full = {}
        self._avail_channel_source_packages = {}

        already_seen_ids = set()
        for chn in relevant:
            timestamp = self._get_channel_timestamp(chn)

            channel_obj = self._channel_collection.get_channel(chn, timestamp)
            sps = set(channel_obj['source_packages'])
            if not sps:
                # No source package info
                continue
            ret_sps = []
            for sp in sps:
                if isinstance(sp, types.StringType):
                    # Old style
                    ret_sps.append((sp, None))
                else:
                    ret_sps.append((sp['id'], sp['last_modified']))
            del sps
            ret_sps.sort()
            self._channel_source_packages[chn] = sorted(set(ret_sps)-already_seen_ids)
            self._channel_source_packages_full[chn] = ret_sps
            self._avail_channel_source_packages[chn] = ret_sps
            already_seen_ids.update(ret_sps)

    def _compute_not_cached_source_packages(self):
        missing_sps = {}

        # First, determine what has to be downloaded
        sp_collection = sync_handlers.SourcePackageCollection()
        for channel, sps in self._channel_source_packages.items():
            missing_sps[channel] = []
            if not sps:
                # Nothing to see here
                continue
            missing_sps[channel] = [sp_id for (sp_id, timestamp) in sps
                                          if not sp_collection.has_package(sp_id, timestamp)]
        return missing_sps

    _query_compare_source_packages = """
        select ps.id, c.checksum_type, c.checksum, ps.path, ps.package_size,
               TO_CHAR(ps.last_modified, 'YYYYMMDDHH24MISS') last_modified
          from rhnPackageSource ps, rhnChecksumView c
         where ps.source_rpm_id = lookup_source_name(:package_id)
           and (ps.org_id = :org_id or
               (ps.org_id is null and :org_id is null))
           and ps.checksum_id = c.id
           and c.checksum = :checksum
           and c.checksum_type = :checksum_type
    """
    def _diff_source_packages_process(self, chunk, channel_label):
        package_collection = sync_handlers.SourcePackageCollection()
        sql_params = ['package_id', 'checksum', 'checksum_type']
        h = rhnSQL.prepare(self._query_compare_source_packages)
        for pid, timestamp in chunk:
            package = package_collection.get_package(pid, timestamp)
            assert package is not None

            params = {}
            for t in sql_params:
                params[t] = package[t] or ""

            if package['org_id'] is not None:
                params['org_id'] = OPTIONS.orgid or DEFAULT_ORG
                package['org_id'] = OPTIONS.orgid  or DEFAULT_ORG
            else:
                params['org_id'] = package['org_id']

            apply(h.execute, (), params)
            row = h.fetchone_dict()
            self._process_package(pid, package, None, row,
                self._missing_channel_source_packages[channel_label],
                self._missing_fs_source_packages[channel_label],
                source=1)

    # XXX the "is null" condition will have to change in multiorg satellites
    def _diff_source_packages(self):
        self._missing_channel_source_packages = {}
        self._missing_fs_source_packages = {}
        for channel_label, upids in self._channel_source_packages.items():
            log(1, _("Diffing source package metadata (what's missing locally?): %s") % channel_label)
            self._missing_channel_source_packages[channel_label] = []
            self._missing_fs_source_packages[channel_label] = []
            self._proces_batch(channel_label, upids[:], None,
                                         self._diff_source_packages_process,
                                         _('Diffing:    '),
                                         [channel_label])

        self._verify_missing_channel_packages(self._missing_channel_source_packages, sources=1)

    def download_source_package_metadata(self):
        log(1, ["", _("Downloading source package metadata")])

        # Get the missing but uncached packages
        missing_packages = self._compute_not_cached_source_packages()

        stream_loader = StreamProducer(
                sync_handlers.get_source_package_handler(),
                self.xmlDataServer, 'getSourcePackageXmlStream')

        for channel, pids in missing_packages.items():
            self._proces_batch(channel, pids[:], messages.package_parsing,
                               stream_loader.process, is_slow=True)
        stream_loader.close()

        # Double-check that we got all the packages
        missing_packages = self._compute_not_cached_source_packages()
        for channel, pids in missing_packages.items():
            if pids:
                # Something may have changed from the moment we started to
                # download the packages till now
                raise ReprocessingNeeded

    def _compute_unique_kickstarts(self):
        """ process package metadata for one channel at a time"""
        relevant = self._channel_req.get_requested_channels()
        self._channel_kickstarts = {}
        already_seen_kickstarts = set()
        for chn in relevant:
            timestamp = self._get_channel_timestamp(chn)

            channel_obj = self._channel_collection.get_channel(chn, timestamp)
            self._channel_kickstarts[chn] = \
			sorted(set(channel_obj['kickstartable_trees'])
                               - already_seen_kickstarts)
            already_seen_kickstarts.update(self._channel_kickstarts[chn])

    def _compute_missing_kickstarts(self):
        """ process package metadata for one channel at a time"""
        relevant = self._channel_req.get_requested_channels()
        coll = sync_handlers.KickstartableTreesCollection()
        missing_kickstarts = {}
        for chn in relevant:
            timestamp = self._get_channel_timestamp(chn)

            channel_obj = self._channel_collection.get_channel(chn, timestamp)
            kickstart_trees = channel_obj['kickstartable_trees']

            for ktid in kickstart_trees:
                # No timestamp for kickstartable trees
                kt = coll.get_item(ktid, timestamp=None)
                assert kt is not None
                kt_label = kt['label']

                # XXX rhnKickstartableTree does not have a last_modified
                # Once we add it, we should be able to do more meaningful
                # diffs
                missing_kickstarts[kt_label] = None

        ret = missing_kickstarts.items()
        ret.sort()
        return ret

    def _download_kickstarts_file(self, chunk, channel_label):
        cfg = config.initUp2dateConfig()
        assert len(chunk) == 1
        item = chunk[0]
        label, base_path, relative_path, timestamp, file_size = item
        path = os.path.join(base_path, relative_path)
        f = FileManip(path, timestamp=timestamp, file_size=file_size)
        # Retry a number of times, we may have network errors
        for i in range(cfg['networkRetries']):
            stream = self._get_ks_file_stream(channel_label, label, relative_path)
            try:
                f.write_file(stream)
                break # inner for
            except FileCreationError, e:
                msg = e[0]
                log2disk(-1, _("Unable to save file %s: %s") % (path,
                    msg))
                # Try again
                continue
        else: # for
            # Retried a number of times and it still failed; log the
            # file as being failed and move on
            log2disk(-1, _("Failed to fetch file %s") % path)

    def download_kickstarts(self):
        """Downloads all the kickstart-related information"""

        log(1, ["", _("Downloading kickstartable trees metadata")])

        self._compute_unique_kickstarts()

        stream_loader = StreamProducer(
                sync_handlers.get_kickstarts_handler(),
                self.xmlDataServer, 'getKickstartsXmlStream')

        for channel, ktids in self._channel_kickstarts.items():
            self._proces_batch(channel, ktids[:], messages.kickstart_parsing,
                               stream_loader.process)
        stream_loader.close()

        missing_ks_files = self._compute_missing_ks_files()

        log(1, ["", _("Downloading kickstartable trees files")])
        sorted_channels = sorted(missing_ks_files.items(), key=lambda x: x[0]) # sort by channel
        for channel, files in sorted_channels:
            self._proces_batch(channel, files[:], messages.kickstart_downloading,
                               self._download_kickstarts_file,
                               nevermorethan=1,
                               process_function_args=[channel])

    def _get_ks_file_stream(self, channel, kstree_label, relative_path):
        if self.mountpoint:
            s = xmlDiskSource.KickstartFileDiskSource(self.mountpoint)
            s.setID(kstree_label)
            s.set_relative_path(relative_path)
            return s.load()

        if CFG.ISS_PARENT:
            return self.xmlDataServer.getKickstartFile(kstree_label, relative_path)
        else:
            srv = xmlWireSource.RPCGetWireSource(self.systemid, self.sslYN,
                                                 self.xml_dump_version)
            return srv.getKickstartFileStream(channel, kstree_label, relative_path)

    def _compute_missing_ks_files(self):
        coll = sync_handlers.KickstartableTreesCollection()

        missing_ks_files = {}
        # download files for the ks trees
        for channel, ktids in self._channel_kickstarts.items():
            missing_ks_files[channel] = missing = []
            for ktid in ktids:
                # No timestamp for kickstartable trees
                kt = coll.get_item(ktid, timestamp=None)
                assert kt is not None
                kt_label = kt['label']
                base_path = kt['base_path']
                files = kt['files']
                for f in files:
                    relative_path = f['relative_path']
                    dest_path = os.path.join(base_path, relative_path)
                    timestamp = rhnLib.timestamp(f['last_modified'])
                    file_size = f['file_size']
                    errcode = self._verify_file(dest_path,
                        timestamp, file_size, f['checksum_type'], f['checksum'])
                    if errcode != 0:
                        # Have to download it
                        val = (kt_label, base_path, relative_path,
                            timestamp, file_size)
                        missing.append(val)
        return missing_ks_files

    def import_kickstarts(self):
        """Imports the kickstart-related information"""

        missing_kickstarts = self._compute_missing_kickstarts()

        if not missing_kickstarts:
            log(1, messages.kickstart_import_nothing_to_do)
            return

        ks_count = len(missing_kickstarts)
        log(1, messages.kickstart_importing % ks_count)

        coll = sync_handlers.KickstartableTreesCollection()
        batch = []
        for ks, timestamp in missing_kickstarts:
            ksobj = coll.get_item(ks, timestamp=timestamp)
            assert ksobj is not None

            if ksobj['org_id'] is not None:
                ksobj['org_id'] = OPTIONS.orgid or DEFAULT_ORG
            batch.append(ksobj)

        importer = sync_handlers.import_kickstarts(batch)
        log(1, messages.kickstart_imported % ks_count)

    def _compute_not_cached_errata(self):
        missing_errata = {}

        # First, determine what has to be downloaded
        errata_collection = sync_handlers.ErrataCollection()
        for channel, errata in self._channel_errata.items():
            missing_errata[channel] = []
            if not errata:
                # Nothing to see here
                continue
            missing_errata[channel] = [eid for (eid, timestamp, advisory_name) in errata
                                               if not errata_collection.has_erratum(eid, timestamp)
                                                  or self.forceAllErrata]
        return missing_errata

    _query_get_db_errata = rhnSQL.Statement("""
        select e.id, e.advisory_name,
               TO_CHAR(e.last_modified, 'YYYYMMDDHH24MISS') last_modified
          from rhnChannelErrata ce, rhnErrata e, rhnChannel c
         where c.label = :channel
           and ce.channel_id = c.id
           and ce.errata_id = e.id
    """)

    def _get_db_channel_errata(self):
        """
        Fetch the errata stored in the local satellite's database. Returned
        as a hash of channel to another hash of advisory names to a tuple of
        errata id and last modified date.
        """
        db_channel_errata = {}
        relevant = self._channel_req.get_requested_channels()
        h = rhnSQL.prepare(self._query_get_db_errata)
        for channel in relevant:
            db_channel_errata[channel] = ce = {}
            h.execute(channel=channel)
            while 1:
                row = h.fetchone_dict()
                if not row:
                    break
                advisory_name = row['advisory_name']
                erratum_id = row['id']
                last_modified = rhnLib.timestamp(row['last_modified'])
                ce[advisory_name] = (erratum_id, last_modified)
        return db_channel_errata

    def _diff_errata(self):
        """ Fetch the errata for this channel"""
        db_channel_errata = self._get_db_channel_errata()

        relevant = self._channel_req.get_requested_channels()

        # Now get the channel's errata
        channel_errata = {}
        for chn in relevant:
            db_ce = db_channel_errata[chn]
            timestamp = self._get_channel_timestamp(chn)

            channel_obj = self._channel_collection.get_channel(chn, timestamp)
            errata_timestamps = channel_obj['errata_timestamps']
            if errata_timestamps is None or self.forceAllErrata:
                # No unique key information, so assume we need all errata
                erratum_ids = channel_obj['errata']
                errata = map(lambda x: (x, None, None), erratum_ids)
                log(2, _("Grabbing all errata for channel %s") % chn)
            else:
                errata = []
                # Check the advisory name and last modification
                for erratum in errata_timestamps:
                    erratum_id = erratum['id']
                    last_modified = erratum['last_modified']
                    last_modified = rhnLib.timestamp(last_modified)
                    advisory_name = erratum['advisory_name']
                    if db_ce.has_key(advisory_name):
                        foo, db_last_modified = db_ce[advisory_name]
                        if last_modified == db_last_modified:
                            # We already have this erratum
                            continue
                    errata.append((erratum_id, last_modified, advisory_name))
            errata.sort()
            channel_errata[chn] = errata

        # Uniquify the errata
        already_seen_errata = set()
        for channel, errata in channel_errata.items():
            uq_errata = set(errata) - already_seen_errata
            self._channel_errata[channel] = sorted(uq_errata)
            already_seen_errata.update(uq_errata)

    def _diff_db_errata(self):
        """ Compute errata that are missing from the satellite
            Kind of similar to diff_errata, if we had the timestamp and advisory
            information available
        """
        errata_collection = sync_handlers.ErrataCollection()
        self._missing_channel_errata = missing_channel_errata = {}
        db_channel_errata = self._get_db_channel_errata()
        for channel, errata in self._channel_errata.items():
            ch_erratum_ids = missing_channel_errata[channel] = []
            for eid, timestamp, advisory_name in errata:
                if timestamp is not None:
                    # Should have been caught by diff_errata
                    ch_erratum_ids.append((eid, timestamp, advisory_name))
                    continue
                # timestamp is None, grab the erratum from the cache
                erratum = errata_collection.get_erratum(eid, timestamp)
                timestamp = rhnLib.timestamp(erratum['last_modified'])
                advisory_name = erratum['advisory_name']
                db_erratum = db_channel_errata[channel].get(advisory_name)
                if db_erratum is None or db_erratum[1] != timestamp or \
                    self.forceAllErrata:
                    ch_erratum_ids.append((eid, timestamp, advisory_name))

    def download_errata(self):
        log(1, ["", _("Downloading errata data")])
        if self.forceAllErrata:
            log(2, _("Forcing download of all errata data for requested channels."))
        self._diff_errata()
        not_cached_errata = self._compute_not_cached_errata()
        stream_loader = StreamProducer(
                sync_handlers.get_errata_handler(),
                self.xmlDataServer, 'getErrataXmlStream')

        sorted_channels = sorted(not_cached_errata.items(), key=lambda x: x[0]) # sort by channel
        for channel, erratum_ids in sorted_channels:
            self._proces_batch(channel, erratum_ids[:], messages.erratum_parsing,
                               stream_loader.process)
        stream_loader.close()
        # XXX This step should go away once the channel info contains the
        # errata timestamps and advisory names
        self._diff_db_errata()
        log(1, _("Downloading errata data complete"))

    # __private methods__
    def _processWithProgressBar(self, batch, size,
                                process_function,
                                prompt=_('Downloading:'),
                                nevermorethan=None,
                                process_function_args=[]):
        pb = ProgressBar(prompt=prompt, endTag=_(' - complete'),
                finalSize=size, finalBarLength=40, stream=sys.stdout)
        if CFG.DEBUG > 2:
            pb.redrawYN = 0
        pb.printAll(1)

        ss = SequenceServer(batch, nevermorethan=(nevermorethan or self._batch_size))
        while not ss.doneYN():
            chunk = ss.getChunk()
            item_count = len(chunk)
            process_function(chunk, *process_function_args)
            ss.clearChunk()
            pb.addTo(item_count)
            pb.printIncrement()
        pb.printComplete()

    def _proces_batch(self, channel, batch, log_msg,
                      process_function,
                      prompt=_('Downloading:'),
                      process_function_args=[],
                      nevermorethan=None,
                      is_slow=False):
        count = len(batch)
        if log_msg:
            log(1, log_msg % (channel, count or _('NONE RELEVANT')))
        if not count:
            return
        if is_slow:
            log(1, messages.warning_slow)
        self._processWithProgressBar(batch, count, process_function,
                        prompt, nevermorethan, process_function_args)

    def _import_packages_process(self, chunk, sources):
        batch = self._get_cached_package_batch(chunk, sources)
        # check to make sure the orgs exported are valid
        _validate_package_org(batch)
        try:
            sync_handlers.import_packages(batch, sources)
        except (SQLError, SQLSchemaError, SQLConnectError), e:
            # an SQL error is fatal... crash and burn
            exitWithTraceback(e, 'Exception caught during import', 13)

    def import_packages(self, sources=0):
        if sources:
            log(1, ["", _("Importing source package metadata")])
            missing_channel_items = self._missing_channel_source_packages
        else:
            log(1, ["", _("Importing package metadata")])
            missing_channel_items = self._missing_channel_packages

        sorted_channels = sorted(missing_channel_items.items(), key=lambda x: x[0]) # sort by channel
        for channel, packages in sorted_channels:
            self._proces_batch(channel, packages[:],
                        messages.package_importing,
                        self._import_packages_process,
                        _('Importing:  '),
                        [sources])
        return self._link_channel_packages()

    def _link_channel_packages(self):
        log(1, ["", messages.link_channel_packages])
        short_package_collection = sync_handlers.ShortPackageCollection()
        package_collection = sync_handlers.PackageCollection()
        uq_packages = {}
        for chn, package_ids in self._channel_packages_full.items():
            for pid in package_ids:
                timestamp = short_package_collection.get_package_timestamp(pid)
                package = short_package_collection.get_package(pid, timestamp)
                if not package:
                    continue
                assert package is not None
                channel_obj = {'label' : chn}
                if uq_packages.has_key(pid):
                    # We've seen this package before - just add this channel
                    # to it
                    uq_packages[pid]['channels'].append(channel_obj)
                else:
                    package['channels'] = [channel_obj]
                    uq_packages[pid] = package

        uq_pkg_data = uq_packages.values()
        # check to make sure the orgs exported are valid
        _validate_package_org(uq_pkg_data)
        try:
            if OPTIONS.mount_point: # if OPTIONS.consider_full is not set interpret dump as incremental
                importer = sync_handlers.link_channel_packages(uq_pkg_data, strict=OPTIONS.consider_full)
            else:
                importer = sync_handlers.link_channel_packages(uq_pkg_data)
        except (SQLError, SQLSchemaError, SQLConnectError), e:
            # an SQL error is fatal... crash and burn
            exitWithTraceback(e, 'Exception caught during import', 14)
        return importer.affected_channels

    def _get_cached_package_batch(self, chunk, sources=0):
        """ short-circuit the most common case"""
        if not chunk:
            return []
        short_package_collection = sync_handlers.ShortPackageCollection()
        if sources:
            package_collection = sync_handlers.SourcePackageCollection()
        else:
            package_collection = sync_handlers.PackageCollection()
        batch = []
        for pid in chunk:
            timestamp = short_package_collection.get_package_timestamp(pid)
            package = package_collection.get_package(pid, timestamp)
            if package is None:
                # not in the cache
                raise Exception(_("Package Not Found in Cache, Clear the Cache to \
		                 Regenerate it."))
            batch.append(package)
        return batch

    def import_errata(self):
        log(1, ["", _("Importing channel errata")])
        errata_collection = sync_handlers.ErrataCollection()
        sorted_channels = sorted(self._missing_channel_errata.items(), key=lambda x: x[0]) # sort by channel_label
        for chn, errata in sorted_channels:
            log(2, _("Importing %s errata for channel %s.") % (len(errata), chn))
            batch = []
            for eid, timestamp, advisory_name in errata:
                erratum = errata_collection.get_erratum(eid, timestamp)
                # bug 161144: it seems that incremental dumps can create an
                # errata collection None
                if erratum is not None:
                    self._fix_erratum(erratum)
                    batch.append(erratum)

            self._proces_batch(chn, batch, messages.errata_importing,
                        sync_handlers.import_errata)

    def _fix_erratum(self, erratum):
        """ Replace the list of packages with references to short packages"""
        sp_coll = sync_handlers.ShortPackageCollection()
        pids = set(erratum['packages'] or [])
        # map all the pkgs objects to the erratum
        packages = []
        # remove packages which are not in the export (e.g. archs we are not syncing)
        for pid in pids:
            try:
                timestamp = sp_coll.get_package_timestamp(pid)
            except KeyError:
                # Package not found, go on - may be part of a channel we don't
                # sync
                continue
            package = sp_coll.get_package(pid, timestamp)

            packages.append(package)

        erratum['packages'] = packages

        if erratum['org_id'] is not None:
            erratum['org_id'] = OPTIONS.orgid or DEFAULT_ORG

        # Associate errata to only channels that are being synced
        # or are synced already
        imported_channels = _getImportedChannels()
        if OPTIONS.channel:
            imported_channels += OPTIONS.channel
        erratum['channels'] = [c for c in erratum['channels']
                                     if c['label'] in imported_channels]

        # Now fix the files
        for errata_file in (erratum['files'] or []):
            errata_file_package = errata_file.get('package')
            errata_file_source_package = errata_file.get('source-package')
            if errata_file['file_type'] == 'RPM' and \
                    errata_file_package is not None:
                try:
                    timestamp = sp_coll.get_package_timestamp(errata_file_package)
                    package = sp_coll.get_package(errata_file_package, timestamp)
                except KeyError:
                    package = None
                errata_file['pkgobj'] = package
            elif errata_file['file_type'] == 'SRPM' and \
                    errata_file_source_package is not None:
                # XXX misa: deal with source rpms
                errata_file['pkgobj'] = None

    def _fetch_packages(self, channel, missing_fs_packages, sources=0):
        short_package_collection = sync_handlers.ShortPackageCollection()
        if sources:
        #    acronym = "SRPM"
            package_collection = sync_handlers.SourcePackageCollection()
        else:
        #    acronym = "RPM"
            package_collection = sync_handlers.PackageCollection()

        self._failed_fs_packages = Queue.Queue()
        self._extinct_packages = Queue.Queue()
        pkgs_total = len(missing_fs_packages)
        pkg_current = 0
        total_size = 0
        queue = Queue.Queue()
        out_queue = Queue.Queue()
        lock = threading.Lock()

        
        #count size of missing packages
        for package_id, path in missing_fs_packages:
            timestamp = short_package_collection.get_package_timestamp(package_id)
            package = package_collection.get_package(package_id, timestamp)
            total_size = total_size+package['package_size']
            queue.put((package_id, path))

        log(1, messages.package_fetch_total_size %
            (self._bytes_to_fuzzy(total_size)))
        real_processed_size = processed_size = 0
        real_total_size = total_size
        start_time = round(time.time())

        all_threads=[]
        for i in range(4):
            t = ThreadDownload(lock, queue, out_queue, short_package_collection, package_collection, self, self._failed_fs_packages, self._extinct_packages, sources, channel)
            t.setDaemon(True)
            t.start()
            all_threads.append(t)

        while (filter(lambda x: x.isAlive(), all_threads)
               and pkg_current < pkgs_total):
            try:
                (rpmManip, package, is_done) = out_queue.get(False, 0.1)
            except Queue.Empty:
                continue
            pkg_current = pkg_current + 1

            if not is_done: # package failed to download or already exist on disk
                real_total_size -= package['package_size']
                processed_size += package['package_size']
                try:
                    out_queue.task_done()
                except AttributeError:
                    pass
                continue
            # Package successfully saved
            filename = os.path.basename(rpmManip.relative_path)

            # Determine downloaded size and remaining time
            size = package['package_size']
            real_processed_size += size
            processed_size += size
            current_time = round(time.time())
            # timedalta could not be multiplicated by float
            remain_time = (datetime.timedelta(seconds=current_time-start_time))*((real_total_size*10000)/real_processed_size-10000)/10000
            # cut off miliseconds
            remain_time = datetime.timedelta(remain_time.days, remain_time.seconds)
            log(1, messages.package_fetch_remain_size_time %
                (self._bytes_to_fuzzy(processed_size), self._bytes_to_fuzzy(total_size), remain_time))

            log(1, messages.package_fetch_successful %
                (pkg_current, pkgs_total, filename, size))
            try:
                out_queue.task_done()
            except AttributeError:
                pass

        extinct_count = self._extinct_packages.qsize()
        failed_count = self._failed_fs_packages.qsize()

        # Printing summary
        log(2, messages.package_fetch_summary % channel, notimeYN=1)
        log(2, messages.package_fetch_summary_success %
            (pkgs_total - extinct_count - failed_count), notimeYN=1)
        log(2, messages.package_fetch_summary_failed % failed_count,
            notimeYN=1)
        log(2, messages.package_fetch_summary_extinct % extinct_count,
            notimeYN=1)

    # Translate x bytes to string "x MB", "x GB" or "x kB"
    def _bytes_to_fuzzy(self, bytes):
        units = [ 'bytes', 'kiB', 'MiB', 'GiB', 'TiB', 'PiB']
        base = 1024
        fuzzy = bytes
        for unit in units:
            if fuzzy >= base:
                fuzzy = float(fuzzy)/base
            else:
                break
        int_len = len("%d" % fuzzy)
        fract_len = 3 - int_len
        return "%*.*f %s" % (int_len, fract_len, fuzzy, unit)

    def _get_package_stream(self, channel, package_id, nvrea, sources):
        """ returns (filepath, stream), so in the case of a "wire source",
            the return value is, of course, (None, stream)
        """

        # Returns a package stream from disk
        if self.mountpoint:
            rpmFile = rpmsPath(package_id, self.mountpoint, sources)
            try:
                stream = open(rpmFile)
            except IOError, e:
                if e.errno != 2: # No such file or directory
                    raise
                return (rpmFile, None)

            return (rpmFile, stream)

        # Wire stream
        if CFG.ISS_PARENT:
            stream  = self.xmlDataServer.getRpm(nvrea, channel)
        else:
            rpmServer = xmlWireSource.RPCGetWireSource(self.systemid, self.sslYN,
                                                       self.xml_dump_version)
            stream = rpmServer.getPackageStream(channel, nvrea)

        return (None, stream)

class ThreadDownload(threading.Thread):
    def __init__(self, lock, queue, out_queue, short_package_collection, package_collection, syncer, failed_fs_packages, extinct_packages, sources, channel):
        threading.Thread.__init__(self)
        self.queue = queue
        self.out_queue = out_queue
        self.short_package_collection = short_package_collection
        self.package_collection = package_collection
        self.syncer = syncer
        self.failed_fs_packages = failed_fs_packages
        self.extinct_packages = extinct_packages
        self.sources = sources
        self.channel = channel
        self.lock = lock

    def run(self):
        while not self.queue.empty():
            #grabs host from queue
            (package_id, path) = self.queue.get()
            timestamp = self.short_package_collection.get_package_timestamp(package_id)
            package = self.package_collection.get_package(package_id, timestamp)
            checksum_type = package['checksum_type']
            checksum = package['checksum']
            package_size = package['package_size']
            if not path:
                nevra = get_nevra(package)
                orgid = None
                if package['org_id']:
                    orgid = OPTIONS.orgid or DEFAULT_ORG
                path = self.syncer._get_rel_package_path(nevra, orgid, self.sources,
                                            checksum_type, checksum)

            # update package path
            package['path'] = path
            self.package_collection.add_item(package)

            errcode = self.syncer._verify_file(path, rhnLib.timestamp(timestamp), package_size,
                                            checksum_type, checksum)
            if errcode == 0:
                # file is already there
                # do not count this size to time estimate
                try:
                    self.queue.task_done()
                except AttributeError:
                    pass
                self.out_queue.put((None, package, False))
                continue

            cfg = config.initUp2dateConfig()
            rpmManip = RpmManip(package, path)
            nvrea = rpmManip.nvrea()

            # Retry a number of times, we may have network errors
            for i in range(cfg['networkRetries']):
                self.lock.acquire()
                try:
                    rpmFile, stream = self.syncer._get_package_stream(self.channel,
                        package_id, nvrea, self.sources)
                except:
                    self.lock.release()
                    raise
                self.lock.release()
                if stream is None:
                    # Mark the package as extinct
                    self.extinct_packages.put(package_id)
                    log(1, messages.package_fetch_extinct %
                        (os.path.basename(path)))
                    break # inner for

                try:
                    rpmManip.write_file(stream)
                    break # inner for
                except FileCreationError, e:
                    msg = e[0]
                    log2disk(-1, _("Unable to save file %s: %s") % (
                        rpmManip.full_path, msg))
                    # Try again
                    continue # inner for

            else: #for
                # Ran out of iterations
                # Mark the package as failed and move on
                self.failed_fs_packages.put(package_id)
                log(1, messages.package_fetch_failed %
                    (os.path.basename(path)))
                # Move to the next package
                try:
                    self.queue.task_done()
                except AttributeError:
                    pass
                self.out_queue.put((rpmManip, package, False))
                continue

            if stream is None:
                # Package is extinct. Move on
                try:
                    self.queue.task_done()
                except AttributeError:
                    pass
                self.out_queue.put((rpmManip, package, False))
                continue

            if self.syncer.mountpoint:
                # Channel dumps import; try to unlink to preserve disk space
                # rpmFile is always returned by _get_package_stream for
                # disk-based imports
                assert(rpmFile is not None)
                try:
                    os.unlink(rpmFile)
                except:
                    pass

            #signals to queue job is done
            try:
                self.queue.task_done()
            except AttributeError:
                pass
            self.out_queue.put((rpmManip, package, True))


class StreamProducer:
    def __init__(self, handler, data_source_class, source_func):
        self.handler = handler
        self.is_disk_loader = data_source_class.is_disk_loader()
        if self.is_disk_loader:
            self.loader = getattr(data_source_class, source_func)()
        else:
            self.loader = getattr(data_source_class, source_func)
        self._args = ()

    def set_args(self, *args):
        self._args = args

    def close(self):
        self.handler.close()

    def process(self, batch):
        if self.is_disk_loader:
            for oid in batch:
                self.loader.setID(oid)
                stream = self.loader.load()
                self.handler.process(stream)
        else:
            # Only use the extra arguments if needed, for now
            args = self._args or (batch, )
            stream = self.loader(*args)
            self.handler.process(stream)

def _verifyPkgRepMountPoint():
    """ Checks the base package repository directory tree for
        existance and permissions.

        Creates base dir if need be, and chowns to apache.root (required
        for rhnpush).
    """

    if not CFG.MOUNT_POINT:
        # Incomplete configuration
        log(-1, _("ERROR: server.mount_point not set in the configuration file"))
        sys.exit(16)

    if not os.path.exists(fileutils.cleanupAbsPath(CFG.MOUNT_POINT)):
        log(-1, _("ERROR: server.mount_point %s do not exist") % fileutils.cleanupAbsPath(CFG.MOUNT_POINT))
        sys.exit(26)

    if not os.path.exists(fileutils.cleanupAbsPath(CFG.MOUNT_POINT+'/'+CFG.PREPENDED_DIR)):
        log(-1, _("ERROR: path under server.mount_point (%s)  do not exist") % fileutils.cleanupAbsPath(CFG.MOUNT_POINT+'/'+CFG.PREPENDED_DIR))
        sys.exit(26)

def _validate_package_org(batch):
    """Validate the orgids associated with packages.
     If its redhat channel default to Null org
     If custom channel and org is specified use that.
     If custom and package org is not valid default to org 1
    """
    orgid = OPTIONS.orgid or None
    for pkg in batch:
        if not pkg['org_id'] or pkg['org_id'] == 'None':
            # default to Null so do nothing
            pkg['org_id'] = None
        elif orgid:
            # if options.orgid specified use it
            pkg['org_id'] = orgid
        else:
            # org from server is not valid
            pkg['org_id'] = DEFAULT_ORG

def _getImportedChannels():
    "Retrieves the channels already imported in the satellite's database"

    try:
        if OPTIONS.include_custom_channels:
            h = rhnSQL.prepare("""select label from rhnChannel""")
        else:
            h = rhnSQL.prepare("""select label from rhnChannel where org_id is null""")
        h.execute()
        return map(lambda x: x['label'], h.fetchall_dict() or [])
    except (SQLError, SQLSchemaError, SQLConnectError), e:
        # An SQL error is fatal... crash and burn
        exitWithTraceback(e, 'SQL ERROR during xml processing', 17)
    return []


def _parseDbString(dbstring):
    """ given "dbusername/dbpassword@dbinstance",
        return (dbusername, dbpassword, dbinstance).
    """
    x = ''
    errorMsg = _('ERROR: in /etc/rhn/rhn.conf DEFAULT_DB '
                'must be of form dbusername/dbpassword@dbinstance')

    # parse instance
    try:
        x = string.split(dbstring, '@')
    except:
        log(-1, errorMsg, stream=sys.stderr)
        sys.exit(18)
    if len(x) != 2:
        log(-1, errorMsg, stream=sys.stderr)
        sys.exit(18)
    dbinstance = x[1]

    # parse username and password
    u_p = string.split(x[0], '/')
    if len(u_p) != 2:
        log(-1, errorMsg, stream=sys.stderr)
        sys.exit(18)
    return (u_p[0], u_p[1], dbinstance)


def processCommandline():
    "process the commandline, setting the OPTIONS object"

    log2disk(-1, _("Commandline: %s") % repr(sys.argv))
    optionsTable = [
        Option(     '--batch-size',          action='store',
            help=_('DEBUG ONLY: max. batch-size for XML/database-import processing (1..%s). "man satellite-sync" for more information.') % SequenceServer.NEVER_MORE_THAN),
        Option(     '--ca-cert',             action='store',
            help=_('alternative SSL CA Cert (fullpath to cert file)')),
        Option('-c','--channel',             action='append',
            help=_('process data for this channel only')),
        Option(     '--consider-full',       action='store_true',
            help=_('disk dump will be considered to be a full export; see "man satellite-sync" for more information.')),
        Option(     '--include-custom-channels',       action='store_true',
            help=_('existing custom channels will also be synced (unless -c is used)')),
        Option('-d','--db',                  action='store',
            help=_('alternative database connection string (username/password@sid)')),
        Option(     '--debug-level',         action='store',
            help=_('override debug level set in /etc/rhn/rhn.conf (which is currently set at %s).') % CFG.DEBUG),
        Option(     '--dump-version',        action='store',
            help=_("requested version of XML dump (default: %s)") % constants.PROTOCOL_VERSION),
        Option(     '--email',               action='store_true',
            help=_('e-mail a report of what was synced/imported')),
        Option(     '--force-all-errata',  action='store_true',
            help=_('forcibly process all (not a diff of) errata metadata')),
        Option(     '--force-all-packages',  action='store_true',
            help=_('forcibly process all (not a diff of) package metadata')),
        Option(     '--http-proxy',          action='store',
            help=_('alternative http proxy (hostname:port)')),
        Option(     '--http-proxy-username', action='store',
            help=_('alternative http proxy username')),
        Option(     '--http-proxy-password', action='store',
            help=_('alternative http proxy password')),
        Option(     '--iss-parent',             action='store',
            help=_('parent satellite to import content from')),
        Option('-l','--list-channels',       action='store_true',
            help=_('list all available channels and exit')),
        Option(     '--list-error-codes',         action='store_true',
            help=_("help on all error codes satellite-sync returns")),
        Option('-m','--mount-point',         action='store',
            help=_('source mount point for import - disk update only')),
        Option(     '--no-errata',           action='store_true',
            help=_('do not process errata data')),
        Option(     '--no-kickstarts',       action='store_true',
            help=_('do not process kickstart data (provisioning only)')),
        Option(     '--no-packages',         action='store_true',
            help=_('do not process full package metadata')),
        Option(     '--no-rpms',             action='store_true',
            help=_('do not download, or process any RPMs')),
        Option(     '--no-ssl',              action='store_true',
            help=_('turn off SSL (not recommended)')),
        Option(    '--orgid',                  action='store',
            help=_('org to which the sync imports data. defaults to the admin account')),
        Option('-p','--print-configuration', action='store_true',
            help=_('print the configuration and exit')),
        Option(     '--rhn-cert',            action='store',
            help=_('satellite certificate to import ') +
                 _('(use with --mount-point only)')),
        Option('-s','--server',              action='store',
            help=_('alternative server with which to connect (hostname)')),
        Option(     '--step',                action='store',
            help=_('synchronize to this step (man satellite-sync for more info)')),
        Option(     '--systemid',            action='store',
            help=_("DEBUG ONLY: alternative path to digital system id")),
        Option(     '--traceback-mail',      action='store',
            help=_('alternative email address(es) for sync output (--email option)')),

        # DEFERRED:
        #Option(     '--source-packages',     action='store_true', help='sync source rpms/metadata as well.'),
        #Option(     '--no-srpms',            action='store_true', help='do not download, or process any SRPMs'),
        #Option(     '--no-source-packages',  action='store_true', help='do not process source package metadata'),
    ]
    optionParser = OptionParser(option_list=optionsTable)
    global OPTIONS
    OPTIONS, args = optionParser.parse_args()

    # we take extra commandline arguments that are not linked to an option
    if args:
        msg = _("ERROR: these arguments make no sense in this context (try --help): %s") % repr(args)
        log2stderr(-1, msg, 1, 1)
        sys.exit(19)

    #
    # process anything CFG related (db, debug, server, and print)
    #
    CFG.set("TRACEBACK_MAIL", OPTIONS.traceback_mail or CFG.TRACEBACK_MAIL)
    CFG.set("RHN_PARENT", idn_ascii_to_pune(OPTIONS.iss_parent or OPTIONS.server or \
             CFG.ISS_PARENT or CFG.RHN_PARENT))
    if OPTIONS.server and not OPTIONS.iss_parent:
        # server option on comman line should override ISS parent from config
        CFG.set("ISS_PARENT", None)
    else:
        CFG.set("ISS_PARENT", idn_ascii_to_pune(OPTIONS.iss_parent or CFG.ISS_PARENT))
        CFG.set("ISS_CA_CHAIN", OPTIONS.ca_cert or CFG.ISS_CA_CHAIN or CFG.CA_CHAIN)

    CFG.set("HTTP_PROXY", idn_ascii_to_pune(OPTIONS.http_proxy or CFG.HTTP_PROXY))
    CFG.set("HTTP_PROXY_USERNAME", OPTIONS.http_proxy_username or CFG.HTTP_PROXY_USERNAME)
    CFG.set("HTTP_PROXY_PASSWORD", OPTIONS.http_proxy_password or CFG.HTTP_PROXY_PASSWORD)
    CFG.set("CA_CHAIN", OPTIONS.ca_cert or CFG.CA_CHAIN)
    CFG.set("DEFAULT_DB", OPTIONS.db or CFG.DEFAULT_DB)
 
    try:
        rhnSQL.initDB(CFG.DEFAULT_DB)
    except (SQLError, SQLSchemaError, SQLConnectError), e:
        # An SQL error is fatal... crash and burn
        log(-1, _("ERROR: Can't connect to the database: %s") % e, stream=sys.stderr)
        log(-1, _("ERROR: Check if your database is running."), stream=sys.stderr)
        sys.exit(20)

    # check the validity of the debug level
    if OPTIONS.debug_level:
        debugRange = 6
        try:
            debugLevel = int(OPTIONS.debug_level)
            if not (0 <= debugLevel <= debugRange):
                raise RhnSyncException, "exception will be caught", sys.exc_info()[2]
        except KeyboardInterrupt, e:
            raise
        except:
            msg = [_("ERROR: --debug-level takes an in integer value within the range %s.") % repr(tuple(range(debugRange + 1))),
                   _("  0  - little logging/messaging."),
                   _("  1  - minimal logging/messaging."),
                   _("  2  - normal level of logging/messaging."),
                   _("  3  - lots of logging/messaging."),
                   _("  4+ - excessive logging/messaging.")]
            log(-1, msg, 1, 1, sys.stderr)
            sys.exit(21)
        else:
            CFG.set('DEBUG', debugLevel)
            initLOG(CFG.LOG_FILE, debugLevel)


    if OPTIONS.print_configuration:
        CFG.show()
        sys.exit(0)


    if OPTIONS.orgid:
        # verify if its a valid org
        orgs = map(lambda a: a['id'], satCerts.get_all_orgs())
        if int(OPTIONS.orgid) not in orgs:
            msg = _("ERROR: Unable to lookup Org Id %s") % OPTIONS.orgid
            log2stderr(-1, msg, cleanYN=1)
            sys.exit(27)

    # the action dictionary used throughout
    actionDict = {}

    if OPTIONS.list_channels:
        if OPTIONS.step:
            log(-1, _("WARNING: --list-channels option overrides any --step option. --step ignored."))
        OPTIONS.step = 'channels'
        actionDict['list-channels'] = 1
    else:
        actionDict['list-channels'] = 0

    #
    # validate the --step option and set up the hierarchy of sync process steps.
    #
    stepHierarchy = Runner.step_hierarchy
    # if no step stated... we do all steps.
    if not OPTIONS.step:
        OPTIONS.step = stepHierarchy[-1]

    if OPTIONS.step not in stepHierarchy:
        log2stderr(-1, _("ERROR: '%s' is not a valid step. See 'man satellite-sync' for more detail.") % OPTIONS.step, 1, 1)
        sys.exit(22)

    #XXX: --source is deferred for the time being
    #OPTIONS.source = OPTIONS.step in sourceSteps

    # populate the action dictionary
    for step in stepHierarchy:
        actionDict[step] = 1
        if step == OPTIONS.step:
            break

    # make sure *all* steps in the actionDict are handled.
    for step in stepHierarchy:
        actionDict[step] = actionDict.has_key(step)

    channels = OPTIONS.channel or []
    if OPTIONS.list_channels:
        actionDict['channels'] = 1
        actionDict['arches'] = 0
        actionDict['channel-families'] = 1
        channels = []

    # Cleanup selected channels.
    # if no channels selected, the default is to "freshen", or select the
    # already existing channels in the local database.
    if not channels:
        channels = _getImportedChannels()

    if not channels:
        if actionDict['channels'] and not actionDict['list-channels']:
            msg = _("ERROR: No channels currently imported; try satellite-sync --list-channels; then satellite-sync -c chn0 -c chn1...")
            log2disk(-1, msg)
            log2stderr(-1, msg, cleanYN=1)
            sys.exit(0)

    # add all the "other" actions specified.
    otherActions = {"no_rpms"            : 'no-rpms',
                   #"no_srpms"           : 'no-srpms',
                    "no_packages"        : 'no-packages',
                   #"no_source_packages" : 'no-source-packages',
                    "no_errata"          : 'no-errata',
                    "no_kickstarts"      : 'no-kickstarts',
                    "force_all_packages" : 'force-all-packages',
                    "force_all_errata"   : 'force-all-errata',
                    'no_ssl'             : 'no-ssl',
                    }

    for oa in otherActions.keys():
        if getattr(OPTIONS, oa):
            actionDict[otherActions[oa]] = 1
        else:
            actionDict[otherActions[oa]] = 0

    if actionDict['no-kickstarts']:
        actionDict['kickstarts'] = 0

    if actionDict['no-errata']:
        actionDict['errata'] = 0

    #if actionDict['no-source-packages']:
    actionDict['source-packages'] = 0

    if actionDict['no-packages']:
        actionDict['packages'] = 0
        actionDict['short'] = 0
        actionDict['download-packages'] = 0
        actionDict['rpms'] = 0
        

    if actionDict['no-rpms']:
        actionDict['rpms'] = 0
        

    #if actionDict['no-srpms']:
    actionDict['srpms'] = 0

    if OPTIONS.batch_size:
        try:
            OPTIONS.batch_size = int(OPTIONS.batch_size)
            if OPTIONS.batch_size not in range(1, 51):
                raise ValueError(_("ERROR: --batch-size must have a value within the range: 1..50"))
        except (ValueError, TypeError):
            # int(None) --> TypeError
            # int('a')  --> ValueError
            raise ValueError(_("ERROR: --batch-size must have a value within the range: 1..50")), None, sys.exc_info()[2]

    OPTIONS.mount_point = fileutils.cleanupAbsPath(OPTIONS.mount_point)
    OPTIONS.rhn_cert = fileutils.cleanupAbsPath(OPTIONS.rhn_cert)
    OPTIONS.systemid = fileutils.cleanupAbsPath(OPTIONS.systemid)

    if OPTIONS.rhn_cert:
        if not OPTIONS.mount_point:
            msg = _("ERROR: --rhn-cert requires --mount-point")
            log2stderr(-1, msg, cleanYN=1)
            sys.exit(23)
        if not os.path.isfile(OPTIONS.rhn_cert):
            msg = _("ERROR: no such file %s") % OPTIONS.rhn_cert
            log2stderr(-1, msg, cleanYN=1)
            sys.exit(24)

    if OPTIONS.mount_point:
        if not os.path.isdir(OPTIONS.mount_point):
            msg = _("ERROR: no such directory %s") % OPTIONS.mount_point
            log2stderr(-1, msg, cleanYN=1)
            sys.exit(25)

    if OPTIONS.list_error_codes:
        msg = [_("Error Codes: Returned codes means:"),
              _(" -1  - Could not lock file or KeyboardInterrupt or SystemExit"),
              _("  0  - User interrupted or intentional exit"),
              _("  1  - attempting to run more than one instance of satellite-sync."),
              _("  2  - Unable to find synchronization tools."),
              _("  3  - a general socket occurred"),
              _("  4  - an SSL error occurred. Recheck your SSL settings."),
              _("  5  - RHN error"),
              _("  6  - unhandled exception occurred"),
              _("  7  - unknown sync error"),
              _("  8  - ERROR: must be root to execute"),
              _("  9  - rpclib fault during synchronization init"),
              _("  10 - synchronization init error"),
              _("  11 - Error parsing XML stream"),
              _("  12 - Channel do not exist"),
              _("  13 - SQL error during importing package metadata"),
              _("  14 - SQL error during linking channel packages"),
              _("  15 - SQL error during xml processing"),
              _("  16 - server.mount_point not set in the configuration file"),
              _("  17 - SQL error during retrieving the channels already imported in the satellite's database"),
              _("  18 - Wrong db connection string in rhn.conf"),
              _("  19 - Bad arguments"),
              _("  20 - Could not connect to db."),
              _("  21 - Bad debug level"),
              _("  22 - Not valid step"),
              _("  23 - error: --rhn-cert requires --mount-point"),
              _("  24 - no such file"),
              _("  25 - no such directory"),
              _("  26 - mount_point does not exist"),
              _("  27 - No such org"),]
        log(-1, msg, 1, 1, sys.stderr)
        sys.exit(0) 

    if OPTIONS.dump_version:
        OPTIONS.dump_version = str(OPTIONS.dump_version)
        if OPTIONS.dump_version not in constants.ALLOWED_SYNC_PROTOCOL_VERSIONS:
            msg = _("ERROR: unknown dump version, try one of %s") % \
                   constants.ALLOWED_SYNC_PROTOCOL_VERSIONS
            log2stderr(-1, msg, cleanYN=1)
            sys.exit(19)

    # return the dictionary of actions, channels
    return actionDict, channels

def formatDateTime(dtstring=None, dt=None):
    """ Format the date time using your locale settings. This assume that your setlocale has been alread called. """
    if not dt:
        dt = time.strptime(dtstring, '%Y%m%d%H%M%S')
    return time.strftime("%c", dt)


if __name__ == '__main__':
    sys.stderr.write("!!! running this directly is advisable *ONLY* for testing"
                     " purposes !!!\n")
    try:
        sys.exit(Runner().main() or 0)
    except (KeyboardInterrupt, SystemExit), e:
        sys.exit(e)
    except Exception:
        from spacewalk.common.rhnTB import fetchTraceback
        tb = 'TRACEBACK: ' + fetchTraceback(with_locals=1)
        log2disk(-1, tb)
        log2email(-1, tb)
        sendMail()
        sys.exit(-1)

