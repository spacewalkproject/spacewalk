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
import com.redhat.rhn.domain.org.Org;
import com.redhat.rhn.frontend.struts.RequestContext;
import com.redhat.rhn.frontend.struts.RhnAction;
import com.redhat.rhn.frontend.struts.RhnHelper;
import com.redhat.rhn.frontend.struts.RhnValidationHelper;
import com.redhat.rhn.manager.channel.repo.CreateRepoCommand;


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
    public static final String OLD_LABEL = "oldLabel";

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
                                "repos.jsp.create.success", repo.getLabel());
                    }
                    else {
                        createSuccessMessage(request,
                                "repos.jsp.update.success", repo.getLabel());
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


    private void setupRepo(HttpServletRequest request, DynaActionForm form,
            ContentSource repo) {

        form.set(LABEL, repo.getLabel());
        form.set(OLD_LABEL, repo.getLabel());
        form.set(URL, repo.getSourceUrl());
        bindRepo(request, repo);
        request.setAttribute(ORG, repo.getOrg());
    }

    /**
     * Method to bind the repo to a request
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
        String url = form.getString(URL);
        Org org = context.getLoggedInUser().getOrg();

        CreateRepoCommand repoCmd = new CreateRepoCommand(label, url, org);
        repoCmd.store();

        return repoCmd.getNewRepo();
    }
}
