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
# Converts bugzilla errata to the intermediate format
#
# $Id$

# XXX: RED HAT INTERNAL ONLY!

# Generic stuff
import os
import pprint
import string
import cgi

# Common stuff
from common import rhnFault, rhnMail, log_error, log_debug, CFG

# Server-side stuff
from server.rhnLib import parseRPMFilename, get_package_path
from server.importlib.importLib import Collection, TransactionError
from server.importlib.packageImport import PackageImport, SourcePackageImport
from server.importlib.errataImport import ErrataImport
from server.importlib.headerSource import rpmBinaryPackage, rpmSourcePackage
from server.importlib.backendOracle import OracleBackend


class BugzillaErrataImport(ErrataImport):
    # save the e-mail address of the person deploying an erratum
    def __init__(self, erratum):
        # Create an errata batch
        batch = Collection()
        batch.append(erratum)
        backend = OracleBackend()
        backend.init()
        timeout = CFG.erratum_notification_timeout
        ErrataImport.__init__(self, batch, backend, queue_timeout=timeout)
        # The prefix is preprended to all paths
        self.prefix = 'rhn/repository'

    def preprocess(self):
        if not len(self.batch):
            # No erratum to process
            return

        # Build a path dictionary
        channels_hash = {}
        for erratum in self.batch:
            for erratum_file in erratum['files']:
                channels = erratum_file['channels']
                for channel in channels:
                    channels_hash[channel] = None

        self.backend.lookupChannels(channels_hash)
        # Build a big fat package batch
        packageBatch = Collection()
        sourcePackageBatch = Collection()
        # Channels affected by source rpms
        srcrpm_channels_hash = {}
        for erratum in self.batch:
            erratumPackages = []
            erratum_files = []
            for erratum_file in erratum['files']:
                filename = erratum_file['filename']
                if has_suffix(filename, '.src.rpm'):
                    file_type = 'SRPM'
                elif has_suffix(filename, '.rpm'):
                    file_type = 'RPM'
                elif has_suffix(filename, '.img'):
                    file_type = 'IMG'
                else:
                    raise rhnFault(47, "Invalid file name %s" % filename,
                        explain=0)
                erratum_file['file_type'] = file_type

                erratum_files.append(erratum_file)

                file_channels = erratum_file['channels']
                channel_list = erratum_file['channel_list'] = []
                for channel in file_channels:
                    channel_h = channels_hash[channel]
                    if channel_h is None:
                        raise rhnFault(47, "Invalid channel name %s" % channel,
                            explain=0)
                    channel_list.append(channel)

                nvrea = parseRPMFilename(filename)
                if nvrea[4] == 'src':
                    isSource = 1
                else:
                    isSource = 0

                # convert nvrea to nevra
                nevra = [nvrea[0], nvrea[3], nvrea[1], nvrea[2], nvrea[4]]

                if isSource:
                    p = rpmSourcePackage()
                else:
                    p = rpmBinaryPackage()

                relative_path = get_package_path(nevra, org_id=None, 
                    prepend=self.prefix, omit_epoch=1, source=isSource)
                filePath = os.path.join(CFG.MOUNT_POINT, relative_path)
                    
                if not os.path.isfile(filePath):
                    # Don't bother to copy the package
                    raise rhnFault(47,
                        "Package %s not found on the server. " % filePath,
                        explain=0)

                p.populateFromFile(filePath, os.path.dirname(relative_path), 
                    org_id=None, channels=channel_list)
                if p["md5sum"] != erratum_file['md5sum']:
                    raise rhnFault(47, 
                        "checksums different for %s: file %s, bugzilla %s" % 
                        (p['path'], p['md5sum'], erratum_file['md5sum']),
                        explain=0)
                if isSource:
                    erratum_file['file_type'] = 'SRPM'
                    sourcePackageBatch.append(p)
                else:
                    erratum_file['file_type'] = 'RPM'
                    packageBatch.append(p)
                    # Map the package back into the erratum
                    erratumPackages.append(p)
                    
                    # Now save in the corresponding src.rpm entry all the
                    # channels affected by this package
                    chhash = {}
                    for ch in channel_list:
                        chhash[ch] = None
                    
                    source_rpm = p['source_rpm']
                    if not srcrpm_channels_hash.has_key(source_rpm):
                        srcrpm_channels_hash[source_rpm] = chhash
                    else:
                        srcrpm_channels_hash[source_rpm].update(chhash)
                        
                erratum_file['package'] = p
            erratum['files'] = erratum_files
            erratum['packages'] = erratumPackages

            # Now fix the channels for all the source rpms - it has to be the
            # intersection of (union of all the channels affected by binary
            # rpms built out of this source) and channel_list
            for erratum_file in erratum_files:
                if erratum_file['file_type'] != 'SRPM':
                    continue
                if not erratum_file.has_key('channel_list'):
                    continue
                if not erratum_file.has_key('package'):
                    continue
                channel_list = []
                source_rpm = erratum_file['package']['source_rpm']
                bin_channels = srcrpm_channels_hash[source_rpm]
                channel_list = filter(lambda x, h=bin_channels:
                    h.has_key(x), erratum_file['channel_list'])
                erratum_file['channel_list'] = channel_list

        # We're done with this hash
        del srcrpm_channels_hash

        # Source packages
        packageImport = SourcePackageImport(sourcePackageBatch, self.backend, 
            caller="server.bugzilla.errata_import")
        packageImport.setIgnoreUploaded(1)
        packageImport.setUploadForce(0)
        packageImport.setTransactional(1)
        try:
            packageImport.run()
        except TransactionError:
            # Transaction failed
            lookup_channels(sourcePackageBatch, source=1)
            failBatch(sourcePackageBatch, source=1)

        # Clean up the package set - just as an example here, since we don't
        # really need the status
        packageImport.status()
        
                
        # Binary packages
        packageImport = PackageImport(packageBatch, self.backend,
            caller="server.bugzilla.errata_import")
        packageImport.setIgnoreUploaded(1)
        packageImport.setUploadForce(0)
        packageImport.setTransactional(1)
        try:
            packageImport.run()
        except TransactionError:
            # Transaction failed
            lookup_channels(packageBatch)
            failBatch(packageBatch)

        packageImport.subscribeToChannels()
        packageImport.status()

        # Gather the package ids and channel ids back
        for erratum in self.batch:
            packages = erratum['packages']
            erratumPackages = {}
            erratumChannels = {}
            for package in packages:
                if package.ignored:
                    continue
                erratumPackages[package.id] = None
                for channel in package.channels:
                    erratumChannels[channel] = None
            objlist = map(lambda x: {'package_id' : x}, erratumPackages.keys())
            erratum['packages'] = objlist

            erratum['channels'] = erratumChannels.keys()

            # Populate the ErrataFile-related entries
            for f in erratum['files']:
                if not f.has_key('package'):
                    continue
                package = f['package']
                del f['package']
                f['package_id'] = package.id
                
                # Determine the channels this file is related to
                for c in f['channel_list']:
                    if not self.channels.has_key(c):
                        self.channels[c] = None

        # There is only one erratum anyway
        self._preprocessErratumCVE(self.batch[0])
        self._preprocessErratumFileChannels(self.batch[0])

    def _preprocessErratumFiles(self, erratum):
        pass
    def _fix_erratum_packages_lookup(self, erratum):
        pass
    def _fix_erratum_file_packages(self, erratum):
        pass

    # inherit fix() from the parent class
    
    # Various lookups we don't need
    def _fix_lookups(self):
        pass
    def _fix_erratum_packages(self, erratum):
        pass

    def _fix_erratum_channels(self, erratum):
        channel_ids = []
        for label in erratum['channels']:
            channel_ids.append({'channel_id' : self.channels[label]['id']})
        erratum['channels'] = channel_ids
    
    def submit(self):
        ErrataImport.submit(self)
        self.__mailAlert(self.batch[0].id, self.batch[0].get('erratum_deployed_by'))

    def __mailAlert(self, errataId, deployed_by=None):
        # Save the e-mail address of the person deploying an erratum
        log_error("Mailing alert for errata id %s, pushed by %s, to %s" % 
            (errataId, deployed_by, CFG.ERRATA_MAILTO))
        
        h = self.backend.dbmodule.prepare("""
            select  
                e.id,
                e.advisory,
                e.advisory_type,
                e.synopsis,
                e.issue_date,
                e.description,
                e.topic
            from
                rhnErrata e
            where
                e.id = :id
            """)
        h.execute(id=errataId)
        erratum = h.fetchone_dict()
        if not erratum:
            raise Exception("This can't happen")

        # Fetch channels
        h = self.backend.dbmodule.prepare("""
            select
                c.label
            from 
                rhnChannelErrata ce,
                rhnChannel c
            where ce.errata_id = :id
            and ce.channel_id = c.id
        """)
        h.execute(id=errataId)
        channels = h.fetchall_dict() or []
        channels = map(lambda x: x['label'], channels)
        erratum['channels'] = channels

        # Fetch packages
        packages = []
        h = self.backend.dbmodule.prepare("""
            select ef.id, ef.filename
              from rhnErrataFile ef
             where ef.errata_id = :errata_id
        """)
        h_channels = self.backend.dbmodule.prepare("""
            select c.label
              from rhnErrataFileChannel efc, rhnChannel c
             where efc.errata_file_id = :errata_file_id
               and efc.channel_id = c.id
        """)
        h.execute(errata_id=errataId)
        while 1:
            row = h.fetchone_dict()
            if not row:
                break
            errata_file_id = row['id']
            filename = row['filename']
            
            # Get the channels now
            h_channels.execute(errata_file_id=errata_file_id)
            channels = h_channels.fetchall_dict() or []
            channels = map(lambda x: x['label'], channels)
            p = {
                'errata_file_id'    : errata_file_id,
                'filename'          : filename,
                'channels'          : channels,
            }
            packages.append(p)
        erratum['packages'] = packages

        msg = "\n%s\n" % pprint.pformat(erratum)
        dbname = string.split(self.backend.dbmodule.database(),'@', 1)[1]

        # Normalize the list of recepients for the e-mail notification
        to = CFG.ERRATA_MAILTO
        if not isinstance(to, type([])):
            # Only one string from the configuration file; make it a list
            to = [to]

        if deployed_by:
            depl_by_string = " by %s" % (deployed_by, )
            if deployed_by not in to:
                # Append the guy who deployed the erratum to the list of
                # recepients for this e-mail notification
                to.append(deployed_by)
        else:
            depl_by_string = ""
        subjecttext  = "[ERRATA] %s pushed to %s%s" % (erratum['advisory'],
            dbname, depl_by_string)

        rhnMail.send(
            {
                "Subject"   : subjecttext, 
                "To"        : string.join(to, ', '),
            }, msg)

    # Check if the erratum was already imported
    def check(self):
        for erratum in self.batch:
            self._check_erratum(erratum)

    def _check_erratum(self, erratum):
        advisory = erratum['advisory']
        db_erratum = self.backend.lookupErratum(erratum)
        if not db_erratum:
            log_debug(5, "Erratum %s not imported yet" % 
                erratum['advisory_name'])
            raise rhnFault(130, "Advisory %s not imported" % advisory)
        db_advisory = db_erratum['advisory']

        if advisory == db_advisory:
            # Already imported
            return 0

        raise rhnFault(130, 
            "Advisory %s not updated (version available: %s)" % 
            (advisory, db_advisory))

def formatPackages(packages):
    result = ""
    for package in packages:
        rowspan = len(package.diff)
        subentry = ""
        for obj in package.diff:
            if not subentry:
                subentry = "%s</tr>" % string.join(
                    map(lambda x: '<td align="left">%s</td>' % cgi.escape(str(x)), obj), "")
            else:
                subentry = subentry + '\t<tr>%s</tr>\n' % string.join(
                    map(lambda x: '<td align="left">%s</td>' % cgi.escape(str(x)), obj),
                    "")
        row = ''
        for e in [package['path'], package.id]:
            row = row + '<td align="left" rowspan=%s width=30>%s</td>' % (rowspan, e)
        row = '<tr>%s%s\n' % (row, subentry)
        result = result + row
    return "<br><table border=1>%s</table>" % result
            
def failBatch(batch, source=0):
    message = "package"
    exmsg = "packages"
    if source:
        message = "package source"
        exmsg = "source packages"
    bad = []
    for package in batch:
        if package.ignored:
            continue
        if package.diff and package.diff.level > 1:
            log_error(
                "Bugzilla %s import error; severity=%s; packageId=%s; %s" % 
                    (message, package.diff.level, package.id, package.diff))
            bad.append(package)
    # Print the packages with problems
    raise TransactionError("Conflicting %s for import" % exmsg,
        formatPackages(bad))

def has_suffix(s, suffix):
    return s[-len(suffix):] == suffix

def lookup_channels(batch, source=0):
    # XXX I hate importing rhnSQL at this level; should figure out a
    # better place for this
    from server import rhnSQL

    if not source:
        query = """
            select c.label
              from rhnChannelPackage cp, rhnChannel c
             where cp.channel_id = c.id
               and c.org_id is null
               and cp.package_id = :package_id
        """
    else:
        query = """
            select distinct c.label
              from rhnChannelPackage cp, rhnChannel c, rhnPackage p,
                   rhnPackageSource ps
             where cp.channel_id = c.id
               and c.org_id is null
               and cp.package_id = p.id
               and p.source_rpm_id = ps.source_rpm_id
               and (
                    (p.org_id is null and ps.org_id is null) or
                    p.org_id = ps.org_id
                   )
               and ps.id = :package_id
        """
    h = rhnSQL.prepare(query)

    for p in batch:
        if p.ignored:
            continue
        if not p.diff:
            continue
        if p.diff.level <= 1:
            # Not different enough
            continue

        h.execute(package_id=p.id)
        channels = map(lambda x: x['label'], h.fetchall_dict() or [])
        incoming_channels = p.get('channels')
        if incoming_channels:
            incoming_channels = incoming_channels.values()
        else:
            incoming_channels = []

        p.diff.append(('channels', string.join(incoming_channels),
            string.join(channels)))


if __name__ == '__main__':
    pass
