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
import java.util.Arrays;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;

import com.redhat.rhn.FaultException;
import com.redhat.rhn.common.hibernate.LookupException;
import com.redhat.rhn.common.localization.LocalizationService;
import com.redhat.rhn.domain.iss.IssFactory;
import com.redhat.rhn.domain.iss.IssMaster;
import com.redhat.rhn.domain.iss.IssMasterOrg;
import com.redhat.rhn.domain.org.Org;
import com.redhat.rhn.domain.org.OrgFactory;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.frontend.xmlrpc.BaseHandler;
import com.redhat.rhn.frontend.xmlrpc.IssDuplicateMasterException;

/**
 * MasterHandler
 *
 * @version $Rev$
 *
 * @xmlrpc.namespace sync.master
 * @xmlrpc.doc Contains methods to set up information about known-"masters", for use
 * on the "slave" side of ISS
 */
public class MasterHandler extends BaseHandler {

    public static final String[] VALID_MASTER_ORG_ATTRS = {
        "masterId", "masterOrgId", "masterOrgName", "localOrgId"
    };
    private static final Set<String> VALIDMASTERORGATTR;
    static {
        VALIDMASTERORGATTR = new HashSet<String>(Arrays.asList(VALID_MASTER_ORG_ATTRS));
    }

    public static final String[] REQUIRED_MASTER_ORG_ATTRS = {
        "masterOrgId", "masterOrgName"
    };
    private static final Set<String> REQUIREDMASTERORGATTRS;
    static {
        REQUIREDMASTERORGATTRS =
                new HashSet<String>(Arrays.asList(REQUIRED_MASTER_ORG_ATTRS));
    }

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
        if (IssFactory.lookupMasterByLabel(label) != null) {
            throw new IssDuplicateMasterException(label);
        }
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
    public IssMaster update(String sessionKey, Integer masterId, String newLabel) {
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
    public int delete(String sessionKey, Integer masterId) {
        IssMaster master = getMaster(sessionKey, masterId);
        IssFactory.delete(master);
        return 1;
    }

    /**
     * Make the specified Master the default for this Slave's satellite-sync
     * @param sessionKey User's session key.
     * @param masterId Id of the Master to be the default
     * @return 1 on success, exception otherwise
     *
     * @xmlrpc.doc Make the specified Master the default for this Slave's satellite-sync
     * @xmlrpc.param #param("string", "sessionKey")
     * @xmlrpc.param #param_desc("int", "id", "Id of the Master to make the default")
     * @xmlrpc.returntype #return_int_success()
     */
    public int makeDefault(String sessionKey, Integer masterId) {
        IssMaster master = getMaster(sessionKey, masterId);
        master.makeDefaultMaster();
        return 1;
    }

    /**
     * Return the current default-master for this slave
     * @param sessionKey User's session key
     * @return current default master, null if there isn't one
     *
     * @xmlrpc.doc Return the current default-master for this slave
     * @xmlrpc.param #param("string", "sessionKey")
     * @xmlrpc.returntype $IssMasterSerializer
     */
    public IssMaster getDefaultMaster(String sessionKey) {
        ensureSatAdmin(getLoggedInUser(sessionKey));
        return IssFactory.getCurrentMaster();
    }

    /**
     * Make this slave have no default Master for satellite-sync
     * @param sessionKey User's session key.
     * @return 1 on success, exception otherwise
     *
     * @xmlrpc.doc Make this slave have no default Master for satellite-sync
     * @xmlrpc.param #param("string", "sessionKey")
     * @xmlrpc.returntype #return_int_success()
     */
    public int unsetDefaultMaster(String sessionKey) {
        ensureSatAdmin(getLoggedInUser(sessionKey));
        IssFactory.unsetCurrentMaster();
        return 1;
    }

    /**
     * Set the CA-CERT filename for specified Master on this Slave
     * @param sessionKey User's session key.
     * @param masterId Id of the Master we're affecting
     * @param caCertFilename path to this Master's CA Cert on this Slave
     * @return 1 on success, exception otherwise
     *
     * @xmlrpc.doc Make the specified Master the default for this Slave's satellite-sync
     * @xmlrpc.param #param("string", "sessionKey")
     * @xmlrpc.param #param_desc("int", "id", "Id of the Master to affect")
     * @xmlrpc.param #param_desc("string", "caCertFilename",
     *  "path to specified Master's CA cert")
     * @xmlrpc.returntype #return_int_success()
     */
    public int setCaCert(String sessionKey, Integer masterId, String caCertFilename) {
        IssMaster master = getMaster(sessionKey, masterId);
        master.setCaCert(caCertFilename);
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
    public IssMaster getMaster(String sessionKey, Integer masterId) {
        User u = getLoggedInUser(sessionKey);
        ensureSatAdmin(u);
        IssMaster master = IssFactory.lookupMasterById(masterId.longValue());
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
     * Get all the masters this slave knows about
     * @param sessionKey User's session key.
     * @return list of all the IssMasters we know about
     *
     * @xmlrpc.doc Get all the masters this slave knows about
     * @xmlrpc.param #param("string", "sessionKey")
     * @xmlrpc.returntype
     *      #array()
     *          $IssMasterSerializer
     *      #array_end()
     */
    public List<IssMaster> getMasters(String sessionKey) {
        User u = getLoggedInUser(sessionKey);
        ensureSatAdmin(u);
        return IssFactory.listAllMasters();
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
     *     $IssMasterOrgSerializer
     *   #array_end()
     */
    public List<IssMasterOrg> getMasterOrgs(String sessionKey, Integer masterId) {
        IssMaster master = getMaster(sessionKey, masterId);
        ArrayList<IssMasterOrg> orgs = new ArrayList<IssMasterOrg>();
        orgs.addAll(master.getMasterOrgs());
        return orgs;
    }

    /**
     * Reset all organizations the specified Master has exported to this Slave
     *
     * @param sessionKey User's session key.
     * @param masterId Id of the Master to look for
     * @param orgMaps List of MasterOrgs we know about
     * @return 1 if successful, exception otherwise
     *
     * @xmlrpc.doc List all organizations the specified Master has exported to this Slave
     * @xmlrpc.param #param("string", "sessionKey")
     * @xmlrpc.param #param_desc("int", "id", "Id of the desired Master")
     * @xmlrpc.param
     *   #array()
     *      #struct("master-org details")
     *          #prop("int", "masterOrgId")
     *          #prop("string", "masterOrgName")
     *          #prop("int", "localOrgId")
     *     #struct_end()
     *   #array_end()
     * @xmlrpc.returntype #return_int_success()
     */
    public int setMasterOrgs(String sessionKey,
                             Integer masterId,
                             List<Map<String, Object>> orgMaps) {
        IssMaster master = getMaster(sessionKey, masterId);
        Set<IssMasterOrg> orgs = new HashSet<IssMasterOrg>();
        for (Map<String, Object> anOrgMap : orgMaps) {
            IssMasterOrg o = validateOrg(anOrgMap);
            orgs.add(o);
        }
        master.resetMasterOrgs(orgs);
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
     * @xmlrpc.param #param_desc("long", "id", "Id of the desired Master")
     * @xmlrpc.param
     *      #struct("master-org details")
     *          #prop("int", "masterOrgId")
     *          #prop("string", "masterOrgName")
     *          #prop("int", "localOrgId")
     *     #struct_end()
     * @xmlrpc.returntype #return_int_success()
     *
     */
    public int addToMaster(String sessionKey,
                           Integer masterId,
                           Map<String, Object> newOrg) {
        IssMaster master = getMaster(sessionKey, masterId);
        IssMasterOrg org = validateOrg(newOrg);
        master.addToMaster(org);
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
                          Integer masterId,
                          Integer masterOrgId,
                          Integer localOrgId) {
        boolean found = false;

        IssMaster master = getMaster(sessionKey, masterId);
        Set<IssMasterOrg> orgs = master.getMasterOrgs();

        Org localOrg = OrgFactory.lookupById(localOrgId.longValue());
        if (localOrg == null) {
            fail("Unable to locate or access Local Organization :" + localOrgId,
                    "lookup.issmaster.local.title", "lookup.issmaster.local.reason1",
                    localOrgId.toString());
        }

        for (IssMasterOrg o : orgs) {
            if (o.getMasterOrgId().equals(masterOrgId.longValue())) {
                o.setLocalOrg(localOrg);
                found = true;
                break;
            }
        }

        if (!found) {
            fail("Unable to locate or access ISS Master Organization : " + masterOrgId,
                    "lookup.issmasterorg.title", "lookup.issmasterorg.reason1",
                    masterOrgId.toString());
        }

        IssFactory.save(master);
        return 1;
    }

    private static Set<String> getValidMasterOrgsAttrs() {
        return VALIDMASTERORGATTR;
    }

    private static Set<String> getRequiredMasterOrgsAttrs() {
        return REQUIREDMASTERORGATTRS;
    }

    private IssMasterOrg validateOrg(Map<String, Object> anOrg) {
        validateMap(getValidMasterOrgsAttrs(), anOrg);
        Set<String> attrs = anOrg.keySet();

        if (!attrs.containsAll(getRequiredMasterOrgsAttrs())) {
            throw new FaultException(-6, "requiredOptionMissing",
                    "Required option missing. List of required options: " +
                            REQUIREDMASTERORGATTRS);
        }

        IssMasterOrg o = new IssMasterOrg();
        for (String attr : attrs) {
            if ("localOrgId".equals(attr)) {
                Integer localId = (Integer)anOrg.get(attr);
                Org local = OrgFactory.lookupById(localId.longValue());
                o.setLocalOrg(local);
            }
            else if ("masterOrgId".equals(attr)) {
                Integer moId = (Integer)anOrg.get(attr);
                o.setMasterOrgId(moId.longValue());
            }
            else {
                setEntityAttribute(attr, o, anOrg.get(attr));
            }
        }

        return o;
    }

    private void validateExists(IssMaster master, String srchString) {
        if (master == null) {
            fail("Unable to locate or access ISS Master : " + srchString,
                    "lookup.issmaster.title", "lookup.issmaster.reason1", srchString);
        }
    }

    private void fail(String msg, String titleKey, String reasonKey, String arg) {
        LocalizationService ls = LocalizationService.getInstance();
        LookupException e = new LookupException(msg);
        e.setLocalizedTitle(ls.getMessage(titleKey));
        e.setLocalizedReason1(ls.getMessage(reasonKey, arg));
        throw e;

    }
}
