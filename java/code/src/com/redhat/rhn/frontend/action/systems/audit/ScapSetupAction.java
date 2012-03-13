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
package com.redhat.rhn.frontend.action.systems.audit;

import com.redhat.rhn.domain.server.Server;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.frontend.struts.RequestContext;
import com.redhat.rhn.frontend.struts.RhnAction;
import com.redhat.rhn.manager.audit.ScapManager;

/**
 * ScapSetupAction
 * @version $Rev$
 */

public abstract class ScapSetupAction extends RhnAction {
    private static final String SCAP_ENABLED = "scapEnabled";

    protected void setupScapEnablementInfo(RequestContext context) {
        Server server = context.lookupAndBindServer();
        User user = context.getLoggedInUser();
        boolean enabled = ScapManager.isScapEnabled(server, user);
        context.getRequest().setAttribute(SCAP_ENABLED, enabled);
    }
}
