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
package com.redhat.rhn.taskomatic.task.entitlement;

import com.redhat.rhn.common.conf.Config;
import com.redhat.rhn.common.db.datasource.DataResult;
import com.redhat.rhn.common.db.datasource.ModeFactory;
import com.redhat.rhn.common.db.datasource.SelectMode;
import com.redhat.rhn.taskomatic.task.threaded.QueueDriver;
import com.redhat.rhn.taskomatic.task.threaded.QueueWorker;

import org.apache.log4j.Logger;

import java.util.Iterator;
import java.util.LinkedList;
import java.util.List;
import java.util.Map;

/**
 * Driver for the threaded entitlement queue
 * @version $Rev$
 */
public class EntitlementQueueDriver implements QueueDriver {
    
    private static final Logger LOG = Logger.getLogger(EntitlementQueueDriver.class);
    
    /**
     * {@inheritDoc}
     */
    public Logger getLogger() {
        return LOG;
    }

    /**
     * {@inheritDoc}
     */    
    public boolean canContinue() {
        return true;
    }
    
    /**
     * {@inheritDoc}
     */
    public int getMaxWorkers() {
        return Config.get().getInt("taskomatic.rapid_repoll_workers", 3);        
    }

    /**
     * {@inheritDoc}
     */
    public List getCandidates() {
        SelectMode mode = ModeFactory.getMode("Task_queries", "fetch_entitlement_org");
        DataResult dr = mode.execute();
        List retval = new LinkedList();
        if (dr != null && dr.size() > 0) {
            for (Iterator rows = dr.iterator(); rows.hasNext();) {
                Map row = (Map) rows.next();
                retval.add((Long) row.get("org_id"));
            }
        }
        return retval;
    }

    /**
     * {@inheritDoc}
     */    
    public QueueWorker makeWorker(Object workItem) {
        Long orgId = (Long) workItem;
        return new EntitlementWorker(orgId, LOG);        
    }

}
