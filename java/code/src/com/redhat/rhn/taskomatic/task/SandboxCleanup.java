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
package com.redhat.rhn.taskomatic.task;

import com.redhat.rhn.common.conf.Config;
import com.redhat.rhn.common.db.datasource.CallableMode;
import com.redhat.rhn.common.db.datasource.ModeFactory;
import com.redhat.rhn.common.db.datasource.SelectMode;

import org.apache.log4j.Logger;
import org.quartz.JobExecutionContext;
import org.quartz.JobExecutionException;

import java.util.HashMap;
import java.util.Iterator;
import java.util.List;
import java.util.Map;

/**
 * SandboxCleanup
 * @version $Rev$
 */
public class SandboxCleanup extends RhnJavaJob {

    /**
     * Used to log stats in the RHNDAEMONSTATE table
     */
    public static final String DISPLAY_NAME = "sandbox_cleanup";

    private Logger log = getLogger(SandboxCleanup.class);

    /**
     * {@inheritDoc}
     */
    public void execute(JobExecutionContext arg0In)
        throws JobExecutionException {

        int sandboxLifetime = Config.get().getInt("sandbox_lifetime"); //in days

        Map params = new HashMap();
        params.put("window", new Integer(sandboxLifetime));
        remove("find_sandbox_file_candidates", params, "remove_sandbox_file");
        remove("find_sandbox_channel_candidates", params, "remove_sandbox_channel");
    }

    private void remove(String candidateQuery, Map candidateParams, String removeQuery) {
        SelectMode candidateMode =
            ModeFactory.getMode("Task_queries", candidateQuery);
        CallableMode removeMode =
            ModeFactory.getCallableMode("Task_queries", removeQuery);
        List candidates = candidateMode.execute(candidateParams);
        if (candidates != null && candidates.size() > 0) {
            Map params = new HashMap();
            Map out = new HashMap();
            for (Iterator iter = candidates.iterator(); iter.hasNext();) {
                Map row = (Map) iter.next();
                params.put("id", row.get("id"));
                removeMode.execute(params, out);
            }
        }
    }

}
