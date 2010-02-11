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
package com.redhat.rhn.frontend.action.systems;

import com.redhat.rhn.common.localization.LocalizationService;
import com.redhat.rhn.domain.errata.ErrataFactory;
import com.redhat.rhn.domain.rhnset.RhnSet;
import com.redhat.rhn.domain.server.Server;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.frontend.action.systems.sdc.SdcHelper;
import com.redhat.rhn.frontend.struts.RequestContext;
import com.redhat.rhn.frontend.struts.RhnAction;
import com.redhat.rhn.frontend.struts.StrutsDelegate;
import com.redhat.rhn.frontend.taglibs.list.helper.ListRhnSetHelper;
import com.redhat.rhn.frontend.taglibs.list.helper.Listable;
import com.redhat.rhn.manager.rhnset.RhnSetDecl;
import com.redhat.rhn.manager.system.SystemManager;

import org.apache.struts.action.ActionForm;
import org.apache.struts.action.ActionForward;
import org.apache.struts.action.ActionMapping;
import org.apache.struts.action.ActionMessage;
import org.apache.struts.action.ActionMessages;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.Iterator;
import java.util.List;
import java.util.Map;
import java.util.Set;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

/**
 * ErrataSetupAction
 * @version $Rev$
 */
public class ErrataSetupAction extends RhnAction implements Listable {
     
    public static final String DISPATCH = "dispatch";
    public static final String LIST_NAME = "errataList";
    
    public static final String ALL = "All";
    public static final String NON_CRITICAL = "errata.updates.noncritical";
    public static final String SECUR = "errata.create.securityadvisory";
    public static final String BUGFIX = "errata.create.bugfixadvisory";
    public static final String ENHANCE = "errata.create.productenhancementadvisory";

    public static final String SELECTOR = "type";



    /** {@inheritDoc} */
    public ActionForward execute(ActionMapping mapping,
                                 ActionForm formIn,
                                 HttpServletRequest request,
                                 HttpServletResponse response) {
        
        RequestContext requestContext = new RequestContext(request);
        User user = requestContext.getLoggedInUser();
        Long sid = requestContext.getRequiredParam("sid");
        RhnSet set = getSetDecl(sid).get(user);  

        

        ListRhnSetHelper help = new ListRhnSetHelper(this, request, getSetDecl(sid));
        help.setListName(LIST_NAME);
        String parentURL = request.getRequestURI() + "?sid=" + sid;
        help.setParentUrl(parentURL);

        help.execute();

        if (help.isDispatched()) {
            if (requestContext.wasDispatched("errata.jsp.apply")) {
                return applyErrata(mapping, formIn, request, response);
            }
        }

        
        String showButton = "true";
        // Show the "Apply Errata" button only when unapplied errata exist:
        if (!SystemManager.hasUnscheduledErrata(user, sid)) {
           showButton = "false";
        }
        





        Map params =  new HashMap();   
        Set keys = request.getParameterMap().keySet();
        for (Iterator i = keys.iterator(); i.hasNext();) {
            String key = (String) i.next();
            params.put(key, request.getParameter(key));
        }
        
        Server server = SystemManager.lookupByIdAndUser(sid, user);
        SdcHelper.ssmCheck(request, server.getId(), user);
        request.setAttribute("showApplyErrata", showButton);
        request.setAttribute("set", set);
        request.setAttribute("system", server);
        request.setAttribute("combo", getComboList(request));
        request.setAttribute(SELECTOR, request.getParameter(SELECTOR));
        
        return getStrutsDelegate().forwardParams(mapping.findForward("default"), params);
    }
    

    private List<Map<String, Object>> getComboList(HttpServletRequest request) {

        String selected = (String) request.getParameter(SELECTOR);

        List<Map<String, Object>> combo = new ArrayList<Map<String, Object>>();

        LocalizationService ls = LocalizationService.getInstance();


        Map<String, Object> tmp = new HashMap<String, Object>();
        tmp.put("name", ALL);
        tmp.put("id", ALL);
        tmp.put("default", ls.getMessage(ALL).equals(selected));

        Map<String, Object> tmp1 = new HashMap<String, Object>();
        tmp1.put("name", NON_CRITICAL);
        tmp1.put("id", NON_CRITICAL);
        tmp1.put("default",  ls.getMessage(NON_CRITICAL).equals(selected));


        Map<String, Object> tmp2 = new HashMap<String, Object>();
        tmp2.put("name", BUGFIX);
        tmp2.put("id", BUGFIX);
        tmp2.put("default",  ls.getMessage(BUGFIX).equals(selected));

        Map<String, Object> tmp3 = new HashMap<String, Object>();
        tmp3.put("name", ENHANCE);
        tmp3.put("id", ENHANCE);
        tmp3.put("default",  ls.getMessage(ENHANCE).equals(selected));

        Map<String, Object> tmp4 = new HashMap<String, Object>();
        tmp4.put("name", SECUR);
        tmp4.put("id", SECUR);
        tmp4.put("default",  ls.getMessage(SECUR).equals(selected));

        combo.add(tmp);
        combo.add(tmp1);
        combo.add(tmp2);
        combo.add(tmp3);
        combo.add(tmp4);
        return combo;

    }


    /**
     * Applies the selected errata
     * @param mapping ActionMapping
     * @param formIn ActionForm
     * @param request ServletRequest
     * @param response ServletResponse
     * @return The ActionForward to go to next.
     */
    public ActionForward applyErrata(ActionMapping mapping,
                                     ActionForm formIn,
                                     HttpServletRequest request,
                                     HttpServletResponse response) {
      
        Map params = new HashMap();
        
        RequestContext requestContext = new RequestContext(request);
        StrutsDelegate strutsDelegate = getStrutsDelegate();
        //if they chose errata, send them to the confirmation page
        Long sid = requestContext.getParamAsLong("sid");
        
        User user = requestContext.getLoggedInUser();
        RhnSet set = getSetDecl(sid).get(user);
        
        //if they chose no errata, return to the same page with a message
        if (set.isEmpty()) {
            ActionMessages msg = new ActionMessages();
            msg.add(ActionMessages.GLOBAL_MESSAGE, 
                    new ActionMessage("errata.applynone"));
            params = makeParamMap(formIn, request);
            strutsDelegate.saveMessages(request, msg);
            return strutsDelegate.forwardParams(mapping.findForward("default"), params);
        }
        
        if (sid != null) {
            params.put("sid", sid);
        }
          
        return strutsDelegate.forwardParams(mapping.findForward("confirm"), params);
    }
    
    /**
     * @return Returns RhnSetDecl.ERRATA
     */
    static RhnSetDecl getSetDecl(Long sid) {
        return RhnSetDecl.ERRATA.createCustom(sid);
    }
    
    /**
     * Makes a parameter map containing request params that need to
     * be forwarded on to the success mapping.
     * @param request HttpServletRequest containing request vars
     * @return Returns Map of parameters
     * TODO: was private
     */
    protected Map makeParamMap(ActionForm form, HttpServletRequest request) {

        RequestContext rctx = new RequestContext(request);
        Map params = rctx.makeParamMapWithPagination();
        Long sid = new RequestContext(request).getParamAsLong("sid");
        if (sid != null) {
            params.put("sid", sid);
        }
        return params;
    }


    /**
     *
     * {@inheritDoc}
     */
    public List getResult(RequestContext context) {
         User user = context.getLoggedInUser();
         Long sid = context.getRequiredParam("sid");
         String type = context.getParam(SELECTOR, false);

         LocalizationService ls = LocalizationService.getInstance();

         List<String> typeList = new ArrayList<String>();

         if (ls.getMessage(BUGFIX).equals(type)) {
             typeList.add(ErrataFactory.ERRATA_TYPE_BUG);
         }
         else if (ls.getMessage(SECUR).equals(type)) {
             typeList.add(ErrataFactory.ERRATA_TYPE_SECURITY);
         }
         else if (ls.getMessage(ENHANCE).equals(type)) {
             typeList.add(ErrataFactory.ERRATA_TYPE_ENHANCEMENT);
         }
         else if (ls.getMessage(NON_CRITICAL).equals(type)) {
             typeList.add(ErrataFactory.ERRATA_TYPE_BUG);
             typeList.add(ErrataFactory.ERRATA_TYPE_ENHANCEMENT);
         }
         else {
             typeList.add(ErrataFactory.ERRATA_TYPE_BUG);
             typeList.add(ErrataFactory.ERRATA_TYPE_ENHANCEMENT);
             typeList.add(ErrataFactory.ERRATA_TYPE_SECURITY);
         }

        return SystemManager.relevantErrata(user, sid, typeList);
    }

}
