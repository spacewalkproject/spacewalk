/**
 * Copyright (c) 2012 Red Hat, Inc.
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
package com.redhat.rhn.domain.audit;

import java.util.HashMap;

import org.apache.log4j.Logger;

import com.redhat.rhn.common.hibernate.LookupException;
import com.redhat.rhn.common.hibernate.HibernateFactory;
import com.redhat.rhn.common.localization.LocalizationService;

/**
 * ScapFactory - the singleton class used to fetch and store
 * com.redhat.rhn.domain.audit.* objects related to SCAP
 * from the database.
 * @version $Rev$
 */
public class ScapFactory extends HibernateFactory {

    private static ScapFactory singleton = new ScapFactory();
    private static Logger log = Logger.getLogger(ScapFactory.class);

    /**
     * Lookup a XCCDF TestResult by the id
     * @param xid of the XCCDF TestResult to search for
     * @return the XccdfTestResult found
     */
    public static XccdfTestResult lookupTestResultById(Long xid) {
        HashMap params = new HashMap();
        params.put("xid", xid);
        return (XccdfTestResult)singleton.lookupObjectByNamedQuery(
                "XccdfTestResult.findById", params);
    }

    /**
     * Lookup an XCCDF TestResult by the id and ensure it is assigned with given system
     * @param xid of the XCCDF TestResult to search for
     * @param sid of the system expected
     * @return the XccdfTestResult found
     */
    public static XccdfTestResult lookupTestResultByIdAndSid(Long xid, Long sid) {
        XccdfTestResult result = lookupTestResultById(xid);
        if (result == null || result.getServer().getId() != sid) {
            LocalizationService ls = LocalizationService.getInstance();
            LookupException e = new LookupException("Could not find XCCDF scan " +
                    xid + " for system " + sid);

            e.setLocalizedTitle(ls.getMessage("lookup.xccdfscan.title"));
            throw e;
        }
        return result;
    }
    /**
     * Get the Logger for the derived class so log messages
     * show up on the correct class.
     * @return Logger
     */
     protected Logger getLogger() {
         return log;
     }
}
