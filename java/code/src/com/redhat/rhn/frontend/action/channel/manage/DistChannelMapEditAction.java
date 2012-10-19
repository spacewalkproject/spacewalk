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
package com.redhat.rhn.frontend.action.channel.manage;

import com.redhat.rhn.common.hibernate.LookupException;
import com.redhat.rhn.common.validator.ValidatorResult;
import com.redhat.rhn.domain.channel.Channel;
import com.redhat.rhn.domain.channel.ChannelArch;
import com.redhat.rhn.domain.channel.ChannelFactory;
import com.redhat.rhn.domain.channel.DistChannelMap;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.frontend.struts.RequestContext;
import com.redhat.rhn.frontend.struts.RhnAction;
import com.redhat.rhn.frontend.struts.RhnHelper;
import com.redhat.rhn.frontend.struts.RhnValidationHelper;
import com.redhat.rhn.manager.channel.ChannelManager;

import org.apache.struts.action.ActionForm;
import org.apache.struts.action.ActionForward;
import org.apache.struts.action.ActionMapping;
import org.apache.struts.action.DynaActionForm;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;


/**
 * DistChannelMapEditAction
 * @version $Rev$
 */
public class DistChannelMapEditAction extends RhnAction {

    public static final String DCM_ID = "dcm";
    public static final String OS = "os";
    public static final String RELEASE = "release";
    public static final String CHANNEL_ARCH = "architecture";
    public static final String CHANNEL_LABEL = "channel_label";
    private static final String VALIDATION_XSD = "/com/redhat/rhn/frontend/action/" +
            "channel/manage/validation/distChannelMapForm.xsd";

    /** {@inheritDoc} */
    public ActionForward execute(ActionMapping mapping,
                                  ActionForm formIn,
                                  HttpServletRequest request,
                                  HttpServletResponse response) {
        DynaActionForm form = (DynaActionForm) formIn;
        RequestContext ctx = new RequestContext(request);
        User user = ctx.getLoggedInUser();

        // setup channel architectures
        List channelArches = new ArrayList();
        List<ChannelArch> arches = ChannelManager.getChannelArchitectures();
        for (ChannelArch arch : arches) {
            Map selection = new HashMap();
            selection.put("label", arch.getName());
            selection.put("value", arch.getLabel());
            channelArches.add(selection);
        }
        ctx.getRequest().setAttribute("channelArches", channelArches);

        // setup subscribable base channels
        List channels = new ArrayList();
        List<Channel> subscribableBaseChannels =
                ChannelFactory.listSubscribableBaseChannels(user);
        for (Channel channel : subscribableBaseChannels) {
            Map selection = new HashMap();
            selection.put("label", channel.getName());
            selection.put("value", channel.getLabel());
            channels.add(selection);
        }
        ctx.getRequest().setAttribute("channels", channels);

        Long dcmId = ctx.getParamAsLong(DCM_ID);
        ctx.getRequest().setAttribute("dcm", dcmId);

        DistChannelMap dcm = null;
        if (dcmId != null) {
            dcm = ChannelFactory.lookupDistChannelMapById(dcmId);
            if (dcm == null) {
                throw new LookupException("There's no such a distribution channel " +
                        "mapping with id: " + dcmId + ".");
            }
        }

        if (ctx.isSubmitted()) {
            ValidatorResult result = RhnValidationHelper.validate(this.getClass(),
                    makeValidationMap(form), null, VALIDATION_XSD);
            if (!result.isEmpty()) {
                getStrutsDelegate().saveMessages(request, result);
                return mapping.findForward(RhnHelper.DEFAULT_FORWARD);
            }

            Channel channel = ChannelFactory.lookupByLabelAndUser(
                    form.getString(CHANNEL_LABEL), user);
            if (dcmId == null || dcm == null || dcm.getOrg() == null) {
                ChannelArch cha = ChannelFactory.lookupArchByLabel(
                        (String) form.get(CHANNEL_ARCH));
                DistChannelMap newDcm = new DistChannelMap(
                        user.getOrg(), (String) form.get(OS), (String) form.get(RELEASE),
                        cha, channel);
                ChannelFactory.save(newDcm);
                createSuccessMessage(request, "distchannelmap.jsp.create.message",
                        newDcm.getOs());
            }
            else {
                dcm.setOs((String) form.get(OS));
                dcm.setChannel(channel);
                ChannelFactory.save(dcm);
                createSuccessMessage(request, "distchannelmap.jsp.update.message",
                        dcm.getOs());
            }

            return mapping.findForward("success");
        }

        if (dcmId != null && dcm != null) {

            form.set(OS, dcm.getOs());
            form.set(RELEASE, dcm.getRelease());
            form.set(CHANNEL_ARCH, dcm.getChannelArch().getLabel());
            form.set(CHANNEL_LABEL, dcm.getChannel().getLabel());

            request.setAttribute(RELEASE, dcm.getRelease());
            request.setAttribute(CHANNEL_ARCH, dcm.getChannelArch().getLabel());
        }

        return mapping.findForward(RhnHelper.DEFAULT_FORWARD);
    }

    private Map<String, String> makeValidationMap(DynaActionForm form) {
        Map<String, String> map = new HashMap<String, String>();
        map.put(OS, form.getString(OS));
        map.put(RELEASE, form.getString(RELEASE));
        return map;
    }
}
