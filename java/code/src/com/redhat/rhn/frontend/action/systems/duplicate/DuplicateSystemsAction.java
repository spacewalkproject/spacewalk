/**
 * Copyright (c) 2010 Red Hat, Inc.
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
package com.redhat.rhn.frontend.action.systems.duplicate;

import com.redhat.rhn.domain.rhnset.RhnSet;
import com.redhat.rhn.frontend.dto.NetworkDto;
import com.redhat.rhn.frontend.struts.RequestContext;
import com.redhat.rhn.frontend.struts.RhnAction;
import com.redhat.rhn.frontend.taglibs.list.ListTagUtil;
import com.redhat.rhn.frontend.taglibs.list.helper.ListRhnSetHelper;
import com.redhat.rhn.frontend.taglibs.list.helper.Listable;
import com.redhat.rhn.manager.rhnset.RhnSetDecl;
import com.redhat.rhn.manager.rhnset.RhnSetManager;
import com.redhat.rhn.manager.system.DuplicateSystemGrouping;
import com.redhat.rhn.manager.system.SystemManager;

import org.apache.commons.lang.StringUtils;
import org.apache.struts.action.ActionForm;
import org.apache.struts.action.ActionForward;
import org.apache.struts.action.ActionMapping;

import java.util.List;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

/**
 * SystemListAction
 * @version $Rev$
 */
public class DuplicateSystemsAction extends RhnAction implements Listable {

    private static final String INACTIVE_COUNT = "inactive_count";
    public static final String MAC_ADDRESS = "macaddress";
    public static final String HOSTNAME = "hostname";
    /**
     *
     * {@inheritDoc}
     */
    public ActionForward execute(ActionMapping mapping,
            ActionForm formIn,
            HttpServletRequest request,
            HttpServletResponse response) {

        RequestContext ctx = new RequestContext(request);
        request.setAttribute(mapping.getParameter(), mapping.getParameter());

        long inactiveHours = 24;
        if (request.getParameter(INACTIVE_COUNT) != null) {
            inactiveHours = Long.parseLong(request.getParameter(INACTIVE_COUNT));
        }
        request.setAttribute(INACTIVE_COUNT, inactiveHours);


        ListRhnSetHelper helper = new ListRhnSetHelper(this, request, getSetDecl());
        helper.setWillClearSet(false);
        helper.execute();
        if (helper.isDispatched()) {
            RequestContext context = new RequestContext(request);
            return handleConfirm(context, mapping);
        }


        String inactiveButton = ListTagUtil.makeExtraButtonName(helper.getUniqueName());
        if (!StringUtils.isBlank(request.getParameter(inactiveButton))) {
            List<DuplicateSystemGrouping> list = getResult(ctx);

            RhnSet set = helper.getSet();
            for (DuplicateSystemGrouping grp : list) {
                for (NetworkDto dto : grp.getSystems()) {
                    if (dto.getInactive() > 0) {
                        set.add(dto.getId().toString());
                    }
                }
            }

            RhnSetManager.store(set);
            helper.resync(request);

        }



        request.setAttribute(inactiveButton,
                "system.select.inactive");
        return mapping.findForward("default");
    }

    private ActionForward handleConfirm(RequestContext context,
            ActionMapping mapping) {
        getStrutsDelegate().saveMessage("duplicate.systems.delete.confirm.message",
                context.getRequest());
        return mapping.findForward("confirm");
    }

    /**
     * {@inheritDoc}
     */
    public List getResult(RequestContext contextIn) {
        Long count = (Long) contextIn.getRequest().getAttribute(INACTIVE_COUNT);
        if (contextIn.getRequest().getAttribute(HOSTNAME) != null) {
            return SystemManager.listDuplicatesByHostname
                                (contextIn.getLoggedInUser(), count);
        }
        else if (contextIn.getRequest().getAttribute(MAC_ADDRESS) != null) {
            return SystemManager.listDuplicatesByMac(contextIn.getLoggedInUser(), count);
        }
        return SystemManager.listDuplicatesByIP(contextIn.getLoggedInUser(), count);
    }

    private RhnSetDecl getSetDecl() {
        return RhnSetDecl.SYSTEMS;
    }

}
