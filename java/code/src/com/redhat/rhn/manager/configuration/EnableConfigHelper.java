/**
 * Copyright (c) 2009--2015 Red Hat, Inc.
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
package com.redhat.rhn.manager.configuration;

import com.redhat.rhn.common.db.datasource.DataResult;
import com.redhat.rhn.domain.action.ActionFactory;
import com.redhat.rhn.domain.rhnset.RhnSet;
import com.redhat.rhn.domain.server.Server;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.frontend.dto.ConfigSystemDto;
import com.redhat.rhn.manager.action.ActionManager;
import com.redhat.rhn.manager.channel.ChannelManager;
import com.redhat.rhn.manager.rhnpackage.PackageManager;
import com.redhat.rhn.manager.rhnset.RhnSetDecl;
import com.redhat.rhn.manager.rhnset.RhnSetManager;
import com.redhat.rhn.manager.system.SystemManager;

import java.util.ArrayList;
import java.util.Date;
import java.util.List;
import java.util.Map;

/**
 * Due to the complicated nature of enabling configuration, this class is
 * used as a way to separate out the logic.
 */
public class EnableConfigHelper {

    private User user;

    protected EnableConfigHelper(User userIn) {
        user = userIn;
    }

    /**
     * Enable the set of systems given for configuration management.
     * @param setLabel The label for the set that contains systems selected for enablement
     * @param earliestIn The earliest time package actions will be scheduled.
     */
    public void enableSystems(String setLabel, Date earliestIn) {
        // earliest = earliestIn;
        ConfigurationManager cm = ConfigurationManager.getInstance();
        //Get the list of systems and what we need to do to them.
        DataResult dr = cm.listNonManagedSystemsInSetElaborate(user, setLabel);

        /*
         * The set going to store the system ids and an error code
         * for any problems we run into.  The element_two column will
         * be used for the error code.
         * I realize that this is cheating with the element_two column,
         * but the other option was to have a separate set for every
         * error condition and then union the sets when we wish to display them.
         *
         * The problem we are solving by using RhnSet is remembering what
         * systems ran into what problems across page requests (pagination especially)
         *
         * TODO: currently any single system will only have one error
         *       condition.  We should probably tell the user multiple
         *       errors if we can.
         */
        RhnSet set = RhnSetDecl.CONFIG_ENABLE_SYSTEMS.create(user);

        //iterate through the dataresult and perform actions
        for (int n = 0; n < dr.getTotalSize(); n++) {
            ConfigSystemDto dto = (ConfigSystemDto)dr.get(n);
            Long sid = new Long(dto.getId().longValue());
            Server current = SystemManager.lookupByIdAndUser(sid, user);
            set.addElement(new Long(dto.getId().longValue()),
                    new Long(enableSystem(dto, current, earliestIn)));
        }

        //save the results
        RhnSetManager.store(set);
    }

    private int enableSystem(ConfigSystemDto dto, Server current, Date earliest) {
        //subscribe the system to RhnTools child channel if they need it.
        if (!dto.isRhnTools()) {
            if (ChannelManager.subscribeToChildChannelWithPackageName(user, current,
                    ChannelManager.TOOLS_CHANNEL_PACKAGE_NAME) == null) {
                return ConfigurationManager.ENABLE_ERROR_RHNTOOLS;
            }
        }

        //schedule package installs for the rhncfg-* packages.
        if (!installPackages(dto, current, earliest)) {
            return ConfigurationManager.ENABLE_ERROR_PACKAGES;
        }

        return ConfigurationManager.ENABLE_SUCCESS;
    }

    private boolean installPackages(ConfigSystemDto dto, Server current, Date earliest) {
        boolean error = false;
        List packages = new ArrayList();

        /*
         * If there is ever an error, we will stop what we are doing.  Utilizing
         * the short circuit of boolean expression evaluation to easily do this.
         */
        error = installPackagesHelper(current, packages,
                                                PackageManager.RHNCFG, dto.getRhncfg());
        error = error || installPackagesHelper(current, packages,
                                                PackageManager.RHNCFG_ACTIONS,
                dto.getRhncfgActions());
        error = error || installPackagesHelper(current, packages,
                                                PackageManager.RHNCFG_CLIENT,
                dto.getRhncfgClient());

        if (error) {
            return false;  //there was an error, bail out
        }
        else if (packages.size() == 0) {
            return true;  //This particular system didn't need any packages
        }

        ActionManager.schedulePackageAction(user, packages,
            ActionFactory.TYPE_PACKAGES_UPDATE, earliest, current);

        return true;

    }

    private boolean installPackagesHelper(Server current,
            List packages, String packageName, int status) {
        if (status == ConfigSystemDto.NEEDED) {
            Map map = PackageManager.lookupEvrIdByPackageName(current.getId(), packageName);
            if (map == null) {
                return true;
            }

            packages.add(map);
        }
        return false;
    }

}
