/**
 * Copyright (c) 2009--2012 Red Hat, Inc.
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
package com.redhat.rhn.domain.rhnpackage;

import com.redhat.rhn.common.db.datasource.CallableMode;
import com.redhat.rhn.common.db.datasource.ModeFactory;
import com.redhat.rhn.common.hibernate.HibernateFactory;

import org.hibernate.Session;

import java.sql.Types;
import java.util.HashMap;
import java.util.Map;

/**
 * PackageEvrFactory
 * @version $Rev$
 */
public class PackageEvrFactory {

    /**
     * Private Constructor
     */
    private PackageEvrFactory() {
    }

    /**
     * Commit a PackageEvr via stored proc - lookup_evr
     * @param evrIn PackageEvr to commit to db
     * @return Returns a new/committed PackageEvr object.
     */
    private static Long lookupPackageEvr(String epoch, String version,
            String release) {

        CallableMode m = ModeFactory.getCallableMode("Package_queries", "lookup_evr");

        Map inParams = new HashMap();
        inParams.put("epoch", epoch);
        inParams.put("version", version);
        inParams.put("release", release);

        Map outParams = new HashMap();
        outParams.put("evrId", new Integer(Types.NUMERIC));

        Map result = m.execute(inParams, outParams);

        return (Long) result.get("evrId");
    }

    /**
     * Creates a new PackageEvr object
     * @param evr PackageEvr
     * @return Returns a committed PackageEvr
     */
    public static PackageEvr lookupOrCreatePackageEvr(PackageEvr evr) {
        if (evr.getId() != null) {
            return lookupPackageEvrById(evr.getId());
        }
        return lookupOrCreatePackageEvr(evr.getEpoch(), evr.getVersion(),
                evr.getRelease());
    }

    /**
     * Creates a new PackageEvr object
     * @param e PackageEvr Epoch
     * @param v PackageEvr Version
     * @param r PackageEvr Release
     * @return Returns a committed PackageEvr
     */
    public static PackageEvr lookupOrCreatePackageEvr(String e, String v, String r) {
        Long id = lookupPackageEvr(e, v, r);
        return lookupPackageEvrById(id);
    }

    /**
     * Lookup a PackageEvr by its id
     * @param id the id to search for
     * @return the PackageEvr found
     */
    public static PackageEvr lookupPackageEvrById(Long id) {
        Session session = HibernateFactory.getSession();
        return (PackageEvr) session.getNamedQuery("PackageEvr.findById").setLong(
                "id", id).uniqueResult();
    }

}
