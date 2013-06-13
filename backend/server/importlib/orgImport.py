#
# Copyright (c) 2013 Red Hat, Inc.
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
# Org import process
#

from importLib import Import

# Here is how this is supposed to work:
# 1) Satellite sync creates a bunch of importLib.Org objects.
#       All ids are master ids.
# 2) Always happens: if it does not exist, we create a master record
# 3) Always happens: if each org has not been synced before,
#       create master org record.
# 4) Iff we are force-creating local orgs, create any orgs that are
#       not already mapped to local orgs.
# 5) Iff we have a master org mapped to local org, create org trust records

class OrgImport(Import):
    def __init__(self, batch, backend, master_label, create_orgs=False):
        Import.__init__(self, batch, backend)
        self.master_label = master_label
        self.create_orgs = create_orgs
        self._create_maps()

    def _create_maps(self):
        self.org_map = self.backend.lookupOrgMap(self.master_label)
        self.mn_to_mi = {} # master org name to master org id map
        self.mi_to_li = {} # master org id to local org id map
        for org in self.org_map:
            if ('master_org_id' in org.keys()
                    and 'master_org_name' in org.keys()
                    and org['master_org_id']
                    and org['master_org_name']):
                self.mn_to_mi[org['master_org_name']] = org['master_org_id']
            if ('master_org_id' in org.keys()
                    and 'local_org_id' in org.keys()
                    and org['master_org_id']
                    and org['local_org_id']):
                self.mi_to_li[org['master_org_id']] = org['local_org_id']

    def submit(self):
        try:
            if not self.backend.lookupMaster(self.master_label):
                self.backend.createMaster(self.master_label)

            missing_master_orgs = []
            for org in self.batch:
                if org['name'] not in self.mn_to_mi.keys():
                    missing_master_orgs.append(org)
            if len(missing_master_orgs) > 0:
                self.backend.createMasterOrgs(self.master_label,
                        missing_master_orgs)

            if self.create_orgs:
                orgs_to_create = []
                for org in self.batch:
                    if (org['id'] not in self.mi_to_li.keys()
                            or not self.mi_to_li[org['id']]):
                        orgs_to_create.append(org['name'])
                if len(orgs_to_create) > 0:
                    new_org_map = self.backend.createOrgs(orgs_to_create)
                    update_master_orgs = []
                    for org in orgs_to_create:
                        update_master_org.append({
                            'master_id': self.mn_to_mi[org],
                            'local_org_id': new_org_map[self.mn_to_mi[org]]})
                    self.backend.updateMasterOrgs(update_master_orgs)

            self._create_maps()
            existing_trusts = self.backend.lookupOrgTrusts()
            trusts_to_create = []
            for org in self.batch:
                for trust in org['org_trust_ids']:
                    if (org['id'] in self.mi_to_li.keys()
                            and trust['org_id'] in self.mi_to_li.keys()
                            and not (org['id'] in existing_trusts.keys()
                                and trust['org_id'] in
                                existing_trusts[org['id']])):
                        trusts_to_create.append({
                                'org_id': self.mi_to_li[org['id']],
                                'trust': self.mi_to_li[trust['org_id']]})
            if len(trusts_to_create) > 0:
                self.backend.createOrgTrusts(trusts_to_create)
        except:
            self.backend.rollback()
            raise
        self.backend.commit()
