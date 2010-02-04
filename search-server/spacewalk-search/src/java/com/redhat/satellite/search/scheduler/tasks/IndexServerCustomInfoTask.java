/**
 * Copyright (c) 2008--2010 Red Hat, Inc.
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
package com.redhat.satellite.search.scheduler.tasks;

import com.ibatis.sqlmap.client.SqlMapException;
import com.redhat.satellite.search.db.DatabaseManager;
import com.redhat.satellite.search.db.Query;
import com.redhat.satellite.search.db.models.GenericRecord;
import com.redhat.satellite.search.db.models.ServerCustomInfo;
import com.redhat.satellite.search.index.IndexManager;
import com.redhat.satellite.search.index.builder.BuilderFactory;

import java.sql.SQLException;
import java.util.Collections;
import java.util.HashMap;
import java.util.HashSet;
import java.util.List;
import java.util.Map;

import org.apache.log4j.Logger;

/**
 * IndexServerCustomInfoTask
 * @version $Rev$
 *
 */
public class IndexServerCustomInfoTask extends GenericIndexTask {
    private static Logger log = Logger.getLogger(IndexServerCustomInfoTask.class);

    /**
     * Will determine if any records have been deleted from the DB, then will
     * delete those records from the lucene index.
     * @return number of deleted records
     */
    protected int handleDeletedRecords(DatabaseManager databaseManager,
            IndexManager indexManager)
        throws SQLException {
        List<ServerCustomInfo> ids = null;
        Query<ServerCustomInfo> query = null;
        String uniqField = null;
        String indexName = null;
        HashSet<String> idSet = null;
        try {
            query = databaseManager.getQuery(getQueryAllIds());
            ids = query.loadList(Collections.EMPTY_MAP);
            if ((ids == null) || (ids.size() == 0)) {
                log.info("Got back no data from '" + getQueryAllIds() + "'");
                log.info("Skipping the handleDeletedRecords() method");
                return 0;
            }
            idSet = new HashSet();
            for (ServerCustomInfo scInfo : ids) {
                idSet.add(scInfo.getUniqId());
            }
            uniqField = getUniqueFieldId();
            indexName = getIndexName();
        }
        catch (SqlMapException e) {
            e.printStackTrace();
            log.info("Error with 'getQueryAllIds()' on " +
                    super.getClass().toString());
            //just print the warning so we know and skip this method.
            return 0;
        }
        finally {
            if (query != null) {
                query.close();
            }
        }
        return indexManager.deleteRecordsNotInList(idSet, indexName, uniqField);
    }




    /**
     *  {@inheritDoc}
     */
    @Override
    protected Map<String, String> getFieldMap(GenericRecord data)
            throws ClassCastException {
        ServerCustomInfo scInfo = (ServerCustomInfo)data;
        Map<String, String> attrs = new HashMap<String, String>();
        attrs.put("uniqId", scInfo.getUniqId());
        attrs.put("serverId", new Long(scInfo.getServerId()).toString());
        attrs.put("value", scInfo.getValue());
        attrs.put("label", scInfo.getLabel());
        attrs.put("createdBy", new Long(scInfo.getCreatedBy()).toString());
        attrs.put("lastModifiedBy", new Long(scInfo.getLastModifiedBy()).toString());
        attrs.put("created", scInfo.getCreated());
        attrs.put("modified", scInfo.getModified());
        return attrs;
    }

    /**
     * {@inheritDoc}
     */
    @Override
    public String getIndexName() {
        return BuilderFactory.SERVER_CUSTOM_INFO_TYPE;
    }

    /**
     *  {@inheritDoc}
     */
    @Override
    protected String getQueryCreateLastRecord() {
        return "createLastServerCustomInfo";
    }

    /**
     * {@inheritDoc}
     */
    @Override
    protected String getQueryLastRecord() {
       return "getLastServerCustomInfoId";
    }

    /**
     * {@inheritDoc}
     */
    @Override
    protected String getQueryLastIndexDate() {
        return "getLastServerCustomInfoIndexRun";
    }

    /**
     * {@inheritDoc}
     */
    @Override
    protected String getQueryRecordsToIndex() {
        return "getServerCustomInfoByIdOrDate";
    }

    /**
     * {@inheritDoc}
     */
    @Override
    protected String getQueryUpdateLastRecord() {
        return "updateLastServerCustomInfo";
    }

    /**
     * {@inheritDoc}
     */
    public String getUniqueFieldId() {
        return "uniqId";
    }
    /**
     * {@inheritDoc}
     */
    public String getQueryAllIds() {
        return "queryAllServerCustomInfoIds";
    }
}
