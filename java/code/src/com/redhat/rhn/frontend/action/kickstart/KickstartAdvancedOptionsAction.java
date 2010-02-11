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
package com.redhat.rhn.frontend.action.kickstart;

import com.redhat.rhn.common.util.MD5Crypt;
import com.redhat.rhn.domain.kickstart.KickstartCommand;
import com.redhat.rhn.domain.kickstart.KickstartCommandName;
import com.redhat.rhn.domain.kickstart.KickstartFactory;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.frontend.struts.RequestContext;
import com.redhat.rhn.frontend.struts.RhnAction;
import com.redhat.rhn.manager.kickstart.KickstartOptionsCommand;

import org.apache.log4j.Logger;
import org.apache.struts.action.ActionErrors;
import org.apache.struts.action.ActionForm;
import org.apache.struts.action.ActionForward;
import org.apache.struts.action.ActionMapping;
import org.apache.struts.action.ActionMessage;
import org.apache.struts.action.ActionMessages;

import java.util.Date;
import java.util.HashSet;
import java.util.Iterator;
import java.util.LinkedList;
import java.util.List;
import java.util.Set;
import java.util.StringTokenizer;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

/**
 * KickstartAdvancedOptions extends RhnAction
 * @version $Rev: 1 $
 */
public class KickstartAdvancedOptionsAction extends RhnAction {

    /**
     * Logger for this class
     */
    private static Logger log = Logger
            .getLogger(KickstartAdvancedOptionsAction.class);

    public static final String OPTIONS = "options";
    public static final String CUSTOM_OPTIONS = "customOptions";
    private static final String NEWLINE = "\n";
    
    /**
     * 
     * {@inheritDoc}
     */
    public final ActionForward execute(ActionMapping mapping,
            ActionForm formIn,
            HttpServletRequest request,
            HttpServletResponse response) {
        
        RequestContext ctx = new RequestContext(request);        
        KickstartHelper helper = new KickstartHelper(request);
        KickstartOptionsCommand cmd = 
            new KickstartOptionsCommand(ctx.getRequiredParam(RequestContext.KICKSTART_ID),
                                        ctx.getCurrentUser());
         
        List displayList = new LinkedList();
        
        //Display message if this kickstart profile's channel is inadequate.
        User user = new RequestContext(request).getLoggedInUser();
        if (!helper.verifyKickstartChannel(cmd.getKickstartData(), user)) {
            getStrutsDelegate().saveMessages(request,
                   helper.createInvalidChannelMsg(cmd.getKickstartData()));
        }
        
        // store/refresh the submitted data
        if (request.getParameter(SUBMITTED) != null) {    
            
            ActionErrors messages = new ActionErrors();
            
            //lets first make sure all required params are set                        
            for (Iterator it = cmd.getRequiredOptions().iterator(); it.hasNext();) {
                KickstartCommandName cn = (KickstartCommandName) it.next();
                if (request.getParameter(cn.getName()) == null) {
                    messages.add(ActionMessages.GLOBAL_MESSAGE,
                            new ActionMessage("errors.required", cn.getName()));
                }
            }
            
            // store to the db
            if (messages.isEmpty()) {
                Set s = new HashSet();
                                
                for (Iterator itr = cmd.getAvailableOptions().iterator(); itr.hasNext();) {
                    
                    KickstartCommandName cn = (KickstartCommandName) itr.next();
                    
                    if (request.getParameter(cn.getName()) != null) {
                        KickstartCommand kc = new KickstartCommand();
                        kc.setCommandName(cn);
                        kc.setKickstartData(cmd.getKickstartData());
                        kc.setCreated(new Date());
                        kc.setModified(new Date());                        
                        if (cn.getArgs().booleanValue()) {
                            String argsName = cn.getName() + "_txt";
                            // handle password encryption
                            if (cn.getName().equals("rootpw")) {
                                String pwarg = request.getParameter(argsName);
                                // password already encrypted
                                if (pwarg.startsWith("$1$")) {
                                    kc.setArguments(pwarg);
                                }
                                // password changed, encrypt it 
                                else {
                                    kc.setArguments(MD5Crypt.crypt(pwarg));
                                }
                            }
                            else {
                                kc.setArguments(request.getParameter(argsName));
                            }
                        }
                        s.add(kc);
                    }                
                }
                log.debug("updating options");
                cmd.getKickstartData().setOptions(s);

                //set custom options
                String customOps = request.getParameter(CUSTOM_OPTIONS);
                Set customSet = new HashSet();
                log.debug("Adding custom options");
                if (customOps != null) {
                    for (StringTokenizer strtok = new StringTokenizer(
                            customOps, NEWLINE); strtok.hasMoreTokens();) {
                        KickstartCommand custom = new KickstartCommand();
                        custom.setCommandName(KickstartFactory
                                .lookupKickstartCommandName("custom"));
                        custom.setArguments(strtok.nextToken());
                        custom.setKickstartData(cmd.getKickstartData());
                        custom.setCustomPosition(customSet.size());
                        custom.setCreated(new Date());
                        custom.setModified(new Date());
                        customSet.add(custom);
                    }
                    log.debug("Clearing custom options");
                    cmd.getKickstartData().setCustomOptions(customSet);
                    log.debug("Adding all");
                }

                cmd.store();
                log.debug("stored.");
                displayList = cmd.getDisplayOptions(); //refresh after storing
                createSuccessMessage(request, getSuccessKey(), null);
            }
            else {
                // refresh the list to display to user and show error msgs
                displayList = cmd.refreshOptions(request.getParameterMap());
                addErrors(request, messages);
            }                                                                        
        }
        else {
            displayList = cmd.getDisplayOptions();
        }
        

        request.setAttribute(RequestContext.KICKSTART, cmd.getKickstartData());
        request.setAttribute(OPTIONS, displayList);
        request.setAttribute(CUSTOM_OPTIONS, cmd.getKickstartData().getCustomOptions());

        return getStrutsDelegate().forwardParams(mapping.findForward("default"),
                request.getParameterMap());
       
    }    
    
    /**
     * 
     * @return i18n key
     */
    private String getSuccessKey() {
        return "kickstart.options.success";        
    }   
        
}
