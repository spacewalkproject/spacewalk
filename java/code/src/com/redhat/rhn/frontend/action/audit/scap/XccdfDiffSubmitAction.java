/**
 * Copyright (c) 2012 Red Hat, Inc.
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
package com.redhat.rhn.frontend.action.audit.scap;

import java.util.List;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.apache.struts.action.ActionErrors;
import org.apache.struts.action.ActionForm;
import org.apache.struts.action.ActionForward;
import org.apache.struts.action.ActionMapping;
import org.apache.struts.action.DynaActionForm;

import com.redhat.rhn.frontend.struts.RequestContext;
import com.redhat.rhn.frontend.struts.RhnAction;
import com.redhat.rhn.frontend.struts.RhnHelper;
import com.redhat.rhn.frontend.struts.RhnValidationHelper;
import com.redhat.rhn.frontend.taglibs.list.ListTagHelper;
import com.redhat.rhn.frontend.taglibs.list.helper.ListHelper;
import com.redhat.rhn.frontend.taglibs.list.helper.Listable;
import com.redhat.rhn.manager.audit.scap.RuleResultComparator;
import com.redhat.rhn.manager.audit.scap.RuleResultDiffer;

/**
 * Static action page.
 */
public class XccdfDiffSubmitAction extends RhnAction implements Listable {
    private static final String FIRST = "first";
    private static final String SECOND = "second";

    /** {@inheritDoc} */
    public ActionForward execute(ActionMapping mapping,
                                  ActionForm formIn,
                                  HttpServletRequest request,
                                  HttpServletResponse response) {
        DynaActionForm form = (DynaActionForm) formIn;
        ActionErrors errors = RhnValidationHelper.validateDynaActionForm(this, form);
        if (!errors.isEmpty()) {
            getStrutsDelegate().saveMessages(request, errors);
            return getStrutsDelegate().forwardParams(
                    mapping.findForward("error"), request.getParameterMap());
        }

        Long first = (Long) form.get(FIRST);
        Long second = (Long) form.get(SECOND);
        // TODO: ensure that scans of given ids exist

        ListHelper helper = new ListHelper(this, request);
        helper.execute();

        request.setAttribute(ListTagHelper.PARENT_URL, request.getRequestURI() +
                "?" + FIRST + "=" + first + "&" + SECOND + "=" + second);

        return mapping.findForward(RhnHelper.DEFAULT_FORWARD);
    }

    /** {@inheritDoc} */
    public List<RuleResultComparator> getResult(RequestContext context) {
        Long first = context.getRequiredParam(FIRST);
        Long second = context.getRequiredParam(SECOND);
        RuleResultDiffer differ = new RuleResultDiffer(first, second);
        return differ.getData();
    }
}
