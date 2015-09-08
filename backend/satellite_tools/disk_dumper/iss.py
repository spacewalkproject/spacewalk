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

import os
import os.path
import sys
import time
import gzip
import dumper
import cStringIO
from spacewalk.common import rhnMail
from spacewalk.common.rhnConfig import CFG, initCFG
from spacewalk.common.rhnTB import Traceback, exitWithTraceback
from spacewalk.server import rhnSQL
from spacewalk.server.rhnSQL import SQLError, SQLSchemaError, SQLConnectError
from spacewalk.satellite_tools.exporter import xmlWriter
from spacewalk.satellite_tools import xmlDiskSource, diskImportLib, progress_bar
from spacewalk.satellite_tools.syncLib import initEMAIL_LOG, dumpEMAIL_LOG, log2email, log2stderr, log2stdout
from iss_ui import UI
from iss_actions import ActionDeps
import shutil
import iss_isos
from spacewalk.common.checksum import getFileChecksum

import gettext
t = gettext.translation('spacewalk-backend-server', fallback=True)
_ = t.ugettext


class ISSError(Exception):

    def __init__(self, msg, tb):
        Exception.__init__(self)
        self.msg = msg
        self.tb = tb


# xmlDiskSource doesn't have a class for short channel packages, so I added one here.
# I named _getFile that way so it's similar to the stuff in xmlDiskSource.
# I grabbed the value of pathkey from dump_channel_packages_short in dumper.py.
class ISSChannelPackageShortDiskSource:

    def __init__(self, mount_point, channel_name=None):
        self.mp = mount_point
        self.channelid = channel_name
        self.pathkey = "xml-channel-packages/rhn-channel-%d.data"

    def setChannel(self, channel_id):
        self.channelid = channel_id

    def _getFile(self):
        return os.path.join(self.mp, self.pathkey % (self.channelid,))


class FileMapper:

    """ This class maps dumps to files. In other words, you give it
    the type of dump you're doing and it gives you the file to
    write it to.
    """

    def __init__(self, mount_point):
        self.mp = mount_point
        self.filemap = {
            'arches':   xmlDiskSource.ArchesDiskSource(self.mp),
            'arches-extra':   xmlDiskSource.ArchesExtraDiskSource(self.mp),
            'blacklists':   xmlDiskSource.BlacklistsDiskSource(self.mp),
            'channelfamilies':   xmlDiskSource.ChannelFamilyDiskSource(self.mp),
            'orgs':   xmlDiskSource.OrgsDiskSource(self.mp),
            'channels':   xmlDiskSource.ChannelDiskSource(self.mp),
            'channel-pkg-short':   ISSChannelPackageShortDiskSource(self.mp),
            'packages-short':   xmlDiskSource.ShortPackageDiskSource(self.mp),
            'packages':   xmlDiskSource.PackageDiskSource(self.mp),
            'sourcepackages':   xmlDiskSource.SourcePackageDiskSource(self.mp),
            'errata':   xmlDiskSource.ErrataDiskSource(self.mp),
            'kickstart_trees':   xmlDiskSource.KickstartDataDiskSource(self.mp),
            'kickstart_files':   xmlDiskSource.KickstartFileDiskSource(self.mp),
            'binary_rpms':   xmlDiskSource.BinaryRPMDiskSource(self.mp),
            'comps':   xmlDiskSource.ChannelCompsDiskSource(self.mp),
        }

    # This will make sure that all of the directories leading up to the
    # xml file actually exist.
    @staticmethod
    def setup_file(ofile):
        # Split the path. The filename is [1], and the directories are in [0].
        dirs_to_make = os.path.split(ofile)[0]

        # Make the directories if they don't already exist.
        if not os.path.exists(dirs_to_make):
            os.makedirs(dirs_to_make)

        return ofile

    # The get*File methods will return the full path to the xml file that the dumps are placed in.
    # pylint: disable=W0212
    def getArchesFile(self):
        return self.setup_file(self.filemap['arches']._getFile())

    def getArchesExtraFile(self):
        return self.setup_file(self.filemap['arches-extra']._getFile())

    def getBlacklistsFile(self):
        return self.setup_file(self.filemap['blacklists']._getFile())

    def getOrgsFile(self):
        return self.setup_file(self.filemap['orgs']._getFile())

    def getChannelFamiliesFile(self):
        return self.setup_file(self.filemap['channelfamilies']._getFile())

    def getBinaryRPMFile(self):
        return self.setup_file(self.filemap['binary_rpms']._getFile())

    def getChannelsFile(self, channelname):
        self.filemap['channels'].setChannel(channelname)
        return self.setup_file(self.filemap['channels']._getFile())

    def getChannelCompsFile(self, channelname):
        self.filemap['comps'].setChannel(channelname)
        return self.setup_file(self.filemap['comps']._getFile())

    def getChannelPackageShortFile(self, channel_id):
        self.filemap['channel-pkg-short'].setChannel(channel_id)
        return self.setup_file(self.filemap['channel-pkg-short']._getFile())

    def getPackagesFile(self, packageid):
        self.filemap['packages'].setID(packageid)
        return self.setup_file(self.filemap['packages']._getFile())

    def getShortPackagesFile(self, packageid):
        self.filemap['packages-short'].setID(packageid)
        return self.setup_file(self.filemap['packages-short']._getFile())

    def getSourcePackagesFile(self, sp_id):
        self.filemap['sourcepackages'].setID(sp_id)
        return self.setup_file(self.filemap['sourcepackages']._getFile())

    def getErrataFile(self, errataid):
        self.filemap['errata'].setID(errataid)
        return self.setup_file(self.filemap['errata']._getFile())

    def getKickstartTreeFile(self, ks_id):
        self.filemap['kickstart_trees'].setID(ks_id)
        return self.setup_file(self.filemap['kickstart_trees']._getFile())

    def getKickstartFileFile(self, ks_label, relative_path):
        self.filemap['kickstart_files'].setID(ks_label)
        self.filemap['kickstart_files'].set_relative_path(relative_path)
        return self.setup_file(self.filemap['kickstart_files']._getFile())


class Dumper(dumper.XML_Dumper):

    """ This class subclasses the XML_Dumper class. It overrides
     the _get_xml_writer method and adds a set_stream method,
     which will let it write to a file instead of over the wire.
    """

    def __init__(self, outputdir, channel_labels, org_ids, hardlinks,
                 start_date, end_date, use_rhn_date, whole_errata):
        dumper.XML_Dumper.__init__(self)
        self.fm = FileMapper(outputdir)
        self.mp = outputdir
        self.pb_label = "Exporting: "
        self.pb_length = 20  # progress bar length
        self.pb_complete = " - Done!"  # string that's printed when progress bar is done.
        self.pb_char = "#"  # the string used as each unit in the progress bar.
        self.hardlinks = hardlinks
        self.filename = None
        self.outstream = None

        self.start_date = start_date
        self.end_date = end_date
        self.use_rhn_date = use_rhn_date
        self.whole_errata = whole_errata

        if self.start_date:
            dates = {'start_date': self.start_date,
                     'end_date': self.end_date, }
        else:
            dates = {}

        # The queries here are a little weird. They grab just enough information
        # to satisfy the dumper objects, which will use the information to look up
        # any additional information that they need. That's why they don't seem to grab all
        # of the information that you'd think would be necessary to sync stuff.
        ####CHANNEL INFO###
        try:
            query = """
                 select ch.id channel_id, label,
                      TO_CHAR(last_modified, 'YYYYMMDDHH24MISS') last_modified
                   from rhnChannel ch
                  where ch.label = :label
                """
            self.channel_query = rhnSQL.Statement(query)
            ch_data = rhnSQL.prepare(self.channel_query)

            comps_query = """
                select relative_filename
                from rhnChannelComps
                where channel_id = :channel_id
                order by id desc
            """
            self.channel_comps_query = rhnSQL.Statement(comps_query)
            channel_comps_sth = rhnSQL.prepare(self.channel_comps_query)

            # self.channel_ids contains the list of dictionaries that hold the channel information
            # The keys are 'channel_id', 'label', and 'last_modified'.
            self.channel_comps = {}

            self.set_exportable_orgs(org_ids)

            # Channel_labels should be the list of channels passed into rhn-satellite-exporter by the user.
            log2stdout(1, "Gathering channel info...")
            for ids in channel_labels:
                ch_data.execute(label=ids)
                ch_info = ch_data.fetchall_dict()

                if not ch_info:
                    raise ISSError("Error: Channel %s not found." % ids, "")

                self.channel_ids = self.channel_ids + ch_info

                channel_comps_sth.execute(channel_id=ch_info[0]['channel_id'])
                comps_info = channel_comps_sth.fetchone_dict()

                if comps_info is not None:
                    self.channel_comps[ch_info[0]['channel_id']] = comps_info['relative_filename']

            # For list of channel families, we want to also list those relevant for channels
            # that are already on disk, so that we do not lose those families with
            # "incremental" dumps. So we will gather list of channel ids for channels already
            # in dump.
            channel_labels_for_families = self.fm.filemap['channels'].list()
            print "Appending channels %s" % (channel_labels_for_families)
            for ids in channel_labels_for_families:
                ch_data.execute(label=ids)
                ch_info = ch_data.fetchall_dict()
                if ch_info:
                    self.channel_ids_for_families = self.channel_ids_for_families + ch_info

        except ISSError:
            # Don't want calls to sys.exit to show up as a "bad" error.
            raise
        except Exception, e:
            tbout = cStringIO.StringIO()
            Traceback(mail=0, ostream=tbout, with_locals=1)
            raise ISSError("%s caught while getting channel info." %
                           e.__class__.__name__, tbout.getvalue()), \
                None, sys.exc_info()[2]

        ###BINARY RPM INFO###
        try:
            if self.whole_errata and self.start_date:
                query = """ select rcp.package_id id, rp.path path
                   from rhnChannelPackage rcp, rhnPackage rp
                        left join rhnErrataPackage rep on rp.id = rep.package_id
                        left join rhnErrata re on rep.errata_id = re.id
                  where rcp.package_id = rp.id
                    and rcp.channel_id = :channel_id
                """
            else:
                query = """
                         select rcp.package_id id, rp.path path
                           from rhnChannelPackage rcp, rhnPackage rp
                          where rcp.package_id = rp.id
                            and rcp.channel_id = :channel_id
                    """

            if self.start_date:
                if self.whole_errata:
                    if self.use_rhn_date:
                        query += """ and
                         ((re.last_modified >= TO_TIMESTAMP(:start_date, 'YYYYMMDDHH24MISS')
                             and re.last_modified <= TO_TIMESTAMP(:end_date, 'YYYYMMDDHH24MISS')
                         ) or (rep.package_id is NULL
                             and rp.last_modified >= TO_TIMESTAMP(:start_date, 'YYYYMMDDHH24MISS')
                             and rp.last_modified <= TO_TIMESTAMP(:end_date, 'YYYYMMDDHH24MISS'))
                         )
                        """
                    else:
                        query += """ and
                         ((re.modified >= TO_TIMESTAMP(:start_date, 'YYYYMMDDHH24MISS')
                         and re.modified <= TO_TIMESTAMP(:end_date, 'YYYYMMDDHH24MISS')
                         ) or (rep.package_id is NULL
                            and rcp.modified >= TO_TIMESTAMP(:start_date, 'YYYYMMDDHH24MISS')
                            and rcp.modified <= TO_TIMESTAMP(:end_date, 'YYYYMMDDHH24MISS'))
                         )
                        """
                elif self.use_rhn_date:
                    query += """
                        and rp.last_modified >= TO_TIMESTAMP(:start_date, 'YYYYMMDDHH24MISS')
                        and rp.last_modified <= TO_TIMESTAMP(:end_date, 'YYYYMMDDHH24MISS')
                        """
                else:
                    query += """
                        and rcp.modified >= TO_TIMESTAMP(:start_date, 'YYYYMMDDHH24MISS')
                        and rcp.modified <= TO_TIMESTAMP(:end_date, 'YYYYMMDDHH24MISS')
                        """
            self.brpm_query = rhnSQL.Statement(query)
            brpm_data = rhnSQL.prepare(self.brpm_query)

            # self.brpms is a list of binary rpm info. It is a list of dictionaries, where each dictionary
            # has 'id' and 'path' as the keys.
            self.brpms = []
            log2stdout(1, "Gathering binary RPM info...")
            for ch in self.channel_ids:
                brpm_data.execute(channel_id=ch['channel_id'], **dates)
                self.brpms = self.brpms + (brpm_data.fetchall_dict() or [])
        except Exception, e:
            tbout = cStringIO.StringIO()
            Traceback(mail=0, ostream=tbout, with_locals=1)
            raise ISSError("%s caught while getting binary rpm info." %
                           e.__class__.__name__, tbout.getvalue()), \
                None, sys.exc_info()[2]

        ###PACKAGE INFO###
        # This will grab channel package information for a given channel.
        try:
            if self.whole_errata and self.start_date:
                query = """
                 select rp.id package_id,
                            TO_CHAR(rp.last_modified, 'YYYYMMDDHH24MISS') last_modified
                 from rhnChannelPackage rcp, rhnPackage rp
                    left join rhnErrataPackage rep on rp.id = rep.package_id
                        left join rhnErrata re on rep.errata_id = re.id
                         where rcp.channel_id = :channel_id
                            and rcp.package_id = rp.id
                    """
            else:
                query = """
                 select rp.id package_id,
                TO_CHAR(rp.last_modified, 'YYYYMMDDHH24MISS') last_modified
           from rhnPackage rp, rhnChannelPackage rcp
          where rcp.channel_id = :channel_id
            and rcp.package_id = rp.id
                """
            if self.start_date:
                if self.whole_errata:
                    if self.use_rhn_date:
                        query += """ and
                         ((re.last_modified >= TO_TIMESTAMP(:start_date, 'YYYYMMDDHH24MISS')
                         and re.last_modified <= TO_TIMESTAMP(:end_date, 'YYYYMMDDHH24MISS')
                         ) or (rep.package_id is NULL
                            and rp.last_modified >= TO_TIMESTAMP(:start_date, 'YYYYMMDDHH24MISS')
                            and rp.last_modified <= TO_TIMESTAMP(:end_date, 'YYYYMMDDHH24MISS'))
                         )
                        """
                    else:
                        query += """ and
                         ((re.modified >= TO_TIMESTAMP(:start_date, 'YYYYMMDDHH24MISS')
                         and re.modified <= TO_TIMESTAMP(:end_date, 'YYYYMMDDHH24MISS')
                         ) or (rep.package_id is NULL
                            and rcp.modified >= TO_TIMESTAMP(:start_date, 'YYYYMMDDHH24MISS')
                            and rcp.modified <= TO_TIMESTAMP(:end_date, 'YYYYMMDDHH24MISS'))
                         )
                        """
                elif self.use_rhn_date:
                    query += """
                    and rp.last_modified >= TO_TIMESTAMP(:start_date, 'YYYYMMDDHH24MISS')
                    and rp.last_modified <= TO_TIMESTAMP(:end_date, 'YYYYMMDDHH24MISS')
                    """
                else:
                    query += """
                    and (rcp.modified >= TO_TIMESTAMP(:start_date, 'YYYYMMDDHH24MISS')
                    and rcp.modified <= TO_TIMESTAMP(:end_date, 'YYYYMMDDHH24MISS'))
                    """
            self.package_query = rhnSQL.Statement(query)
            package_data = rhnSQL.prepare(self.package_query)

            # self.pkg_info will be a list of dictionaries containing channel package information.
            # The keys are 'package_id' and 'last_modified'.
            self.pkg_info = []

            # This fills in the pkg_info list with channel package information from the channels in
            # self.channel_ids.
            log2stdout(1, "Gathering package info...")
            for channel_id in self.channel_ids:
                package_data.execute(channel_id=channel_id['channel_id'], **dates)
                a_package = package_data.fetchall_dict() or []

                # Don't bother placing None into self.pkg_info.
                if a_package:
                    self.pkg_info = self.pkg_info + a_package

        except Exception, e:
            tbout = cStringIO.StringIO()
            Traceback(mail=0, ostream=tbout, with_locals=1)
            raise ISSError("%s caught while getting package info." %
                           e.__class__.__name__, tbout.getvalue()), \
                None, sys.exc_info()[2]

        ###SOURCE PACKAGE INFO###
        try:
            query = """
                  select ps.id package_id,
                         TO_CHAR(ps.last_modified,'YYYYMMDDHH24MISS') last_modified,
                         ps.source_rpm_id source_rpm_id
                    from rhnPackageSource ps
                """
            if self.start_date:
                if self.whole_errata:
                    query += """
                        left join rhnErrataFilePackageSource refps on refps.package_id = ps.id
                        left join rhnErrataFile ref on refps.errata_file_id = ref.id
                        left join rhnErrata re on ref.errata_id = re.id
                    """
                    if self.use_rhn_date:
                        query += """ and
                         ((re.last_modified >= TO_TIMESTAMP(:start_date, 'YYYYMMDDHH24MISS')
                         and re.last_modified <= TO_TIMESTAMP(:end_date, 'YYYYMMDDHH24MISS')
                         ) or (refps.package_id is NULL
                            and ps.last_modified >= TO_TIMESTAMP(:start_date, 'YYYYMMDDHH24MISS')
                            and ps.last_modified <= TO_TIMESTAMP(:end_date, 'YYYYMMDDHH24MISS'))
                         )
                        """
                    else:
                        query += """ and
                         ((re.modified >= TO_TIMESTAMP(:start_date, 'YYYYMMDDHH24MISS')
                         and re.modified <= TO_TIMESTAMP(:end_date, 'YYYYMMDDHH24MISS')
                         ) or (refps.package_id is NULL
                            and ps.modified >= TO_TIMESTAMP(:start_date, 'YYYYMMDDHH24MISS')
                            and ps.modified <= TO_TIMESTAMP(:end_date, 'YYYYMMDDHH24MISS'))
                         )
                        """
                elif self.use_rhn_date:
                    query += """
                    where ps.last_modified >= TO_TIMESTAMP(:start_date, 'YYYYMMDDHH24MISS')
                     and ps.last_modified <= TO_TIMESTAMP(:end_date, 'YYYYMMDDHH24MISS')
                    """
                else:
                    query += """
                    where ps.modified >= TO_TIMESTAMP(:start_date, 'YYYYMMDDHH24MISS')
                     and ps.modified <= TO_TIMESTAMP(:end_date, 'YYYYMMDDHH24MISS')
                    """
            self.source_package_query = rhnSQL.Statement(query)
            source_package_data = rhnSQL.prepare(self.source_package_query)
            source_package_data.execute(**dates)

            # self.src_pkg_info is a list of dictionaries containing the source package information.
            # The keys for each dictionary are 'package_id', 'last_modified', and 'source_rpm_id'.
            self.src_pkg_info = source_package_data.fetchall_dict() or []

            # Again, don't bother placing None into the list.
            if not self.src_pkg_info:
                self.src_pkg_info = []

        except Exception, e:
            tbout = cStringIO.StringIO()
            Traceback(mail=0, ostream=tbout, with_locals=1)
            raise ISSError("%s caught while getting source package info." %
                           e.__class__.__name__, tbout.getvalue()), \
                None, sys.exc_info()[2]

        ###ERRATA INFO###
        try:
            query = """
                   select e.id errata_id,
                          TO_CHAR(e.last_modified,'YYYYMMDDHH24MISS') last_modified,
                          e.advisory_name "advisory-name"
                     from rhnChannelErrata ce, rhnErrata e
                    where ce.channel_id = :channel_id
                      and ce.errata_id = e.id
                """
            if self.start_date:
                if self.use_rhn_date:
                    query += """
                      and e.last_modified >= TO_TIMESTAMP(:start_date, 'YYYYMMDDHH24MISS')
                      and e.last_modified <= TO_TIMESTAMP(:end_date, 'YYYYMMDDHH24MISS')
                      """
                else:
                    query += """
                      and ce.modified >= TO_TIMESTAMP(:start_date, 'YYYYMMDDHH24MISS')
                      and ce.modified <= TO_TIMESTAMP(:end_date, 'YYYYMMDDHH24MISS')
                      """
            self.errata_query = rhnSQL.Statement(query)
            errata_data = rhnSQL.prepare(self.errata_query)

            # self.errata_info will be a list of dictionaries containing errata info for the channels
            # that the user listed. The keys are 'errata_id' and 'last_modified'.
            self.errata_info = []
            log2stdout(1, "Gathering errata info...")
            for channel_id in self.channel_ids:
                errata_data.execute(channel_id=channel_id['channel_id'], **dates)
                an_errata = errata_data.fetchall_dict() or []
                if an_errata:
                    self.errata_info = self.errata_info + an_errata

        except Exception, e:
            tbout = cStringIO.StringIO()
            Traceback(mail=0, ostream=tbout, with_locals=1)
            raise ISSError("%s caught while getting errata info." %
                           e.__class__.__name__, tbout.getvalue()), \
                None, sys.exc_info()[2]

        ###KICKSTART DATA/TREES INFO###
        try:
            query = """
                select  kt.id kstree_id, kt.label kickstart_label,
                        TO_CHAR(kt.last_modified, 'YYYYMMDDHH24MISS') last_modified
                  from  rhnKickstartableTree kt
                 where   kt.channel_id = :channel_id
                 """
            if self.start_date:
                if self.use_rhn_date:
                    query += """
                    and kt.last_modified >= TO_TIMESTAMP(:start_date, 'YYYYMMDDHH24MISS')
                    and kt.last_modified <= TO_TIMESTAMP(:end_date, 'YYYYMMDDHH24MISS')
                    and kt.org_id is Null
                    """
                else:
                    query += """
                    and kt.modified >= TO_TIMESTAMP(:start_date, 'YYYYMMDDHH24MISS')
                    and kt.modified <= TO_TIMESTAMP(:end_date, 'YYYYMMDDHH24MISS')
                    and kt.org_id is Null
                    """
            self.kickstart_trees_query = rhnSQL.Statement(query)
            kickstart_data = rhnSQL.prepare(self.kickstart_trees_query)
            self.kickstart_trees = []
            log2stdout(1, "Gathering kickstart data...")
            for channel_id in self.channel_ids:
                kickstart_data.execute(channel_id=channel_id['channel_id'],
                                       **dates)
                a_tree = kickstart_data.fetchall_dict() or []
                if a_tree:
                    self.kickstart_trees = self.kickstart_trees + a_tree

        except Exception, e:
            tbout = cStringIO.StringIO()
            Traceback(mail=0, ostream=tbout, with_locals=1)
            raise ISSError("%s caught while getting kickstart data info." %
                           e.__class__.__name__, tbout.getvalue()), \
                None, sys.exc_info()[2]

        ###KICKSTART FILES INFO###
        try:
            query = """
                    select rktf.relative_filename "relative-path",
                           c.checksum_type "checksum-type", c.checksum,
                           rktf.file_size "file-size",
                           TO_CHAR(rktf.last_modified, 'YYYYMMDDHH24MISS') "last-modified",
                           rkt.base_path "base-path",
                           rkt.label "label",
                           TO_CHAR(rkt.modified, 'YYYYMMDDHH24MISS') "modified"
                      from rhnKSTreeFile rktf, rhnKickstartableTree rkt,
                           rhnChecksumView c
                     where rktf.kstree_id = :kstree_id
                       and rkt.id = rktf.kstree_id
                       and rktf.checksum_id = c.id
                """
            if self.start_date:
                if self.use_rhn_date:
                    query += """
                        and rkt.last_modified >= TO_TIMESTAMP(:start_date, 'YYYYMMDDHH24MISS')
                        and rkt.last_modified <= TO_TIMESTAMP(:end_date, 'YYYYMMDDHH24MISS')
                    """
                else:
                    query += """
                        and rkt.modified >= TO_TIMESTAMP(:start_date, 'YYYYMMDDHH24MISS')
                        and rkt.modified <= TO_TIMESTAMP(:end_date, 'YYYYMMDDHH24MISS')
                    """
            self.kickstart_files_query = rhnSQL.Statement(query)
            kickstart_files = rhnSQL.prepare(self.kickstart_files_query)
            self.kickstart_files = []
            log2stdout(1, "Gathering kickstart files info...")
            for kstree in self.kickstart_trees:
                kickstart_files.execute(kstree_id=kstree['kstree_id'], **dates)
                a_file = kickstart_files.fetchall_dict() or []
                if a_file:
                    self.kickstart_files = self.kickstart_files + a_file

        except Exception, e:
            tbout = cStringIO.StringIO()
            Traceback(mail=0, ostream=tbout, with_locals=1)
            raise ISSError("%s caught while getting kickstart files info." %
                           e.__class__.__name__, tbout.getvalue()), \
                None, sys.exc_info()[2]

    # The close method overrides the parent classes close method. This implementation
    # closes the self.outstream, which is an addition defined in this subclass.
    # set_filename and _get_xml_writer for more info.
    def close(self):
        self.outstream.close()

    # This is an addition that allows the caller to set the filename for the output stream.
    def set_filename(self, filename):
        self.filename = filename

    # This method overrides the parent class's version of this method. This version allows the output stream to
    # be a file, which should have been set prior to this via the set_filename method.
    # TODO: Add error-checking. Either give self.outstream a sane default or have it throw an error if it hasn't
    #      been set yet.
    def _get_xml_writer(self):
        self.outstream = open(self.filename, "w")
        return xmlWriter.XMLWriter(stream=self.outstream)

    # The dump_* methods aren't really overrides because they don't preserve the method
    # signature, but they are meant as replacements for the methods defined in the base
    # class that have the same name. They will set up the file for the dump, collect info
    # necessary for the dumps to take place, and then call the base class version of the
    # method to do the actual dumping.
    def _dump_simple(self, filename, dump_func, startmsg, endmsg, exceptmsg):
        try:
            print "\n"
            log2stdout(1, startmsg)
            pb = progress_bar.ProgressBar(self.pb_label,
                                          self.pb_complete,
                                          1,
                                          self.pb_length,
                                          self.pb_char)
            pb.printAll(1)
            self.set_filename(filename)
            dump_func(self)

            pb.addTo(1)
            pb.printIncrement()
            pb.printComplete()
            log2stdout(4, endmsg % filename)

        except Exception, e:
            tbout = cStringIO.StringIO()
            Traceback(mail=0, ostream=tbout, with_locals=1)
            raise ISSError(exceptmsg % e.__class__.__name__, tbout.getvalue()), \
                None, sys.exc_info()[2]

    def dump_arches(self, rpm_arch_type_only=0):
        self._dump_simple(self.fm.getArchesFile(), dumper.XML_Dumper.dump_arches,
                          "Exporting arches...",
                          "Arches exported to %s",
                          "%s caught in dump_arches.")

    # This dumps arches_extra
    def dump_server_group_type_server_arches(self, rpm_arch_type_only=0, virt_filter=0):
        self._dump_simple(self.fm.getArchesExtraFile(),
                          dumper.XML_Dumper.dump_server_group_type_server_arches,
                          "Exporting arches extra...",
                          "Arches Extra exported to %s",
                          "%s caught in dump_server_group_type_server_arches.")

    def dump_blacklist_obsoletes(self):
        self._dump_simple(self.fm.getBlacklistsFile(),
                          dumper.XML_Dumper.dump_blacklist_obsoletes,
                          "Exporting blacklists...",
                          "Blacklists exported to %s",
                          "%s caught in dump_blacklist_obsoletes.")

    def dump_channel_families(self):
        self._dump_simple(self.fm.getChannelFamiliesFile(),
                          dumper.XML_Dumper.dump_channel_families,
                          "Exporting channel families...",
                          "Channel Families exported to %s",
                          "%s caught in dump_channel_families.")

    def dump_orgs(self):
        self._dump_simple(self.fm.getOrgsFile(),
                          dumper.XML_Dumper.dump_orgs,
                          "Exporting orgs...",
                          "Orgs exported to %s",
                          "%s caught in dump_orgs.")

    def dump_channels(self, channel_labels=None, start_date=None, end_date=None,
                      use_rhn_date=True, whole_errata=False):
        try:
            print "\n"
            log2stdout(1, "Exporting channel info...")
            pb = progress_bar.ProgressBar(self.pb_label,
                                          self.pb_complete,
                                          len(self.channel_ids),
                                          self.pb_length,
                                          self.pb_char)
            pb.printAll(1)
            for channel in self.channel_ids:
                self.set_filename(self.fm.getChannelsFile(channel['label']))
                dumper.XML_Dumper.dump_channels(self, [channel],
                                                self.start_date, self.end_date,
                                                self.use_rhn_date, self.whole_errata)

                log2email(4, "Channel: %s" % channel['label'])
                log2email(5, "Channel exported to %s" % self.fm.getChannelsFile(channel['label']))

                if channel['channel_id'] in self.channel_comps:
                    full_filename = os.path.join(CFG.MOUNT_POINT, self.channel_comps[channel['channel_id']])
                    target_filename = self.fm.getChannelCompsFile(channel['label'])
                    log2stderr(3, "Need to copy %s to %s" % (full_filename, target_filename))

                    # the comps.xml file will get gzipped afterwards
                    # but it's still faster to do hardlink first
                    if self.hardlinks:
                        os.link(full_filename, target_filename)
                    else:
                        shutil.copyfile(full_filename, target_filename)

                pb.addTo(1)
                pb.printIncrement()
            pb.printComplete()
            log2stderr(3, "Number of channels exported: %s" % str(len(self.channel_ids)))

        except Exception, e:
            tbout = cStringIO.StringIO()
            Traceback(mail=0, ostream=tbout, with_locals=1)
            raise ISSError("%s caught in dump_channels." % e.__class__.__name__,
                           tbout.getvalue()), \
                None, sys.exc_info()[2]

    def dump_channel_packages_short(self, channel_label=None, last_modified=None, filepath=None,
                                    validate_channels=False, send_headers=False,
                                    open_stream=True):
        try:
            print "\n"
            for ch_id in self.channel_ids:
                filepath = self.fm.getChannelPackageShortFile(ch_id['channel_id'])
                self.set_filename(filepath)
                dumper.XML_Dumper.dump_channel_packages_short(self, ch_id, ch_id['last_modified'], filepath)

        except Exception, e:
            tbout = cStringIO.StringIO()
            Traceback(mail=0, ostream=tbout, with_locals=1)
            raise ISSError("%s caught in dump_channel_packages_short." %
                           e.__class__.__name__, tbout.getvalue()), \
                None, sys.exc_info()[2]

    def dump_packages(self, packages=None):
        try:
            print "\n"
            log2stdout(1, "Exporting packages...")
            pb = progress_bar.ProgressBar(self.pb_label,
                                          self.pb_complete,
                                          len(self.pkg_info),
                                          self.pb_length,
                                          self.pb_char)
            pb.printAll(1)
            for pkg_info in self.pkg_info:
                package_name = "rhn-package-" + str(pkg_info['package_id'])
                self.set_filename(self.fm.getPackagesFile(package_name))
                dumper.XML_Dumper.dump_packages(self, [pkg_info])

                log2email(4, "Package: %s" % package_name)
                log2email(5, "Package exported to %s" % self.fm.getPackagesFile(package_name))

                pb.addTo(1)
                pb.printIncrement()
            pb.printComplete()
            log2stdout(3, "Number of packages exported: %s" % str(len(self.pkg_info)))

        except Exception, e:
            tbout = cStringIO.StringIO()
            Traceback(mail=0, ostream=tbout, with_locals=1)
            raise ISSError("%s caught in dump_packages." % e.__class__.__name__,
                           tbout.getvalue()), \
                None, sys.exc_info()[2]

    def dump_packages_short(self, packages=None):
        try:
            print "\n"
            log2stdout(1, "Exporting short packages...")
            pb = progress_bar.ProgressBar(self.pb_label,
                                          self.pb_complete,
                                          len(self.pkg_info),
                                          self.pb_length,
                                          self.pb_char)
            pb.printAll(1)
            for pkg_info in self.pkg_info:
                package_name = "rhn-package-" + str(pkg_info['package_id'])
                self.set_filename(self.fm.getShortPackagesFile(package_name))
                dumper.XML_Dumper.dump_packages_short(self, [pkg_info])

                log2email(4, "Short Package: %s" % package_name)
                log2email(5, "Short Package exported to %s" % package_name)
                pb.addTo(1)
                pb.printIncrement()
            pb.printComplete()
            log2stdout(3, "Number of short packages exported: %s" % str(len(self.pkg_info)))

        except Exception, e:
            tbout = cStringIO.StringIO()
            Traceback(mail=0, ostream=tbout, with_locals=1)
            raise ISSError("%s caught in dump_packages_short." %
                           e.__class__.__name__, tbout.getvalue()), \
                None, sys.exc_info()[2]

    def dump_source_packages(self, packages=None):
        try:
            print "\n"
            for pkg_info in self.src_pkg_info:
                self.set_filename(self.fm.getSourcePackagesFile("rhn-source-package-" + str(pkg_info['package_id'])))
                dumper.XML_Dumper.dump_source_packages(self, [pkg_info])

        except Exception, e:
            tbout = cStringIO.StringIO()
            Traceback(mail=0, ostream=tbout, with_locals=1)
            raise ISSError("%s caught in dump_source_packages." %
                           e.__class__.__name__, tbout.getvalue()), \
                None, sys.exc_info()[2]

    def dump_errata(self, errata=None, verify_errata=False):
        try:
            print "\n"
            log2stdout(1, "Exporting errata...")
            pb = progress_bar.ProgressBar(self.pb_label,
                                          self.pb_complete,
                                          len(self.errata_info),
                                          self.pb_length,
                                          self.pb_char)
            pb.printAll(1)
            for errata_info in self.errata_info:
                erratum_name = "rhn-erratum-" + str(errata_info['errata_id'])
                self.set_filename(self.fm.getErrataFile(erratum_name))
                dumper.XML_Dumper.dump_errata(self, [errata_info])

                log2email(4, "Erratum: %s" % str(errata_info['advisory-name']))
                log2email(5, "Erratum exported to %s" % self.fm.getErrataFile(erratum_name))

                pb.addTo(1)
                pb.printIncrement()
            pb.printComplete()
            log2stdout(3, "Number of errata exported: %s" % str(len(self.errata_info)))

        except Exception, e:
            tbout = cStringIO.StringIO()
            Traceback(mail=0, ostream=tbout, with_locals=1)
            raise ISSError("%s caught in dump_errata." % e.__class__.__name__,
                           tbout.getvalue()), \
                None, sys.exc_info()[2]

    def dump_kickstart_data(self):
        try:
            print "\n"
            log2stdout(1, "Exporting kickstart data...")
            pb = progress_bar.ProgressBar(self.pb_label,
                                          self.pb_complete,
                                          len(self.kickstart_trees),
                                          self.pb_length,
                                          self.pb_char)
            pb.printAll(1)
            for kickstart_tree in self.kickstart_trees:
                self.set_filename(self.fm.getKickstartTreeFile(kickstart_tree['kickstart_label']))  # , 'foo/bar'))
                dumper.XML_Dumper.dump_kickstartable_trees(self, [kickstart_tree])

                log2email(5, "KS Data: %s" % str(kickstart_tree['kickstart_label']))

                pb.addTo(1)
                pb.printIncrement()
            pb.printComplete()
            log2stdout(3, "Amount of kickstart data exported: %s" % str(len(self.kickstart_trees)))

        except Exception, e:
            tbout = cStringIO.StringIO()
            Traceback(mail=0, ostream=tbout, with_locals=1)
            raise ISSError("%s caught in dump_kickstart_data." %
                           e.__class__.__name__, tbout.getvalue()), \
                None, sys.exc_info()[2]

    def dump_kickstart_files(self):
        try:
            print "\n"
            log2stdout(1, "Exporting kickstart files...")
            pb = progress_bar.ProgressBar(self.pb_label,
                                          self.pb_complete,
                                          len(self.kickstart_files),
                                          self.pb_length,
                                          self.pb_char)
            pb.printAll(1)
            for kickstart_file in self.kickstart_files:
                # get the path to the kickstart files under the satellite's mount point
                path_to_files = os.path.join(CFG.MOUNT_POINT,
                                             kickstart_file['base-path'],
                                             kickstart_file['relative-path'])

                # Make sure the path actually exists
                if not os.path.exists(path_to_files):
                    raise ISSError("Missing kickstart file under satellite mount-point: %s" % (path_to_files,), "")

                # generate the path to the kickstart files under the export directory.
                path_to_export_file = self.fm.getKickstartFileFile(
                    kickstart_file['label'],
                    kickstart_file['relative-path'])
                #os.path.join(self.mp, kickstart_file['base-path'], kickstart_file['relative-path'])
                if os.path.exists(path_to_export_file):
                    # already exists, skip ks file
                    continue
                # Get the dirs to the file under the export directory.
                dirs_to_file = os.path.split(path_to_export_file)[0]

                # create the directory to the kickstart files under the export directory, if necessary.
                if not os.path.exists(dirs_to_file):
                    os.makedirs(dirs_to_file)
                try:
                    if self.hardlinks:
                        # Make hardlinks
                        try:
                            os.link(path_to_files, path_to_export_file)
                        except OSError:
                            pass
                    else:
                        # Copy file from satellite to export dir.
                        shutil.copyfile(path_to_files, path_to_export_file)
                except IOError, e:
                    tbout = cStringIO.StringIO()
                    Traceback(mail=0, ostream=tbout, with_locals=1)
                    raise ISSError("Error: Error copying file: %s: %s" % (path_to_files,
                                                                          e.__class__.__name__), tbout.getvalue()), \
                        None, sys.exc_info()[2]

                log2email(5, "Kickstart File: %s" %
                          os.path.join(kickstart_file['base-path'],
                                       kickstart_file['relative-path']))

                pb.addTo(1)
                pb.printIncrement()

            pb.printComplete()
            log2stdout(3, "Number of kickstart files exported: %s" % str(len(self.kickstart_files)))
        except ISSError:
            raise
        except Exception, e:
            tbout = cStringIO.StringIO()
            Traceback(mail=0, ostream=tbout, with_locals=1)
            raise ISSError("%s caught in dump_kickstart_files." %
                           e.__class__.__name__, tbout.getvalue()), \
                None, sys.exc_info()[2]

    # RPM and SRPM dumping code
    def dump_rpms(self):
        try:
            print "\n"
            log2stdout(1, "Exporting binary RPMs...")
            pb = progress_bar.ProgressBar(self.pb_label,
                                          self.pb_complete,
                                          len(self.brpms),
                                          self.pb_length,
                                          self.pb_char)
            pb.printAll(1)
            for rpm in self.brpms:
                # generate path to the rpms under the mount point
                path_to_rpm = diskImportLib.rpmsPath("rhn-package-%s" % str(rpm['id']), self.mp)

                # get the dirs to the rpm
                dirs_to_rpm = os.path.split(path_to_rpm)[0]

                if (not rpm['path']):
                    raise ISSError("Error: Missing RPM under the satellite mount point. (Package id: %s)" %
                                   rpm['id'], "")
                # get the path to the rpm from under the satellite's mountpoint
                satellite_path = os.path.join(CFG.MOUNT_POINT, rpm['path'])

                if not os.path.exists(satellite_path):
                    raise ISSError("Error: Missing RPM under the satellite mount point: %s" % (satellite_path,), "")

                # create the directory for the rpm, if necessary.
                if not os.path.exists(dirs_to_rpm):
                    os.makedirs(dirs_to_rpm)

                # check if the path to rpm hardlink already exists
                if os.path.exists(path_to_rpm):
                    continue

                try:
                    # copy the file to the path under the mountpoint.
                    if self.hardlinks:
                        os.link(satellite_path, path_to_rpm)
                    else:
                        shutil.copyfile(satellite_path, path_to_rpm)
                except IOError, e:
                    tbout = cStringIO.StringIO()
                    Traceback(mail=0, ostream=tbout, with_locals=1)
                    raise ISSError("Error: Error copying file %s: %s" %
                                   (os.path.join(CFG.MOUNT_POINT, rpm['path']),
                                    e.__class__.__name__), tbout.getvalue()), \
                        None, sys.exc_info()[2]
                except OSError, e:
                    tbout = cStringIO.StringIO()
                    Traceback(mail=0, ostream=tbout, with_locals=1)
                    raise ISSError("Error: Could not make hard link %s: %s (different filesystems?)" %
                                   (os.path.join(CFG.MOUNT_POINT, rpm['path']),
                                    e.__class__.__name__), tbout.getvalue()), \
                        None, sys.exc_info()[2]
                log2email(5, "RPM: %s" % rpm['path'])

                pb.addTo(1)
                pb.printIncrement()
            pb.printComplete()
            log2stdout(3, "Number of RPMs exported: %s" % str(len(self.brpms)))
        except ISSError:
            raise

        except Exception, e:
            tbout = cStringIO.StringIO()
            Traceback(mail=0, ostream=tbout, with_locals=1)
            raise ISSError("%s caught in dump_rpms." % e.__class__.__name__,
                           tbout.getvalue()), \
                None, sys.exc_info()[2]


def get_report():
    body = dumpEMAIL_LOG()
    return body


def print_report():
    print ""
    print "REPORT:"
    report_string = get_report()
    sys.stdout.write(str(report_string))


# Stolen and modified from satsync.py
def sendMail():
    # Send email summary
    body = dumpEMAIL_LOG()
    if body:
        print "+++ sending log as an email +++"
        headers = {
            'Subject': 'Spacewalk Management Satellite Export report from %s' % os.uname()[1],
        }
        #sndr = CFG.get('traceback_mail', 'rhn-satellite')
        sndr = 'rhn-satellite@%s' % os.uname()[1]
        rhnMail.send(headers, body, sender=sndr)
    else:
        print "+++ email requested, but there is nothing to send +++"


def handle_error(message, traceback):
    log2stderr(-1, "\n" + message)
    log2email(-1, traceback)


# This class is a mess.
class ExporterMain:

    def __init__(self):
        initCFG('server.iss')

        # pylint: disable=E1101
        self.options = UI()
        self.action_deps = ActionDeps(self.options)
        self.action_order, self.actions = self.action_deps.get_actions()
        if self.options.debug_level:
            debug_level = int(self.options.debug_level)
        else:
            debug_level = int(CFG.DEBUG)

        CFG.set("TRACEBACK_MAIL", self.options.traceback_mail or CFG.TRACEBACK_MAIL)
        CFG.set("DEBUG", debug_level)
        CFG.set("ISSEMAIL", self.options.email)

        initEMAIL_LOG()

        # This was taken straight from satsync.py.
        try:
            rhnSQL.initDB()
        except SQLConnectError:
            print 'SQLERROR: There was an error connecting to the Database.'
            sys.exit(-1)
        except (SQLError, SQLSchemaError), e:
            # An SQL error is fatal... crash and burn
            exitWithTraceback(e, 'SQL ERROR during xml processing', -1)

        # This was cribbed from satsync.py.
        if self.options.print_configuration:
            CFG.show()
            sys.exit(0)

        if self.options.list_channels:
            self.print_list_channels(self.list_channels())
            sys.exit(0)

        if self.options.list_orgs:
            self.print_orgs(self.list_orgs())
            sys.exit(0)

        # From this point on everything should assume a list of channels, so it needs to be a list
        # even if there's only one entry.
        if self.options.all_channels:
            channel_dict = self.list_channels()
            self.options.channel = []
            for pc in channel_dict.keys():
                self.options.channel.append(pc)
                self.options.channel.extend(channel_dict[pc])
        elif self.options.channel:
            if not isinstance(self.options.channel, type([])):
                self.options.channel = [self.options.channel]
        else:
            sys.stdout.write("--channel not included!\n")
            sys.exit(0)

        # Same as above but for orgs
        if self.options.all_orgs:
            orgs = self.list_orgs()
            self.options.org = []
            for org in orgs:
                self.options.org.append(org['id'])
        elif self.options.org:
            if not type(self.options.org, type([])):
                self.options.org = [self.options.org]
            orgs = {}
            for org in self.list_orgs():
                orgs[org['name']] = str(org['id'])
            using_orgs = []
            for org in self.options.org:
                # User might have specified org name or org id, try both
                if org in orgs.values():  # ids
                    using_orgs.append(org)
                elif org in orgs.keys():  # names
                    using_orgs.append(orgs[org])
                else:
                    sys.stdout.write("Org not found: %s\n" % org)
                    exit(0)
            self.options.org = using_orgs
        else:
            self.options.org = []
        self.options.org = [str(x) for x in self.options.org]

        # Since everything gets dumped to a directory it wouldn't make
        # much sense if it wasn't required.
        if self.options.dir:
            self.isos_dir = os.path.join(self.options.dir, "satellite-isos")
            self.outputdir = self.options.dir
        else:
            sys.stdout.write("--dir not included!\n")
            sys.exit(0)

        if self.options.use_sync_date and self.options.use_rhn_date:
            sys.stderr.write("--use-rhn-date and --use-sync-date are mutually exclusive.\n")
            sys.exit(1)
        elif self.options.use_sync_date:
            self.options.use_rhn_date = False
        else:
            self.options.use_rhn_date = True

        if self.options.end_date and not self.options.start_date:
            sys.stderr.write("--end-date must be used with --start-date.\n")
            sys.exit(1)

        if self.options.end_date and len(self.options.end_date) < 8:
            sys.stdout.write(_("format of %s should be at least YYYYMMDD.\n") % '--end-date')
            sys.exit(1)

        if self.options.start_date and len(self.options.start_date) < 8:
            sys.stdout.write(_("format of %s should be at least YYYYMMDD.\n") % '--start-date')
            sys.exit(1)

        if self.options.start_date:
            if self.options.end_date is None:
                self.end_date = time.strftime("%Y%m%d%H%M%S")
            else:
                self.end_date = self.options.end_date.ljust(14, '0')

            self.start_date = self.options.start_date.ljust(14, '0')
            print "start date limit: %s" % self.start_date
            print "end date limit: %s" % self.end_date
        else:
            self.start_date = None
            self.end_date = None

        if self.start_date and self.options.whole_errata:
            self.whole_errata = self.options.whole_errata

        # verify mountpoint
        if os.access(self.outputdir, os.F_OK | os.R_OK | os.W_OK):
            if os.path.isdir(self.outputdir):
                self.dumper = Dumper(self.outputdir,
                                     self.options.channel,
                                     self.options.org,
                                     self.options.hard_links,
                                     start_date=self.start_date,
                                     end_date=self.end_date,
                                     use_rhn_date=self.options.use_rhn_date,
                                     whole_errata=self.options.whole_errata)
                self.actionmap = {
                    'arches':   {'dump': self.dumper.dump_arches},
                    'arches-extra':   {'dump': self.dumper.dump_server_group_type_server_arches},
                    'blacklists':   {'dump': self.dumper.dump_blacklist_obsoletes},
                    'channel-families':   {'dump': self.dumper.dump_channel_families},
                    'channels':   {'dump': self.dumper.dump_channels},
                    'packages':   {'dump': self.dumper.dump_packages},
                    'short':   {'dump': self.dumper.dump_packages_short},
                    #'channel-pkg-short' :   {'dump' : self.dumper.dump_channel_packages_short},
                    #'source-packages'   :   {'dump' : self.dumper.dump_source_packages},
                    'errata':   {'dump': self.dumper.dump_errata},
                    'kickstarts':   {'dump': [self.dumper.dump_kickstart_data,
                                              self.dumper.dump_kickstart_files]},
                    'rpms':   {'dump': self.dumper.dump_rpms},
                    'orgs':   {'dump': self.dumper.dump_orgs},
                }
            else:
                print "The output directory is not a directory"
                sys.exit(-1)
        else:
            print "can't access output directory"
            sys.exit(-1)

    @staticmethod
    def list_channels():
        """ return all available channels

            the returned format is dictionary containing base_label as keys and value is list
            of labels of child channels
        """
        # The keys for channel_dict are the labels of the base channels.
        # The values associated with each key is a list of the labels of
        # the child channels whose parent channel is the key.
        channel_dict = {}

        # Grab some info on base channels. Base channels
        # have parent_channel set to null.
        base_channel_query = rhnSQL.Statement("""
            select  id, label
            from    rhnChannel
            where   parent_channel is null
        """)
        base_channel_data = rhnSQL.prepare(base_channel_query)
        base_channel_data.execute()
        base_channels = base_channel_data.fetchall_dict()

        # Grab some info on child channels.
        child_channel_query = rhnSQL.Statement("""
            select  id, label, parent_channel
            from    rhnChannel
            where   parent_channel = :id
        """)
        child_channel_data = rhnSQL.prepare(child_channel_query)

        if base_channels:
            for ch in base_channels:
                base_label = ch['label']
                base_id = ch['id']

                # If the base channel isn't in channel_dict yet, create
                # an empty list for it.
                if not base_label in channel_dict:
                    channel_dict[base_label] = []

                # grab the child channel information for this base channel.
                child_channel_data.execute(id=base_id)
                child_channels = child_channel_data.fetchall_dict()

                # If the base channel has some child channels, add them
                # to the list associated with the base channel in channel_dict.
                # Organizing the labels this way makes it a lot easier to print
                # out.
                if child_channels:
                    for child in child_channels:
                        child_label = child['label']
                        channel_dict[base_label].append(child_label)
        return channel_dict

    @staticmethod
    def print_list_channels(channel_dict):
        """ channel_dict is dictionary containing base_label as keys and value is list
            of labels of child channels
        """
        if channel_dict:
            # Print the legend.
            print "Channel List:"
            print "B = Base Channel"
            print "C = Child Channel"
            print ""

            base_template = "B %s"
            child_template = "C\t%s"

            # Print channel information.
            for pc in channel_dict.keys():
                print base_template % (pc,)
                for cc in channel_dict[pc]:
                    print child_template % (cc,)
                print " "
        else:
            print "No Channels available for listing."

    @staticmethod
    def list_orgs():
        """
        Return a list of all orgs.
        """
        org_query = rhnSQL.Statement("""
            select  id, name
            from    web_customer
        """)
        org_data = rhnSQL.prepare(org_query)
        org_data.execute()
        return org_data.fetchall_dict()

    @staticmethod
    def print_orgs(orgs):
        if orgs and len(orgs) > 0:
            print "Orgs available for export:"
            for org in orgs:
                print "Id: %s, Name: \'%s\'" % (org['id'], org['name'])
        else:
            print "No Orgs available for listing."

    def main(self):
        # pylint: disable=E1101
        try:
            for action in self.action_order:
                if self.actions[action] == 1:
                    if not action in self.actionmap:
                        # If we get here there's a programming error. It means that self.action_order
                        # contains a action that isn't defined in self.actionmap.
                        sys.stderr.write("List of actions doesn't have %s.\n" % (action,))
                    else:
                        if isinstance(self.actionmap[action]['dump'], type([])):
                            for dmp in self.actionmap[action]['dump']:
                                dmp()
                        else:
                            self.actionmap[action]['dump']()

                        # Now Compress the dump data
                        if action != 'rpms':
                            if action == 'arches-extra':
                                action = 'arches'
                            if action == 'short':
                                action = 'packages_short'
                            if action == 'channel-families':
                                action = 'channel_families'
                            if action == 'kickstarts':
                                action = 'kickstart_trees'
                            os_data_dir = os.path.join(self.outputdir, action)
                            if os.path.exists(os_data_dir):
                                for fpath, _dirs, files in \
                                        os.walk(os_data_dir):
                                    for f in files:
                                        if f.endswith(".xml"):
                                            filepath = os.path.join(fpath, f)
                                            compress_file(filepath)
            if self.options.make_isos:
                #iso_output = os.path.join(self.isos_dir, self.dump_dir)
                iso_output = self.isos_dir
                if not os.path.exists(iso_output):
                    os.makedirs(iso_output)

                iss_isos.create_isos(self.outputdir, iso_output,
                                     "rhn-export", self.start_date, self.end_date,
                                     iso_type=self.options.make_isos)

                # Generate md5sum digest file for isos
                if os.path.exists(iso_output):
                    f = open(os.path.join(iso_output, 'MD5SUM'), 'w')
                    for iso_file in os.listdir(iso_output):
                        if self.options.make_isos != "dvds":
                            if iso_file != "MD5SUM":
                                md5_val = getFileChecksum('md5', (os.path.join(iso_output, iso_file)))
                                md5str = "%s  %s\n" % (md5_val, iso_file)
                                f.write(md5str)
                    f.close()

            if self.options.email:
                sendMail()

            if self.options.print_report:
                print_report()

        except SystemExit:
            sys.exit(0)

        except ISSError, isserror:
            # I have the tb get generated in the functions that the the error occurred in to minimize
            # the amount of extra crap that shows up in it.
            tb = isserror.tb
            msg = isserror.msg
            handle_error(msg, tb)

            if self.options.email:
                sendMail()
            if self.options.print_report:
                print_report()

            sys.exit(-1)

        except Exception, e:  # pylint: disable=E0012, W0703
            # This should catch the vast majority of errors that aren't ISSErrors
            tbout = cStringIO.StringIO()
            Traceback(mail=0, ostream=tbout, with_locals=1)
            msg = "Error: %s caught!" % e.__class__.__name__
            handle_error(msg, tbout.getvalue())
            if self.options.email:
                sendMail()
            if self.options.print_report:
                print_report()
            sys.exit(-1)


def compress_file(f):
    """
    Gzip the given file and then remove the file.
    """
    datafile = open(f, 'r')
    gzipper = gzip.GzipFile(f + '.gz', 'w', 9)
    gzipper.write(datafile.read())
    gzipper.flush()
    # close opened streams
    gzipper.close()
    datafile.close()
    # removed the old file
    os.unlink(f)

if __name__ == "__main__":
    em = ExporterMain()
    em.main()
