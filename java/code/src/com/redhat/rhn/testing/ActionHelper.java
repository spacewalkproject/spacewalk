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
package com.redhat.rhn.testing;

import com.redhat.rhn.common.util.MethodUtil;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.frontend.struts.RequestContext;
import com.redhat.rhn.frontend.struts.RhnHelper;
import com.redhat.rhn.frontend.taglibs.list.ListTagUtil;
import com.redhat.rhn.frontend.taglibs.list.TagHelper;
import com.redhat.rhn.manager.user.UserManager;

import org.apache.struts.action.Action;
import org.apache.struts.action.ActionForward;
import org.apache.struts.action.ActionMapping;

import java.util.Locale;

import junit.framework.Assert;

/**
 * ActionHelper - abstract base class that can be used to setup
 * tests to verify our struts Actions.
 * @version $Rev$
 */
public class ActionHelper extends Assert {
    
    private ActionMapping mapping;
    private ActionForward success;
    private Action action;
    private RhnMockDynaActionForm form;
    private RhnMockHttpServletRequest request;
    private RhnMockHttpServletResponse response;
    private User user;

    /**
     * Setup the Action with the proper Request, Form, Response, etc...
     * 
     * @param actionIn The Action we want to setup to test.
     * @throws Exception if error occurs setting up the Action.
     */
     public void setUpAction(Action actionIn) throws Exception {
         setUpAction(actionIn, "default");
     }
    
    /**
    * Setup the Action with the proper Request, Form, Response.  With this version
    * of the method we allow the caller to specify the expected name of the Forward
    * the Action should generate.
    * 
    * @param actionIn The Action we want to setup to test.
    * @param expectedForwardName expected name of the forward you want the Action 
    *        to generate.
    * @throws Exception if error occurs setting up the Action.
    */
    public void setUpAction(Action actionIn, String expectedForwardName) throws Exception {
        action = actionIn;
        mapping = new ActionMapping();
        setExpectedForward(expectedForwardName);
        form = new RhnMockDynaActionForm();
        request = TestUtils.getRequestWithSessionAndUser();
        request.setLocale(Locale.getDefault());
        response = new RhnMockHttpServletResponse();
        
        RequestContext requestContext = new RequestContext(request);

        user = UserManager.lookupUser(requestContext.getLoggedInUser(), 
                requestContext.getParamAsLong("uid"));
        request.setAttribute(RhnHelper.TARGET_USER, user);
        // we have to get the actual user here so we can call setupAddParamter
        // a second time.  The MockRequest counts the number of times getParamter
        // is called.
        request.setupAddParameter("uid", user.getId().toString());
        
    }
    
    /**
     * Execute the Action and check for success.  
     * @param methodName the name of the method you want to execute 
     * in the Action.  If not specified, will call execute()
     * @throws Exception if error occurs executing Action.
     * @return ActionForward the ActionForward the Action gave us.  Can be 
     * examined to assert its state and make sure things were returned properly
     */
    public ForwardWrapper executeAction(String methodName) throws Exception {
        return executeAction(methodName, true);
    }
    
    /**
     * Execute the Action and check for success.  
     * @param methodName the name of the method you want to execute 
     * in the Action.  If not specified, will call execute()
     * @param successCheck validate expected ActionForward here
     * @throws Exception if error occurs executing Action.
     * @return ActionForward the ActionForward the Action gave us.  Can be 
     * examined to assert its state and make sure things were returned properly
     */
    public ForwardWrapper executeAction(String methodName, boolean successCheck) 
                         throws Exception {
        
        ActionForward rc = null;
        // Here we dynamically call the dispatch method
        if (methodName != null) {
            Object[] params = new Object[4];
            params[0] = mapping;
            params[1] = form;
            params[2] = request;
            params[3] = response;
            rc = (ActionForward) MethodUtil.callMethod(action, methodName, params);
        } 
        else {
            rc = action.execute(mapping, form, request, response);    
        }
        
        // We can only test the name and the path
        // startswith because an Action might add 
        // a param to the path.
        if (successCheck) {
            assertEquals(success.getName(), rc.getName());
            assertTrue(rc.getPath().startsWith("path"));
        }
        return new ForwardWrapper(rc);
    }

    /**
     * Execute the Action and check for success
     * @throws Exception if error occurs executing Action.
     * @return ActionForward the ActionForward the Action gave us.  Can be 
     * examined to assert its state and make sure things were returned properly
     */
    public ForwardWrapper executeAction() throws Exception {
        return executeAction(null);
    }
    
    /**
     * Get the response used by the helper.
     * @return response used
     */
    public RhnMockHttpServletResponse getResponse() {
        return response;
    }
    /**
    * Get the Request associated with this test
    * @return RhnMockHttpServletRequest used.
    */
    public RhnMockHttpServletRequest getRequest() {
        return request;
    }

    /**
    * Get the Form associated with this test
    * @return RhnMockDynaActionForm used.
    */
    public RhnMockDynaActionForm getForm() {
        return form;
    }
    
    /**
    * Get the User associated with this test
    * @return User used.
    */
    public User getUser() {
        return user;
    }
    
    /**
     * Return the ActionMapping used by the Action
     * @return ActionMapping used to execute the Action
     */
    public ActionMapping getMapping() {
        return mapping;
    }

    /**
     * Necessary setup for an action that calls 
     * {@link com.redhat.rhn.frontend.struts.RhnListAction#clampListBounds 
     * clampListBounds}. Declares necessary request parameters and sets
     * them to moderately bogus values.
     */
    public void setupClampListBounds() {
        setupClampListBounds("");
    }
    
    /**
     * Necessary setup for an action that calls 
     * {@link com.redhat.rhn.frontend.struts.RhnListAction#clampListBounds 
     * clampListBounds}. Declares necessary request parameters and sets
     * them to moderately bogus values.  This version allows you to specify 
     * a filter string.
     * @param filterString the filter string we want to test out.
     */
    public void setupClampListBounds(String filterString) {
        getRequest().setupAddParameter(RequestContext.LIST_DISPLAY_EXPORT, "0");
        getRequest().setupAddParameter(RequestContext.FILTER_STRING, filterString);
        getRequest().setupAddParameter(RequestContext.PREVIOUS_FILTER_STRING, filterString);
        getRequest().setupAddParameter("newset", (String)null);
        getRequest().setupAddParameter("returnvisit", (String) null);
        setupProcessPagination();
    }

    /**
     * Setup request parameters that are often used by 
     * listview Actions.
     */
    public void setupProcessPagination() {
        getRequest().setupAddParameter("First", "someValue");
        getRequest().setupAddParameter("first_lower", "10");
        getRequest().setupAddParameter("Prev", "0");
        getRequest().setupAddParameter("prev_lower", "");
        getRequest().setupAddParameter("Next", "20");
        getRequest().setupAddParameter("next_lower", "");
        getRequest().setupAddParameter("Last", "");
        getRequest().setupAddParameter("last_lower", "20");
        getRequest().setupAddParameter("lower", "10");
    }
    
    
    /**
     * Setup the request parameters for ListSelection
     * @param listName The name of the list, from 
     *  com.redhat.rhn.frontend.taglibs.list.ListTag
     */
    public void setupListSelection(String listName) {
        String uniqueName = TagHelper.generateUniqueName(listName);
        String selectAction = ListTagUtil.makeSelectActionName(uniqueName);
        String sel = ListTagUtil.makeSelectedItemsName(uniqueName);
        String items = ListTagUtil.makePageItemsName(uniqueName);
        getRequest().setupAddParameter(selectAction, (String)null);
        getRequest().setupAddParameter(sel, (String)null);
        getRequest().setupAddParameter(items, (String)null);
        
    }
    
    /**
     * Sets the expected forward to an ActionForward with the
     * specified name and adds this forward to the mapping
     * @param name The name of the expected forward
     */
    public void setExpectedForward(String name) {
        success = new ActionForward(name, "path", false);
        mapping.addForwardConfig(success);
    }
    
}
