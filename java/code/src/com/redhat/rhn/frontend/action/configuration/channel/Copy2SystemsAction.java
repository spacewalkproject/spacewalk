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
package com.redhat.rhn.frontend.action.configuration.channel;

import com.redhat.rhn.domain.config.ConfigChannel;
import com.redhat.rhn.domain.server.Server;
import com.redhat.rhn.domain.server.ServerFactory;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.frontend.struts.RequestContext;
import com.redhat.rhn.manager.configuration.ConfigurationManager;
import com.redhat.rhn.manager.rhnset.RhnSetDecl;

import java.util.List;

import javax.servlet.http.HttpServletRequest;

/**
 * Copy2SystemsAction
 * @version $Rev$
 */
public class Copy2SystemsAction extends BaseCopyToAction {

    /**
     * Return the list of systems whose local-channels this user can copy files to
     * {@inheritDoc}
     */
    public List getData(HttpServletRequest req) {
        RequestContext ctx = new RequestContext(req);
        User user = ctx.getLoggedInUser();
        ConfigurationManager cm = ConfigurationManager.getInstance();
        return cm.listSystemsForCopy(user, null);
    }

    /**
     * For this class, the destination-id is a server-id, and the resulting
     * config-channel is the local channel for that system
     * {@inheritDoc}
     */
    public ConfigChannel getDestinationFromId(Long destId) {
        Server s = ServerFactory.lookupById(destId);
        return s.getLocalOverride();
    }

    /**
     * JSP is showing systems
     * {@inheritDoc}
     */
    public String getJspLabel() {
        return "systems";
    }

    /**
     * The RhnSet we use to handle selection is the CONFIG_SYSTEMS set
     * {@inheritDoc}
     */
    public RhnSetDecl getSetDecl() {
        return RhnSetDecl.CONFIG_SYSTEMS;
    }

    /**
     * {@inheritDoc}
     */
    public String getSuccessKey(int numFiles, int numChannels) {
        if (numFiles == 1 && numChannels == 1) {
            return "copy2systems.jsp.success.1x1";
        }
        else if (numFiles == 1) {
            return "copy2systems.jsp.success.1xn";
        }
        else if (numChannels == 1) {
            return "copy2systems.jsp.success.nx1";
        }
        else {
            return "copy2systems.jsp.success.nxn";
        }
    }
}
