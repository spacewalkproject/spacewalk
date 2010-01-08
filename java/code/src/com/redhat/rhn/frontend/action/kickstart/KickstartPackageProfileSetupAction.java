/**
 * Copyright (c) 2009 Red Hat, Inc.
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
package com.redhat.rhn.frontend.action.kickstart;

import com.redhat.rhn.domain.kickstart.KickstartData;
import com.redhat.rhn.domain.kickstart.KickstartFactory;
import com.redhat.rhn.domain.rhnpackage.profile.Profile;
import com.redhat.rhn.frontend.struts.RequestContext;
import com.redhat.rhn.frontend.struts.RhnAction;
import com.redhat.rhn.frontend.taglibs.list.ListTagHelper;
import com.redhat.rhn.frontend.taglibs.list.helper.ListHelper;
import com.redhat.rhn.frontend.taglibs.list.helper.Listable;
import com.redhat.rhn.manager.profile.ProfileManager;

import org.apache.commons.lang.StringUtils;
import org.apache.struts.action.ActionForm;
import org.apache.struts.action.ActionForward;
import org.apache.struts.action.ActionMapping;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

/**
 * KickstartPackageProfilesEditAction - setup for listing the profiles available 
 * for selection.
 * @version $Rev: 1 $
 */
public class KickstartPackageProfileSetupAction extends RhnAction implements Listable {


    public static final String UPDATE_METHOD = "kickstart.packageprofile.jsp.submit";
    public static final String CLEAR_METHOD = "kickstart.packageprofile.jsp.clear";

    /**
     *
     * {@inheritDoc}
     */
    public ActionForward execute(ActionMapping mapping,
            ActionForm formIn,
            HttpServletRequest request,
            HttpServletResponse response) {

        RequestContext context = new RequestContext(request);



        KickstartData ks = KickstartFactory.lookupKickstartDataByIdAndOrg(
                context.getCurrentUser().getOrg(), context.getRequiredParam("ksid"));

        request.setAttribute(RequestContext.KICKSTART, ks);
        ListHelper helper = new ListHelper(this, request);
        helper.execute();

        if (context.wasDispatched("kickstart.packageprofile.jsp.submit")) {
            String selected = ListTagHelper.getRadioSelection(helper.getListName(),
                                        request);
            if (StringUtils.isNumeric(selected)) {
                Profile prof = ProfileManager.lookupByIdAndOrg(new Long(selected),
                                context.getCurrentUser().getOrg());
                ks.getKickstartDefaults().setProfile(prof);

                Map params = new HashMap();
                params.put("ksid", ks.getId());
                getStrutsDelegate().saveMessage(UPDATE_METHOD, request);
                return getStrutsDelegate().forwardParams(mapping.findForward("success"),
                    params);
            }
        }
        else if (context.wasDispatched("kickstart.packageprofile.jsp.clear")) {
            ks.getKickstartDefaults().setProfile(null);
            KickstartFactory.saveKickstartData(ks);
            request.setAttribute("ksid", ks.getId());
                Map params = new HashMap();
                params.put("ksid", ks.getId());
                getStrutsDelegate().saveMessage(CLEAR_METHOD, request);
                return getStrutsDelegate().forwardParams(mapping.findForward("success"),
                    params);

        }
        if (ks.getKickstartDefaults().getProfile() != null) {
            ListTagHelper.selectRadioValue(helper.getListName(),
                ks.getKickstartDefaults().getProfile().getId().toString(), request);
        }
        return mapping.findForward("default");
    }

    /**
     *
     * {@inheritDoc}
     */
    public List getResult(RequestContext rctx) {
        KickstartData ksdata = KickstartFactory
        .lookupKickstartDataByIdAndOrg(rctx.getCurrentUser().getOrg(),
                rctx.getRequiredParam(RequestContext.KICKSTART_ID));

        return ProfileManager.compatibleWithChannel(
            ksdata.getKickstartDefaults().getKstree().getChannel(),
            rctx.getCurrentUser().getOrg(), null);
    }

}
