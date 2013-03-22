/**
 * Copyright (c) 2013 Red Hat, Inc.
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

package com.redhat.rhn.frontend.action.systems;

import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.domain.server.CrashFactory;
import com.redhat.rhn.frontend.dto.CrashSystemsDto;
import com.redhat.rhn.frontend.dto.IdenticalCrashesDto;
import com.redhat.rhn.frontend.struts.RequestContext;
import com.redhat.rhn.frontend.struts.RhnAction;
import com.redhat.rhn.frontend.struts.RhnHelper;
import com.redhat.rhn.frontend.taglibs.list.helper.Listable;
import com.redhat.rhn.frontend.taglibs.list.helper.ListHelper;

import org.apache.struts.action.ActionForm;
import org.apache.struts.action.ActionForward;
import org.apache.struts.action.ActionMapping;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import java.util.List;

/**
 * SoftwareCrashUuidDetailsAction
 * @version $Rev$
 */
public class SoftwareCrashUuidDetailsAction extends RhnAction implements Listable {

    public static final String UUID = "uuid";
    public static final String CRASHES_SUMMARY = "crashesSummary";

    /**
     * {@inheritDoc}
     */
    public ActionForward execute(ActionMapping mapping,
                                 ActionForm formIn,
                                 HttpServletRequest request,
                                 HttpServletResponse response) {

        RequestContext ctx = new RequestContext(request);
        User user = ctx.getCurrentUser();
        String uuid = ctx.getParam(UUID, true);
        List<IdenticalCrashesDto> crashesSummary =
            CrashFactory.listCrashUuidDetails(user, user.getOrg(), uuid);
        request.setAttribute(CRASHES_SUMMARY, crashesSummary.get(0));

        ListHelper helper = new ListHelper(this, request);
        helper.execute();

        return mapping.findForward(RhnHelper.DEFAULT_FORWARD);
    }

    /**
     * {@inheritDoc}
     */
    public List<CrashSystemsDto> getResult(RequestContext contextIn) {
        User user = contextIn.getCurrentUser();
        String uuid = contextIn.getParam(UUID, true);
        return CrashFactory.listCrashSystems(user, user.getOrg(), uuid);
    }
}
