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
package com.redhat.rhn.frontend.action.channel.manage.repo;

import java.util.HashMap;
import java.util.Map;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.apache.log4j.Logger;
import org.apache.struts.action.ActionForm;
import org.apache.struts.action.ActionForward;
import org.apache.struts.action.ActionMapping;
import org.apache.struts.action.DynaActionForm;

import com.redhat.rhn.common.validator.ValidatorException;
import com.redhat.rhn.common.validator.ValidatorResult;
import com.redhat.rhn.domain.channel.ContentSource;
import com.redhat.rhn.domain.kickstart.cobbler.CobblerSnippet;
import com.redhat.rhn.frontend.action.common.BadParameterException;
import com.redhat.rhn.frontend.struts.RequestContext;
import com.redhat.rhn.frontend.struts.RhnAction;
import com.redhat.rhn.frontend.struts.RhnHelper;
import com.redhat.rhn.frontend.struts.RhnValidationHelper;


/**
 * CobblerSnippetDetailsAction
 * @version $Rev$
 */
public class RepoDetailsAction extends RhnAction {
    private static final Logger LOG =
                Logger.getLogger(RepoDetailsAction.class);
    public static final String ORG = "org";
    public static final String CREATE_MODE = "create_mode";
    public static final String REPO = "repo";
    public static final String URL = "url";
    public static final String LABEL = "label";
    public static final String OLD_LABEL = "old_label";

    private static final String VALIDATION_XSD =
                "/com/redhat/rhn/frontend/action/channel/" +
                        "manage/repo/validation/repoForm.xsd";
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
                    ContentSource repo = submit(request, form);
                    if (isCreateMode(request)) {
                        createSuccessMessage(request,
                                "repo.create.success", repo.getLabel());
                    }
                    else {
                        createSuccessMessage(request,
                                "repo.update.success", repo.getLabel());
                    }

                    request.removeAttribute(CREATE_MODE);
                    setupRepo(request, form, repo);
                    return getStrutsDelegate().forwardParam(mapping.findForward("success"),
                                        LABEL, repo.getLabel());
                }
                catch (ValidatorException ve) {
                    getStrutsDelegate().saveMessages(request, ve.getResult());
                    RhnValidationHelper.setFailedValidation(request);
                }
            }
        }

        return mapping.findForward(RhnHelper.DEFAULT_FORWARD);
    }

    private Map<String,String> makeValidationMap(DynaActionForm form) {
        Map<String,String> map = new HashMap<String,String>();
        map.put(LABEL, form.getString(LABEL));
        map.put(URL, form.getString(URL));
        return map;
    }

    private boolean isCreateMode(HttpServletRequest request) {
        return Boolean.TRUE.equals(request.getAttribute(CREATE_MODE));
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
                    "The parameter " + LABEL + " is required.");
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
    static CobblerSnippet loadEditableRepo(HttpServletRequest request) {
        return loadEditableSnippet(request, LABEL);
    }

    private void setupRepo(HttpServletRequest request, DynaActionForm form,
            ContentSource repo) {

        form.set(LABEL, repo.getLabel());
        form.set(OLD_LABEL, repo.getLabel());
        form.set(URL, repo.getSourceUrl());
        bindRepo(request, repo);
        request.setAttribute(ORG, repo.getOrg());
    }

    /**
     * Method to bind the cobbler snippet to a request
     * @param request the servlet request
     * @param snip the snippet to bind
     */
    public static void bindRepo(HttpServletRequest request, ContentSource repo) {
        request.setAttribute(REPO, repo);
    }

    private ContentSource submit(HttpServletRequest request, DynaActionForm form) {
        RequestContext context = new RequestContext(request);
        String label = isCreateMode(request) ?
                    form.getString(LABEL) : form.getString(OLD_LABEL);

        /*
        CobblerSnippet snip = CobblerSnippet.createOrUpdate(
                isCreateMode(request),
                name,
                form.getString(CONTENTS),
                context.getLoggedInUser().getOrg());
        if (!isCreateMode(request) &&
                !form.getString(NAME).equals(form.getString(OLD_NAME))) {
            snip.rename(form.getString(NAME));
        }
        */
        return null;
    }
}
