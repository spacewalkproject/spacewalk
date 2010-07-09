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

import com.redhat.rhn.common.hibernate.HibernateFactory;
import com.redhat.rhn.common.hibernate.HibernateRuntimeException;
import com.redhat.rhn.common.localization.LocalizationService;
import com.redhat.rhn.common.util.StringUtil;
import com.redhat.rhn.domain.errata.Errata;
import com.redhat.rhn.frontend.action.common.BadParameterException;
import com.redhat.rhn.frontend.struts.RequestContext;
import com.redhat.rhn.frontend.struts.RhnValidationHelper;
import com.redhat.rhn.frontend.struts.StrutsDelegate;
import com.redhat.rhn.manager.errata.ErrataManager;

import org.apache.commons.collections.IteratorUtils;
import org.apache.commons.lang.StringUtils;
import org.apache.struts.action.ActionErrors;
import org.apache.struts.action.ActionForm;
import org.apache.struts.action.ActionForward;
import org.apache.struts.action.ActionMapping;
import org.apache.struts.action.ActionMessage;
import org.apache.struts.action.ActionMessages;
import org.apache.struts.action.DynaActionForm;
import org.apache.struts.actions.LookupDispatchAction;
import org.hibernate.HibernateException;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.HashMap;
import java.util.HashSet;
import java.util.Iterator;
import java.util.List;
import java.util.Map;
import java.util.Set;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

/**
 * EditAction
 * @version $Rev$
 */
public class EditAction extends LookupDispatchAction {

    private StrutsDelegate getStrutsDelegate() {
        return StrutsDelegate.getInstance();
    }

    /**
     * This method acts as the default if the dispatch parameter is not in the map
     * It also represents the SetupAction
     * @param mapping ActionMapping
     * @param formIn ActionForm
     * @param request HttpServletRequest
     * @param response HttpServletResponse
     * @return ActionForward, the forward for the jsp
     */
    public ActionForward unspecified(ActionMapping mapping,
                                     ActionForm formIn,
                                     HttpServletRequest request,
                                     HttpServletResponse response) {

        RequestContext requestContext = new RequestContext(request);
        Errata errata = requestContext.lookupErratum();

        DynaActionForm form = (DynaActionForm) formIn;

        String keywordDisplay = StringUtil.join(
                LocalizationService.getInstance().getMessage("list delimiter"),
                IteratorUtils.getIterator(errata.getKeywords()));

        //pre-populate form with current values
        form.set("synopsis", errata.getSynopsis());
        form.set("advisoryName", errata.getAdvisoryName());
        form.set("advisoryRelease", errata.getAdvisoryRel().toString());
        form.set("advisoryType", errata.getAdvisoryType());
        form.set("advisoryTypeLabels", ErrataManager.advisoryTypeLabels());
        form.set("product", errata.getProduct());
        form.set("topic", errata.getTopic());
        form.set("description", errata.getDescription());
        form.set("solution", errata.getSolution());
        form.set("refersTo", errata.getRefersTo());
        form.set("notes", errata.getNotes());
        form.set("keywords", keywordDisplay);

        return setupPage(request, mapping, errata);
    }

    /**
     * This method sets up the page for view
     * @param request HttpServletRequest
     * @param mapping ActionMapping
     * @param errata The errata being edited
     * @return ActionForward the default forward
     */
    public ActionForward setupPage(HttpServletRequest request, ActionMapping mapping,
                                   Errata errata) {

        //What type of errata is this? we need to set isPublished
        if (errata.isPublished()) {
        request.setAttribute("isPublished", "true");
        }
        else {
        request.setAttribute("isPublished", "false");
        }
        //set the list of bugs
        request.setAttribute("bugs", errata.getBugs());
        //set advisory for toolbar
        request.setAttribute("advisory", errata.getAdvisory());
        //set advisoryTypes list for select drop down
        request.setAttribute("advisoryTypes", ErrataManager.advisoryTypes());

        return mapping.findForward("default");
    }

    /**
     * This method handles changing an UnpublishedErrata to a PublishedErrata
     * @param mapping Action mapping
     * @param formIn Form
     * @param request The request
     * @param response The response
     * @return Returns an ActionForward for either published or failure
     */
    public ActionForward publish(ActionMapping mapping,
                                 ActionForm formIn,
                                 HttpServletRequest request,
                                 HttpServletResponse response) {
        //forward to the channels page so user can associate channels
        //with this errata.
        return getStrutsDelegate().forwardParam(mapping.findForward("published"),
                "eid", request.getParameter("eid"));
    }

    /**
     * Sends a notification
     * @param mapping Action mapping
     * @param formIn Form
     * @param request The request
     * @param response The response
     * @return Returns an ActionForward for either notified or failure
     */
    public ActionForward notify(ActionMapping mapping,
                                ActionForm formIn,
                                HttpServletRequest request,
                                HttpServletResponse response) {
        //forward to notify page with eid
        return getStrutsDelegate().forwardParam(mapping.findForward("notified"),
                                      "eid",
                                      request.getParameter("eid"));
    }

    /**
     * Updates the errata according to info on the page.
     * @param mapping Action mapping
     * @param formIn Form
     * @param request The request
     * @param response The response
     * @return Returns an ActionForward for either updated or failure
     */
    public ActionForward update(ActionMapping mapping,
                                ActionForm formIn,
                                HttpServletRequest request,
                                HttpServletResponse response) {
        //Get the errata
        Errata e = new RequestContext(request).lookupErratum();

        DynaActionForm form = (DynaActionForm) formIn;
        //Validate the form to make sure everything was filled out correctly
        List bugs = new ArrayList();
        ActionErrors errors = validateForm(form, request, e, bugs);

        if (!errors.isEmpty()) { //Something is wrong. Forward to failure mapping.
            addErrors(request, errors);
            //return to the same page with the errors
            return setupPage(request, mapping, e);
        }

        //set l10n-ed advisoryTypeLabels list for select drop down
        form.set("advisoryTypeLabels", ErrataManager.advisoryTypeLabels());

        //Fill out errata
        e.setSynopsis(form.getString("synopsis"));
        e.setAdvisoryName(form.getString("advisoryName"));
        e.setAdvisoryRel(new Long(form.getString("advisoryRelease")));
        e.setAdvisoryType(form.getString("advisoryType"));
        e.setProduct(form.getString("product"));
        //Advisory = advisoryName-advisoryRelease
        e.setAdvisory(form.getString("advisoryName") + "-" +
                      form.getString("advisoryRelease"));
        e.setTopic(form.getString("topic"));
        e.setDescription(form.getString("description"));
        e.setSolution(form.getString("solution"));
        e.setRefersTo(form.getString("refersTo"));
        e.setNotes(form.getString("notes"));

        //Clear all the keywords and bugs we have, and then add the ones on page
        if (e.getKeywords() != null) {
            e.getKeywords().clear();
        }
        if (e.getBugs() != null) {
            e.getBugs().clear();
        }
        try {
            //We have to flush the session so that orphaned keywords and bugs
            //get deleted from the database.  This is BS, Hibernate should in all
            //reasonable application be able to manage sets correctly so that we
            //don't have to do this.  Consulting www.hibernate.org brings this 'fix'
            //of flushing the session and states, "This kind of problem occurs
            //rarely in practice."  #yell, curse, complain#
            HibernateFactory.getSession().flush();
        }
        catch (HibernateException ex) {
            throw new HibernateRuntimeException("Error flushing session", ex);
        }

        //add bugs from the form
        Iterator i = bugs.iterator();
        while (i.hasNext()) {
            String[] bug = (String[])i.next();
            Long bugid = new Long(bug[0]);
            String summary = bug[1];
            //should this be a published or unpublished bug?
            if (e.isPublished()) {
                e.addBug(ErrataManager.createNewPublishedBug(bugid, summary));
            }
            else { //add a new UnpublishedBug
                e.addBug(ErrataManager.createNewUnpublishedBug(bugid, summary));
            }
        }

        //add keywords... split on commas and add separately to list
        String keywordsField = form.getString("keywords");
        if (keywordsField != null && keywordsField.length() > 0) {
            List keywordsOnPage = Arrays.asList(keywordsField.split(","));
            Iterator keywordItr = keywordsOnPage.iterator();
            while (keywordItr.hasNext()) {
                String keyword = (String) keywordItr.next();
                keyword = keyword.trim();
                if (keyword != null && keyword.length() > 0) {
                    e.addKeyword(keyword);
                }
            }
        }

        //Save errata back to db
        ErrataManager.storeErrata(e);

        ActionMessages messages = new ActionMessages();
        messages.add(ActionMessages.GLOBAL_MESSAGE,
                     new ActionMessage("errata.edit.updated"));
        getStrutsDelegate().saveMessages(request, messages);
        //return to the same page with the message
        return setupPage(request, mapping, e);
    }

    /**
     * Validate the form and add bugs to the list
     * @param form The form we are validating
     * @param request HttpServletRequest
     * @param errata The errata we are editing
     * @param bugs list of the bugs for the errata
     * @return ActionErrors, empty if no errors
     */
    public ActionErrors validateForm(DynaActionForm form, HttpServletRequest request,
                                     Errata errata, List bugs) {

        ActionErrors errors = RhnValidationHelper.validateDynaActionForm(this, form);

        /*
         * Errata error check
         * Make sure advisory name is unique and does not begin with 'RH'
         */
        String advisoryNameFromForm = form.getString("advisoryName");

        //Get all the parameters (so we can detect changes to existing bugs)
        Iterator params = request.getParameterMap().keySet().iterator();

        /*
         * Now we add each bug id to a list
         * The reason we have to do this is so that users can edit existing bugs
         * The implementation here is a little annoying, but since there can be
         * any number of bugs here, this seems to be the only real way.
         */
        List bugIds = new ArrayList();
        while (params.hasNext()) {
            String next = (String) params.next();
            if (next.startsWith("buglistId")) {
                bugIds.add(next);
            }
        }

        // Make sure advisoryName is unique
        if (!ErrataManager.advisoryNameIsUnique(errata.getId(), advisoryNameFromForm)) {
            errors.add(ActionMessages.GLOBAL_MESSAGE,
                       new ActionMessage("errata.edit.error.uniqueAdvisoryName"));
        }
        // Make sure advisoryName does not begin with RH
        if (advisoryNameFromForm.toUpperCase().startsWith("RH")) {
            errors.add(ActionMessages.GLOBAL_MESSAGE,
                       new ActionMessage("errata.edit.error.rhAdvisoryName"));
        }

        Iterator i = bugIds.iterator();
        Set ids = new HashSet(); //This is for verifying that each id is unique
        while (i.hasNext()) {
            String next = (String)i.next();
            String id;
            String summary;
            //The suffix is the bug id or 'New'.  It is needed to match the id and summary
            //fields and to deal with the special differences between old bugs and new bugs
            String suffix = next.substring("buglistId".length());
            //the one possible new bug has the 'New' suffix
            boolean newbug = suffix.equals("New");

            try {
                id = request.getParameter(next).trim();
                summary = request.getParameter("buglistSummary" + suffix);
            }
            catch (IllegalArgumentException iae) {
                //This means that the buglistId key is not in the parameter map
                //or that it doesn't have a corresponding summary key
                //The former should never happen because we got the key from the
                //map to begin with.  The latter should never happen unless somebody
                //is screwing with the request.  @see WEB-INF/pages/errata/edit.jsp
                throw new BadParameterException("Invalid bugListId", iae);
            }

            //Test that all existing bugs have the id field filled in
            if (!newbug && id.length() == 0) {
                errors.add(ActionMessages.GLOBAL_MESSAGE,
                           new ActionMessage("errata.edit.error.id"));
            }
            //Test that all existing bugs have the summary field filled in
            if (!newbug && summary.length() == 0) {
                errors.add(ActionMessages.GLOBAL_MESSAGE,
                        new ActionMessage("errata.edit.error.summary"));
            }
            //Test that new bugs have either both or neither id and summary
            if (newbug && id.length() > 0 && summary.length() == 0) {
                errors.add(ActionMessages.GLOBAL_MESSAGE,
                        new ActionMessage("errata.edit.error.summary"));
            }
            if (newbug && summary.length() > 0 && id.length() == 0) {
                errors.add(ActionMessages.GLOBAL_MESSAGE,
                        new ActionMessage("errata.edit.error.id"));
            }
            //Test that bug id is a number
            if (!StringUtils.isNumeric(id)) {
                errors.add(ActionMessages.GLOBAL_MESSAGE,
                        new ActionMessage("errata.edit.error.idNonNumeric"));
            }
            //Make sure that bug summary isn't too big
            if (summary.length() > 4000) {
                errors.add(ActionMessages.GLOBAL_MESSAGE,
                        new ActionMessage("errata.edit.error.summaryLength"));
            }
            //Make sure that bug id isn't too big
            if (id.length() > 18) {
                errors.add(ActionMessages.GLOBAL_MESSAGE,
                        new ActionMessage("errata.edit.error.idLength"));
            }
            //Test that bug id is unique
            if (ids.contains(id)) {
                errors.add(ActionMessages.GLOBAL_MESSAGE,
                        new ActionMessage("errata.edit.error.idUnique"));
            }

            //Add this bug to the collection so that we can update the errata easily
            ids.add(id);
            if (!newbug || id.length() > 0) {
                String[] bug = new String[2];
                bug[0] = id;
                bug[1] = summary;
                bugs.add(bug);
            }
        }

        return errors;
    }

    /**
     * {@inheritDoc}
     */
    protected Map getKeyMethodMap() {
        Map map = new HashMap();
        map.put("errata.edit.publisherrata", "publish");
        map.put("errata.edit.sendnotification", "notify");
        map.put("errata.edit.submit", "addBug");
        map.put("errata.edit.delete", "deleteBug");
        map.put("errata.edit.updateerrata", "update");
        return map;
    }

}
