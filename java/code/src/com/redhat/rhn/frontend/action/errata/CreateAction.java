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
package com.redhat.rhn.frontend.action.errata;

import com.redhat.rhn.domain.errata.Bug;
import com.redhat.rhn.domain.errata.Errata;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.frontend.struts.RequestContext;
import com.redhat.rhn.frontend.struts.RhnAction;
import com.redhat.rhn.frontend.struts.RhnValidationHelper;
import com.redhat.rhn.frontend.struts.StrutsDelegate;
import com.redhat.rhn.manager.errata.ErrataManager;

import org.apache.struts.action.ActionErrors;
import org.apache.struts.action.ActionForm;
import org.apache.struts.action.ActionForward;
import org.apache.struts.action.ActionMapping;
import org.apache.struts.action.ActionMessage;
import org.apache.struts.action.ActionMessages;
import org.apache.struts.action.DynaActionForm;

import java.util.Arrays;
import java.util.Date;
import java.util.Iterator;
import java.util.List;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

/**
 * CreateAction
 * @version $Rev$
 */
public class CreateAction extends RhnAction {

    /**
     * {@inheritDoc}
     */
    public ActionForward execute(ActionMapping mapping,
                                 ActionForm formIn,
                                 HttpServletRequest request,
                                 HttpServletResponse response) {
        DynaActionForm form = (DynaActionForm) formIn;

        RequestContext requestContext = new RequestContext(request);
        StrutsDelegate strutsDelegate = getStrutsDelegate();

        //Validate the form to make sure everything was filled out correctly
        ActionErrors errors = RhnValidationHelper.validateDynaActionForm(this, form);

        String advisoryNameFromForm = form.getString("advisoryName");
        //Make sure advisoryName is unique
        if (!ErrataManager.advisoryNameIsUnique(null, advisoryNameFromForm)) {
            errors.add(ActionMessages.GLOBAL_MESSAGE,
                       new ActionMessage("errata.edit.error.uniqueAdvisoryName"));
        }
        // Make sure advisoryName does not begin with RH
        if (advisoryNameFromForm.toUpperCase().startsWith("RH")) {
            errors.add(ActionMessages.GLOBAL_MESSAGE,
                       new ActionMessage("errata.edit.error.rhAdvisoryName"));
        }
        if (!errors.isEmpty()) { // We've got errors. Forward to failure mapping.
            addErrors(request, errors);
            return mapping.findForward("failure");
        }

        //Create a new unpublished errata
        Errata e = ErrataManager.createNewErrata();
        e.setSynopsis(form.getString("synopsis"));
        e.setAdvisoryName(form.getString("advisoryName"));
        e.setAdvisoryRel(new Long(form.getString("advisoryRelease")));
        e.setAdvisoryType(form.getString("advisoryType"));
        e.setProduct(form.getString("product"));

        //Advisory = advisoryName-advisoryRelease
        e.setAdvisory(form.getString("advisoryName") + "-" +
                      form.getString("advisoryRelease"));

        //create a bug and add it to the set
        Bug bug = createBug(form);
        if (bug != null) {
            e.addBug(bug);
        }
        e.setTopic(form.getString("topic"));
        e.setDescription(form.getString("description"));
        e.setSolution(form.getString("solution"));

        //add keywords... split on commas and add separately to list
        String keywordsField = form.getString("keywords");
        if (keywordsField != null) {
            List keywords = Arrays.asList(keywordsField.split(","));
            Iterator keywordItr = keywords.iterator();
            while (keywordItr.hasNext()) {
                String keyword = (String) keywordItr.next();
                keyword = keyword.trim();
                if (keyword != null && keyword.length() > 0) {
                    e.addKeyword(keyword);
                }
            }
        }
        e.setRefersTo(form.getString("refersTo"));
        e.setNotes(form.getString("notes"));

        //Set issueDate to now
        Date date = new Date(System.currentTimeMillis());
        e.setIssueDate(date);
        e.setUpdateDate(date);

        //Set the org for the errata to the logged in user's org
        User user = requestContext.getLoggedInUser();
        e.setOrg(user.getOrg());

        ErrataManager.storeErrata(e);

        ActionMessages msgs = new ActionMessages();
        msgs.add(ActionMessages.GLOBAL_MESSAGE,
                 new ActionMessage("errata.created",
                                   e.getAdvisoryName(),
                                   e.getAdvisoryRel().toString()));
        saveMessages(request, msgs);
        return strutsDelegate.forwardParam(mapping.findForward("success"),
                                      "eid",
                                      e.getId().toString());
    }

    /**
     * Helper method to create a new bug from a form
     * @param form the form containing the bug items
     * @return Returns a new bug.
     */
    private Bug createBug(DynaActionForm form) {
        //if id and summary are not null, we can create a new bug, otherwise return null
        if (form.getString("buglistId").length() > 0 &&
            form.getString("buglistSummary").length() > 0) {
            Long id = new Long(form.getString("buglistId"));
            String summary = form.getString("buglistSummary");
            return ErrataManager.createNewUnpublishedBug(id, summary);
        }
        else {
            return null;
        }
    }
}
