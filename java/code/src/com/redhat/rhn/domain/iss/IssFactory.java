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

package com.redhat.rhn.domain.iss;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.apache.log4j.Logger;
import org.hibernate.Query;

import com.redhat.rhn.common.hibernate.HibernateFactory;

/**
 * IssSlaveFactory - the singleton class used to fetch and store
 * com.redhat.rhn.domain.server.IssSlave objects from the database.
 * @version $Rev$
 */
public class IssFactory extends HibernateFactory {

    private static IssFactory singleton = new IssFactory();
    private static Logger log = Logger.getLogger(IssFactory.class);

    private IssFactory() {
        super();
    }

    protected Logger getLogger() {
        return log;
    }

    /***
     *  IssSlave helpers
     ***/

    /**
     * Lookup a IssSlave by its id
     * @param id the id to search for
     * @return the IssSlave found
     */
    public static IssSlave lookupSlaveById(Long id) {
        Map<String, Long> params = new HashMap<String, Long>();
        params.put("id", id);
        return (IssSlave) singleton.lookupObjectByNamedQuery(
                "IssSlave.findById", params);
    }

    /**
     * List all IssSlaves for this Master
     * @return list of all the slaves
     */
    public static List<IssSlave> listAllIssSlaves() {
        Map params = new HashMap();
        return (List<IssSlave>)singleton.listObjectsByNamedQuery(
                "IssSlave.lookupAll", params);
    }

    /**
     * Remove all entries mapping local-orgs to specified slave
     * @param sid ID of slave whose entries we're removing
     */
    public static void clearMapsForSlave(Long sid) {
        Map<String, Long> params = new HashMap<String, Long>();
        params.put("sid", sid);
        Query q = HibernateFactory.getSession().getNamedQuery("IssSlaveOrgs.removeAll");
        q.setParameter("sid", sid);
        q.executeUpdate();
    }

    /***
     *  IssOrgCatalogue helpers
     ***/

    /**
     * Lookup a IssOrgCatalogue by its id
     * @param id the id to search for
     * @return the IssOrgCatalogue entry found
     */
    public static IssOrgCatalogue lookupMasterById(Long id) {
        Map<String, Long> params = new HashMap<String, Long>();
        params.put("id", id);
        return (IssOrgCatalogue) singleton.lookupObjectByNamedQuery(
                "IssOrgCatalogue.findById", params);
    }

    /**
     * List all IssOrgCatalogue entries for this Slave
     * @return list of all masters known to this slave
     */
    public static List<IssOrgCatalogue> listAllMasters() {
        Map params = new HashMap();
        return (List<IssOrgCatalogue>)singleton.listObjectsByNamedQuery(
                "IssOrgCatalogue.lookupAll", params);
    }

    /***
     *  Common helpers
     ***/

    /**
     * Delete an entity.
     * @param entity to delete.
     */
    public static void delete(Object entity) {
        singleton.removeObject(entity);
    }

    /**
     * Insert or Update an entity.
     * @param entity to be stored in database.
     */
    public static void save(Object entity) {
        singleton.saveObject(entity);
    }

    /**
     * Remove an entity from the DB
     * @param entity to be removed from database.
     */
    public static void remove(Object entity) {
        singleton.removeObject(entity);
    }

}
