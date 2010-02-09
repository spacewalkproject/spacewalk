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
package com.redhat.rhn.domain.rhnpackage;

import com.redhat.rhn.common.db.datasource.CallableMode;
import com.redhat.rhn.common.db.datasource.ModeFactory;
import com.redhat.rhn.common.hibernate.HibernateFactory;

import org.apache.log4j.Logger;
import org.hibernate.Session;

import java.sql.Types;
import java.util.HashMap;
import java.util.Map;

/**
 * PackageEvrFactory
 * @version $Rev$
 */
public class PackageEvrFactory {

    private static Logger log = Logger.getLogger(PackageEvrFactory.class);

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
    public static PackageEvr save(PackageEvr evrIn) {

        CallableMode m = ModeFactory.getCallableMode("Package_queries", "lookup_evr");

        Map inParams = new HashMap();
        inParams.put("epoch", evrIn.getEpoch());
        inParams.put("version", evrIn.getVersion());
        inParams.put("release", evrIn.getRelease());

        Map outParams = new HashMap();
        outParams.put("evrId", new Integer(Types.NUMERIC));

        Map result = m.execute(inParams, outParams);

        Long newEvrId = new Long(result.get("evrId").toString());

        return lookupPackageEvrById(newEvrId);
    }

    /**
     * Creates a new PackageEvr object
     * @param e PackageEvr Epoch
     * @param v PackageEvr Version
     * @param r PackageEvr Release
     * @return Returns a committed PackageEvr
     */
    public static PackageEvr createPackageEvr(String e, String v, String r) {
        PackageEvr evr = new PackageEvr();
        evr.setEpoch(e);
        evr.setVersion(v);
        evr.setRelease(r);

        return PackageEvrFactory.save(evr);
    }

    /**
     * Lookup a PackageEvr by its id
     * @param id the id to search for
     * @return the PackageEvr found
     */
    public static PackageEvr lookupPackageEvrById(Long id) {
        Session session = HibernateFactory.getSession();
        return (PackageEvr) session.getNamedQuery("PackageEvr.findById").setString(
                "id", id.toString()).uniqueResult();
    }

}
