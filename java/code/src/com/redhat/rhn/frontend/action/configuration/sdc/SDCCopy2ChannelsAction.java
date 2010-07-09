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

import com.redhat.rhn.common.db.datasource.DataResult;
import com.redhat.rhn.domain.server.Server;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.frontend.action.configuration.channel.Copy2ChannelsAction;
import com.redhat.rhn.frontend.struts.RequestContext;
import com.redhat.rhn.manager.configuration.ConfigurationManager;
import com.redhat.rhn.manager.rhnset.RhnSetDecl;

import org.apache.struts.action.ActionForward;
import org.apache.struts.action.ActionMapping;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

import javax.servlet.http.HttpServletRequest;


/**
 * SDCCopy2ChannelsAction
 * @version $Rev$
 */
public class SDCCopy2ChannelsAction extends Copy2ChannelsAction {
    /**
     *
     * {@inheritDoc}
     */
    protected RhnSetDecl getFileSetDecl() {
        return RhnSetDecl.CONFIG_FILE_NAMES;
    }

    /**
     *
     * {@inheritDoc}
     */
    protected void setupRequest(HttpServletRequest req) {
        RequestContext ctx = new RequestContext(req);
        Server s = ctx.lookupAndBindServer();
        String url = req.getRequestURI() + "?" +
                            RequestContext.SID + "=" + s.getId();
        req.setAttribute("parentUrl", url);
    }

    /**
     *
     * {@inheritDoc}
     */
    protected ActionForward doCopy(ActionMapping mapping,
            HttpServletRequest req, User user) {
        ActionForward forward = super.doCopy(mapping, req, user);
        RequestContext ctx = new RequestContext(req);
        Server s = ctx.lookupAndBindServer();
        Map params = new HashMap();
        params.put(RequestContext.SID, s.getId());
        return getStrutsDelegate().forwardParams(forward, params);
    }

    /**
     * {@inheritDoc}
     */
    public List getData(HttpServletRequest req) {
        RequestContext ctx = new RequestContext(req);
        User user = ctx.getLoggedInUser();
        ConfigurationManager cm = ConfigurationManager.getInstance();

        DataResult rs =  cm.listGlobalChannels(user, null);
        Map elabParams = new HashMap();
        elabParams.put("user_id", user.getId());
        rs.elaborate(elabParams);
        return rs;
    }
}
