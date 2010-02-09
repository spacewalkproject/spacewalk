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
package com.redhat.rhn.frontend.action.channel;

import com.redhat.rhn.common.db.datasource.DataResult;
import com.redhat.rhn.domain.channel.ChannelFamily;
import com.redhat.rhn.domain.channel.ChannelFamilyFactory;
import com.redhat.rhn.frontend.dto.ChannelOverview;
import com.redhat.rhn.frontend.listview.PageControl;
import com.redhat.rhn.frontend.struts.BaseListAction;
import com.redhat.rhn.frontend.struts.RequestContext;
import com.redhat.rhn.manager.channel.ChannelManager;

/**
 * ChannelEntitlementSetupAction
 * @version $Rev$
 */
public class ChannelEntitlementSetupAction extends BaseListAction {

    /**
     * {@inheritDoc}
     */
    protected DataResult getDataResult(RequestContext rctx, PageControl pc) {
        DataResult<ChannelOverview> list = ChannelManager.entitlements(
                rctx.getCurrentUser().getOrg().getId(), pc);
        
        /* hate doing this, as we should really change the view and queries to support this
         * This is for bz 435894   Opened bz 445260 to fix this properly.  Simply need to
         * change the rhnChannelFamilyOverview view to also return the channel family's 
         * orgid and then change the ChannelManagemer.entitlements() query to provide 
         * the org_id in the ChannelOverview dto.  If we do these two things, the code
         * below can be removed and simply return the list
         */
        for (ChannelOverview item : list) {
            ChannelFamily fam = ChannelFamilyFactory.lookupById(item.getId());
            if (fam.getOrg() != null) {
                item.setOrgId(fam.getOrg().getId());
            }
        }
        return list;
    }

}
