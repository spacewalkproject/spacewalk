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
package com.redhat.rhn.frontend.action.configuration.files;

import com.redhat.rhn.common.db.datasource.DataResult;
import com.redhat.rhn.common.util.DatePicker;
import com.redhat.rhn.domain.config.ConfigChannel;
import com.redhat.rhn.domain.config.ConfigChannelType;
import com.redhat.rhn.domain.config.ConfigFile;
import com.redhat.rhn.domain.config.ConfigRevision;
import com.redhat.rhn.domain.server.Server;
import com.redhat.rhn.domain.server.ServerFactory;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.frontend.action.configuration.ConfigActionHelper;
import com.redhat.rhn.frontend.dto.ConfigSystemDto;
import com.redhat.rhn.frontend.struts.RequestContext;
import com.redhat.rhn.frontend.struts.RhnAction;
import com.redhat.rhn.manager.configuration.ConfigurationManager;

import org.apache.struts.action.ActionForm;
import org.apache.struts.action.ActionForward;
import org.apache.struts.action.ActionMapping;
import org.apache.struts.action.ActionMessage;
import org.apache.struts.action.ActionMessages;
import org.apache.struts.action.DynaActionForm;

import java.util.Date;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

/**
 * LocalRevisionDeployAction
 * @version $Rev: 1 $
 */
public class LocalRevisionDeployAction extends RhnAction {

    /** Name of the system this file is associated with (local and sandbox only) */
    public static final String SYSTEM      = "system";
    public static final String SYSTEM_ID   = "sid";
    public static final String LAST_DEPLOY = "lastDeploy";
    public static final String DEPLOYABLE = "deployable";

    /** {@inheritDoc} */
    public ActionForward execute(ActionMapping mapping, ActionForm form,
            HttpServletRequest request, HttpServletResponse response) {

        RequestContext requestContext = new RequestContext(request);
        Map params = makeParamMap(request);
        ConfigActionHelper.processParamMap(request, params);

        DynaActionForm dForm = (DynaActionForm) form;
        User usr = requestContext.getLoggedInUser();

        ConfigRevision cr = ConfigActionHelper.findRevision(request);

        if (ConfigChannelType.global().equals(
                cr.getConfigFile().getConfigChannel().getConfigChannelType())) {
            return getStrutsDelegate().forwardParams(mapping.findForward("global"),
                    params);
        }

        if (cr != null) {
            Server srv = findServer(request, cr);
            if (ConfigurationManager.getInstance().isConfigEnabled(srv, usr)) {
                request.setAttribute(DEPLOYABLE, Boolean.TRUE);
            }
            if (isSubmitted(dForm)) {
                submitDeploy(dForm, cr, srv, usr);
                success(request);
                return getStrutsDelegate().forwardParams(mapping.findForward("success"),
                        params);
            }
            updateRequest(request, cr, srv);
        }

        DatePicker d = getStrutsDelegate().prepopulateDatePicker(request, dForm, "date",
                DatePicker.YEAR_RANGE_POSITIVE);
        request.setAttribute("date", d);
        ConfigActionHelper.setupRequestAttributes(requestContext, cr.getConfigFile(), cr);
        return getStrutsDelegate().forwardParams(mapping.findForward("default"), params);
    }

    protected Server findServer(HttpServletRequest request, ConfigRevision cr) {
        RequestContext requestContext = new RequestContext(request);

        Server srv = null;
        User usr = requestContext.getLoggedInUser();
        ConfigFile cf = cr.getConfigFile();
        ConfigChannel cc = cf.getConfigChannel();
        if (cc.isLocalChannel() || cc.isSandboxChannel()) {
            List infos = ConfigurationManager.getInstance().getSystemInfo(usr, cc);
            if (infos != null && infos.size() > 0) {
                long srvId = ((ConfigSystemDto)infos.get(0)).getId().longValue();
                srv = ServerFactory.lookupById(new Long(srvId));
            }
        }
        return srv;
    }

    protected void updateRequest(HttpServletRequest request, ConfigRevision cr,
            Server srv) {
        RequestContext requestContext = new RequestContext(request);

        User usr = requestContext.getLoggedInUser();
        ConfigFile cf = cr.getConfigFile();
        ConfigChannel cc = cf.getConfigChannel();

        if (cc.isGlobalChannel()) {
            return;
        }

        request.setAttribute(SYSTEM, srv.getName());
        request.setAttribute(SYSTEM_ID, srv.getId());

        if (cc.isLocalChannel()) {
            DataResult dr = ConfigurationManager.getInstance().getSuccesfulDeploysTo(usr,
                    cf.getConfigFileName(), srv);
            if (dr != null && dr.size() > 0) {
                request.setAttribute(LAST_DEPLOY, dr.get(0));
            }
        }
    }

    protected void submitDeploy(DynaActionForm form, ConfigRevision cr,
            Server srv, User u) {
        Date datePicked = getStrutsDelegate().
           readDatePicker(form, "date", DatePicker.YEAR_RANGE_POSITIVE);
        Set file = new HashSet();
        file.add(cr.getConfigFile().getId());
        Set system = new HashSet();
        system.add(srv.getId());
        ConfigurationManager.getInstance().deployFiles(u, file, system, datePicked);
    }

    private void success(HttpServletRequest request) {
        ActionMessages msg = new ActionMessages();
        msg.add(ActionMessages.GLOBAL_MESSAGE,
                new ActionMessage("filedeploy.success"));
        getStrutsDelegate().saveMessages(request, msg);
    }
}
