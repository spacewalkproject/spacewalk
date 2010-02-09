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
package com.redhat.rhn.frontend.action.kickstart.tree;

import com.redhat.rhn.domain.kickstart.KickstartFactory;
import com.redhat.rhn.domain.kickstart.KickstartableTree;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.frontend.action.kickstart.KickstartVariableAction;
import com.redhat.rhn.frontend.struts.RequestContext;
import com.redhat.rhn.manager.kickstart.cobbler.CobblerXMLRPCHelper;

import org.cobbler.CobblerObject;
import org.cobbler.Distro;

/**
 * 
 * KickstartProfileVariableAction
 * @version $Rev$
 */
public class KickstartTreeVariableAction extends KickstartVariableAction {

    @Override
    protected CobblerObject getCobblerObject(String cobblerId, User user) {
        CobblerXMLRPCHelper helper = new CobblerXMLRPCHelper();
        return Distro.lookupById(helper.getConnection(user), cobblerId);
    }

    @Override
    protected String getCobblerId(RequestContext context) {
        Long kstid = context.getRequiredParam(RequestContext.KSTREE_ID);
        KickstartableTree tree = KickstartFactory.lookupKickstartTreeByIdAndOrg(
                kstid, context.getLoggedInUser().getOrg());
        if (tree == null) {
            return null;
        }
        return tree.getCobblerId();
    }

    @Override
    protected String getObjectString() {
        return RequestContext.KSTREE_ID;
    }

}
