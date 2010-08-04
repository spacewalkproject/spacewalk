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
package com.redhat.rhn.frontend.action.systems.sdc;

import com.redhat.rhn.domain.action.Action;
import com.redhat.rhn.domain.action.ActionFactory;
import com.redhat.rhn.domain.server.CPU;
import com.redhat.rhn.domain.server.Server;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.frontend.struts.RequestContext;
import com.redhat.rhn.frontend.struts.RhnAction;
import com.redhat.rhn.manager.action.ActionManager;
import com.redhat.rhn.manager.system.SystemManager;
import org.apache.struts.action.ActionForm;
import org.apache.struts.action.ActionForward;
import org.apache.struts.action.ActionMapping;
import org.apache.struts.action.DynaActionForm;

import java.util.Date;
import java.util.Map;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

/**
 * SystemHardwareAction handles the interaction of the ChannelDetails page.
 * @version $Rev$
 */
public class SystemHardwareAction extends RhnAction {
    public static final String SID = "sid";

    /** {@inheritDoc} */
    public ActionForward execute(ActionMapping mapping,
            ActionForm formIn,
            HttpServletRequest request,
            HttpServletResponse response) {

        DynaActionForm form = (DynaActionForm)formIn;
        RequestContext ctx = new RequestContext(request);
        User user =  ctx.getLoggedInUser();
        Map params = makeParamMap(request);
        String fwd = "default";

        Long sid = ctx.getRequiredParam(RequestContext.SID);
        Server server = SystemManager.lookupByIdAndUser(sid, user);

        CPU cpu = server.getCpu();
        Date now = new Date();
        request.setAttribute(SID, sid);

        if (isSubmitted(form)) {
            Action a = ActionManager.scheduleHardwareRefreshAction(user, server, now);
            ActionFactory.save(a);

            createSuccessMessage(request, "message.refeshScheduled", server.getName());

            // No idea why I have to do this  :(
            params.put(SID, sid);

            fwd = "success";
        }

        request.setAttribute("system", server);

        request.setAttribute("cpu_model", cpu.getModel());
        request.setAttribute("cpu_mhz", cpu.getMHz());
        request.setAttribute("cpu_vendor", cpu.getVendor());
        request.setAttribute("cpu_stepping", cpu.getStepping());
        request.setAttribute("cpu_family", cpu.getFamily());
        request.setAttribute("cpu_arch", cpu.getArch().getName());
        request.setAttribute("cpu_cache", cpu.getCache());

        request.setAttribute("system_ram", server.getRam());
        request.setAttribute("system_swap", server.getSwap());

        request.setAttribute("dmi_vendor", server.getDmi().getVendor());
        request.setAttribute("dmi_system", server.getDmi().getSystem());
        request.setAttribute("dmi_product", server.getDmi().getProduct());
        request.setAttribute("dmi_bios", server.getDmi().getBios());
        request.setAttribute("dmi_asset_tag", server.getDmi().getAsset());
        request.setAttribute("dmi_board", server.getDmi().getBoard());

        request.setAttribute("network_hostname", server.getHostname());
        request.setAttribute("network_ip_addr", server.getIpAddress());

        request.setAttribute("parentUrl", request.getRequestURI());

        return getStrutsDelegate().forwardParams(
                mapping.findForward(fwd), params);
    }
}

