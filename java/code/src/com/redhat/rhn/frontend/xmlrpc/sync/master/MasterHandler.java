/**
 * Copyright (c) 2013 Red Hat, Inc.
 *
 * This software is licensed to you under the GNU General Public License,
 * version 2 (GPLv2). There is NO WARRANTY for this software, express or
 * implied, including the implied warranties of MERCHANTABILITY or FITNESS
 * FOR A PARTICULAR PURPOSE. You should have received a copy of GPLv2
 * along with this software; if not, see
 * http://www.gnu.org/licenses/old-licenses/gpl-2.0.txt.
 *
 * Red Hat trademarks are not licensed under GPLv2. No permission is
 * granted to use or replicate Red Hat trademarks that are incorporated
 * in this software or its documentation.
 */
package com.redhat.rhn.frontend.xmlrpc.sync.master;

import java.util.ArrayList;
import java.util.HashSet;
import java.util.List;
import java.util.Set;

import com.redhat.rhn.common.hibernate.LookupException;
import com.redhat.rhn.common.localization.LocalizationService;
import com.redhat.rhn.domain.iss.IssFactory;
import com.redhat.rhn.domain.iss.IssMaster;
import com.redhat.rhn.domain.iss.IssMasterOrgs;
import com.redhat.rhn.domain.org.Org;
import com.redhat.rhn.domain.org.OrgFactory;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.frontend.xmlrpc.BaseHandler;

/**
 * MasterHandler
 *
 * @version $Rev$
 *
 * @xmlrpc.namespace iss.master
 * @xmlrpc.doc Contains methods to set up information about known-"masters", for use
 * on the "slave" side of ISS
 */
public class MasterHandler extends BaseHandler {

    /**
     * Create a new Master, known to this Slave.
     * @param sessionKey User's session key.
     * @param label Master's fully-qualified domain name
     * @return Newly created ISSMaster object.
     *
     * @xmlrpc.doc Create a new Master, known to this Slave.
     * @xmlrpc.param #param("string", "sessionKey")
     * @xmlrpc.param #param_desc("string", "label", "Master's fully-qualified domain name")
     * @xmlrpc.returntype $IssMasterSerializer
     */
    public IssMaster create(String sessionKey, String label) {
        User u = getLoggedInUser(sessionKey);
        ensureSatAdmin(u);
        IssMaster master = new IssMaster();
        master.setLabel(label);
        IssFactory.save(master);
        master = (IssMaster) IssFactory.reload(master);
        return master;
    }

    /**
     * Updates the label of the specified Master
     * @param sessionKey User's session key.
     * @param masterId Id of the Master to update
     * @param newLabel new label
     * @return updated IssMaster
     *
     * @xmlrpc.doc Updates the label of the specified Master
     * @xmlrpc.param #param("string", "sessionKey")
     * @xmlrpc.param #param_desc("int", "id", "Id of the Master to update")
     * @xmlrpc.param #param_desc("string", "label", "Desired new label")
     * @xmlrpc.returntype $IssMasterSerializer
     */
    public IssMaster update(String sessionKey, Long masterId, String newLabel) {
        IssMaster master = getMaster(sessionKey, masterId);
        master.setLabel(newLabel);
        IssFactory.save(master);
        return master;
    }

    /**
     * Removes a specified Master
     *
     * @param sessionKey User's session key.
     * @param masterId Id of the Master to remove
     * @return 1 on success, exception otherwise
     *
     * @xmlrpc.doc Remove the specified Master
     * @xmlrpc.param #param("string", "sessionKey")
     * @xmlrpc.param #param_desc("int", "id", "Id of the Master to remove")
     * @xmlrpc.returntype #return_int_success()
     */
    public int delete(String sessionKey, Long masterId) {
        IssMaster master = getMaster(sessionKey, masterId);
        IssFactory.delete(master);
        return 1;
    }

    /**
     * Find a Master by specifying its ID
     * @param sessionKey User's session key.
     * @param masterId Id of the Master to look for
     * @return the specified Master if found, exception otherwise
     *
     * @xmlrpc.doc Remove the specified Master
     * @xmlrpc.param #param("string", "sessionKey")
     * @xmlrpc.param #param_desc("int", "id", "Id of the desired Master")
     * @xmlrpc.returntype $IssMasterSerializer
     */
    public IssMaster getMaster(String sessionKey, Long masterId) {
        User u = getLoggedInUser(sessionKey);
        ensureSatAdmin(u);
        IssMaster master = IssFactory.lookupMasterById(masterId);
        validateExists(master, masterId.toString());
        return master;
    }

    /**
     * Find a Master by specifying its label
     * @param sessionKey User's session key.
     * @param masterLabel Label of the Master to look for
     * @return the specified Master if found, exception otherwise
     *
     * @xmlrpc.doc Remove the specified Master
     * @xmlrpc.param #param("string", "sessionKey")
     * @xmlrpc.param #param_desc("string", "label", "Label of the desired Master")
     * @xmlrpc.returntype $IssMasterSerializer
     */
    public IssMaster getMasterByLabel(String sessionKey, String masterLabel) {
        User u = getLoggedInUser(sessionKey);
        ensureSatAdmin(u);
        IssMaster master = IssFactory.lookupMasterByLabel(masterLabel);
        validateExists(master, masterLabel);
        return master;
    }

    /**
     * List all organizations the specified Master has exported to this Slave
     *
     * @param sessionKey User's session key.
     * @param masterId Id of the Master to look for
     * @return List of MasterOrgs we know about
     *
     * @xmlrpc.doc List all organizations the specified Master has exported to this Slave
     * @xmlrpc.param #param("string", "sessionKey")
     * @xmlrpc.param #param_desc("int", "id", "Id of the desired Master")
     * @xmlrpc.returntype
     *   #array()
     *     $IssMasterOrgsSerializer
     *   #array_end()
     */
    public List<IssMasterOrgs> getMasterOrgs(String sessionKey, Long masterId) {
        IssMaster master = getMaster(sessionKey, masterId);
        return new ArrayList<IssMasterOrgs>(master.getMasterOrgs());
    }

    /**
     * Reset all organizations the specified Master has exported to this Slave
     *
     * @param sessionKey User's session key.
     * @param masterId Id of the Master to look for
     * @param orgs List of MasterOrgs we know about
     * @return 1 if successful, exception otherwise
     *
     * @xmlrpc.doc List all organizations the specified Master has exported to this Slave
     * @xmlrpc.param #param("string", "sessionKey")
     * @xmlrpc.param #param_desc("int", "id", "Id of the desired Master")
     * @xmlrpc.param
     *   #array()
     *     $IssMasterOrgsSerializer
     *   #array_end()
     * @xmlrpc.returntype #return_int_success()
     */
    public int setMasterOrgs(String sessionKey, Long masterId, List<IssMasterOrgs> orgs) {
        IssMaster master = getMaster(sessionKey, masterId);
        for (IssMasterOrgs o : orgs) {
            o.setMaster(master);
        }
        master.setMasterOrgs(new HashSet<IssMasterOrgs>(orgs));
        IssFactory.save(master);
        return 1;
    }

    /**
     * Add a single organizations to the list of those the specified Master has
     * exported to this Slave
     *
     * @param sessionKey User's session key.
     * @param masterId Id of the Master to look for
     * @param newOrg new master-organization to add
     * @return 1 if success, exception otherwise
     *
     * @xmlrpc.doc Add a single organizations to the list of those the specified Master has
     * exported to this Slave
     * @xmlrpc.param #param("string", "sessionKey")
     * @xmlrpc.param #param_desc("int", "id", "Id of the desired Master")
     * @xmlrpc.param #param("newOrg", $IssMasterOrgsSerializer)
     * @xmlrpc.returntype #return_int_success()
     *
     */
    public int addToMaster(String sessionKey, Long masterId, IssMasterOrgs newOrg) {
        IssMaster master = getMaster(sessionKey, masterId);
        newOrg.setMaster(master);
        Set<IssMasterOrgs> orgs = master.getMasterOrgs();
        orgs.add(newOrg);
        master.setMasterOrgs(orgs);
        IssFactory.save(master);
        return 1;
    }

    /**
     * Map a given master-organization to a specific local-organization
     *
     * @param sessionKey User's session key.
     * @param masterId Id of the Master to look for
     * @param masterOrgId id of the master-organization to work with
     * @param localOrgId id of the local organization to map to masterOrgId
     * @return 1 if success, exception otherwise
     *
     * @xmlrpc.doc Add a single organizations to the list of those the specified Master has
     * exported to this Slave
     * @xmlrpc.param #param("string", "sessionKey")
     * @xmlrpc.param #param_desc("int", "masterId", "Id of the desired Master")
     * @xmlrpc.param #param_desc("int", "masterOrgId", "Id of the desired Master")
     * @xmlrpc.param #param_desc("int", "localOrgId", "Id of the desired Master")
     * @xmlrpc.returntype #return_int_success()
     *
     */
    public int mapToLocal(String sessionKey,
                          Long masterId,
                          Long masterOrgId,
                          Long localOrgId) {
        boolean found = false;

        IssMaster master = getMaster(sessionKey, masterId);
        Set<IssMasterOrgs> orgs = master.getMasterOrgs();

        Org localOrg = OrgFactory.lookupById(localOrgId);
        if (localOrg == null) {
            fail("Unable to locate or access Local Organization :" + localOrgId,
                    "lookup.issmaster.local.title", "lookup.issmaster.local.reason1");
        }

        for (IssMasterOrgs o : orgs) {
            if (o.getMasterOrgId().equals(masterOrgId)) {
                o.setLocalOrg(localOrg);
                found = true;
                break;
            }
        }

        if (!found) {
            fail("Unable to locate or access ISS Master Organization : " + masterOrgId,
                    "lookup.issmasterorg.title", "lookup.issmasterorg.reason1");
        }

        IssFactory.save(master);
        return 1;
    }

    private void validateExists(IssMaster master, String srchString) {
        if (master == null) {
            fail("Unable to locate or access ISS Master : " + srchString,
                    "lookup.issmaster.title", "lookup.issmaster.reason1");
        }
    }

    private void fail(String msg, String titleKey, String reasonKey) {
        LocalizationService ls = LocalizationService.getInstance();
        LookupException e = new LookupException(msg);
        e.setLocalizedTitle(ls.getMessage(titleKey));
        e.setLocalizedReason1(ls.getMessage(reasonKey));
        throw e;

    }
}
