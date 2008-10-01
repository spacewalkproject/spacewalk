/**
 * Copyright (c) 2008 Red Hat, Inc.
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

import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.frontend.struts.RequestContext;
import com.redhat.rhn.frontend.struts.RhnAction;
import com.redhat.rhn.frontend.taglibs.list.ListHelper;
import com.redhat.rhn.frontend.taglibs.list.Listable;
import com.redhat.rhn.manager.user.UserManager;

import org.apache.struts.action.ActionForm;
import org.apache.struts.action.ActionForward;
import org.apache.struts.action.ActionMapping;

import java.util.List;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

/**
 * EnabledListSetupAction
 * @version $Rev$
 */
public class EnabledListSetupAction extends RhnAction implements Listable {

    /**
     * ${@inheritDoc}
     */
    public ActionForward execute(ActionMapping mapping, ActionForm form, 
            HttpServletRequest request, HttpServletResponse response) throws Exception {
        ListHelper helper = new ListHelper(this);
        return helper.execute(mapping, form, request, response);
    }

    /**
     * ${@inheritDoc}
     */
    @Override
    public String getDataSetName() {
        return "pageList";
    }

    /**
     * ${@inheritDoc}
     */
    @Override
    public String getListName() {
        return null;
    }

    /**
     * ${@inheritDoc}
     */
    @Override
    public String getParentUrl(RequestContext context) {
        return context.getRequest().getRequestURI();
    }

    /**
     * ${@inheritDoc}
     */
    @Override
    public List getResult(RequestContext context, ActionMapping mapping) {
        User user = context.getLoggedInUser();
        return UserManager.activeInOrg2(user);
    }
}
