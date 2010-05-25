/**
 * Copyright (c) 2009--2010 Red Hat, Inc.
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
package com.redhat.rhn.domain.errata;

import com.redhat.rhn.common.hibernate.HibernateFactory;

import org.apache.log4j.Logger;

import java.util.HashMap;
import java.util.Map;

/**
 * ErrataFactory - the singleton class used to fetch and store
 * com.redhat.rhn.domain.errata.Errata objects from the
 * database.
 * @version $Rev$
 */
public class CveFactory extends HibernateFactory {

    private static CveFactory singleton = new CveFactory();
    private static Logger log = Logger.getLogger(CveFactory.class);

    private CveFactory() {
        super();
    }

    /**
     * Get the Logger for the derived class so log messages
     * show up on the correct class
     */
    protected Logger getLogger() {
        return log;
    }

    /**
     * Lookup a CVE by name
     * @param name Name of CVE to be retrieved
     * @return CVE object found
     */
    public static Cve lookupByName(String name) {
        Map params = new HashMap();
        params.put("name", name);
        return (Cve)singleton.lookupObjectByNamedQuery("Cve.lookupByName", params);
    }

    /**
     * Insert or Update a CVE.
     * @param cve CVE to be stored in database.
     */
    public static void save(Cve cve) {
        singleton.saveObject(cve);
    }

}
