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

import com.redhat.rhn.domain.user.PaneFactory;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.frontend.struts.RequestContext;
import com.redhat.rhn.frontend.struts.RhnAction;
import com.redhat.rhn.frontend.struts.RhnHelper;
import com.redhat.rhn.frontend.struts.StrutsDelegate;
import com.redhat.rhn.manager.user.UserManager;

import org.apache.commons.lang.BooleanUtils;
import org.apache.struts.action.ActionForm;
import org.apache.struts.action.ActionForward;
import org.apache.struts.action.ActionMapping;
import org.apache.struts.action.ActionMessage;
import org.apache.struts.action.ActionMessages;
import org.apache.struts.action.DynaActionForm;

import java.util.HashSet;
import java.util.Map;
import java.util.Set;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

/**
 * UserPreferencesAction, edit action for user detail page
 * @version $Rev: 1196 $
 */
public class UserPrefAction extends RhnAction {

    /** {@inheritDoc} */
    public ActionForward execute(ActionMapping mapping,
                                 ActionForm formIn,
                                 HttpServletRequest request,
                                 HttpServletResponse response) {

        DynaActionForm form = (DynaActionForm)formIn;
        RequestContext requestContext = new RequestContext(request);
        StrutsDelegate strutsDelegate = getStrutsDelegate();

        User user = UserManager.lookupUser(requestContext.getLoggedInUser(),
                requestContext.getParamAsLong("uid"));
        request.setAttribute(RhnHelper.TARGET_USER, user);
        if (user == null) {
            user = requestContext.getLoggedInUser();
        }

        user.setEmailNotify(BooleanUtils.toInteger((Boolean) form
                .get("emailNotif"), 1, 0, 0));
        user.setPageSize(getAsInt(form, "pagesize", 5));

        handlePanes(form, user);

        UserManager.storeUser(user);

        ActionMessages msgs = new ActionMessages();
        msgs.add(ActionMessages.GLOBAL_MESSAGE,
                new ActionMessage("message.preferencesModified"));
        strutsDelegate.saveMessages(request, msgs);

        return strutsDelegate.forwardParam(mapping.findForward("success"), "uid",
                                      String.valueOf(user.getId()));
    }

    private void handlePanes(DynaActionForm form, User user) {
        Map allPanes = PaneFactory.getAllPanes();

        String[] selections = (String[]) form.get("selectedPanes");
        Set hiddenPanes = new HashSet(allPanes.values());

        if (selections != null) {
            for (int i = 0; i < selections.length; i++) {
                hiddenPanes.remove(allPanes.get(selections[i]));
            }
        }
        user.setHiddenPanes(hiddenPanes);
    }

    /**
     * Returns the Integer property from the given form as an int.  If property
     * does not exist we return the default value specified by def.
     * @param form DynaActionForm containing the property.
     * @param property Property to be transformed.
     * @param def Default value if property is null.
     * @return the Integer property from the given form as an int.  If property
     * does not exist we return the default value specified by def.
     */
    private int getAsInt(DynaActionForm form, String property, int def) {
        Integer i = (Integer) form.get(property);
        if (i == null) {
            return def;
        }
        return i.intValue();
    }

    /**
     * Returns the Boolean property from the given form as an boolean.  If
     * property does not exist we return the default value specified by flag.
     * @param form DynaActionForm containing the property.
     * @param property Property to be transformed.
     * @param flag Default value if property is null.
     * @return the Boolean property from the given form as an boolean.  If
     * property does not exist we return the default value specified by flag.
     */
    /*private Boolean getBoolean(DynaActionForm form, String property,
                              Boolean flag) {

        Boolean b = (Boolean) form.get(property);
        if (b == null) {
            return flag;
        }
        return b;
    }*/
}
