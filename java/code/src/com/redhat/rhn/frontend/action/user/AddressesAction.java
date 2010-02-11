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
package com.redhat.rhn.frontend.action.user;

import com.redhat.rhn.domain.user.Address;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.domain.user.legacy.LegacyRhnUserImpl;
import com.redhat.rhn.frontend.action.common.BadParameterException;
import com.redhat.rhn.frontend.struts.RequestContext;
import com.redhat.rhn.frontend.struts.RhnAction;
import com.redhat.rhn.frontend.struts.RhnHelper;
import com.redhat.rhn.manager.user.UserManager;

import org.apache.struts.action.ActionForm;
import org.apache.struts.action.ActionForward;
import org.apache.struts.action.ActionMapping;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

/**
 * AddressesAction Setup the Addresses on the Request so
 * the AddressTag will be able to render
 * @version $Rev: 1226 $
 */
public class AddressesAction extends RhnAction {

    /** {@inheritDoc} */
    public ActionForward execute(ActionMapping mapping,
                                 ActionForm formIn,
                                 HttpServletRequest request,
                                 HttpServletResponse response) {
        
        RequestContext requestContext = new RequestContext(request);
        
        Long uid = requestContext.getParamAsLong("uid");
        //Addresses under /rhn/users needs parameter, but /rhn/account does not
        if (request.getRequestURL().toString().indexOf("/rhn/users/") != -1 &&
                uid == null) {
            throw new BadParameterException("uid is null for /rhn/users/");
        }

        User user = UserManager.lookupUser(requestContext.getLoggedInUser(), uid);
        request.setAttribute(RhnHelper.TARGET_USER, user);
        if (user == null) {
            user = requestContext.getLoggedInUser();
        }

        // Set the User on the Request
        request.setAttribute(RhnHelper.TARGET_USER, user);

        LegacyRhnUserImpl lUser = (LegacyRhnUserImpl) user;
    
        
        // Set the Addresses on the Request
        Address marketing = lUser.getAddress();

        request.setAttribute(RhnHelper.TARGET_ADDRESS_MARKETING, marketing);
        return mapping.findForward("default");
    }

}
