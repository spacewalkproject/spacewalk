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

import com.redhat.rhn.domain.rhnset.RhnSet;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.manager.rhnset.RhnSetDecl;

import javax.servlet.http.HttpServletRequest;

/**
 *
 * SdcHelper
 * @version $Rev$
 */
public class SdcHelper {


    public static final String INSSM = "inSSM";

    private SdcHelper() {

    }


    /**
     * Checks to see if a system is in the SSM set, and sets a request attribute
     * accordingly
     * @param request the request to set the attribute on
     * @param sid the systemid of the system
     * @param user the user doing the request
     */
    public static void ssmCheck(HttpServletRequest request, Long sid, User user) {
        RhnSet set = RhnSetDecl.SYSTEMS.get(user);
        request.setAttribute(SdcHelper.INSSM, set.contains(sid));
    }
}
