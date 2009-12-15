/**
 * Copyright (c) 2009 Red Hat, Inc.
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
import com.redhat.rhn.common.util.StringUtil;
import com.redhat.rhn.domain.action.Action;
import com.redhat.rhn.domain.action.ActionFactory;
import com.redhat.rhn.domain.action.config.ConfigAction;
import com.redhat.rhn.domain.action.server.ServerAction;
import com.redhat.rhn.domain.config.ConfigChannelType;
import com.redhat.rhn.domain.config.ConfigFileCount;
import com.redhat.rhn.domain.role.RoleFactory;
import com.redhat.rhn.domain.server.Server;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.frontend.action.configuration.ConfigActionHelper;
import com.redhat.rhn.frontend.action.systems.sdc.SdcHelper;
import com.redhat.rhn.frontend.struts.RequestContext;
import com.redhat.rhn.frontend.struts.RhnAction;
import com.redhat.rhn.manager.action.ActionManager;
import com.redhat.rhn.manager.configuration.ConfigurationManager;

import org.apache.struts.action.ActionForm;
import org.apache.struts.action.ActionForward;
import org.apache.struts.action.ActionMapping;

import java.util.ArrayList;
import java.util.Iterator;
import java.util.List;
import java.util.Set;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

/**
 * OverviewAction
 * @version $Rev$
 */
public class OverviewAction extends RhnAction {
    public static final String GLOBAL_CONFIG_CHANNELS = "globalConfigChannels"; 
    public static final String CENRALLY_MANAGED_FILES = "centralFiles";
    public static final String CENRALLY_DEPLOYABLE_FILES = "deployableFiles";
    public static final String LOCALLY_MANAGED_FILES = "localFiles";
    public static final String SANDBOX_MANAGED_FILES = "sandboxFiles";
    
    public static final String DEPLOYMENT_TIME_MESSAGE = "deploymentTimeMessage";
    public static final String DEPLOYMENT_DETAILS_MESSAGE = "deploymentDetailsMessage";
    public static final String DIFF_TIME_MESSAGE = "diffTimeMessage";
    public static final String DIFF_DETAILS_MESSAGE = "diffDetailsMessage";
    public static final String DIFF_ACTION_MESSAGE = "diffActionMessage";
    public static final String SYSTEM_ID = "sid";
    
    public static final String CONFIG_ENABLED = "configEnabled";
    
    public static final String DIFF_ACTION_MESSAGE_PREFIX = "sdc.config.diff.files_";
    public static final String DIFF_DETAIL_MESSAGE_PREFIX = 
                                                    "sdc.config.differing.files_";
    
    private static final int NONE = 0;
    private static final int SINGULAR = 1;
    private static final int PLURAL = 2;
    
    private static final String LOCAL_FILES_URL = 
                    "/rhn/systems/details/configuration/ViewModifyLocalPaths.do";
    private static final String CENTRAL_FILES_URL = 
                    "/rhn/systems/details/configuration/ViewModifyCentralPaths.do";
    private static final String SANDBOX_FILES_URL = 
                    "/rhn/systems/details/configuration/ViewModifySandboxPaths.do";
    private static final String ADD_FILES_URL = 
                        "/rhn/systems/details/configuration/addfiles/UploadFile.do";
    
    private static final String DEPLOY_FILES_URL = 
                        "/rhn/systems/details/configuration/DeployFile.do";
    private static final String COMPARE_FILES_URL = 
                            "/rhn/systems/details/configuration/DiffFile.do";
    
    private static final String ACTION_DETAILS_URL = 
                                "/network/systems/details/history/event.pxt";    

    private static final String USER_DETAILS_URL = 
                                            "/rhn/users/UserDetails.do";
    private static final String CONFIG_CHANNELS_URL = 
                    "/rhn/systems/details/configuration/ConfigChannelList.do";
    
    /**
     * {@inheritDoc}
     */
    public ActionForward execute(ActionMapping mapping, 
                                    ActionForm formIn,
                                    HttpServletRequest request, 
                                    HttpServletResponse response) {
        RequestContext context = new RequestContext(request);
        
        User user = context.getLoggedInUser();
        Server server = context.lookupAndBindServer();
        
        ConfigurationManager cm = ConfigurationManager.getInstance();

        setupFiles(context, 
                LOCALLY_MANAGED_FILES, 
                cm.countLocallyManagedPaths(server, 
                                            user,
                                    ConfigChannelType.local()),
                                    LOCAL_FILES_URL + "?sid=" + server.getId());
        
        setupFiles(context, 
                SANDBOX_MANAGED_FILES, 
                cm.countLocallyManagedPaths(server, 
                                            user,
                                ConfigChannelType.sandbox()),
                                SANDBOX_FILES_URL + "?sid=" + server.getId());        
        setupFiles(context, 
                CENRALLY_DEPLOYABLE_FILES, 
                cm.countCentrallyDeployablePaths(server, user),
                DEPLOY_FILES_URL + "?sid=" + server.getId());        
        
        setupFiles(context, 
                CENRALLY_MANAGED_FILES, 
                cm.countCentrallyManagedPaths(server, user),
                CENTRAL_FILES_URL + "?sid=" + server.getId());
        

        String configChannelsMsg = ConfigActionHelper.makeChannelCountsMessage(
                                              server.getConfigChannels().size(),
                                 CONFIG_CHANNELS_URL + "?sid=" + server.getId());

        request.setAttribute(GLOBAL_CONFIG_CHANNELS, configChannelsMsg);
        SdcHelper.ssmCheck(request, server.getId(), user);
        setupLastDeploymentInfo(context);
        setupConfigEnablementInfo(context);
        setupLastDiffInfo(context);        
        
        return mapping.findForward("default");
    }

    
    private void setupFiles(RequestContext context,
                                String key,
                                ConfigFileCount info,
                                String url) {
        if (info.getDirectories() == 0 && info.getFiles() == 0) {
            Server server = context.lookupAndBindServer();
            url = ADD_FILES_URL + "?sid=" + server.getId();
        }
        context.getRequest().setAttribute(key, 
                        ConfigActionHelper.makeFileCountsMessage(info, url));
    }    
    

    /**
     * Sets up the info needed for the last diff/compare section 
     * @param context the request context
     */

    private void setupLastDiffInfo(RequestContext context) {
        ConfigurationManager cm = ConfigurationManager.getInstance();

        Server server = context.lookupAndBindServer();
        HttpServletRequest request = context.getRequest();
        LocalizationService service = LocalizationService.getInstance();
        User user = context.getLoggedInUser();
        /**
         * Do the diff action.
         */
        
        Action sysCompare = ActionManager.lookupLastCompletedAction(user,
                                             ActionFactory.TYPE_CONFIGFILES_DIFF,
                                                                server);
        if (sysCompare == null) {
            String url = COMPARE_FILES_URL + "?sid=" + server.getId();
            Object [] params = new Object[] { url };
            request.setAttribute(DIFF_TIME_MESSAGE, "");
            
            request.setAttribute(DIFF_ACTION_MESSAGE,
                                    service.getMessage("sdc.config.diff.noaction",
                                            params));            
        }
        else {
            request.setAttribute(DIFF_TIME_MESSAGE,
                               makeTimeMessage(sysCompare, user, server));
            ConfigFileCount total = cm.countAllActionPaths(server, sysCompare);
            
            ConfigFileCount successful = cm.countSuccessfulCompares
                                                     (server, sysCompare);
            ConfigFileCount differing = cm.countDifferingPaths(server, sysCompare);
            
            
            String url = ACTION_DETAILS_URL +
                            "?hid=" + sysCompare.getId() +
                                    "&sid=" + server.getId();
                
            setupDiffActionMessage(request, total, successful, differing, url);
        }
    }

    /**
     * Sets up the info needed for the last deployment section 
     * @param context the request context
     */
    private void setupLastDeploymentInfo(RequestContext context) {
        LocalizationService service  = LocalizationService.getInstance();
        ConfigurationManager cm = ConfigurationManager.getInstance();

        Server server = context.lookupAndBindServer();
        HttpServletRequest request = context.getRequest();
        User user = context.getLoggedInUser();
        
        ConfigAction ca = (ConfigAction)ActionManager.lookupLastCompletedAction(user,
                                               ActionFactory.TYPE_CONFIGFILES_DEPLOY, 
                                                         server);
        
        if (ca == null) {
            String url = DEPLOY_FILES_URL + "?sid=" + server.getId();
            Object [] params = new Object[] { url };
            request.setAttribute(DEPLOYMENT_TIME_MESSAGE, "");
            
            request.setAttribute(DEPLOYMENT_DETAILS_MESSAGE,
                                    service.getMessage("sdc.config.deploy.noaction",
                                            params));
        }
        else {
            
            request.setAttribute(DEPLOYMENT_TIME_MESSAGE,
                               makeTimeMessage(ca, user, server));
            ConfigFileCount total = cm.countAllActionPaths(server, ca);
            
            ServerAction sa = findServerAction(ca.getServerActions(), server);
            
            Object [] params = new Object[2];

            params[0] = ConfigActionHelper.makeFileCountsMessage(total, 
                                                                null, true);            
            params[1] = ACTION_DETAILS_URL + 
                                "?hid=" + ca.getId() + "&sid=" + server.getId();            
            String messageKey;
            
            if (ActionFactory.STATUS_FAILED.equals(sa.getStatus())) {
                messageKey = "sdc.config.deploy.failure";
            } 
            else {
                messageKey = "sdc.config.deploy.success";
            }

            String msg = service.getMessage(messageKey, params);
            request.setAttribute(DEPLOYMENT_DETAILS_MESSAGE, msg);
        }
    }
    
    private static int getSuffix(long i) {
        if (i == 1) {
            return SINGULAR;
        }
        if (i > 1) {
            return PLURAL;
        }
        
        return NONE;
    }

    private void  setupDiffActionMessage(HttpServletRequest request,
            ConfigFileCount total,
            ConfigFileCount successful,
            ConfigFileCount differing,
            String url) {

        int filesSuffix = getSuffix(total.getFiles());
        int dirsSuffix = getSuffix(total.getDirectories());
        int symlinksSuffix = getSuffix(total.getSymlinks());

        String messageKey = DIFF_ACTION_MESSAGE_PREFIX +
            filesSuffix + "_dirs_" + dirsSuffix + "_symlinks_" + symlinksSuffix;

        List params = new ArrayList();
        // setup the params
        params.add(String.valueOf(successful.getFiles()));
        params.add(String.valueOf(total.getFiles()));
        params.add(String.valueOf(successful.getDirectories()));
        params.add(String.valueOf(total.getDirectories()));
        params.add(String.valueOf(successful.getSymlinks()));
        params.add(String.valueOf(total.getSymlinks()));
        params.add(url);

        LocalizationService service  = LocalizationService.getInstance();
        if (params.isEmpty()) {
            request.setAttribute(DIFF_ACTION_MESSAGE,
                    service.getMessage(messageKey));
        }
        else {
            request.setAttribute(DIFF_ACTION_MESSAGE,
                    service.getMessage(messageKey, params.toArray()));
        }

        if (successful.getFiles() + successful.getSymlinks() > 0) {
            String diffActionKey;
            if (differing.getFiles() + differing.getSymlinks() == 0) {
                diffActionKey = DIFF_DETAIL_MESSAGE_PREFIX + "0";
                request.setAttribute(DIFF_DETAILS_MESSAGE,
                        service.getMessage(diffActionKey));
            }
            else {
                diffActionKey = DIFF_DETAIL_MESSAGE_PREFIX +
                    getSuffix(successful.getFiles() + successful.getSymlinks());
                if (successful.getFiles() + successful.getSymlinks() == 1) {
                    request.setAttribute(DIFF_DETAILS_MESSAGE,
                            service.getMessage(diffActionKey));
                }
                else {
                    Object [] keyParams = new Object[] {
                        String.valueOf(differing.getFiles() + differing.getSymlinks()),
                        String.valueOf(successful.getFiles() + successful.getSymlinks())
                    };
                    request.setAttribute(DIFF_DETAILS_MESSAGE,
                            service.getMessage(diffActionKey, keyParams));
                }
            }

        }
    }

    private String makeTimeMessage(Action action, 
                                        User loggedInUser,
                                        Server server) {
        
        ServerAction sa = findServerAction(action.getServerActions(),
                                                        server);
        assert sa != null : "Could not find a server action," +
                                " that matched the server -[" +
                                server.getId() +
                                "]  to Action-[ " + 
                                action.getId() + 
                                "]";
        String time = StringUtil.categorizeTime(sa.getCompletionTime().getTime(),
                                                    StringUtil.WEEKS_UNITS);
        
        time = "<b>" + time + "</b>";
        LocalizationService service  = LocalizationService.getInstance();
        User scheduledUser = action.getSchedulerUser();
        if (scheduledUser == null) {
            return time; 
        }
        
        
        String url = null;
        if (loggedInUser.getRoles().contains(RoleFactory.ORG_ADMIN)) {
            url = USER_DETAILS_URL + "?uid=" + scheduledUser.getId();
            return service.getMessage("sdc.config.time.message_url",
                                           new Object[] { time,
                                                           url,
                                                           scheduledUser.getLogin()});
        }

        return service.getMessage("sdc.config.time.message_url",
                                    new Object[] { time,
                                                    scheduledUser.getLogin()});
    }
    
    private ServerAction  findServerAction(Set serverActions, 
                                            Server server) {
        for (Iterator itr = serverActions.iterator(); itr.hasNext();) {
            ServerAction sa = (ServerAction) itr.next();
            if (server.equals(sa.getServer())) {
                return sa;
            }
        }
        return null;
    }
    
    private void setupConfigEnablementInfo(RequestContext context) {
        Server server = context.lookupAndBindServer();
        User user  = context.getLoggedInUser();
        ConfigurationManager cm = ConfigurationManager.getInstance();
        context.getRequest().setAttribute(CONFIG_ENABLED, 
                                cm.isConfigEnabled(server, user));
    }
}
