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

package com.redhat.rhn.frontend.action.channel;

import com.redhat.rhn.common.db.datasource.DataResult;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.frontend.action.systems.BaseSystemsAction;
import com.redhat.rhn.frontend.dto.ChannelOverview;
import com.redhat.rhn.frontend.dto.SystemOverview;
import com.redhat.rhn.frontend.listview.PageControl;
import com.redhat.rhn.frontend.struts.RequestContext;
import com.redhat.rhn.manager.channel.ChannelManager;
import com.redhat.rhn.manager.system.SystemManager;

import org.apache.struts.action.ActionForm;
import org.apache.struts.action.ActionForward;
import org.apache.struts.action.ActionMapping;

import java.util.Arrays;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

/**
 * EntitledSystemsSetupAction
 * @version $Rev$
 */
public class EntitledSystemsSetupAction extends BaseSystemsAction {

    private static final String LIST_NAME = "entitledSystemsList";
    public static final String DATA_SET = "entitlements";

    private String entitlementType;
    private Long cfid;
    public static final String FLEX_ENTITLEMENT = "flex";
    public static final String REGULAR_ENTITLEMENT = "regular";
    public static final String ALL_ENTITLEMENTS = "all";
    public static final String[] ALLOWED_VALUES = new String[]
        {FLEX_ENTITLEMENT, REGULAR_ENTITLEMENT, ALL_ENTITLEMENTS};

    /**
     * {@inheritDoc}
     */
    public ActionForward execute(ActionMapping mapping, ActionForm formIn,
            HttpServletRequest request, HttpServletResponse response) {
        RequestContext requestContext = new RequestContext(request);
        entitlementType = requestContext.getRequiredParamAsString("type");

        if (Arrays.binarySearch(ALLOWED_VALUES, entitlementType) < 0) {
            entitlementType = ALL_ENTITLEMENTS;
        }

        User user = requestContext.getCurrentUser();
        cfid = requestContext.getRequiredParam("cfam_id");
        ChannelOverview co = ChannelManager.getEntitlement(user.getOrg().getId(), cfid);

        request.setAttribute("entitlementType", entitlementType);
        request.setAttribute("familyName", co.getName());

        return super.execute(mapping, formIn, request, response);
    }

    /**
     * {@inheritDoc}
     */
    protected DataResult<SystemOverview> getDataResult(User user, PageControl pc,
        ActionForm formIn) {
        return SystemManager.getEntitledSystems(cfid, user, entitlementType, pc);
    }
}
