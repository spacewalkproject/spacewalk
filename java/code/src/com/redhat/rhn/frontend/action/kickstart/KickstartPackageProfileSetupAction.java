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

import com.redhat.rhn.common.db.datasource.DataResult;
import com.redhat.rhn.domain.kickstart.KickstartData;
import com.redhat.rhn.domain.kickstart.KickstartFactory;
import com.redhat.rhn.frontend.listview.PageControl;
import com.redhat.rhn.frontend.struts.RequestContext;
import com.redhat.rhn.manager.profile.ProfileManager;
import com.redhat.rhn.manager.rhnset.RhnSetDecl;

import java.util.Iterator;
import java.util.LinkedList;
import java.util.List;

/**
 * KickstartPackageProfilesEditAction - setup for listing the profiles available 
 * for selection.
 * @version $Rev: 1 $
 */
public class KickstartPackageProfileSetupAction extends BaseKickstartListSetupAction {

    /**
     * {@inheritDoc}
     */
    protected Iterator getCurrentItemsIterator(KickstartData ksdata) {
        List l = new LinkedList();
        if (ksdata.getKickstartDefaults().getProfile() != null) {
            l.add(ksdata.getKickstartDefaults().getProfile());
        }
        return l.iterator();
    }

    /**
     * {@inheritDoc}
     */
    public RhnSetDecl getSetDecl() {
        return RhnSetDecl.PACKAGE_PROFILES;
    }

    /**
     * {@inheritDoc}
     */
    protected DataResult getDataResult(RequestContext rctx, PageControl pc) {
        KickstartData ksdata = KickstartFactory
            .lookupKickstartDataByIdAndOrg(rctx.getCurrentUser().getOrg(),
                    rctx.getRequiredParam(RequestContext.KICKSTART_ID));

        return ProfileManager.compatibleWithChannel(
                ksdata.getKickstartDefaults().getKstree().getChannel(),
                rctx.getCurrentUser().getOrg(), pc);
    }
}
