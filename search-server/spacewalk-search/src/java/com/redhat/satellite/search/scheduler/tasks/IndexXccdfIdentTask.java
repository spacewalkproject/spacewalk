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
package com.redhat.satellite.search.scheduler.tasks;

import com.redhat.satellite.search.db.models.GenericRecord;
import com.redhat.satellite.search.db.models.XccdfIdent;
import com.redhat.satellite.search.index.builder.BuilderFactory;

import org.apache.log4j.Logger;

import java.util.HashMap;
import java.util.Map;

/**
 * IndexXccdfIdentTask
 * @version $Rev$
 */
public class IndexXccdfIdentTask extends GenericIndexTask {

    private static Logger log = Logger.getLogger(IndexXccdfIdentTask.class);

    /**
     *  {@inheritDoc}
     */
    @Override
    protected Map<String, String> getFieldMap(GenericRecord data)
            throws ClassCastException {
        XccdfIdent dev = (XccdfIdent)data;
        Map<String, String> attrs = new HashMap<String, String>();
        attrs.put("id", new Long(dev.getId()).toString());
        attrs.put("identifier", dev.getIdentifier());
        return attrs;
    }

    /**
     * {@inheritDoc}
     */
    @Override
    public String getIndexName() {
        return BuilderFactory.XCCDF_IDENT_TYPE;
    }

    /**
     *  {@inheritDoc}
     */
    @Override
    protected String getQueryCreateLastRecord() {
        return "createLastXccdfIdent";
    }

    /**
     * {@inheritDoc}
     */
    @Override
    protected String getQueryLastRecord() {
       return "getLastXccdfIdentId";
    }

    /**
     * {@inheritDoc}
     */
    @Override
    protected String getQueryLastIndexDate() {
        return "getLastXccdfIdentIndexRun";
    }

    /**
     * {@inheritDoc}
     */
    @Override
    protected String getQueryRecordsToIndex() {
        return "getXccdfIdentById";
    }

    /**
     * {@inheritDoc}
     */
    @Override
    protected String getQueryUpdateLastRecord() {
        return "updateLastXccdfIdent";
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
        return "queryAllXccdfIdentIds";
    }
}
