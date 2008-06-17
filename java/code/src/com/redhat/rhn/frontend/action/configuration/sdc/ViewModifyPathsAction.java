/**
 * Copyright (c) 2008 Red Hat, Inc.
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

import com.redhat.rhn.common.localization.LocalizationService;
import com.redhat.rhn.domain.config.ConfigChannel;
import com.redhat.rhn.domain.config.ConfigChannelType;
import com.redhat.rhn.domain.config.ConfigFile;
import com.redhat.rhn.domain.config.ConfigRevision;
import com.redhat.rhn.domain.rhnset.RhnSet;
import com.redhat.rhn.domain.rhnset.RhnSetElement;
import com.redhat.rhn.domain.server.Server;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.frontend.action.systems.sdc.SdcHelper;
import com.redhat.rhn.frontend.struts.RequestContext;
import com.redhat.rhn.frontend.struts.RhnAction;
import com.redhat.rhn.frontend.struts.RhnHelper;
import com.redhat.rhn.frontend.struts.RhnListSetHelper;
import com.redhat.rhn.frontend.taglibs.list.ListTagHelper;
import com.redhat.rhn.manager.configuration.ConfigurationManager;
import com.redhat.rhn.manager.rhnset.RhnSetDecl;
import com.redhat.rhn.manager.rhnset.RhnSetManager;

import org.apache.struts.action.ActionForm;
import org.apache.struts.action.ActionForward;
import org.apache.struts.action.ActionMapping;
import org.apache.struts.action.ActionMessage;
import org.apache.struts.action.ActionMessages;

import java.util.HashMap;
import java.util.Iterator;
import java.util.List;
import java.util.Map;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;


/**
 * ViewModifyCentralPathsAction
 * @version $Rev$
 */
public class ViewModifyPathsAction extends RhnAction {
    public static final String COPY_TO_LOCAL = "copy_to_local";
    public static final String COPY_TO_SANDBOX = "copy_to_sandbox";
    public static final String COPY_TO_GLOBAL = "copy_to_global";
    public static final String DELETE_FILES = "delete_files";
    
    public static final String COPY_TO_LOCAL_KEY = 
                                    "sdc.config.file_list.copy_to_local";
    public static final String COPY_TO_SANDBOX_KEY = 
                                    "sdc.config.file_list.copy_to_sandbox";
    public static final String COPY_TO_GLOBAL_KEY = 
                                     "sdc.config.file_list.copy_to_global";
    public static final String DELETE_FILES_KEY = 
                                    "sdc.config.file_list.delete_files";
    
    public static final String DISPATCH = "dispatch";
    public static final String LIST_NAME = "files";
    public static final String DATA_SET = "pageList";
    
    public static final String SANDBOX_SUCCESS_KEY = 
                                     "sdc.config.file_list.sandbox.success";
    
    public static final String LOCAL_SUCCESS_KEY = 
                                      "sdc.config.file_list.local.success";
    
    public static final String DELETE_FILES_SANDBOX_SUCCESS_KEY = 
                                       "sdc.config.file_list.sandbox.delete.success";
    
    public static final String DELETE_FILES_LOCAL_SUCCESS_KEY =
                                       "sdc.config.file_list.local.delete.success";
    /**
     * ${@inheritDoc}
     */
    public ActionForward execute(ActionMapping mapping, ActionForm form, 
            HttpServletRequest request, HttpServletResponse response) throws Exception {

        RequestContext context = new RequestContext(request);
        User user = context.getLoggedInUser();
        
        RhnSet set =  getDecl().get(user);
        //if its not submitted
        // ==> this is the first visit to this page
        // clear the 'dirty set'
        if (!context.isSubmitted()) {
            set.clear();
            RhnSetManager.store(set);
        }
        setupButtons(request);
        RhnListSetHelper helper = new RhnListSetHelper(request);
        
        if (request.getParameter(DISPATCH) != null) {
            // if its one of the Dispatch actions handle it..            
            helper.updateSet(set, LIST_NAME);
            if (!set.isEmpty()) {
                return handleDispatchAction(mapping, context);
            }
            else {
                RhnHelper.handleEmptySelection(request);
            }
        }        
        
        //mapping.getParameter() is used to identify the type
        // channel we are trying to process..
        // the struts-config has paramter set to 
        // either 'sandbox' or 'local' or 'central'
        request.setAttribute(mapping.getParameter(), Boolean.TRUE);

        Server server = context.lookupAndBindServer();
        ConfigurationManager cm = ConfigurationManager.getInstance();
        List dataSet = cm.listManagedPathsFor(server, user, 
                                             getType(mapping.getParameter()));
        // if its a list action update the set and the selections
        if (ListTagHelper.getListAction(LIST_NAME, request) != null) {
            helper.execute(set, 
                            LIST_NAME,
                            dataSet);
        }        

        // if I have a previous set selections populate data using it       
        if (!set.isEmpty()) {
            helper.syncSelections(set, dataSet);
            ListTagHelper.setSelectedAmount(LIST_NAME, set.size(), request);            
        }
        request.setAttribute(ListTagHelper.PARENT_URL, 
                            request.getRequestURI() + "?sid=" + server.getId());
        request.setAttribute(DATA_SET, dataSet);
        SdcHelper.ssmCheck(request, server.getId(), user);
        ListTagHelper.bindSetDeclTo(LIST_NAME, getDecl(), request);
        return mapping.findForward(RhnHelper.DEFAULT_FORWARD);
    }

    /**
     * Handles a dispatch action
     * Could be One of copy_to_sandbox,
     * copy_to_local, copy_to_global
     * &amp; delete_files
     * @param mapping the action mapping used for returning 'forward' url
     * @param context the request context
     * @return the forward url
     */
    private ActionForward  handleDispatchAction(ActionMapping mapping, 
                                                RequestContext context) {
        
        User user = context.getLoggedInUser();
        Server server = context.lookupAndBindServer();
        String action = COPY_TO_GLOBAL;
        Map params = new HashMap();
        params.put(RequestContext.SID, server.getId().toString());
        
        if (context.wasDispatched(COPY_TO_LOCAL_KEY)) {
            int size = copySelectedToChannel(server.getLocalOverride(),
                                    user);
            successMessage(context.getRequest(), 
                               LOCAL_SUCCESS_KEY, size);
            action = COPY_TO_LOCAL;
        }
        else if (context.wasDispatched(COPY_TO_SANDBOX_KEY)) {
            int size = copySelectedToChannel(server.getSandboxOverride(),
                    user);            
            successMessage(context.getRequest(), 
                                SANDBOX_SUCCESS_KEY, size);
            action = COPY_TO_SANDBOX;
        }
        else if (context.wasDispatched(DELETE_FILES_KEY)) {
            action = DELETE_FILES;
            if (ConfigChannelType.local().getLabel().
                                            equals(mapping.getParameter())) {
                int size = deleteFiles(server.getLocalOverride(), user);
                successMessage(context.getRequest(), 
                                    DELETE_FILES_LOCAL_SUCCESS_KEY, size);                
            }
            else {
                int size = deleteFiles(server.getSandboxOverride(), user);
                successMessage(context.getRequest(), 
                                    DELETE_FILES_SANDBOX_SUCCESS_KEY, size);
            }
        }
        //if its a COPY_TO_GLOBAL, we'd use the forward 
        // link from the struts-config.xml so thats covered..
        // even though that doesn appear in the if/else clause
        return getStrutsDelegate().
                     forwardParams(mapping.findForward(action), params);            
    }

    /**
     * Deletes the selected files from a given channel.
     * @param channel channel to remove the files from
     * @param user user needed for permission checking..
     * @return returns the number of files deleted
     */
    private int deleteFiles(ConfigChannel channel,
                                User user) {
        ConfigurationManager cm = ConfigurationManager.getInstance();
        RhnSet set =  getDecl().get(user);
        for (Iterator itr = set.getElements().iterator(); itr.hasNext();) {
            RhnSetElement e = (RhnSetElement) itr.next();
            ConfigFile cf = cm.lookupConfigFile(user, e.getElement());
            cm.deleteConfigFile(user, cf);
        }
        int size = set.size();
        set.clear();
        RhnSetManager.store(set);
        return size;
        
    }
    
    /**
     * Copies the select files to a given channel..
     * @param channel channel to copy the files to..
     * @param user used for security..
     * @return returns the number of files copied
     */
    private int copySelectedToChannel(ConfigChannel channel,
                                        User user) {
        ConfigurationManager cm = ConfigurationManager.getInstance();
        RhnSet set =  getDecl().get(user);
        for (Iterator itr = set.getElements().iterator(); itr.hasNext();) {
            Long fileId = ((RhnSetElement)itr.next()).getElement();
            ConfigFile cf = cm.lookupConfigFile(user, fileId);
            ConfigRevision cr = cf.getLatestConfigRevision();
            cm.copyConfigFile(cr, channel, user);
        }
        int size = set.size();
        set.clear();
        RhnSetManager.store(set);
        return size;
    }
    
    private void successMessage(HttpServletRequest req,
                                             String key,
                                             long numFiles) {
        ActionMessages msg = new ActionMessages();
        Object[] args = new Object[] {String.valueOf(numFiles)};
        
        msg.add(ActionMessages.GLOBAL_MESSAGE, new ActionMessage(key, args));
        saveMessages(req, msg);        
    }
    
    /**
     * 
     * @return the set declaration used to this action.. 
     */
    protected RhnSetDecl getDecl() {
        return RhnSetDecl.CONFIG_FILE_NAMES;
    }
    
    /**
     * Returns the "ConfigChannelType" based on 
     * the channel type key..
     * @param channelType the key -> 'central'| 'local' | 'sandbox' 
     * @return the channel type..
     */
    private ConfigChannelType getType(String channelType) {

        if (ConfigChannelType.global().getLabel().
                                                    equals(channelType)) {
            return ConfigChannelType.global();
        }
        else if (ConfigChannelType.local().getLabel().
                                                        equals(channelType)) {
            return ConfigChannelType.local();
        }
        else if (ConfigChannelType.sandbox().getLabel().
                                                        equals(channelType)) {
            return ConfigChannelType.sandbox();
        }
        String message = "Unknown channel type provided.. [" + channelType +
                                    "] in " + getClass().getName() +
                                    ".getType ()"; 
                            
        throw new RuntimeException(message);
    }
    
    private void setupButtons(HttpServletRequest request) {
        LocalizationService ls = LocalizationService.getInstance();
        request.setAttribute(COPY_TO_LOCAL, 
                            ls.getMessage(COPY_TO_LOCAL_KEY));
        request.setAttribute(COPY_TO_GLOBAL, 
                        ls.getMessage(COPY_TO_GLOBAL_KEY));
        request.setAttribute(COPY_TO_SANDBOX, 
                        ls.getMessage(COPY_TO_SANDBOX_KEY));        

        request.setAttribute(DELETE_FILES, 
                ls.getMessage(DELETE_FILES_KEY));        
    }
}
