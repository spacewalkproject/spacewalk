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
package com.redhat.rhn.manager.satellite;

import com.redhat.rhn.common.hibernate.HibernateFactory;
import com.redhat.rhn.domain.kickstart.KickstartData;
import com.redhat.rhn.domain.kickstart.KickstartFactory;
import com.redhat.rhn.domain.kickstart.KickstartSession;
import com.redhat.rhn.domain.task.Task;
import com.redhat.rhn.domain.task.TaskFactory;
import com.redhat.rhn.manager.BaseTransactionCommand;
import com.redhat.rhn.manager.kickstart.KickstartSessionCreateCommand;

import org.apache.log4j.Logger;

import java.util.List;


/**
 * Class responsible for executing one-time upgrade logic
 * 
 * @version $Rev$
 */
public class UpgradeCommand extends BaseTransactionCommand {

    /**
     * Logger for this class
     */
    private static Logger log = Logger.getLogger(UpgradeCommand.class);
    
    public static final String UPGRADE_TASK_NAME = "upgrade_satellite_";
    public static final String UPGRADE_KS_PROFILES = 
        UPGRADE_TASK_NAME + "kickstart_profiles";
    
    /**
     * Constructor
     */
    public UpgradeCommand() {
        super(log);
    }


    /**
     * Excute the upgrade step
     */
    public void store() {
        try {
            HibernateFactory.getSession().beginTransaction();
            List upgradeTasks = TaskFactory.getTaskListByNameLike(UPGRADE_TASK_NAME);
            // Loop over upgrade tasks and execute the steps.
            for (int i = 0; i < upgradeTasks.size(); i++) {
                Task t = (Task) upgradeTasks.get(i);
                // Use WARN because we want this logged.
                if (t != null) {
                    log.warn("got upgrade task: " + t.getName());
                    if (t.getName().equals(UPGRADE_KS_PROFILES)) {
                        processKickstartProfiles();
                        TaskFactory.remove(t);
                    }
                }
            }
        }
        catch (Exception e) {
            log.error("Problem upgrading!", e);
            HibernateFactory.rollbackTransaction();
            
        }
        finally {
            handleTransaction();
        }
    }
    
    private void processKickstartProfiles() {
        // Use WARN here because we want this operation logged.
        log.warn("Processing ks profiles.");
        List allKickstarts = KickstartFactory.listAllKickstartData();
        for (int i = 0; i < allKickstarts.size(); i++) {
            KickstartData ksdata = (KickstartData) allKickstarts.get(i);
            KickstartSession ksession = 
                KickstartFactory.lookupDefaultKickstartSessionForKickstartData(ksdata);
            if (ksession == null) {
                log.warn("Kickstart does not have a session: id: " + ksdata.getId() + 
                        " label: " + ksdata.getLabel());
                KickstartSessionCreateCommand kcmd = new KickstartSessionCreateCommand(
                        ksdata.getOrg(), ksdata);
                kcmd.store();
                log.warn("Created kickstart session and key");
            }

        }
    }

}
