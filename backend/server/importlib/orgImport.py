#
# Copyright (c) 2013--2016 Red Hat, Inc.
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

# Thanks for this class goes to Alex Martelli:
# http://stackoverflow.com/questions/1151658/python-hashable-dicts


class hashabledict(dict):

    def __key(self):
        return tuple((k, self[k]) for k in sorted(self))

    def __hash__(self):
        return hash(self.__key())

    def __eq__(self, other):
        return self.__key() == other.__key()


class OrgImport(Import):

    def __init__(self, batch, backend, master_label, create_orgs=False):
        Import.__init__(self, batch, backend)
        self.master_label = master_label
        self.create_orgs = create_orgs
        self._create_maps()

    def _create_maps(self):
        org_map = self.backend.lookupOrgMap(self.master_label)
        self.mn_to_mi = org_map['master-name-to-master-id']
        self.mi_to_li = org_map['master-id-to-local-id']

    def submit(self):
        try:
            # Always happens: if it does not exist, we create a master record
            if not self.backend.lookupMaster(self.master_label):
                self.backend.createMaster(self.master_label)

            # Always happens: if each org has not been synced before,
            # create master org record.
            missing_master_orgs = []
            for org in self.batch:
                if org['name'] not in list(self.mn_to_mi.keys()):
                    missing_master_orgs.append(org)
            if len(missing_master_orgs) > 0:
                self.backend.createMasterOrgs(self.master_label,
                                              missing_master_orgs)

            # Iff we are force-creating local orgs, create any orgs that are
            # not already mapped to local orgs. If a local org exists with
            # the same name as the master org, use that instead. Link local
            # orgs with master orgs.
            if self.create_orgs:
                orgs_to_create = []
                orgs_to_link = []
                update_master_orgs = []
                for org in self.batch:
                    if (org['id'] not in list(self.mi_to_li.keys())
                            or not self.mi_to_li[org['id']]):
                        local_id = self.backend.lookupOrg(org['name'])
                        if local_id:
                            orgs_to_link.append({
                                'master_id': org['id'],
                                'local_id': local_id})
                        else:
                            orgs_to_create.append(org['name'])
                if len(orgs_to_create) > 0:
                    new_org_map = self.backend.createOrgs(orgs_to_create)
                    for org in orgs_to_create:
                        update_master_orgs.append({
                            'master_id': self.mn_to_mi[org],
                            'local_id': new_org_map[org]})
                update_master_orgs += orgs_to_link
                if len(update_master_orgs) > 0:
                    self.backend.updateMasterOrgs(update_master_orgs)

            # refresh maps after we've just changed things
            self._create_maps()

            # Iff we have a master org mapped to local org, create org
            # trust records
            # we need to uniquify in case user has mapped multiple orgs
            # together
            trusts_to_create = set([])
            for org in self.batch:
                for trust in org['org_trust_ids']:
                    if (org['id'] in list(self.mi_to_li.keys())
                            and trust['org_id'] in list(self.mi_to_li.keys())):
                        my_org_id = self.mi_to_li[org['id']]
                        self.backend.clearOrgTrusts(my_org_id)
                        my_trust_id = self.mi_to_li[trust['org_id']]
                        trusts_to_create.add(hashabledict({
                            'org_id': my_org_id,
                            'trust': my_trust_id}))
                        # org trusts are always bi-directional
                        # (even if we are not syncing the other org)
                        trusts_to_create.add(hashabledict({
                            'org_id': my_trust_id,
                            'trust': my_org_id}))

            if len(trusts_to_create) > 0:
                self.backend.createOrgTrusts(trusts_to_create)
        except:
            self.backend.rollback()
            raise
        self.backend.commit()
