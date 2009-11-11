#!/usr/bin/python
# Copyright (C) 2008 Red Hat, Inc.
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

from satellite_tools.exporter import exportLib

from server import rhnSQL

class ChannelDumper(_ChannelDumper):
    tag_name = 'rhn-channel'

    def __init__(self, writer, row):
        BaseRowDumper.__init__(self, writer, row)

    #_query_release_channel_map = rhnSQL.Statement("""
    #    select dcm.os product, dcm.release version,
    #           dcm.eus_release release, ca.label channel_arch,
    #           dcm.is_default is_default
    #      from rhnDistChannelMap dcm, rhnChannelArch ca
    #     where dcm.channel_id = :channel_id
    #       and dcm.channel_arch_id = ca.id
    #       and dcm.is_eus = 'Y'
    #""")
    def set_iterator(self):
        arrayiterator = _ChannelDumper.set_iterator()
        arr = arrayiterator._arr
        mappings = [
            ('rhn-channel-receiving-updates', 'receiving_updates'),
        ]
        for k, v in mappings:
            arr.append(SimpleDumper(self._writer, k, self._row[v]))

        #channel_id = self._row['id']
        ## Add EUS info
        #h = rhnSQL.prepare(self._query_release_channel_map)
        #h.execute(channel_id=channel_id)
        #arr.append(ReleaseDumper(self._writer, h))
        return arrayiterator


#class ReleaseDumper(BaseDumper):
#    tag_name = 'rhn-release'
#
#    def dump_subelement(self, data):
#        d = _ReleaseDumper(self._writer, data)
#        d.dump()
#
#class _ReleaseDumper(BaseRowDumper):
#    tag_name = 'rhn-release'
#
#    def set_attributes(self):
#        return {
#            'product'       : self._row['product'],
#            'version'       : self._row['version'],
#            'release'       : self._row['release'],
#            'channel-arch'  : self._row['channel_arch'],
#            'is-default'  : self._row['is_default'],
#        }


#class _PackageDumper(BaseRowDumper):
#    tag_name = 'rhn-package'
#
#    def set_attributes(self):
#        attrs = ["name", "version", "release", "package_arch",
#            "package_group", "rpm_version", "package_size", "payload_size",
#            "build_host", "source_rpm", "md5sum", "payload_format",
#            "compat", "cookie", "org_id"]
#        attrdict = {
#            'id'            : "rhn-package-%s" % self._row['id'],
#            'epoch'         : self._row['epoch'] or "",
#            'build-time'    : _dbtime2timestamp(self._row['build_time']),
#            'last-modified' : _dbtime2timestamp(self._row['last_modified']),
#        }
#        for attr in attrs:
#            attrdict[attr.replace('_', '-')] = self._row[attr]
#        return attrdict
#

##
class ShortPackagesDumper(BaseDumper):
    tag_name = 'rhn-packages-short'

    def set_iterator(self):
        if self._iterator:
            return self._iterator

        # Sample query only
        h = rhnSQL.prepare("""
            select
                p.id,
                pn.name,
                pe.evr.version version,
                pe.evr.release release,
                pe.evr.epoch epoch,
                pa.label package_arch,
                p.md5sum,
                p.org_id,
                TO_CHAR(p.last_modified, 'YYYYMMDDHH24MISS') last_modified
            from rhnPackage p, rhnPackageName pn, rhnPackageEVR pe,
                rhnPackageArch pa
            where p.name_id = pn.id
            and p.evr_id = pe.id
            and p.package_arch_id = pa.id
            and p.path is not null
            and rownum < 3
        """)
        h.execute()
        return h

    def dump_subelement(self, data):
        attributes = {}
        attrs = [
            "id", "name", "version", "release", "epoch",
            "package_arch", "md5sum", "package_size", "org_id",
        ]
        for attr in attrs:
            attributes[attr.replace('_', '-')] = data[attr]
        attributes['id'] = "rhn-package-%s" % data['id']
        attributes['epoch'] = data['epoch'] or ""
        attributes['last-modified'] = _dbtime2timestamp(data['last_modified'])
        d = EmptyDumper(self._writer, 'rhn-package-short',
            attributes=attributes)
        d.dump()


## Errata
class ErrataDumper(BaseDumper):
    tag_name = 'rhn-errata'

    def set_iterator(self):
        if self._iterator:
            return self._iterator

        _query_errata_info = """
            select
                    e.id,
                    e.advisory_name,
                    e.advisory,
                    e.advisory_type,
                    e.advisory_rel,
                    e.product,
                    e.description,
                    %s
                    e.topic,
                    e.solution,
                    TO_CHAR(e.issue_date, 'YYYYMMDDHH24MISS') issue_date,
                    TO_CHAR(e.update_date, 'YYYYMMDDHH24MISS') update_date,
                    TO_CHAR(e.last_modified, 'YYYYMMDDHH24MISS') last_modified,
                    e.refers_to,
                    e.notes
             from rhnErrata e
            where rownum < 3
        """

        # include severity into synopsis before
        # exporting to satellite.
        # Also ignore the first 18 characters in
        # the label(errata.sev.label.) from
        # rhnErrataSeverity table
        synopsis = """
            (select SUBSTR(label,18) || ':'
               from rhnErrataSeverity
              where id = e.severity_id) || e.synopsis synposis,"""
        h = rhnSQL.prepare(_query_errata_info % synopsis)
        h.execute()
        return h


class _ErratumDumper(BaseRowDumper):
    tag_name = 'rhn-erratum'

    def set_attributes(self):
        h = rhnSQL.prepare("""
            select c.label
            from rhnChannelErrata ec, rhnChannel c
            where ec.channel_id = c.id
            and ec.errata_id = :errata_id
        """)
        h.execute(errata_id=self._row['id'])
        channels = [x['label'] for x in h.fetchall_dict() or []]

        h = rhnSQL.prepare("""
            select ep.package_id
            from rhnErrataPackage ep
            where ep.errata_id = :errata_id
        """)
        h.execute(errata_id=self._row['id'])
        packages = ["rhn-package-%s" % x['package_id'] for x in \
                h.fetchall_dict() or []]

        h = rhnSQL.prepare("""
            select c.name cve
            from rhnErrataCVE ec, rhnCVE c
            where ec.errata_id = :errata_id
            and ec.cve_id = c.id
        """)
        h.execute(errata_id=self._row['id'])
        cves = [x['cve'] for x in h.fetchall_dict() or []]

        return {
            'id'        : 'rhn-erratum-%s' % self._row['id'],
            'advisory'  : self._row['advisory'],
            'channels'  : ' '.join(channels),
            'packages'  : ' '.join(packages),
            'cve-names' : ' '.join(cves),
        }

    def set_iterator(self):
        arr = []

        mappings = [
            ('rhn-erratum-advisory-name', 'advisory_name', 32),
            ('rhn-erratum-advisory-rel', 'advisory_rel', 32),
            ('rhn-erratum-advisory-type', 'advisory_type', 32),
            ('rhn-erratum-product', 'product', 64),
            ('rhn-erratum-description', 'description', 4000),
            ('rhn-erratum-synopsis', 'synopsis', 4000),
            ('rhn-erratum-topic', 'topic', 4000),
            ('rhn-erratum-solution', 'solution', 4000),
            ('rhn-erratum-refers-to', 'refers_to', 4000),
            ('rhn-erratum-notes', 'notes', 4000),
        ]
        for k, v, b in mappings:
            arr.append(SimpleDumper(self._writer, k, self._row[v] or "", b))
        arr.append(SimpleDumper(self._writer, 'rhn-erratum-issue-date',
            _dbtime2timestamp(self._row['issue_date'])))
        arr.append(SimpleDumper(self._writer, 'rhn-erratum-update-date',
            _dbtime2timestamp(self._row['update_date'])))
        arr.append(SimpleDumper(self._writer, 'rhn-erratum-last-modified',
            _dbtime2timestamp(self._row['last_modified'])))

        h = rhnSQL.prepare("""
            select keyword
            from rhnErrataKeyword
            where errata_id = :errata_id
        """)
        h.execute(errata_id=self._row['id'])
        arr.append(_ErratumKeywordDumper(self._writer, data_iterator=h))

        h = rhnSQL.prepare("""
            select bug_id, summary
            from rhnErrataBuglist
            where errata_id = :errata_id
        """)
        h.execute(errata_id=self._row['id'])
        arr.append(_ErratumBuglistDumper(self._writer, data_iterator=h))
        _query_errata_file_info = """
             select ef.id errata_file_id, ef.md5sum,
                    ef.filename, eft.label type,
                    efp.package_id, efps.package_id source_package_id
               from rhnErrataFile ef, rhnErrataFileType eft,
                    rhnErrataFilePackage efp, rhnErrataFilePackageSource efps
              where ef.errata_id = :errata_id
                and ef.type = eft.id
                %s
                and ef.id = efp.errata_file_id (+)
                and ef.id = efps.errata_file_id (+)

        """
        type_id_sql = """and ef.type != (select id
                                           from rhnErrataFileType
                                          where label = 'OVAL')"""
        # SATSYNC: Ignore the Oval files stuff(typeid=4)
        # while exporting errata File info to satellite
        h = rhnSQL.prepare(_query_errata_file_info % type_id_sql)
        h.execute(errata_id=self._row['id'])
        arr.append(_ErratumFilesDumper(self._writer, data_iterator=h))

        return ArrayIterator(arr)


def errata_cursor(errata_id):
    _query_errata_info = """
        select
            e.id,
            e.advisory_name,
            e.advisory,
            e.advisory_type,
            e.advisory_rel,
            e.product,
            e.description,
            %s
            e.topic,
            e.solution,
            TO_CHAR(e.issue_date, 'YYYYMMDDHH24MISS') issue_date,
            TO_CHAR(e.update_date, 'YYYYMMDDHH24MISS') update_date,
            e.refers_to,
            e.notes
        from rhnErrata e
        where e.id = :errata_id
    """

    # include severity into synopsis before
    # exporting to satellite.
    # Also ignore the first 17 characters in
    # the label(errata.sev.label.) from
    # rhnErrataSeverity table
    synopsis = """
        (select SUBSTR(label,18) || ':'
           from rhnErrataSeverity
          where id = e.severity_id) || e.synopsis synposis,
    """
    h = rhnSQL.prepare(_query_errata_info % synopsis)
    h.execute(errata_id=errata_id)
    return h


class ProductNamesDumper(BaseDumper):

    tag_name = "rhn-product-names"

    def set_iterator(self):
        query = rhnSQL.prepare("""
            select label, name from rhnProductName
        """)
        query.execute()
        return query

    def dump_subelement(self, data):
        EmptyDumper(self._writer, 'rhn-product-name', data).dump()
