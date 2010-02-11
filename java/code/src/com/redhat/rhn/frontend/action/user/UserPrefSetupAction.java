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
package com.redhat.rhn.frontend.action.user;

import com.redhat.rhn.common.localization.LocalizationService;
import com.redhat.rhn.domain.user.Pane;
import com.redhat.rhn.domain.user.PaneFactory;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.frontend.action.common.BadParameterException;
import com.redhat.rhn.frontend.struts.LabelValueEnabledBean;
import com.redhat.rhn.frontend.struts.RequestContext;
import com.redhat.rhn.frontend.struts.RhnAction;
import com.redhat.rhn.frontend.struts.RhnHelper;
import com.redhat.rhn.frontend.taglibs.list.decorators.PageSizeDecorator;
import com.redhat.rhn.manager.user.UserManager;

import org.apache.commons.lang.BooleanUtils;
import org.apache.struts.action.ActionForm;
import org.apache.struts.action.ActionForward;
import org.apache.struts.action.ActionMapping;
import org.apache.struts.action.DynaActionForm;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.Iterator;
import java.util.List;
import java.util.Map;
import java.util.Set;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

/**
 * UserPreferencesAction, edit action for user detail page
 * @version $Rev: 1226 $
 */
public class UserPrefSetupAction extends RhnAction {

    /** {@inheritDoc} */
    public ActionForward execute(ActionMapping mapping,
                                 ActionForm formIn,
                                 HttpServletRequest request,
                                 HttpServletResponse response) {
        DynaActionForm form = (DynaActionForm)formIn;
        RequestContext requestContext = new RequestContext(request);
        Long uid = requestContext.getParamAsLong("uid");
        //UserPreferences under /rhn/users needs parameter, but /rhn/account does not
        if (request.getRequestURL().toString().indexOf("/rhn/users/") != -1 &&
                uid == null) {
            throw new BadParameterException(
                    "Invalid [null] value for parameter uid");
        }

        User user = UserManager.lookupUser(requestContext.getLoggedInUser(), uid);
        request.setAttribute(RhnHelper.TARGET_USER, user);
        if (user == null) {
            user = requestContext.getLoggedInUser();
        }

        form.set("uid", user.getId());
        form.set("emailNotif", BooleanUtils.toBooleanObject(user
                .getEmailNotify()));

        form.set("pagesize", new Integer(user.getPageSize()));

        setupTasks(form, user);
        request.setAttribute("pagesizes", getPageSizes());

        return mapping.findForward("default");
    }

    /**
     * Returns list of page sizes in increments of 5 upto max.
     * @return List of page sizes in increments of 5 upto max.
     */
    private List getPageSizes() {
        List pages = new ArrayList();
        for (int i : PageSizeDecorator.getPageSizes()) {
            String istr = String.valueOf(i);
            pages.add(createDisplayMap(istr, istr));
        }
        return pages;
    }
    
    private void setupTasks(DynaActionForm form, User user) {
        // sets up the possible tasks...
        Set userPanes = user.getHiddenPanes();

        List displayPanes = new ArrayList();

        List selectedPanes = new ArrayList();

        Map allPanes = PaneFactory.getAllPanes();

        for (Iterator itr = allPanes.keySet().iterator(); itr.hasNext();) {
            String key = (String) itr.next();
            Pane pane = (Pane) allPanes.get(key);
            if (pane.isValidFor(user)) {
                displayPanes.add(new LabelValueEnabledBean(makeDisplayString(pane),
                                            key));
                if (!userPanes.contains(pane)) {
                    selectedPanes.add(key);
                }                
            }
        }

        form.set("possiblePanes", displayPanes.toArray(new LabelValueEnabledBean[0]));
        form.set("selectedPanes", selectedPanes.toArray(new String[0]));
    }

    private String makeDisplayString(Pane pane) {
        LocalizationService service = LocalizationService.getInstance();
        return "<strong>" + service.getMessage(pane.getNameKey()) +
                   ":</strong>" + service.getMessage(pane.getDescriptionKey());
    }
    
    private Map createDisplayMap(String display, String value) {
        Map selection = new HashMap();
        selection.put("display", display);
        selection.put("value", value);
        return selection;
    }     
}
