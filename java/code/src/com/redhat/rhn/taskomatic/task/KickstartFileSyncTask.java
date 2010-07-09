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
import com.redhat.rhn.common.conf.ConfigDefaults;
import com.redhat.rhn.domain.kickstart.KickstartData;
import com.redhat.rhn.domain.kickstart.KickstartFactory;
import com.redhat.rhn.manager.kickstart.cobbler.CobblerXMLRPCHelper;

import org.apache.log4j.Logger;
import org.cobbler.CobblerConnection;
import org.cobbler.Profile;
import org.quartz.JobExecutionContext;
import org.quartz.JobExecutionException;

import java.io.File;
import java.util.List;
import java.util.concurrent.atomic.AtomicLong;

/**
 *
 * KickstartFileSyncTask
 *   Syncs kickstart profiles that were generated using the wizard.
 *   If the file does not exist on the file system, it re-generates the kickstart
 *   and saves it back to disk.
 * @version $Rev$
 */
public class KickstartFileSyncTask extends RhnJavaJob {

    private static final AtomicLong LAST_UPDATED = new AtomicLong();
    private long WARN_COUNT;

    /**
     * Used to log stats in the RHNDAEMONSTATE table
     */
    public static final String DISPLAY_NAME = "sync_from_cobbler";

    private Logger log = getLogger(KickstartFileSyncTask.class);

    /**
     * Default constructor
     */
    public KickstartFileSyncTask() {
        WARN_COUNT = 0;
    }

    /**
     * {@inheritDoc}
     */
    public void execute(JobExecutionContext ctxIn) throws JobExecutionException {

        CobblerConnection cc = CobblerXMLRPCHelper.getConnection(
                Config.get().getString(ConfigDefaults.COBBLER_AUTOMATED_USER));

        List<KickstartData> kickstarts = KickstartFactory.listAllKickstartData();
        for (KickstartData ks : kickstarts) {
            //If this is a wizard profile
            if (!ks.isRawData()) {
                Profile p = Profile.lookupById(cc, ks.getCobblerId());
                if (p != null) {
                    String file = p.getKickstart();
                    if (file != null && !(new File(file)).exists()) {
                        KickstartFactory.saveKickstartData(ks);
                    }
                }
            }
        }
    }
}
