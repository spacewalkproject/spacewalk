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
package com.redhat.rhn.taskomatic.task.repomd;

import com.redhat.rhn.common.db.NamedPreparedStatement;
import com.redhat.rhn.common.db.datasource.ModeFactory;
import com.redhat.rhn.common.db.datasource.SelectMode;
import com.redhat.rhn.common.hibernate.HibernateFactory;
import com.redhat.rhn.domain.channel.Channel;
import com.redhat.rhn.taskomatic.task.TaskConstants;

import org.apache.log4j.Logger;

import java.math.BigDecimal;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.ResultSetMetaData;
import java.sql.SQLException;
import java.util.Date;
import java.util.HashMap;
import java.util.Map;

/**
 * 
 * @version $Rev $
 * 
 */
public class PackageCapabilityIterator {

    private static Logger log = Logger
            .getLogger(PackageCapabilityIterator.class);
    private static final String PACKAGE_ID = "package_id";

    private String queryName;
    private SelectMode mode;
    private ResultSet rs;
    private ResultSetMetaData rsmd;
    private Map row;
    private boolean goBack;
    private boolean hasMoreRows;

    /**
     * 
     * @param ch channel
     * @param queryNameIn query name
     */
    public PackageCapabilityIterator(Channel ch, String queryNameIn) {
        queryName = queryNameIn;
        // The following usage of SelectMode is only to fetch the named query
        // from the .xml
        // file and to replace the bind parameters. We will execute the query
        // through raw
        // JDBC since we don't want to keep few million rows of data in memory.
        SelectMode modeIn = ModeFactory.getMode(TaskConstants.MODE_NAME,
                queryName);
        String query = NamedPreparedStatement.replaceBindParams(modeIn.getQuery()
                .getOrigQuery(), new HashMap());

        row = new HashMap();
        goBack = false;
        hasMoreRows = true;
        try {
            PreparedStatement ps = HibernateFactory.getSession().connection()
                    .prepareStatement(query);
            ps.setLong(1, ch.getId());
            rs = ps.executeQuery();
            rsmd = rs.getMetaData();
        }
        catch (SQLException sqle) {
            log.error("SQLexception", sqle);
        }
    }

    /**
     * 
     * @param pkgId package Id
     * @return Returns the next pkg in the sequence
     */
    public boolean hasNextForPackage(long pkgId) {
        if (!next()) {
            return false;
        }
        long current = getPkgId();
        if (current == pkgId) {
            // We're still on the requested package
            return true;
        }
        if (current > pkgId) {
            // We've past the package boundary, and have already fetched one row
            // from the next package. Please put it back.
            goBack = true;
            return false;
        }
        // At this point we know that we still haven't reached our package.
        // Perform a seek() to the point where our package starts.
        while (current < pkgId) {
            if (!next()) {
                return false;
            }
            current = getPkgId();
        }
        // If no rows can be found for the requested package, return false.
        return current == pkgId;
    }

    /**
     * 
     * @param key as string
     * @return key as string
     */
    public String getString(String key) {
        return (String) row.get(key.toLowerCase());
    }

    /**
     * 
     * @param key key as string
     * @return key as bigDecimal number
     */
    public BigDecimal getNumber(String key) {
        return (BigDecimal) row.get(key.toLowerCase());
    }

    /**
     * 
     * @param key key as string
     * @return key as date
     */
    public Date getDate(String key) {
        return (Date) row.get(key.toLowerCase());
    }

    /**
     * 
     * @return package Id
     */
    private long getPkgId() {
        return Long.valueOf(row.get(PACKAGE_ID).toString());
    }

    /**
     * 
     * @return next element in the row
     */
    private boolean next() {
        if (!hasMoreRows) {
            return false;
        }
        if (goBack) {
            goBack = false;
            return true;
        }
        hasMoreRows = false;
        try {
            hasMoreRows = rs.next();
        }
        catch (SQLException sqle) {
            log.error("SQLexception", sqle);
        }
        if (hasMoreRows) {
            storeRow();
        }
        else {
            // in case iterator has no rows at all, row.get(PACKAGE_ID) would
            // return null,
            // so we can't use getPkgId()
            log.debug("End of resultset for " + queryName + ", " +
                    "last package seen: " + row.get(PACKAGE_ID));
        }
        return hasMoreRows;
    }

    /**
     * stores the elements to the row object
     */
    private void storeRow() {
        try {
            for (int i = 1; i <= rsmd.getColumnCount(); i++) {
                Object obj = rs.getObject(i);
                String column = rsmd.getColumnName(i);
                row.put(column.toLowerCase(), obj);
            }
        }
        catch (SQLException sqle) {
            log.error("SQLexception", sqle);
        }
    }

}
