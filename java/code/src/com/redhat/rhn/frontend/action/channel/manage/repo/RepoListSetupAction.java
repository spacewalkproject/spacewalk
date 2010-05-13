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

import java.util.Collections;
import java.util.List;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.apache.struts.action.ActionForm;
import org.apache.struts.action.ActionForward;
import org.apache.struts.action.ActionMapping;

import com.redhat.rhn.common.util.DynamicComparator;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.frontend.dto.ContentSourceDto;
import com.redhat.rhn.frontend.struts.RequestContext;
import com.redhat.rhn.frontend.struts.RhnAction;
import com.redhat.rhn.manager.channel.RepoLister;

/**
 * RepoListSetupAction : class to list repos
 * @version $Rev: 1 $
 */
public class RepoListSetupAction extends RhnAction {

    private static final DynamicComparator LABEL_COMPARATOR =
                new DynamicComparator("label", true);
    /**
     * ${@inheritDoc}
     */
    public ActionForward execute(ActionMapping mapping, ActionForm form,
            HttpServletRequest request, HttpServletResponse response) throws Exception {

        request.setAttribute(mapping.getParameter(), Boolean.TRUE);
        RequestContext context = new RequestContext(request);
        User user = context.getLoggedInUser();
        List<ContentSourceDto> result;

        result = RepoLister.getInstance().list(user);
        Collections.sort(result, LABEL_COMPARATOR);
        request.setAttribute("pageList", result);
        request.setAttribute("parentUrl", request.getRequestURI());
        return mapping.findForward("default");
    }

}
