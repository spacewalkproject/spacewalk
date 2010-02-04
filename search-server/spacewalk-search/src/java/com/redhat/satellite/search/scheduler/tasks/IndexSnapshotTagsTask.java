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

import com.redhat.satellite.search.db.models.GenericRecord;
import com.redhat.satellite.search.db.models.SnapshotTag;
import com.redhat.satellite.search.index.builder.BuilderFactory;

import java.util.HashMap;
import java.util.Map;

/**
 * IndexSnapshotTagsTask
 * @version $Rev$
 *
 */
public class IndexSnapshotTagsTask extends GenericIndexTask {

    /**
     *  {@inheritDoc}
     */
    @Override
    protected Map<String, String> getFieldMap(GenericRecord data)
            throws ClassCastException {
        SnapshotTag sTag = (SnapshotTag)data;
        Map<String, String> attrs = new HashMap<String, String>();
        attrs.put("snapshotId", new Long(sTag.getSnapshotId()).toString());
        attrs.put("tagNameId", new Long(sTag.getTagNameId()).toString());
        attrs.put("serverId", new Long(sTag.getServerId()).toString());
        attrs.put("orgId", new Long(sTag.getOrgId()).toString());
        attrs.put("name", sTag.getName());
        attrs.put("created", sTag.getCreated());
        attrs.put("modified", sTag.getModified());
        return attrs;
    }

    /**
     * {@inheritDoc}
     */
    @Override
    public String getIndexName() {
        return BuilderFactory.SNAPSHOT_TAG_TYPE;
    }

    /**
     *  {@inheritDoc}
     */
    @Override
    protected String getQueryCreateLastRecord() {
        return "createLastSnapshotTag";
    }

    /**
     * {@inheritDoc}
     */
    @Override
    protected String getQueryLastRecord() {
       return "getLastSnapshotTagId";
    }

    /**
     * {@inheritDoc}
     */
    @Override
    protected String getQueryLastIndexDate() {
        return "getLastSnapshotTagIndexRun";
    }

    /**
     * {@inheritDoc}
     */
    @Override
    protected String getQueryRecordsToIndex() {
        return "getSnapshotTagByIdOrDate";
    }

    /**
     * {@inheritDoc}
     */
    @Override
    protected String getQueryUpdateLastRecord() {
        return "updateLastSnapshotTag";
    }

    /**
     * {@inheritDoc}
     */
    public String getUniqueFieldId() {
        return "tagNameId";
    }
    
    /**
     * {@inheritDoc}
     */
    public String getQueryAllIds() {
        return "queryAllSnapshotTagIds";
    }
}
