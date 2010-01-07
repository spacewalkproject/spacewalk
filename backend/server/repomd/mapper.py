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
#
#   Classes for mapping domain objects to the rhn db.
#

import os.path
import re
import time

from common import CFG
from common import rhnCache
from server import rhnSQL

import domain


CACHE_PREFIX = "/var/cache/rhn/"


class ChannelMapper:

    """ Data Mapper for Channels to the RHN db. """
    
    def __init__(self, pkg_mapper, erratum_mapper, comps_mapper):
        self.pkg_mapper = pkg_mapper
        self.erratum_mapper = erratum_mapper
        self.comps_mapper = comps_mapper

        self.channel_details_sql = rhnSQL.prepare("""
        select
            c.label,
            c.name,
            ct.label checksum_type
        from
            rhnChannel c,
            rhnChecksumType ct
        where c.id = :channel_id
          and c.checksum_type_id = ct.id
        """)

        self.channel_sql = rhnSQL.prepare("""
        select
            package_id
        from
            rhnChannelPackage
        where
            channel_id = :channel_id
        """)

        self.last_modified_sql = rhnSQL.prepare("""
        select
            last_modified
        from
            rhnChannel
        where id = :channel_id
        """)

        self.errata_id_sql = rhnSQL.prepare("""
        select
            e.id
        from
            rhnChannelErrata ce,
            rhnErrata e
        where
            ce.channel_id = :channel_id
        and e.id = ce.errata_id
        """)

        self.comps_id_sql = rhnSQL.prepare("""
        select
            id
        from
            rhnChannelComps
        where
            channel_id = :channel_id
        """)

        self.cloned_from_id_sql = rhnSQL.prepare("""
        select
            original_id id
        from
            rhnChannelCloned
        where
            id = :channel_id
        """)

    def last_modified(self, channel_id):
        """ Get the last_modified field for the provided channel_id. """
        self.last_modified_sql.execute(channel_id = channel_id)
        return self.last_modified_sql.fetchone()[0]

    def get_channel(self, channel_id):
        """ Load the channel with id channel_id and its packages. """

        self.channel_details_sql.execute(channel_id = channel_id)
        details = self.channel_details_sql.fetchone()
        
        channel = domain.Channel(channel_id)
    
        channel.label = details[0]
        channel.name = details[1]
        channel.checksum_type = details[2]

        self.channel_sql.execute(channel_id = channel_id)
        package_ids = self.channel_sql.fetchall()

        channel.num_packages = len(package_ids)
        channel.packages = self._package_generator(package_ids)

        channel.errata = self._erratum_generator(channel_id)

        self.comps_id_sql.execute(channel_id = channel_id)
        comps_id = self.comps_id_sql.fetchone()

        if comps_id:
            channel.comps = self.comps_mapper.get_comps(comps_id[0])

        self.cloned_from_id_sql.execute(channel_id = channel_id)
        cloned_row = self.cloned_from_id_sql.fetchone()
        if cloned_row is not None:
            channel.cloned_from_id = cloned_row[0]
        else:
            channel.cloned_from_id = None

        return channel

    def _package_generator(self, package_ids):
        for package_id in package_ids:
            pkg = self.pkg_mapper.get_package(package_id[0])
            yield pkg 

    def _erratum_generator(self, channel_id):
        self.errata_id_sql.execute(channel_id = channel_id)
        erratum_ids = self.errata_id_sql.fetchall()

        for erratum_id in erratum_ids:
            erratum = self.erratum_mapper.get_erratum(erratum_id[0])
            yield erratum


class CachedPackageMapper:

    """ Data Mapper for Packages to an on-disc cache. """
   
    def __init__(self, mapper):
        cache = rhnCache.Cache()

        # For more speed, we won't compress.
        # cache = rhnCache.CompressedCache(cache)

        cache = rhnCache.ObjectCache(cache)
        self.cache = rhnCache.NullCache(cache)
        self.mapper = mapper

    def get_package(self, package_id):
        """
        Load the package with id package_id. 
        
        Load from the cache, if it is new enough. If not, fall back to the
        provided mapper.
        """
        package_id = str(package_id)

        last_modified = str(self.mapper.last_modified(package_id))
        last_modified = last_modified.replace(" ", "")
        last_modified = last_modified.replace(":", "")
        last_modified = last_modified.replace("-", "")

        cache_key = "repomd-packages/" + package_id
        if self.cache.has_key(cache_key, last_modified):
            package = self.cache.get(cache_key)
        else:
            package = self.mapper.get_package(package_id)
            self.cache.set(cache_key, package, last_modified)

        return package

class SqlPackageMapper:

    """ Data Mapper for Packages to the RHN db. """
    
    def __init__(self):
        self.details_sql = rhnSQL.prepare("""
        select
            pn.name,  
            pevr.version,  
            pevr.release,  
            pevr.epoch,  
            pa.label arch,  
            c.checksum checksum,
            p.summary,
            p.description,
            p.vendor,
            p.build_time,
            p.package_size,
            p.payload_size,
            p.header_start,
            p.header_end,
            pg.name package_group,
            p.build_host,
            p.copyright,
            p.path,
            sr.name source_rpm,
            p.last_modified,
            c.checksum_type
        from  
            rhnPackage p,
            rhnPackageName pn,
            rhnPackageEVR pevr,
            rhnPackageArch pa,
            rhnPackageGroup pg,
            rhnSourceRPM sr,
            rhnChecksumView c
        where
            p.id = :package_id
        and p.name_id = pn.id
        and p.evr_id = pevr.id
        and p.package_arch_id = pa.id
        and p.package_group = pg.id
        and p.source_rpm_id = sr.id
        and p.checksum_id = c.id
        """)
       
        self.filelist_sql = rhnSQL.prepare("""
        select
            pc.name
        from
            rhnPackageCapability pc,
            rhnPackageFile pf
        where
            pf.package_id = :package_id
        and pf.capability_id = pc.id
        """)

        self.prco_sql = rhnSQL.prepare("""
        select
           'provides',
           pp.sense,
           pc.name,
           pc.version
        from
           rhnPackageCapability pc,
           rhnPackageProvides pp
        where
           pp.package_id = :package_id
           and pp.capability_id = pc.id
        union all
        select
           'requires',
           pr.sense,
           pc.name,
           pc.version
        from
           rhnPackageCapability pc,
           rhnPackageRequires pr
        where
           pr.package_id = :package_id
           and pr.capability_id = pc.id
        union all
        select
           'conflicts',
           pcon.sense,
           pc.name,
           pc.version
        from
           rhnPackageCapability pc,
           rhnPackageConflicts pcon
        where
           pcon.package_id = :package_id
           and pcon.capability_id = pc.id
        union all
        select
           'obsoletes',
           po.sense,
           pc.name,
           pc.version
        from
           rhnPackageCapability pc,
           rhnPackageObsoletes po
        where
           po.package_id = :package_id
           and po.capability_id = pc.id
        """)

        self.last_modified_sql = rhnSQL.prepare("""
        select
            last_modified
        from
            rhnPackage
        where id = :package_id
        """)

        self.other_sql = rhnSQL.prepare("""
        select
            name,
            text,
            time
        from
            rhnPackageChangelog
        where package_id = :package_id
        """)

    def last_modified(self, package_id):
        """ Get the last_modified date on the package with id package_id. """
        self.last_modified_sql.execute(package_id = package_id)
        return self.last_modified_sql.fetchone()[0]
    
    def get_package(self, package_id):
        """ Get the package with id package_id from the RHN db. """
        package = domain.Package(package_id)
        self._fill_package_details(package)
        self._fill_package_prco(package)
        self._fill_package_filelist(package)
        self._fill_package_other(package)
        return package

    def _get_package_filename(self, pkg): 
        if pkg[17]: 
            path = pkg[17] 
            return os.path.basename(path) 
        else: 
            name = pkg[0] 
            version = pkg[1] 
            release = pkg[2] 
            arch = pkg[4] 

            return "%s-%s-%s.%s.rpm" % (name, version, release, arch) 

    def _fill_package_details(self, package):
        """ Load the packages basic details (summary, description, etc). """
        self.details_sql.execute(package_id = package.id)
        pkg = self.details_sql.fetchone()

        package.name = pkg[0] 
        package.version = pkg[1]
        package.release = pkg[2]
        if pkg[3] != None:
            package.epoch = pkg[3]
        package.arch = pkg[4]

        package.checksum_type = pkg[20]
        package.checksum = pkg[5]
        package.summary = string_to_unicode(pkg[6])
        package.description = string_to_unicode(pkg[7])
        package.vendor = string_to_unicode(pkg[8])

        package.build_time = oratimestamp_to_sinceepoch(pkg[9])
        
        package.package_size = pkg[10]
        package.payload_size = pkg[11]
        package.header_start = pkg[12]
        package.header_end = pkg[13]
        package.package_group = pkg[14]
        package.build_host = pkg[15]
        package.copyright = string_to_unicode(pkg[16])
        package.filename = self._get_package_filename(pkg)
        package.source_rpm = pkg[18]

    def _fill_package_prco(self, package):
        """ Load the package's provides, requires, conflicts, obsoletes. """
        self.prco_sql.execute(package_id = package.id)
        deps = self.prco_sql.fetchall() or []

        for item in deps:
            version = item[3] or ""
            relation = ""
            release = None
            epoch = 0
            if version:
                sense = item[1] or 0
                relation = SqlPackageMapper.__get_relation(sense)

                vertup = version.split('-')
                if len(vertup) > 1:
                    version = vertup[0]
                    release = vertup[1]

                vertup = version.split(':')
                if len(vertup) > 1:
                    epoch = vertup[0]
                    version = vertup[1]
            
            dep = {'name' : string_to_unicode(item[2]), 'flag' : relation,
                'version' : version, 'release' : release, 'epoch' : epoch}

            if item[0] == "provides":
                package.provides.append(dep)
            elif item[0] == "requires":
                package.requires.append(dep)
            elif item[0] == "conflicts":
                package.conflicts.append(dep)
            elif item[0] == "obsoletes":
                package.obsoletes.append(dep)
            else:
                assert False, "Unknown PRCO type: %s" % item[0]

#    @staticmethod
    def __get_relation(sense):
        """ Convert the binary sense into a string. """

        # Flip the bits for easy comparison
        sense = sense & 0xf
        
        if sense == 2: 
            relation = "LT"
        elif sense == 4: 
            relation = "GT"
        elif sense == 8: 
            relation = "EQ"
        elif sense == 10: 
            relation = "LE"
        elif sense == 12:
            relation = "GE"
        else:
            assert False, "Unknown relation sense: %s" % sense

        return relation
       
    __get_relation = staticmethod(__get_relation)
    
    def _fill_package_filelist(self, package):
        """ Load the package's list of files. """
        self.filelist_sql.execute(package_id = package.id)
        files = self.filelist_sql.fetchall() or []

        for file_dict in files:
            package.files.append(string_to_unicode(file_dict[0]))

    def _fill_package_other(self, package):
        """ Load the package's changelog info. """
        
        self.other_sql.execute(package_id = package.id)
        log_data = self.other_sql.fetchall() or []
        
        for data in log_data:
           
            date = oratimestamp_to_sinceepoch(data[2])

            chglog = {'author' : string_to_unicode(data[0]), 'date' : date,
                      'text' : string_to_unicode(data[1])}
            package.changelog.append(chglog)


class CachedErratumMapper:

    """ Data Mapper for Errata to an on-disc cache. """
   
    def __init__(self, mapper, package_mapper):
        self.package_mapper = package_mapper

        cache = rhnCache.Cache()
        cache = rhnCache.ObjectCache(cache)
        self.cache = rhnCache.NullCache(cache)
        self.mapper = mapper

    def get_erratum(self, erratum_id):
        """
        Load the erratum with id erratum_id. 
        
        Load from the cache, if it is new enough. If not, fall back to the
        provided mapper.
        """
        erratum_id = str(erratum_id)

        last_modified = str(self.mapper.last_modified(erratum_id))
        last_modified = re.sub(" ", "", last_modified)
        last_modified = re.sub(":", "", last_modified)
        last_modified = re.sub("-", "", last_modified)

        cache_key = "repomd-errata/" + erratum_id
        if self.cache.has_key(cache_key, last_modified):
            erratum = self.cache.get(cache_key)
            for package_id in erratum.package_ids:
                package = self.package_mapper.get_package(package_id)
                erratum.packages.append(package)
        else:
            erratum = self.mapper.get_erratum(erratum_id)

            tmp_packages = erratum.packages
            erratum.packages = []
            self.cache.set(cache_key, erratum, last_modified)
            erratum.packages = tmp_packages

        return erratum


class SqlErratumMapper:

    def __init__(self, package_mapper):
        self.package_mapper = package_mapper

        self.last_modified_sql = rhnSQL.prepare("""
        select
            last_modified
        from
            rhnErrata
        where id = :erratum_id
        """)

        self.erratum_details_sql = rhnSQL.prepare("""
        select
            advisory,
            advisory_name,
            advisory_type,
            advisory_rel,
            description,
            synopsis,
            TO_CHAR(issue_date, 'YYYY-MM-DD HH24:MI:SS') AS issue_date,
            TO_CHAR(update_date, 'YYYY-MM-DD HH24:MI:SS') AS update_date
        from
            rhnErrata
        where
            id = :erratum_id
       """)   
       
        self.erratum_cves_sql = rhnSQL.prepare("""
        select
            cve.name as cve_name
        from 
            rhnCVE cve, 
            rhnErrataCVE ec
        where
            ec.errata_id = :erratum_id
        and ec.cve_id = cve.id
        """)

        self.erratum_bzs_sql = rhnSQL.prepare("""
        select
            bug_id,
            summary
        from
            rhnErrataBuglist
        where 
            errata_id = :erratum_id
        """)

        self.erratum_packages_sql = rhnSQL.prepare("""
        select
            package_id
        from
            rhnErrataPackage
        where
            errata_id = :erratum_id
        """)

    def last_modified(self, erratum_id):
        """ Get the last_modified field for the provided erratum_id. """
        self.last_modified_sql.execute(erratum_id = erratum_id)
        return self.last_modified_sql.fetchone()[0]

    def get_erratum(self, erratum_id):
        """ Get the package with id package_id from the RHN db. """
        erratum = domain.Erratum(erratum_id)
        self._fill_erratum_details(erratum)

        # TODO: These two don't work on satellites.
        # We must not install the tables there
        self._fill_erratum_bz_references(erratum)
        self._fill_erratum_cve_references(erratum)

        self._fill_erratum_packages(erratum)
        return erratum

    def _fill_erratum_details(self, erratum):
        self.erratum_details_sql.execute(erratum_id = erratum.id)
        ertm = self.erratum_details_sql.fetchone()
    
        erratum.readable_id = ertm[0]
        erratum.title = ertm[1]
   
        if ertm[2] == 'Security Advisory':
            erratum.advisory_type = 'security'
        elif ertm[2] == 'Bug Fix Advisory':
            erratum.advisory_type = 'bugfix'
        elif ertm[2] == 'Product Enhancement Advisory':
            erratum.advisory_type = 'enhancement'
        else:
            erratum.advisory_type = 'errata'
       
        erratum.version = ertm[3]
        erratum.description = ertm[4]
        erratum.synopsis = ertm[5]
        erratum.issued = ertm[6]
        erratum.updated = ertm[7]

    def _fill_erratum_bz_references(self, erratum):
        self.erratum_bzs_sql.execute(erratum_id = erratum.id)
        bz_refs = self.erratum_bzs_sql.fetchall_dict()

        if bz_refs:
            erratum.bz_references = bz_refs

    def _fill_erratum_cve_references(self, erratum):
        self.erratum_cves_sql.execute(erratum_id = erratum.id)
        cve_refs = self.erratum_cves_sql.fetchall()

        for cve_ref in cve_refs:
            erratum.cve_references.append(cve_ref[0])

    def _fill_erratum_packages(self, erratum):
        self.erratum_packages_sql.execute(erratum_id = erratum.id)
        pkgs = self.erratum_packages_sql.fetchall()

        for pkg in pkgs:
            package = self.package_mapper.get_package(pkg[0])
            erratum.packages.append(package)
            erratum.package_ids.append(pkg[0])


class SqlCompsMapper:

    def __init__(self):
        self.comps_sql = rhnSQL.prepare("""
        select
            relative_filename
        from
            rhnChannelComps
        where 
            id = :comps_id
        """)

    def get_comps(self, comps_id):
        self.comps_sql.execute(comps_id = comps_id)
        comps_row = self.comps_sql.fetchone()
        filename = os.path.join(CFG.mount_point, comps_row[0])
        return domain.Comps(comps_id, filename)


def get_channel_mapper():
    """ Factory Method-ish function to load a Channel Mapper. """
    package_mapper = get_package_mapper()
    erratum_mapper = get_erratum_mapper(package_mapper)
    comps_mapper = SqlCompsMapper()
    channel_mapper = ChannelMapper(package_mapper, erratum_mapper, comps_mapper)

    return channel_mapper


def get_package_mapper():
    """ Factory Method-ish function to load a Package Mapper. """
    package_mapper = SqlPackageMapper()
    package_mapper = CachedPackageMapper(package_mapper)

    return package_mapper


def get_erratum_mapper(package_mapper):
    """ Factory Method-ish function to load an Erratum Mapper. """
    erratum_mapper = SqlErratumMapper(package_mapper)
    erratum_mapper = CachedErratumMapper(erratum_mapper, package_mapper)

    return erratum_mapper


def oratimestamp_to_sinceepoch(ts):
    return time.mktime((ts.year, ts.month, ts.day, ts.hour, ts.minute,
        ts.second, 0, 0, -1))

def string_to_unicode(text):
    if text is None:
        return ''
    if isinstance(text, unicode):
        return text

    #First try a bunch of encodings in strict mode
    encodings = ['ascii', 'iso-8859-1', 'iso-8859-15', 'iso-8859-2']
    for encoding in encodings:
        try:
            dec = text.decode(encoding)
            enc = dec.encode('utf-8')
            return enc
        except UnicodeError:
            continue

    # None of those worked, just do ascii with replace
    dec = text.decode(encoding, 'replace')
    enc = dec.encode('utf-8', 'replace')
    return enc
