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

import com.redhat.rhn.common.util.DatePicker;
import com.redhat.rhn.domain.action.config.ConfigUploadAction;
import com.redhat.rhn.domain.config.ConfigChannel;
import com.redhat.rhn.domain.rhnset.RhnSet;
import com.redhat.rhn.domain.rhnset.RhnSetElement;
import com.redhat.rhn.domain.server.Server;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.frontend.struts.RequestContext;
import com.redhat.rhn.frontend.struts.RhnListDispatchAction;
import com.redhat.rhn.manager.action.ActionManager;
import com.redhat.rhn.manager.rhnset.RhnSetDecl;
import com.redhat.rhn.manager.rhnset.RhnSetManager;

import org.apache.struts.action.ActionForm;
import org.apache.struts.action.ActionForward;
import org.apache.struts.action.ActionMapping;
import org.apache.struts.action.ActionMessage;
import org.apache.struts.action.ActionMessages;
import org.apache.struts.action.DynaActionForm;

import java.util.Date;
import java.util.HashSet;
import java.util.Iterator;
import java.util.Map;
import java.util.Set;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;


/**
 * ImportFileConfirmSubmitAction, for sdc configuration
 * @version $Rev$
 */
public class ImportFileConfirmSubmitAction extends RhnListDispatchAction {

    /**
     * {@inheritDoc}
     */
    protected void processMethodKeys(Map map) {
        map.put("sdcimportconfirm.jsp.confirm", "confirm");
    }

    /**
     * {@inheritDoc}
     */
    protected void processParamMap(ActionForm formIn, HttpServletRequest request,
            Map params) {
        params.put("sid", request.getParameter("sid"));
        getStrutsDelegate().rememberDatePicker(params, (DynaActionForm)formIn,
                "date", DatePicker.YEAR_RANGE_POSITIVE);
    }

    /**
     * Actually schedules the config upload action.
     * @param mapping struts ActionMapping
     * @param formIn struts ActionForm
     * @param request HttpServletRequest
     * @param response HttpServletResponse
     * @return A Forward to the managed files page
     */
    public ActionForward confirm(ActionMapping mapping, ActionForm formIn,
            HttpServletRequest request, HttpServletResponse response) {
        RequestContext ctxt = new RequestContext(request);
        User user = ctxt.getLoggedInUser();
        Server server = ctxt.lookupServer();

        //The set of config file names to add to the action.
        RhnSet set = RhnSetDecl.CONFIG_IMPORT_FILE_NAMES.get(user);

        //We currently have a set of RhnSetElements, but we need a set
        //of Longs, this does that conversion.
        Set cfnids = new HashSet();
        Iterator i = set.getElements().iterator();
        while (i.hasNext()) {
            cfnids.add(((RhnSetElement)i.next()).getElement());
        }

        //The channel to which files will be uploaded
        ConfigChannel sandbox = server.getSandboxOverride();
        //The earliest time to perform the action.
        Date earliest = getStrutsDelegate().readDatePicker((DynaActionForm)formIn,
                "date", DatePicker.YEAR_RANGE_POSITIVE);
        ConfigUploadAction upload = (ConfigUploadAction)ActionManager
                .createConfigUploadAction(user, cfnids, server, sandbox, earliest);

        //clear the set, we are done with it.
        RhnSetManager.remove(set);

        //Create a success message
        if (upload != null) {
            ActionMessages msgs = new ActionMessages();
            Object[] params = new Object[2];
            params[0] = new Long(upload.getRhnActionConfigFileName().size());
            params[1] = "/rhn/schedule/ActionDetails.do?aid=" + upload.getId();
            msgs.add(ActionMessages.GLOBAL_MESSAGE,
                    new ActionMessage("config.import.success", params));
            getStrutsDelegate().saveMessages(request, msgs);
        }

        return getStrutsDelegate().forwardParams(
                mapping.findForward("success"), makeParamMap(formIn, request));
    }

}
