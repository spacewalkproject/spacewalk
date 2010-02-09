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
package com.redhat.rhn.frontend.action.kickstart.cobbler;

import com.redhat.rhn.common.validator.ValidatorException;
import com.redhat.rhn.common.validator.ValidatorResult;
import com.redhat.rhn.domain.kickstart.cobbler.CobblerSnippet;
import com.redhat.rhn.frontend.action.common.BadParameterException;
import com.redhat.rhn.frontend.struts.RequestContext;
import com.redhat.rhn.frontend.struts.RhnAction;
import com.redhat.rhn.frontend.struts.RhnHelper;
import com.redhat.rhn.frontend.struts.RhnValidationHelper;

import org.apache.log4j.Logger;
import org.apache.struts.action.ActionForm;
import org.apache.struts.action.ActionForward;
import org.apache.struts.action.ActionMapping;
import org.apache.struts.action.DynaActionForm;

import java.util.HashMap;
import java.util.Map;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;


/**
 * CobblerSnippetDetailsAction
 * @version $Rev$
 */
public class CobblerSnippetDetailsAction extends RhnAction {
    private static final Logger LOG = 
                Logger.getLogger(CobblerSnippetDetailsAction.class);
    public static final String PREFIX = "prefix";
    public static final String NAME = "name";
    public static final String OLD_NAME = "oldName";
    public static final String ORG = "org";
    public static final String CONTENTS = "contents";
    public static final String CREATE_MODE = "create_mode";
    public static final String SNIPPET = "snippet";

    private static final String VALIDATION_XSD =
                "/com/redhat/rhn/frontend/action/kickstart/" +
                        "cobbler/validation/cobblerSnippetsForm.xsd";    
    /** {@inheritDoc} */
    public ActionForward execute(ActionMapping mapping,
                                  ActionForm formIn,
                                  HttpServletRequest request,
                                  HttpServletResponse response) {
        DynaActionForm form = (DynaActionForm) formIn;
        RequestContext ctx = new RequestContext(request);
        
        request.setAttribute(mapping.getParameter(), Boolean.TRUE);
        
        if (ctx.isSubmitted()) {
            
            
            ValidatorResult result = RhnValidationHelper.validate(this.getClass(), 
                            makeValidationMap(form), null, 
                                VALIDATION_XSD);
            if (!result.isEmpty()) {
                getStrutsDelegate().saveMessages(request, result);
                RhnValidationHelper.setFailedValidation(request);
            }
            else {
                try {
                    CobblerSnippet snip = submit(request, form);
                    if (isCreateMode(request)) {
                        createSuccessMessage(request, 
                                "cobblersnippet.create.success", snip.getName());
                    }
                    else {
                        createSuccessMessage(request, 
                                "cobblersnippet.update.success", snip.getName());
                    }
                    
                    request.removeAttribute(CREATE_MODE);
                    setupSnippet(request, form, snip);
                    return getStrutsDelegate().forwardParam(mapping.findForward("success"),
                                        NAME, snip.getName());
                }
                catch (ValidatorException ve) {
                    getStrutsDelegate().saveMessages(request, ve.getResult());
                    RhnValidationHelper.setFailedValidation(request);
                }                
            }
        }
        setup(request, form);    
        return mapping.findForward(RhnHelper.DEFAULT_FORWARD);
    }

    private Map makeValidationMap(DynaActionForm form) {
        Map map = new HashMap();
        map.put(NAME, form.getString(NAME));
        map.put(OLD_NAME, form.getString(OLD_NAME));
        map.put(CONTENTS, form.getString(CONTENTS));
        return map;
    }

    
    private boolean isCreateMode(HttpServletRequest request) {
        return Boolean.TRUE.equals(request.getAttribute(CREATE_MODE));
    }
    
    
    private void setup(HttpServletRequest request, DynaActionForm form) {
        RequestContext context = new RequestContext(request);
        if (isCreateMode(request)) {
            request.setAttribute(PREFIX, CobblerSnippet.getPrefixFor(
                            context.getLoggedInUser().getOrg()));
        }
        else {
            String param = NAME;
            if (!isCreateMode(request) && RhnValidationHelper.
                                        getFailedValidation(request)) {
                param = OLD_NAME;
            }
            CobblerSnippet snip = loadEditableSnippet(request, param);
            setupSnippet(request, form, snip);
        }
    }

    /**
     * Helper method to get a cobbler snippet.. This code is in this 
     * action because we need it to throw a "BadParameterException" 
     * if the set up complains... Also it gets info from the request object
     * so this is the right place...
     * @param request  the request
     * @param lookupParam the parameter to which the snippet name is bound.. 
     * @return the cobbler snippet parameter "name"
     */
    private static CobblerSnippet loadEditableSnippet(HttpServletRequest request, 
                                    String lookupParam) {
        RequestContext context = new RequestContext(request);
        try {
            String name = context.getParam(lookupParam, true);
            return  CobblerSnippet.loadEditable(name, 
                        context.getLoggedInUser().getOrg());
        }
        catch (ValidatorException ve) {
            LOG.error(ve);
            throw new BadParameterException(
                    "The parameter " + NAME + " is required.");
        }        
    }

    
    /**
     * Helper method to get a cobbler snippet.. This code is in this 
     * action because we need it to throw a "BadParameterException" 
     * if the set up complains... Also it gets info from the request object
     * so this is the right place...
     * @param request  the request
     * @return the cobbler snippet parameter "name"
     */
    static CobblerSnippet loadEditableSnippet(HttpServletRequest request) {
        return loadEditableSnippet(request, NAME);
    }
    
    private void setupSnippet(HttpServletRequest request, DynaActionForm form,
            CobblerSnippet snip) {
        request.setAttribute(PREFIX, snip.getPrefix());
        form.set(NAME, snip.getName());
        form.set(OLD_NAME, snip.getName());
        form.set(CONTENTS, snip.getContents());
        bindSnippet(request, snip);
        request.setAttribute(ORG, snip.getOrg().getName());
    }

    /**
     * Method to bind the cobbler snippet to a request
     * @param request the servlet request
     * @param snip the snippet to bind
     */
    public static void bindSnippet(HttpServletRequest request, CobblerSnippet snip) {
        request.setAttribute(SNIPPET, snip);        
    }
    
    private CobblerSnippet submit(HttpServletRequest request, DynaActionForm form) {
        RequestContext context = new RequestContext(request);
        String name = isCreateMode(request) ? 
                    form.getString(NAME) : form.getString(OLD_NAME);
        
        
        CobblerSnippet snip = CobblerSnippet.createOrUpdate(
                isCreateMode(request),
                name,
                form.getString(CONTENTS), 
                context.getLoggedInUser().getOrg());
        if (!isCreateMode(request) &&  
                !form.getString(NAME).equals(form.getString(OLD_NAME))) {
            snip.rename(form.getString(NAME));
        }
        return snip;
    }
}
