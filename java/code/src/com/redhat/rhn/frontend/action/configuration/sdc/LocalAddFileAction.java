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
package com.redhat.rhn.frontend.action.configuration.sdc;

import com.redhat.rhn.domain.config.ConfigChannel;
import com.redhat.rhn.domain.server.Server;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.frontend.action.configuration.BaseAddFilesAction;
import com.redhat.rhn.frontend.action.systems.sdc.SdcHelper;
import com.redhat.rhn.frontend.struts.RequestContext;

import java.util.Map;

import javax.servlet.http.HttpServletRequest;

/**
 * LocalAddFileAction, sdc add config file action.
 * @version $Rev$
 */
public class LocalAddFileAction extends BaseAddFilesAction {

    /**
     * {@inheritDoc}
     */
    protected ConfigChannel getConfigChannel(HttpServletRequest request) {
        RequestContext ctx = new RequestContext(request);
        //new files will always go to the sandbox, not the local override.
        return ctx.lookupServer().getSandboxOverride();
    }

    /**
     * {@inheritDoc}
     */
    protected void processRequest(HttpServletRequest request) {
        RequestContext ctx = new RequestContext(request);
        Server server = ctx.lookupAndBindServer();
        User user = ctx.getLoggedInUser();
        SdcHelper.ssmCheck(request, server.getId(), user);
    }

    protected Map makeParamMap(HttpServletRequest request) {
        Map map = super.makeParamMap(request);
        RequestContext ctx = new RequestContext(request);
        map.put(RequestContext.SID, 
                ctx.lookupAndBindServer().getId().toString());
        return map;
    }
}
