/**
 * Copyright (c) 2013 SUSE
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
package com.redhat.rhn.manager.kickstart;

import com.redhat.rhn.common.validator.ValidatorError;
import com.redhat.rhn.domain.action.ActionFactory;
import com.redhat.rhn.domain.kickstart.KickstartData;
import com.redhat.rhn.domain.kickstart.KickstartFactory;
import com.redhat.rhn.domain.server.Server;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.frontend.dto.SystemOverview;
import com.redhat.rhn.manager.kickstart.cobbler.CobblerSystemCreateCommand;
import com.redhat.rhn.manager.kickstart.cobbler.CobblerXMLRPCHelper;
import com.redhat.rhn.manager.system.SystemManager;

import java.util.LinkedList;
import java.util.List;

/**
 * Creates multiple Cobbler system records.
 * @version $Rev$
 */
public class SSMCreateRecordCommand {

    /** The currently logged in user. */
    private User user;

    /** The selected profile ID or null if selection is based on IP ranges. */
    private String selectedProfileId;

    /** Output list of servers that had records created. */
    private List<Server> succeededServers;

    /**
     * Instantiates a new command.
     * @param userIn currently logged in user
     * @param selectedProfileIdIn selected profile ID or null if selection is
     *            based on IP ranges
     */
    public SSMCreateRecordCommand(User userIn, String selectedProfileIdIn) {
        super();
        user = userIn;
        selectedProfileId = selectedProfileIdIn;
    }

    /**
     * Gets the succeeded servers.
     * @return the succeeded servers
     */
    public List<Server> getSucceededServers() {
        return succeededServers;
    }

    /**
     * Runs the command.
     * @return the list
     */
    public List<ValidatorError> store() {
        succeededServers = new LinkedList<Server>();
        List<ValidatorError> errors = new LinkedList<ValidatorError>();
        List<SystemOverview> systemOverviews = KickstartManager.getInstance()
            .kickstartableSystemsInSsm(user);

        for (SystemOverview systemOverview : systemOverviews) {
            ValidatorError error = store(systemOverview);
            if (error != null) {
                errors.add(error);
            }
        }

        return errors;
    }

    /**
     * Runs the command on a single system.
     * @param systemOverview
     * @return an error or null
     */
    private ValidatorError store(SystemOverview systemOverview) {
        Long sid = systemOverview.getId();
        if (ActionFactory.doesServerHaveKickstartScheduled(sid)) {
            return new ValidatorError("kickstart.schedule.already.scheduled.jsp",
                systemOverview.getName());
        }

        Server server = SystemManager.lookupByIdAndUser(sid, user);

        String cobblerId = selectedProfileId;
        if (cobblerId == null) {
            KickstartData data = KickstartManager.getInstance()
                .findProfileForServersNetwork(server);
            if (data != null) {
                cobblerId = data.getCobblerId();
            }
        }

        org.cobbler.Profile profile = null;
        KickstartData data = null;
        if (cobblerId != null) {
            profile = org.cobbler.Profile.lookupById(
                CobblerXMLRPCHelper.getConnection(user), cobblerId);
            data = KickstartFactory.lookupKickstartDataByCobblerIdAndOrg(user.getOrg(),
                cobblerId);
        }

        if (profile == null) {
            return new ValidatorError("kickstart.schedule.no.profile.jsp",
                systemOverview.getName());
        }

        CobblerSystemCreateCommand command = new CobblerSystemCreateCommand(server,
            profile.getName(), data);
        ValidatorError error = command.store();
        if (error == null) {
            succeededServers.add(server);
        }

        return null;
    }
}
