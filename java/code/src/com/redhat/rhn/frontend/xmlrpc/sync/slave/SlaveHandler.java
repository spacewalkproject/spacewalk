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
package com.redhat.rhn.frontend.xmlrpc.sync.slave;

import java.util.ArrayList;
import java.util.HashSet;
import java.util.List;
import java.util.Set;

import com.redhat.rhn.common.hibernate.LookupException;
import com.redhat.rhn.common.localization.LocalizationService;
import com.redhat.rhn.domain.iss.IssFactory;
import com.redhat.rhn.domain.iss.IssSlave;
import com.redhat.rhn.domain.org.Org;
import com.redhat.rhn.domain.org.OrgFactory;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.frontend.xmlrpc.BaseHandler;
import com.redhat.rhn.frontend.xmlrpc.IssDuplicateSlaveException;

/**
 * SlaveHandler
 *
 * @version $Rev$
 *
 * @xmlrpc.namespace sync.slave
 * @xmlrpc.doc Contains methods to set up information about allowed-"slaves", for use
 * on the "master" side of ISS
 */
public class SlaveHandler extends BaseHandler {

    /**
     * Create a new Slave, known to this Master.
     * @param sessionKey User's session key.
     * @param inSlave Slave's fully-qualified domain name
     * @param inEnabled Is this Slave allowed to talk to us?
     * @param inAllowAllOrgs Should we export all orgs to this Slave?
     * @return Newly created ISSSlave object.
     *
     * @xmlrpc.doc Create a new Slave, known to this Slave.
     * @xmlrpc.param #param("string", "sessionKey")
     * @xmlrpc.param #param_desc("string", "slave", "Slave's fully-qualified domain name")
     * @xmlrpc.param #param_desc("boolean",
     *    "enabled", "Let this slave talk to us?")
     * @xmlrpc.param #param_desc("boolean",
     *    "allowAllOrgs", "Export all our orgs to this slave?")
     * @xmlrpc.returntype $IssSlaveSerializer
     */
    public IssSlave create(String sessionKey,
                           String inSlave,
                           Boolean inEnabled,
                           Boolean inAllowAllOrgs) {
        User u = getLoggedInUser(sessionKey);
        ensureSatAdmin(u);
        if (IssFactory.lookupSlaveByName(inSlave) != null) {
            throw new IssDuplicateSlaveException(inSlave);
        }

        IssSlave slave = new IssSlave();
        slave.setSlave(inSlave);
        slave.setEnabled(inEnabled ? "Y" : "N");
        slave.setAllowAllOrgs(inAllowAllOrgs ? "Y" : "N");
        IssFactory.save(slave);
        slave = (IssSlave) IssFactory.reload(slave);
        return slave;
    }

    /**
     * Updates the label of the specified Slave
     * @param sessionKey User's session key.
     * @param inSlaveId id of slave to update
     * @param inSlave Slave's fully-qualified domain name
     * @param inEnabled Is this Slave allowed to talk to us?
     * @param inAllowAllOrgs Should we export all orgs to this Slave?
     * @return updated IssSlave
     *
     * @xmlrpc.doc Updates the label of the specified Slave
     * @xmlrpc.param #param("string", "sessionKey")
     * @xmlrpc.param #param_desc("int", "id", "Id of the Slave to update")
     * @xmlrpc.param #param_desc("string", "slave", "Slave's fully-qualified domain name")
     * @xmlrpc.param #param_desc("boolean",
     *    "enabled", "Let this slave talk to us?")
     * @xmlrpc.param #param_desc("boolean",
     *    "allowAllOrgs", "Export all our orgs to this slave?")
     * @xmlrpc.returntype $IssSlaveSerializer
     */
    public IssSlave update(String sessionKey,
                           Integer inSlaveId,
                           String inSlave,
                           Boolean inEnabled,
                           Boolean inAllowAllOrgs) {
        IssSlave slave = getSlave(sessionKey, inSlaveId);
        slave.setSlave(inSlave);
        slave.setEnabled(inEnabled ? "Y" : "N");
        slave.setAllowAllOrgs(inAllowAllOrgs ? "Y" : "N");
        IssFactory.save(slave);
        slave = (IssSlave) IssFactory.reload(slave);
        return slave;
    }

    /**
     * Removes a specified Slave
     *
     * @param sessionKey User's session key.
     * @param inSlaveId Id of the Slave to remove
     * @return 1 on success, exception otherwise
     *
     * @xmlrpc.doc Remove the specified Slave
     * @xmlrpc.param #param("string", "sessionKey")
     * @xmlrpc.param #param_desc("int", "id", "Id of the Slave to remove")
     * @xmlrpc.returntype #return_int_success()
     */
    public int delete(String sessionKey, Integer inSlaveId) {
        IssSlave slave = getSlave(sessionKey, inSlaveId);
        IssFactory.delete(slave);
        return 1;
    }

    /**
     * Find a Slave by specifying its ID
     * @param sessionKey User's session key.
     * @param slaveId Id of the Slave to look for
     * @return the specified Slave if found, exception otherwise
     *
     * @xmlrpc.doc Find a Slave by specifying its ID
     * @xmlrpc.param #param("string", "sessionKey")
     * @xmlrpc.param #param_desc("int", "id", "Id of the desired Slave")
     * @xmlrpc.returntype $IssSlaveSerializer
     */
    public IssSlave getSlave(String sessionKey, Integer slaveId) {
        User u = getLoggedInUser(sessionKey);
        ensureSatAdmin(u);
        IssSlave slave = IssFactory.lookupSlaveById(slaveId.longValue());
        validateExists(slave, slaveId.toString());
        return slave;
    }

    /**
     * Find a Slave by specifying its Fully-Qualified Domain Name
     * @param sessionKey User's session key.
     * @param slaveFqdn Domain name of the Slave to look for
     * @return the specified Slave if found, exception otherwise
     *
     * @xmlrpc.doc Find a Slave by specifying its Fully-Qualified Domain Name
     * @xmlrpc.param #param("string", "sessionKey")
     * @xmlrpc.param #param_desc("string", "fqdn", "Domain-name of the desired Slave")
     * @xmlrpc.returntype $IssSlaveSerializer
     */
    public IssSlave getSlaveByName(String sessionKey, String slaveFqdn) {
        User u = getLoggedInUser(sessionKey);
        ensureSatAdmin(u);
        IssSlave slave = IssFactory.lookupSlaveByName(slaveFqdn);
        validateExists(slave, slaveFqdn);
        return slave;
    }

    /**
     * Get all the slaves this master knows about
     * @param sessionKey User's session key.
     * @return list of all the IssSlaves we know about
     *
     * @xmlrpc.doc Get all the slaves this master knows about
     * @xmlrpc.param #param("string", "sessionKey")
     * @xmlrpc.returntype
     *      #array()
     *          $IssSlaveSerializer
     *      #array_end()
     */
    public List<IssSlave> getSlaves(String sessionKey) {
        User u = getLoggedInUser(sessionKey);
        ensureSatAdmin(u);
        return IssFactory.listAllIssSlaves();
    }

    /**
     * Get all the orgs that this master is willing to export to the specified slave
     * @param sessionKey User's session key.
     * @param slaveId Id of the Slave to look for
     * @return list of all the IssSlaves we know about
     *
     * @xmlrpc.doc Get all the slaves this master knows about
     * @xmlrpc.param #param("string", "sessionKey")
     * @xmlrpc.param #param_desc("int", "id", "Id of the desired Slave")
     * @xmlrpc.returntype #array_single("int", "ids of allowed organizations")
     */
    public List<Integer> getAllowedOrgs(String sessionKey, Integer slaveId) {
        IssSlave slave = getSlave(sessionKey, slaveId);
        List<Integer> allowedOrgIds = new ArrayList<Integer>();
        for (Org o : slave.getAllowedOrgs()) {
            allowedOrgIds.add(o.getId().intValue());
        }
        return allowedOrgIds;
    }

    /**
     * Set the orgs that this master is willing to export to the specified slave
     * @param sessionKey User's session key.
     * @param slaveId Id of the Slave to look for
     * @param orgIds List of org-ids we're willing to export
     * @return 1 for success, exception otherwise
     *
     * @xmlrpc.doc Get all the slaves this master knows about
     * @xmlrpc.param #param("string", "sessionKey")
     * @xmlrpc.param #param_desc("int", "id", "Id of the desired Slave")
     * @xmlrpc.param #array_single("int", "List of revisions to delete")
     * @xmlrpc.returntype #return_int_success()
     */
    public int setAllowedOrgs(String sessionKey, Integer slaveId, List<Integer> orgIds) {
        IssSlave slave = getSlave(sessionKey, slaveId);
        Set<Org> orgs = getOrgsFromIds(orgIds);
        slave.setAllowedOrgs(orgs);
        return 1;
    }

    private void validateExists(IssSlave slave, String srchString) {
        if (slave == null) {
            fail("Unable to locate or access ISS Slave : " + srchString,
                    "lookup.issslave.title", "lookup.issslave.reason1", srchString);
        }
    }

    private void fail(String msg, String titleKey, String reasonKey, String arg) {
        LocalizationService ls = LocalizationService.getInstance();
        LookupException e = new LookupException(msg);
        e.setLocalizedTitle(ls.getMessage(titleKey));
        e.setLocalizedReason1(ls.getMessage(reasonKey, arg));
        throw e;
    }

    private Set<Org> getOrgsFromIds(List<Integer> orgIds) {
        Set<Org> orgs = new HashSet<Org>();
        for (Integer oid : orgIds) {
            Org o = OrgFactory.lookupById(oid.longValue());
            orgs.add(o);
        }
        return orgs;
    }
}
