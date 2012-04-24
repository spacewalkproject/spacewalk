/**
 * Copyright (c) 2009--2011 Red Hat, Inc.
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
import com.redhat.rhn.domain.server.Device;
import com.redhat.rhn.domain.server.NetworkInterface;
import com.redhat.rhn.domain.server.Server;
import com.redhat.rhn.domain.server.ServerFactory;
import com.redhat.rhn.domain.server.ServerNetAddress6;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.frontend.struts.RequestContext;
import com.redhat.rhn.frontend.struts.RhnAction;
import com.redhat.rhn.frontend.taglibs.list.ListTagHelper;
import com.redhat.rhn.manager.action.ActionManager;
import com.redhat.rhn.manager.system.SystemManager;

import org.apache.commons.lang.StringUtils;
import org.apache.struts.action.ActionForm;
import org.apache.struts.action.ActionForward;
import org.apache.struts.action.ActionMapping;
import org.apache.struts.action.DynaActionForm;

import java.util.ArrayList;
import java.util.Collections;
import java.util.Date;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.StringTokenizer;

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

        setupForm(request, cpu, server);

        return getStrutsDelegate().forwardParams(
                mapping.findForward(fwd), params);
    }

    private void setupForm(HttpServletRequest request, CPU cpu, Server server) {

        request.setAttribute("system", server);
        if (cpu != null) {
            request.setAttribute("cpu_model", cpu.getModel());
            request.setAttribute("cpu_count", cpu.getNrCPU());
            request.setAttribute("cpu_mhz", cpu.getMHz());
            request.setAttribute("cpu_vendor", cpu.getVendor());
            request.setAttribute("cpu_stepping", cpu.getStepping());
            request.setAttribute("cpu_family", cpu.getFamily());
            request.setAttribute("cpu_arch", server.getServerArch().getName());
            request.setAttribute("cpu_cache", cpu.getCache());
        }


        request.setAttribute("system_ram", server.getRam());
        request.setAttribute("system_swap", server.getSwap());

        StringBuffer dmiBios = new StringBuffer();
        if (server.getDmi() != null) {

            if (server.getDmi().getBios() != null) {
                if (StringUtils.isNotEmpty(server.getDmi().getBios().getVendor())) {
                    dmiBios.append(server.getDmi().getBios().getVendor() + " ");
                }
                if (StringUtils.isNotEmpty(server.getDmi().getBios().getVersion())) {
                    dmiBios.append(server.getDmi().getBios().getVersion() + " ");
                }
                if (StringUtils.isNotEmpty(server.getDmi().getBios().getRelease())) {
                    dmiBios.append(server.getDmi().getBios().getRelease());
                }
            }

            request.setAttribute("dmi_vendor", server.getDmi().getVendor());
            request.setAttribute("dmi_system", server.getDmi().getSystem());
            request.setAttribute("dmi_product", server.getDmi().getProduct());
            request.setAttribute("dmi_bios", dmiBios.toString());
            request.setAttribute("dmi_asset_tag", server.getDmi().getAsset());
            request.setAttribute("dmi_board", server.getDmi().getBoard());
        }

        request.setAttribute("network_hostname", server.getDecodedHostname());
        request.setAttribute("network_ip_addr", server.getIpAddress());
        request.setAttribute("network_ip6_addr", server.getIp6Address());
        request.setAttribute("network_cnames", server.getDecodedCnames());

        List<String> nicList = new ArrayList();
        for (NetworkInterface n : server.getNetworkInterfaces()) {
            nicList.add(n.getName());
        }
        Collections.sort(nicList);

        List nicList2 = new ArrayList();
        for (String nicName : nicList) {
            Map nic = new HashMap();
            NetworkInterface n = server.getNetworkInterface(nicName);
            nic.put("name", n.getName());
            nic.put("ip", n.getIpaddr());
            nic.put("netmask", n.getNetmask());
            nic.put("broadcast", n.getBroadcast());
            nic.put("hwaddr", n.getHwaddr());
            nic.put("module", n.getModule());
            nicList2.add(nic);
        }
        request.setAttribute("network_interfaces", nicList2);

        List nicList3 = new ArrayList();
        for (String nicName : nicList) {
            NetworkInterface n = server.getNetworkInterface(nicName);
            for (ServerNetAddress6 na6 : n.getIPv6Addresses()) {
                Map nic = new HashMap();
                nic.put("name", n.getName());
                nic.put("hwaddr", n.getHwaddr());
                nic.put("module", n.getModule());
                nic.put("ip6", na6.getAddress());
                nic.put("netmask", na6.getNetmask());
                nic.put("scope", na6.getScope());
                nicList3.add(nic);
            }
        }
        request.setAttribute("ipv6_network_interfaces", nicList3);

        List<String> hdd = new ArrayList();
        List miscDevices = new ArrayList();
        List videoDevices = new ArrayList();
        List audioDevices = new ArrayList();
        List captureDevices = new ArrayList();
        List usbDevices = new ArrayList();

        for (Device d : server.getDevices()) {
            Map device = new HashMap();
            String desc = null;
            String vendor = null;

            if (d.getDescription() != null) {
                StringTokenizer st = new StringTokenizer(d.getDescription(), "|");
                vendor = st.nextToken();
                if (st.hasMoreTokens()) {
                    desc = st.nextToken();
                }
            }

            if (desc != null) {
                device.put("description", desc);
                device.put("vendor", vendor);
            }
            else {
                device.put("description", d.getDescription());
            }
            device.put("bus", d.getBus());
            device.put("detached", d.getDetached().toString());
            device.put("device", d.getDevice());
            device.put("driver", d.getDriver());
            device.put("pcitype", d.getPcitype().toString());
            if (d.getDeviceClass().equals("HD")) {
                continue;
            }
            else if (d.getDeviceClass().equals("VIDEO")) {
                videoDevices.add(device);
            }
            else if (d.getDeviceClass().equals("USB")) {
                usbDevices.add(device);
            }
            else if (d.getDeviceClass().equals("AUDIO")) {
                audioDevices.add(device);
            }
            else if (d.getDeviceClass().equals("CAPTURE")) {
                captureDevices.add(device);
            }
            else {
                if (!d.getBus().equals("MISC")) {
                    miscDevices.add(device);
                }
            }
        }

        List storageDevices = new ArrayList();
        for (Device hd : ServerFactory.lookupStorageDevicesByServer(server)) {
            Device d = hd;
            Map device = new HashMap();
            device.put("description", d.getDescription());
            device.put("device", d.getDevice());
            device.put("bus", d.getBus());
            storageDevices.add(device);
        }

        request.setAttribute("storageDevices", storageDevices);
        request.setAttribute("videoDevices", videoDevices);
        request.setAttribute("audioDevices", audioDevices);
        request.setAttribute("miscDevices", miscDevices);
        request.setAttribute("usbDevices", usbDevices);
        request.setAttribute("captureDevices", captureDevices);

        request.setAttribute(ListTagHelper.PARENT_URL, request.getRequestURI());
    }

}
