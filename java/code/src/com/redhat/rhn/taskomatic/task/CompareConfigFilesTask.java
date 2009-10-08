
package com.redhat.rhn.taskomatic.task;

import com.redhat.rhn.domain.action.Action;
import com.redhat.rhn.domain.action.ActionFactory;
import com.redhat.rhn.domain.action.config.ConfigAction;
import com.redhat.rhn.domain.config.ConfigFile;
import com.redhat.rhn.domain.config.ConfigRevision;
import com.redhat.rhn.domain.config.ConfigurationFactory;
import com.redhat.rhn.domain.server.Server;
import com.redhat.rhn.domain.server.ServerFactory;
import com.redhat.rhn.frontend.dto.ConfigFileNameDto;
import com.redhat.rhn.frontend.dto.SystemOverview;
import com.redhat.rhn.manager.configuration.ConfigurationManager;
import com.redhat.rhn.manager.system.SystemManager;

import org.apache.log4j.Logger;
import org.quartz.Job;
import org.quartz.JobExecutionContext;
import org.quartz.JobExecutionException;

/**
 * Compare Config Files
 *  Schedules a comparison of config files on all systems
 *
 * @version $Rev$
 */
public class CompareConfigFilesTask implements Job {

    /**
     * Used to log stats in the RHNDAEMONSTATE table
     */
    public static final String DISPLAY_NAME = "compare_config_files";

    private static Logger log = Logger.getLogger(CompareConfigFilesTask.class);

    /**
     * Default constructor
     */
    public CompareConfigFilesTask() {
    }

    /**
     * {@inheritDoc}
     */
    public void execute(JobExecutionContext context)
            throws JobExecutionException {

        log.info("running config compare");

        ConfigurationManager cm = ConfigurationManager.getInstance();

        for (SystemOverview sys : SystemManager.listAllSystems()) {
            Action act = ActionFactory.createAction(ActionFactory.TYPE_CONFIGFILES_DIFF);
            ConfigAction cfact = (ConfigAction) act;
            Server server = ServerFactory.lookupById(sys.getId());

            if (server.isInactive()) {
                continue;
            }

            // set up needed fields for the action
            act.setName(act.getActionType().getName());
            act.setOrg(server.getOrg());

            // add the server to the action
            ActionFactory.addServerToAction(server, act);

            // add file revisions to the action
            for (ConfigFileNameDto cfn : cm.listAllFileNamesForSystem(server)) {
                Long cfid = cfn.getConfigFileId();
                ConfigFile cf = ConfigurationFactory.lookupConfigFileById(cfid);
                ConfigRevision crev = cf.getLatestConfigRevision();

                ActionFactory.addConfigRevisionToAction(crev, server, cfact);
            }

            if (act.getServerActions().size() < 1) {
                continue;
            }
            if (cfact.getConfigRevisionActions().size() < 1) {
                continue;
            }

            ActionFactory.save(act);
        }
    }
}

// vim: ts=4:expandtab
