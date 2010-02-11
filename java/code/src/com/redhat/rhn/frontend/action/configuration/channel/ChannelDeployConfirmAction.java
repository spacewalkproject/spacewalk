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

import com.redhat.rhn.common.db.datasource.DataList;
import com.redhat.rhn.common.db.datasource.DataResult;
import com.redhat.rhn.common.util.DatePicker;
import com.redhat.rhn.domain.config.ConfigChannel;
import com.redhat.rhn.domain.rhnset.RhnSet;
import com.redhat.rhn.domain.rhnset.RhnSetElement;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.frontend.action.configuration.ConfigActionHelper;
import com.redhat.rhn.frontend.struts.RequestContext;
import com.redhat.rhn.frontend.struts.RhnAction;
import com.redhat.rhn.manager.configuration.ConfigurationManager;
import com.redhat.rhn.manager.rhnset.RhnSetDecl;

import org.apache.struts.action.ActionErrors;
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
 * ChannelDeployConfirmAction
 * @version $Rev$
 */
public class ChannelDeployConfirmAction extends RhnAction {
    
    /**
     * ${@inheritDoc}
     */
    public ActionForward execute(ActionMapping mapping, ActionForm form, 
            HttpServletRequest request, HttpServletResponse response) throws Exception {
        
        RequestContext ctx = new RequestContext(request);
        User user = ctx.getLoggedInUser();
        
        ConfigChannel cc = setupLists(request, user);
        request.setAttribute("parentUrl", request.getRequestURI() + "?ccid=" + cc.getId());

        DynaActionForm dForm = (DynaActionForm)form;
        
        if (isSubmitted(dForm) && request.getParameter("dispatch") != null) {
            if (doScheduleDeploy(request, dForm)) {
                ConfigActionHelper.clearRhnSets(user);
                return prepareToLeave(mapping, request, cc, dForm, "success");
            }
            else {
                return prepareToLeave(mapping, request, cc, dForm, "failure");
            }
        }
        else {
            return prepareToLeave(mapping, request, cc, dForm, "default");
       }
    }

    private ActionForward prepareToLeave(ActionMapping mapping, HttpServletRequest req, 
            ConfigChannel cc, DynaActionForm dForm, String forwardLabel) {
        DatePicker picker = getStrutsDelegate().
            prepopulateDatePicker(req, dForm, "date", DatePicker.YEAR_RANGE_POSITIVE);
        req.setAttribute("date", picker);

        ConfigActionHelper.setupRequestAttributes(new RequestContext(req), cc);
        Map m = makeParamMap(req);
        return getStrutsDelegate().forwardParams(mapping.findForward(forwardLabel), m);
    }

    private ConfigChannel setupLists(HttpServletRequest request, User user) {
        ConfigChannel cc = ConfigActionHelper.getChannel(request);

        DataResult files = ConfigurationManager.getInstance().
            listCurrentFiles(user, cc, null, 
                    RhnSetDecl.CONFIG_CHANNEL_DEPLOY_REVISIONS.getLabel());
        DataList list = new DataList(files);
        list.setMode(files.getMode());
        list.setElaboratorParams(files.getElaborationParams());
        request.setAttribute("selectedFiles", list);
        
        DataResult systems = ConfigurationManager.getInstance().
            listSystemInfoForChannel(user, cc, null, true);
        //systems.elaborate(systems.getElaborationParams());
        list = new DataList(systems);
        list.setMode(systems.getMode());
        list.setElaboratorParams(systems.getElaborationParams());
        request.setAttribute("selectedSystems", list);
        
        ActionErrors errs = new ActionErrors();
        if (files.getTotalSize() == 0) {
            // Error - you have to have files selcted
            errs.add(ActionMessages.GLOBAL_MESSAGE, 
                    new ActionMessage("deployconfirm.jsp.zeroFiles"));
        }
        
        if (systems.getTotalSize() == 0) {
            // Error - you have to have systems selcted
            errs.add(ActionMessages.GLOBAL_MESSAGE, 
                    new ActionMessage("deployconfirm.jsp.zeroSystems"));
        }
        saveMessages(request, errs);
        
        return cc;
    }

    protected Map makeParamMap(HttpServletRequest request) {
        Map m = super.makeParamMap(request);
        ConfigChannel cc = ConfigActionHelper.getChannel(request);
        ConfigActionHelper.processParamMap(cc, m);
        return m;
    }
    
    private boolean doScheduleDeploy(HttpServletRequest req, DynaActionForm form) {
        User usr = new RequestContext(req).getLoggedInUser();
        
        RhnSet files = RhnSetDecl.CONFIG_CHANNEL_DEPLOY_REVISIONS.get(usr);
        if (files.size() == 0) {
            // Error - you have to have files selcted
            createErrorMessage(req, "deployconfirm.jsp.zeroFiles", null);
            return false;
        }
        Set fileIds = buildIds(files);
        
        RhnSet systems = RhnSetDecl.CONFIG_CHANNEL_DEPLOY_SYSTEMS.get(usr);
        if (systems.size() == 0) {
            // Error - you have to have systems selcted
            createErrorMessage(req, "deployconfirm.jsp.zeroSystems", null);
            return false;
        }
        Set systemIds = buildIds(systems);
        Date datePicked = getStrutsDelegate().readDatePicker(form, "date", 
                DatePicker.YEAR_RANGE_POSITIVE);
        
        Map m = ConfigurationManager.getInstance().
            deployFiles(usr, fileIds, systemIds, datePicked);
        
        Long successes = m.get("success") == null ? new Long(0) : (Long)m.get("success");
        Long overrides = m.get("override") == null ? new Long(0) : (Long)m.get("override");
        
        ActionMessages msgs = new ActionMessages();
        if (successes.longValue() == 1) {
            msgs.add(ActionMessages.GLOBAL_MESSAGE,
                    new ActionMessage("deployconfirm.jsp.success", successes));
        }
        else {
            msgs.add(ActionMessages.GLOBAL_MESSAGE,
                    new ActionMessage("deployconfirm.jsp.successes", successes));
        }
        
        if (overrides.longValue() == 1) {
            msgs.add(ActionMessages.GLOBAL_MESSAGE,
                    new ActionMessage("deployconfirm.jsp.override", overrides));
        }
        else {
            msgs.add(ActionMessages.GLOBAL_MESSAGE,
                    new ActionMessage("deployconfirm.jsp.overrides", overrides));

        }
        saveMessages(req, msgs);

        return true;
    }
    
    private Set buildIds(RhnSet revisions) {
        Set s = new HashSet();
        for (Iterator itr = revisions.getElements().iterator(); itr.hasNext();) {
            RhnSetElement elt = (RhnSetElement)itr.next();
            Long id = elt.getElement();
            s.add(id);
        }
        return s;
    }

}
