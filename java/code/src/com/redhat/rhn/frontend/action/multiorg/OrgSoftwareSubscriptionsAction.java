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
package com.redhat.rhn.frontend.action.multiorg;

import com.redhat.rhn.common.validator.ValidatorError;
import com.redhat.rhn.common.validator.ValidatorException;
import com.redhat.rhn.domain.channel.ChannelFamily;
import com.redhat.rhn.domain.channel.ChannelFamilyFactory;
import com.redhat.rhn.domain.org.Org;
import com.redhat.rhn.domain.org.OrgFactory;
import com.redhat.rhn.frontend.dto.ChannelOverview;
import com.redhat.rhn.frontend.dto.OrgChannelFamily;
import com.redhat.rhn.frontend.struts.RequestContext;
import com.redhat.rhn.frontend.struts.RhnAction;
import com.redhat.rhn.frontend.struts.RhnValidationHelper;
import com.redhat.rhn.frontend.taglibs.list.helper.ListHelper;
import com.redhat.rhn.frontend.taglibs.list.helper.Listable;
import com.redhat.rhn.manager.channel.ChannelManager;
import com.redhat.rhn.manager.org.UpdateOrgSoftwareEntitlementsCommand;

import org.apache.commons.lang.StringUtils;
import org.apache.log4j.Logger;
import org.apache.struts.action.ActionErrors;
import org.apache.struts.action.ActionForm;
import org.apache.struts.action.ActionForward;
import org.apache.struts.action.ActionMapping;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;


/**
 * OrgSoftwareSubscriptionsAction - updates the Channel subs for a single org
 * @version $Rev: 1 $
 */
public class OrgSoftwareSubscriptionsAction extends RhnAction implements Listable {
    private static final String SUBSCRIPTIONS = "subscriptions";
    private static Logger log = Logger.getLogger(OrgSoftwareSubscriptionsAction.class);

    private static String makeLabel(HttpServletRequest request) {
        RequestContext ctx = new RequestContext(request);
        Long oid = ctx.getParamAsLong(RequestContext.ORG_ID);
        return "OrgSoftwareSubscriptions" + oid;
    }

    /** {@inheritDoc} */
    public ActionForward execute(ActionMapping mapping,
                                  ActionForm formIn,
                                  HttpServletRequest request,
                                  HttpServletResponse response) {

        RequestContext ctx = new RequestContext(request);
        Long oid = ctx.getParamAsLong(RequestContext.ORG_ID);
        Org org = OrgFactory.lookupById(oid);
        request.setAttribute("org", org);

        Map params = new HashMap();
        params.put(RequestContext.ORG_ID, oid);
        ListHelper helper = new ListHelper(this, request, params);
        helper.execute();

        if (!ctx.isSubmitted()) {
            Map<String, String> subsMap = new HashMap<String, String>();
            List <OrgChannelFamily> subs = helper.getDataSet();
            for (OrgChannelFamily sub : subs) {
                if (sub.getMaxAvailable() > 0) {
                    subsMap.put(sub.getKey(), sub.getMaxMembers().toString());
                }
                if (sub.getMaxAvailableFlex() > 0) {
                    subsMap.put(sub.getFlexKey(), sub.getMaxFlex().toString());
                }
            }
            request.getSession().setAttribute(makeLabel(request), subsMap);
        }
        else {
            Map <String, String> subsMap = (Map <String, String>)
                                    request.getSession().getAttribute(makeLabel(request));
            for (String id : subsMap.keySet()) {
                if (request.getParameter(id) != null) {
                    subsMap.put(id, request.getParameter(id));
                }
            }
        }
        request.setAttribute(SUBSCRIPTIONS,
                    request.getSession().getAttribute(makeLabel(request)));

        ActionForward retval =
            mapping.findForward("default");

        if (ctx.wasDispatched("orgdetails.jsp.submit")) {
            ActionErrors ae =  updateSubscriptions(org, request);
            if (ae != null && ae.size() > 0) {
                getStrutsDelegate().saveMessages(request, ae);
                retval = getStrutsDelegate().forwardParam(mapping.findForward("error"),
                        "oid", oid.toString());

            }
            else {
                createSuccessMessage(request, "org.entitlements.syssoft.success", null);
                retval = getStrutsDelegate().forwardParam(mapping.findForward("success"),
                        "oid", oid.toString());
                request.getSession().removeAttribute(makeLabel(request));
            }
        }
        return retval;
    }



    private ActionErrors updateSubscriptions(Org org, HttpServletRequest request) {
        if (org.getId().equals(OrgFactory.getSatelliteOrg().getId())) {
            return RhnValidationHelper.validatorErrorToActionErrors(
                    new ValidatorError("org.entitlements.system.defaultorg"));
        }

        ActionErrors errors = new ActionErrors();

        Map <String, String> subsMap = (Map <String, String>)
                                request.getAttribute(SUBSCRIPTIONS);

        List <ChannelOverview> entitlements = ChannelManager.entitlements(
                OrgFactory.getSatelliteOrg().getId(), null);

        for (ChannelOverview co : entitlements) {
            ChannelFamily cfm = ChannelFamilyFactory.lookupById(co.getId().longValue());

            String regCountKey = OrgChannelFamily.makeKey(co.getId());
            try {
                Long regCount = subsMap.containsKey(regCountKey) ?
                        processCount(subsMap.get(regCountKey), errors, cfm) : 0;
                if (regCount != null) {
                    String flexCountKey = OrgChannelFamily.makeFlexKey(co.getId());
                    Long flex = subsMap.containsKey(flexCountKey) ?
                            processCount(subsMap.get(flexCountKey), errors, cfm) : 0;

                    if (flex != null && regCount != null) {
                        UpdateOrgSoftwareEntitlementsCommand cmd =
                            new UpdateOrgSoftwareEntitlementsCommand(cfm.getLabel(), org,
                                    regCount, flex);
                        ValidatorError ve = cmd.store();
                        if (ve != null) {
                            errors.add(
                                    RhnValidationHelper.validatorErrorToActionErrors(ve));
                        }
                    }
                }
            }
            catch (ValidatorException ve) {
                errors.add(RhnValidationHelper.validatorErrorToActionErrors(
                                           ve.getResult().getErrors().get(0)));
            }
        }
        return errors;
    }


    private Long processCount(String count, ActionErrors errors, ChannelFamily cfm) {
        if (!StringUtils.isBlank(count)) {
            // check for invalid number format
            try {
                return Long.parseLong(count.trim());
            }
            catch (NumberFormatException ex) {
                ValidatorException.raiseException("orgsoftwaresubs.invalid", cfm.getName());
            }
        }

        return null;
    }

    /**
     * {@inheritDoc}
     */
    public List getResult(RequestContext contextIn) {
        Org org = (Org)contextIn.getRequest().getAttribute("org");
        List<OrgChannelFamily> subs =  ChannelManager.
                listChannelFamilySubscriptionsFor(org);
        return subs;
    }


}
