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
import com.redhat.rhn.domain.action.Action;
import com.redhat.rhn.domain.action.ActionFactory;
import com.redhat.rhn.domain.action.ActionType;
import com.redhat.rhn.domain.action.config.ConfigAction;
import com.redhat.rhn.domain.action.config.ConfigUploadAction;
import com.redhat.rhn.domain.config.ConfigChannel;
import com.redhat.rhn.domain.rhnset.RhnSet;
import com.redhat.rhn.domain.rhnset.RhnSetElement;
import com.redhat.rhn.domain.server.Server;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.frontend.struts.RequestContext;
import com.redhat.rhn.frontend.struts.RhnHelper;
import com.redhat.rhn.frontend.struts.RhnListDispatchAction;
import com.redhat.rhn.manager.action.ActionManager;
import com.redhat.rhn.manager.configuration.ConfigurationManager;
import com.redhat.rhn.manager.rhnset.RhnSetDecl;
import com.redhat.rhn.manager.rhnset.RhnSetManager;

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
 * ImportFileConfirmSubmitAction, for sdc configuration
 * @version $Rev$
 */
public class FileListConfirmSubmitAction extends RhnListDispatchAction {

    /**
     * {@inheritDoc}
     */
    protected void processMethodKeys(Map map) {
        map.put("sdcimportconfirm.jsp.confirm", "importFile");
        map.put("sdcdeployconfirm.jsp.schedule", "deploy");
        map.put("sdcdiffconfirm.jsp.schedule", "diff");
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
    public ActionForward importFile(ActionMapping mapping, ActionForm formIn,
            HttpServletRequest request, HttpServletResponse response) {
        RequestContext ctxt = new RequestContext(request);
        User user = ctxt.getLoggedInUser();
        Server server = ctxt.lookupServer();
        
        //The set of config file names to add to the action.
        RhnSet set = RhnSetDecl.CONFIG_IMPORT_FILE_NAMES.get(user);
        Set cfnids = getCfnids(set);
        //if they don't have a set, don't do anything.
        if (cfnids.size() < 1) {
            return createNoSelectedMessage(request, mapping, formIn, server.getId());
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
            createSuccessMessage(upload, upload.getRhnActionConfigFileName().size(),
                    "config.import.success", request);
        }
        
        return getStrutsDelegate().forwardParam(
                mapping.findForward("success"), "sid", server.getId().toString());
    }
    
    /**
     * Actually schedules the config deploy action.
     * @param mapping struts ActionMapping
     * @param formIn struts ActionForm
     * @param request HttpServletRequest
     * @param response HttpServletResponse
     * @return A Forward to the managed files page
     */
    public ActionForward deploy(ActionMapping mapping, ActionForm formIn,
            HttpServletRequest request, HttpServletResponse response) {
        return createRevisionAction(request, formIn, mapping,
                ActionFactory.TYPE_CONFIGFILES_DEPLOY, "config.deploy.success");
    }
    
    /**
     * Actually schedules the config diff action.
     * @param mapping struts ActionMapping
     * @param form struts ActionForm
     * @param request HttpServletRequest
     * @param response HttpServletResponse
     * @return A Forward to the managed files page
     */
    public ActionForward diff(ActionMapping mapping, ActionForm form,
            HttpServletRequest request, HttpServletResponse response) {
        return createRevisionAction(request, form, mapping,
                ActionFactory.TYPE_CONFIGFILES_DIFF, "config.diff.success");
    }
    
    private ActionForward createRevisionAction(HttpServletRequest request, ActionForm form,
            ActionMapping mapping, ActionType type, String successKey) {
        RequestContext ctxt = new RequestContext(request);
        User user = ctxt.getLoggedInUser();
        Long sid = ctxt.getRequiredParam("sid");
        
        //create a set of config revisions from the set of config file names
        RhnSet set = RhnSetDecl.CONFIG_FILE_NAMES.get(user);
        Set revisions = getCrids(set, sid);
        //if they don't have a set, don't do anything.
        if (revisions.size() < 1) {
            return createNoSelectedMessage(request, mapping, form, sid);
        }
        
        //we need a set, so add our one server to a set.
        Set servers = new HashSet();
        servers.add(sid);
        
        //create the action
        Date earliest = getStrutsDelegate().readDatePicker((DynaActionForm)form,
                "date", DatePicker.YEAR_RANGE_POSITIVE);
        ConfigAction action = (ConfigAction)ActionManager.createConfigAction(user,
                revisions, servers, type, earliest);
        
        //clean-up the set we just worked with
        RhnSetManager.remove(set);
        
        //create a success message
        if (action != null) {
            createSuccessMessage(action, action.getConfigRevisionActions().size(),
                    successKey, request);
        }
        
        //success, go to the config file manage page
        return getStrutsDelegate().forwardParam(
                mapping.findForward("success"), "sid", sid.toString());
    }
    
    private Set getCfnids(RhnSet rhnSet) {
        //We currently have a set of RhnSetElements, but we need a set
        //of Longs, this does that conversion.
        Set cfnids = new HashSet();
        Iterator i = rhnSet.getElements().iterator();
        while (i.hasNext()) {
            cfnids.add(((RhnSetElement)i.next()).getElement());
        }
        return cfnids;
    }
    
    private void createSuccessMessage(Action action, int successes,
            String transKey, HttpServletRequest request) {
        ActionMessages msgs = new ActionMessages();
        Object[] params = new Object[2];
        params[0] = new Long(successes);
        params[1] = "/rhn/schedule/ActionDetails.do?aid=" + action.getId();
        msgs.add(ActionMessages.GLOBAL_MESSAGE,
                new ActionMessage(transKey, params));
        getStrutsDelegate().saveMessages(request, msgs);
    }
    
    private Set getCrids(RhnSet rhnSet, Long sid) {
        Set revisions = new HashSet();
        
        //go through all of the selected file names
        Iterator nameItty = rhnSet.getElements().iterator();
        while (nameItty.hasNext()) {
            Long cfnid = ((RhnSetElement)nameItty.next()).getElement();
            Long crid = ConfigurationManager.getInstance()
                    .getDeployableRevisionForFileName(cfnid, sid);
            
            //add to the set if this system has a deployable revision of this
            //file name
            if (crid != null) {
                revisions.add(crid);
            }
        }
        
        return revisions;
    }
    
    private ActionForward createNoSelectedMessage(HttpServletRequest request,
            ActionMapping mapping, ActionForm formIn, Long sid) {
        ActionErrors errors = new ActionErrors();
        errors.add(ActionMessages.GLOBAL_MESSAGE,
                new ActionMessage("sdcfilelist.jsp.noSelected"));
        addErrors(request, errors);
        return getStrutsDelegate().forwardParam(
                mapping.findForward(RhnHelper.DEFAULT_FORWARD),
                "sid", sid.toString());
    }

}
