/**
 * Copyright (c) 2014 Red Hat, Inc.
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
package com.redhat.rhn.frontend.action.ssm;

import com.redhat.rhn.domain.server.ServerFactory;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.frontend.dto.SystemOverview;
import com.redhat.rhn.frontend.struts.RequestContext;
import com.redhat.rhn.frontend.struts.RhnAction;
import com.redhat.rhn.frontend.struts.RhnHelper;
import com.redhat.rhn.frontend.taglibs.list.helper.ListHelper;
import com.redhat.rhn.frontend.taglibs.list.helper.Listable;
import com.redhat.rhn.manager.entitlement.EntitlementManager;
import com.redhat.rhn.manager.rhnset.RhnSetDecl;
import com.redhat.rhn.manager.system.SystemManager;

import org.apache.commons.lang.StringUtils;
import org.apache.struts.action.ActionForm;
import org.apache.struts.action.ActionForward;
import org.apache.struts.action.ActionMapping;
import org.apache.struts.action.DynaActionForm;
import java.util.LinkedList;
import java.util.List;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

/**
 * Tag system shapshots so that you can roll back to them later
 * @author Stephen Herr <sherr@redhat.com>
 */
public class TagSystemsAction extends RhnAction implements Listable<SystemOverview> {
    protected static final String TAG = "tag";

    /**
     * Runs this action.
     * @param mapping action mapping
     * @param formIn form submitted values
     * @param request http request object
     * @param response http response object
     * @return an action forward object
     */
    @Override
    public ActionForward execute(ActionMapping mapping, ActionForm formIn,
        HttpServletRequest request, HttpServletResponse response) {
        RequestContext context = new RequestContext(request);
        DynaActionForm form = (DynaActionForm) formIn;
        User user = context.getCurrentUser();

        ListHelper helper = new ListHelper(this, request);
        helper.setListName("systemList");
        helper.setDataSetName(RequestContext.PAGE_LIST);
        helper.execute();

        if (context.isSubmitted()) {
            String tagName = form.get(TAG).toString();
            if (StringUtils.isBlank(tagName)) {
                createErrorMessage(request, "system.history.snapshot.tagNameEmpty", null);
                return mapping.findForward(RhnHelper.DEFAULT_FORWARD);
            }

            ServerFactory.bulkAddTagToSnapshot(tagName, "system_list", user);

            createSuccessMessage(request, "system.history.snapshot.tagCreateSuccess", null);
        }

        return mapping.findForward(RhnHelper.DEFAULT_FORWARD);
    }

    /**
     * ${@inheritDoc}
     */
    public List<SystemOverview> getResult(RequestContext context) {
        User user = context.getCurrentUser();
        return SystemManager.entitledInSet(user, RhnSetDecl.SYSTEMS.getLabel(),
            new LinkedList<String>() {
                {
                    add(EntitlementManager.ENTERPRISE_ENTITLED);
                }
            });
    }
}
