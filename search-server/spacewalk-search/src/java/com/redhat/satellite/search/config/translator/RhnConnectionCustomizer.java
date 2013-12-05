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
package com.redhat.satellite.search.config.translator;

import com.mchange.v2.c3p0.ConnectionCustomizer;
import com.redhat.satellite.search.db.DatabaseManager;

import org.apache.log4j.Logger;

import java.lang.reflect.Method;
import java.sql.Connection;
import java.util.TimeZone;
/**
 * RhnConnectionCustomizer
 * @version $Rev$
 */
public class RhnConnectionCustomizer implements ConnectionCustomizer {

    private static final Logger LOG = Logger.getLogger(RhnConnectionCustomizer.class);

    /**
     * {@inheritDoc}
     */
    public void onAcquire(Connection c, String pdsIdt) throws Exception {
        if (DatabaseManager.isOracle()) {
            try {
                Method setSessionTimeZoneMethod = Class.forName(
                        "oracle.jdbc.driver.OracleConnection").getMethod(
                        "setSessionTimeZone", String.class);
                if (setSessionTimeZoneMethod != null) {
                    setSessionTimeZoneMethod.invoke(c, TimeZone.getDefault().getID());
                }
            }
            catch (Exception e) {
                LOG.warn("Failed to set session time zone.");
            }
        }
    }

    /**
     * {@inheritDoc}
     */
    public void onCheckIn(Connection c, String pdsIdt) throws Exception {
        // empty
    }

    /**
     * {@inheritDoc}
     */
    public void onCheckOut(Connection c, String pdsIdt) throws Exception {
        // empty
    }

    /**
     * {@inheritDoc}
     */
    public void onDestroy(Connection c, String pdsIdt) throws Exception {
        // empty
    }
}
