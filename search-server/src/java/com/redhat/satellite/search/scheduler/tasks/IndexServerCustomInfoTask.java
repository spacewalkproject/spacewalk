/**
 * Copyright (c) 2008 Red Hat, Inc.
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

import com.redhat.satellite.search.db.models.GenericRecord;
import com.redhat.satellite.search.db.models.ServerCustomInfo;
import com.redhat.satellite.search.index.builder.BuilderFactory;

import java.util.HashMap;
import java.util.Map;

/**
 * IndexServerCustomInfoTask
 * @version $Rev$
 *
 */
public class IndexServerCustomInfoTask extends GenericIndexTask {

    /**
     *  {@inheritDoc}
     */
    @Override
    protected Map<String, String> getFieldMap(GenericRecord data)
            throws ClassCastException {
        ServerCustomInfo scInfo = (ServerCustomInfo)data;
        Map<String, String> attrs = new HashMap<String, String>();
        attrs.put("serverId", new Long(scInfo.getServerId()).toString());
        attrs.put("value", scInfo.getValue());
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
        return new String("createLastServerCustomInfo");
    }

    /**
     * {@inheritDoc}
     */
    @Override
    protected String getQueryLastRecord() {
       return new String("getLastServerCustomInfoId");
    }

    /**
     * {@inheritDoc}
     */
    @Override
    protected String getQueryLastIndexDate() {
        return new String("getLastServerCustomInfoIndexRun");
    }

    /**
     * {@inheritDoc}
     */
    @Override
    protected String getQueryRecordsToIndex() {
        return new String("getServerCustomInfoByIdOrDate");
    }

    /**
     * {@inheritDoc}
     */
    @Override
    protected String getQueryUpdateLastRecord() {
        return new String("updateLastServerCustomInfo");
    }

    /**
     * {@inheritDoc}
     */
    public String getUniqueFieldId() {
        return "id";
    }
    /**
     * {@inheritDoc}
     */
    public String getQueryAllIds() {
        return new String("queryAllServerCustomInfoIds");
    }
}
