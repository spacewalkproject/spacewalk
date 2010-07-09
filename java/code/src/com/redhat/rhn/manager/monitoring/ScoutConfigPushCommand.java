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
package com.redhat.rhn.manager.monitoring;

import com.redhat.rhn.common.db.datasource.CallableMode;
import com.redhat.rhn.common.db.datasource.ModeFactory;
import com.redhat.rhn.common.validator.ValidatorError;
import com.redhat.rhn.domain.monitoring.satcluster.SatCluster;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.manager.BasePersistOperation;

import java.util.HashMap;
import java.util.Iterator;
import java.util.Map;

/**
 * ScoutConfigPushCommand - simple command to invoke a Scout Config push for
 * all the Scouts defined within an Organization.
 * @version $Rev$
 */
public class ScoutConfigPushCommand extends BasePersistOperation {

    /**
     * Constructor with User who wants to issue the Command
     * @param userIn who is wanting to push the scout configs.
     */
    public ScoutConfigPushCommand(User userIn) {
        super();
        this.user = userIn;
    }

    /**
     * {@inheritDoc}
     */
    public ValidatorError store() {
        Iterator i = this.user.getOrg().getMonitoringScouts().iterator();

        while (i.hasNext()) {
            SatCluster sc = (SatCluster) i.next();
            Map in = new HashMap();
            in.put("org_id", this.user.getOrg().getId());
            in.put("scout_id", sc.getId());
            in.put("user_id", this.user.getId());

            CallableMode m = ModeFactory.getCallableMode(
                    "Monitoring_queries", "push_scout_config");

            m.execute(in, new HashMap());
        }

        return null;
    }

}
